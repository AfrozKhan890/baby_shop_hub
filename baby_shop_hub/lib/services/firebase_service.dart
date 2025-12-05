import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  bool _initialized = false;

  // Initialize Firebase
  Future<void> initialize() async {
    try {
      print('🔄 Initializing Firebase...');
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _initialized = true;
      print('✅ Firebase initialized successfully');
      print('📊 Firestore instance: $_firestore');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      _initialized = false;
    }
  }

  // Check if Firebase is initialized
  bool get isInitialized => _initialized;

  // Test connection to Firestore
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing Firestore connection...');
      final snapshot = await _firestore.collection('products').limit(1).get();
      print('✅ Firestore connected, found ${snapshot.docs.length} products');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }

  // ============ PRODUCTS ============

  // Get all products with debug
  Stream<List<Product>> getProducts() {
    print('🔄 Getting products from Firestore...');
    
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .handleError((error) {
          print('❌ Firestore error: $error');
          return Stream.value([]);
        })
        .map((snapshot) {
          print('📦 Received ${snapshot.docs.length} products');
          return snapshot.docs
              .map((doc) {
                try {
                  return Product.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing product ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .toList();
        });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    if (category == 'All') {
      return getProducts();
    }
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Get featured products
  Stream<List<Product>> getFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()) ||
                product.brand.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // ============ USERS ============

  // Get user data
  Stream<AppUser?> getUserData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => 
            snapshot.exists ? AppUser.fromFirestore(snapshot) : null);
  }

  // Create or update user
  Future<void> saveUserData(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore());
  }

  // ============ AUTH ============

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email sign in
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email sign up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}