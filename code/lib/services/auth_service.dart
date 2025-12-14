import '../models/address_model.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AppUser? _currentUser;
  bool _isLoggedIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@%*])[A-Za-z\d@%*]{8,}$'
  );

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );

  final RegExp _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final RegExp _phoneRegex = RegExp(r'^[0-9+]{10,15}$');

  Future<bool> signup(String name, String email, String password, String phone) async {
    try {
      if (!_nameRegex.hasMatch(name)) {
        throw FirebaseAuthException(
          code: 'invalid-name',
          message: 'Name can only contain letters and spaces'
        );
      }

      if (!_emailRegex.hasMatch(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please enter a valid email address'
        );
      }

      if (!_passwordRegex.hasMatch(password)) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must contain: 8+ characters, 1 uppercase, 1 lowercase, 1 number, 1 special character (@, %, *)'
        );
      }

      String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (!_phoneRegex.hasMatch(cleanedPhone)) {
        throw FirebaseAuthException(
          code: 'invalid-phone',
          message: 'Please enter a valid phone number (10-15 digits)'
        );
      }

      try {
        final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isNotEmpty) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email is already registered'
          );
        }
      } catch (e) {}

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final userId = userCredential.user!.uid;
      
      final newUser = AppUser(
        id: userId,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: cleanedPhone,
        addresses: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: 'user',
        isEmailVerified: false,
        lastLogin: DateTime.now(),
      );

      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .set(newUser.toMap());
      } catch (e) {
        await userCredential.user!.delete();
        throw FirebaseAuthException(
          code: 'firestore-error',
          message: 'Failed to save user data'
        );
      }

      _currentUser = newUser;
      _isLoggedIn = true;
      notifyListeners();

      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      try {
        await userCredential.user!.sendEmailVerification();
      } catch (verificationError) {}

      return true;
      
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'empty-fields',
          message: 'Please enter email and password'
        );
      }

      if (!_emailRegex.hasMatch(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please enter a valid email address'
        );
      }

      final cleanEmail = email.trim().toLowerCase();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        final missingUser = AppUser(
          id: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? cleanEmail,
          phone: '',
          addresses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          role: 'user',
          isEmailVerified: userCredential.user!.emailVerified,
          lastLogin: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(missingUser.toMap());
        
        _currentUser = missingUser;
      } else {
        _currentUser = AppUser.fromFirestore(userDoc);
      }

      _isLoggedIn = true;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
            'lastLogin': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });

      return true;
      
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAdmin() async {
    if (_currentUser == null) {
      return false;
    }
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .get();
          
      if (userDoc.exists) {
        final user = AppUser.fromFirestore(userDoc);
        return user.role == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool get isCurrentUserAdmin {
    return _currentUser?.role == 'admin';
  }

  Future<void> checkCurrentUser() async {
    try {
      final currentAuthUser = _auth.currentUser;
      
      if (currentAuthUser != null) {
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(currentAuthUser.uid)
              .get();
          
          if (userDoc.exists) {
            _currentUser = AppUser.fromFirestore(userDoc);
            _isLoggedIn = true;
            notifyListeners();
          } else {
            final newUser = AppUser(
              id: currentAuthUser.uid,
              name: currentAuthUser.displayName ?? 'User',
              email: currentAuthUser.email ?? '',
              phone: '',
              addresses: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              role: 'user',
              isEmailVerified: currentAuthUser.emailVerified,
              lastLogin: DateTime.now(),
            );
            
            await _firestore
                .collection('users')
                .doc(currentAuthUser.uid)
                .set(newUser.toMap());
            
            _currentUser = newUser;
            _isLoggedIn = true;
            notifyListeners();
          }
        } catch (firestoreError) {
          _currentUser = AppUser(
            id: currentAuthUser.uid,
            name: currentAuthUser.displayName ?? 'User',
            email: currentAuthUser.email ?? '',
            phone: '',
            addresses: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            role: 'user',
            isEmailVerified: currentAuthUser.emailVerified,
            lastLogin: DateTime.now(),
          );
          _isLoggedIn = true;
          notifyListeners();
        }
      } else {
        _currentUser = null;
        _isLoggedIn = false;
        notifyListeners();
      }
    } catch (e) {
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    try {
      if (email == 'admin@example.com' && password == 'admin123') {
        final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
        
        if (signInMethods.isEmpty) {
          final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await userCredential.user!.sendEmailVerification();
        }
        
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final adminUser = AppUser(
          id: userCredential.user!.uid,
          name: 'Admin User',
          email: email,
          phone: '03001234567',
          addresses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          role: 'admin',
          isEmailVerified: true,
          lastLogin: DateTime.now(),
        );
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(adminUser.toMap(), SetOptions(merge: true));
        
        _currentUser = adminUser;
        _isLoggedIn = true;
        notifyListeners();
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}