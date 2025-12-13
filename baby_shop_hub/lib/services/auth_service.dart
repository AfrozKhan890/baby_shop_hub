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

  // ✅ Test Firebase connection
  Future<bool> testSignup() async {
    try {
      print('🔄 Testing Firebase connection...');
      
      final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
      final testPassword = 'Test@1234';
      
      print('📝 Test Email: $testEmail');
      print('📝 Test Password: $testPassword');
      
      // Test Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      print('✅ Auth test PASSED: ${userCredential.user!.uid}');
      
      // Test Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': testEmail,
            'createdAt': DateTime.now(),
            'role': 'user'
          });
      
      print('✅ Firestore test PASSED');
      
      // Test login
      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword
      );
      print('✅ Login test PASSED');
      
      // Test user ko delete kardo
      await userCredential.user!.delete();
      print('✅ Test user deleted');
      
      return true;
    } catch (e) {
      print('❌ Test FAILED: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    try {
      print('📝 ===== SIGNUP STARTED =====');
      print('📝 Name: $name');
      print('📝 Email: $email');
      print('📝 Phone: $phone');
      print('📝 Password Length: ${password.length}');

      // 1. VALIDATION
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
        print('❌ Password validation failed for: $password');
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

      print('✅ All validations passed');

      // 2. CHECK IF EMAIL EXISTS
      print('📝 Checking if email exists...');
      try {
        final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isNotEmpty) {
          print('❌ Email already exists');
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email is already registered'
          );
        }
      } catch (e) {
        print('📝 Email check: $e');
      }

      // 3. CREATE USER IN FIREBASE AUTH
      print('📝 Creating user in Firebase Auth...');
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final userId = userCredential.user!.uid;
      print('✅ Firebase Auth user created: $userId');
      
      // 4. CREATE USER OBJECT
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

      // 5. SAVE TO FIRESTORE
      print('📝 Saving to Firestore...');
      try {
        final userMap = newUser.toMap();
        print('📝 User data to save: $userMap');
        
        await _firestore
            .collection('users')
            .doc(userId)
            .set(userMap);
        
        print('✅ User saved to Firestore');
      } catch (e) {
        print('❌ Firestore save error: $e');
        // Rollback: Delete Firebase Auth user
        await userCredential.user!.delete();
        throw FirebaseAuthException(
          code: 'firestore-error',
          message: 'Failed to save user data: $e'
        );
      }

      // 6. UPDATE LOCAL STATE
      _currentUser = newUser;
      _isLoggedIn = true;
      notifyListeners();

      // 7. IMMEDIATELY LOGIN AFTER SIGNUP (to verify credentials)
      print('📝 Verifying login after signup...');
      await _auth.signOut(); // First signout
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      print('✅ Login verification successful');

      // 8. SEND VERIFICATION EMAIL
      try {
        await userCredential.user!.sendEmailVerification();
        print('✅ Email verification sent');
      } catch (verificationError) {
        print('⚠️ Email verification failed: $verificationError');
      }

      print('✅ ===== SIGNUP COMPLETED =====');
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException in signup: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ General error in signup: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('🔐 ===== LOGIN ATTEMPT =====');
      print('🔐 Email: $email');
      
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

      // Clean and format email
      final cleanEmail = email.trim().toLowerCase();
      print('🔐 Clean Email: $cleanEmail');
      print('🔐 Password Length: ${password.length}');

      // Sign in with Firebase Auth
      print('🔐 Attempting Firebase Auth signin...');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      print('✅ Firebase Auth successful: ${userCredential.user!.uid}');

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('❌ User exists in Auth but not in Firestore');
        
        // Create user in Firestore if missing
        print('🔄 Creating missing user in Firestore...');
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
        
        print('✅ Missing user created in Firestore');
        _currentUser = missingUser;
      } else {
        print('✅ User found in Firestore');
        _currentUser = AppUser.fromFirestore(userDoc);
      }

      _isLoggedIn = true;
      notifyListeners();

      // Update last login
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
            'lastLogin': DateTime.now(),
            'updatedAt': DateTime.now(),
          });

      print('✅ ===== LOGIN SUCCESSFUL =====');
      print('✅ User: ${_currentUser!.name}');
      print('✅ Role: ${_currentUser!.role}');
      
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ LOGIN FAILED: ${e.code} - ${e.message}');
      
      // Additional debug info
      if (e.code == 'invalid-credential') {
        print('⚠️ Possible causes:');
        print('⚠️ 1. Wrong password');
        print('⚠️ 2. User deleted from Firebase Auth');
        print('⚠️ 3. Password changed');
        print('⚠️ 4. Network issues');
      }
      
      rethrow;
    } catch (e, stackTrace) {
      print('❌ General error in login: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
      print('🚪 User logged out');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  Future<bool> isAdmin() async {
    if (_currentUser == null) return false;
    return _currentUser!.role == 'admin';
  }

  // ✅ New method: Check if user is logged in on app start
 Future<void> checkCurrentUser() async {
  try {
    print('🔄 Checking current user status...');
    final currentAuthUser = _auth.currentUser;
    
    if (currentAuthUser != null) {
      print('✅ Firebase Auth user found: ${currentAuthUser.uid}');
      print('📧 User email: ${currentAuthUser.email}');
      print('🔐 Email verified: ${currentAuthUser.emailVerified}');
      
      try {
        // Try to get user from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(currentAuthUser.uid)
            .get();
        
        if (userDoc.exists) {
          print('✅ User found in Firestore');
          _currentUser = AppUser.fromFirestore(userDoc);
          _isLoggedIn = true;
          notifyListeners();
          
          print('👤 Logged in as: ${_currentUser!.name}');
          print('🎭 Role: ${_currentUser!.role}');
          print('📞 Phone: ${_currentUser!.phone}');
        } else {
          print('⚠️ User exists in Auth but not in Firestore');
          print('🔄 Creating user in Firestore...');
          
          // Create user in Firestore
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
          
          print('✅ User created in Firestore');
        }
      } catch (firestoreError) {
        print('❌ Firestore error: $firestoreError');
        // At least set auth state
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
      print('ℹ️ No user logged in');
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  } catch (e) {
    print('❌ Error checking current user: $e');
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
}