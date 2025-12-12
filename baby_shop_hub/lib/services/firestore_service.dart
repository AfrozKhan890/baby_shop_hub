import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart' as app_order;

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static CollectionReference get productsCollection =>
      _firestore.collection('products');
      
  static CollectionReference get usersCollection =>
      _firestore.collection('users');
      
  static CollectionReference get ordersCollection =>
      _firestore.collection('orders');

  // ========== PRODUCT CRUD OPERATIONS ==========

  static Future<String> addProduct(Product product) async {
    try {
      final docRef = await productsCollection.add(product.toMap());
      
      await productsCollection.doc(docRef.id).update({
        'id': docRef.id,
      });
      
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  static Future<void> updateProduct(String productId, Product product) async {
    try {
      await productsCollection.doc(productId).update(product.toMap());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  static Future<Product?> getProduct(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  static Stream<List<Product>> getProductsStream() {
    return productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  static Stream<List<Product>> getProductsByCategory(String category) {
    return productsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  static Stream<List<Product>> getFeaturedProducts() {
    return productsCollection
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // ========== USER OPERATIONS ==========

  static Future<void> setUser(AppUser user) async {
    try {
      await usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error setting user: $e');
      rethrow;
    }
  }

  static Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await getUser(user.uid);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // ========== ORDER OPERATIONS ==========

  static Future<String> addOrder(app_order.Order order) async {
    try {
      final docRef = await ordersCollection.add(order.toMap());
      
      await ordersCollection.doc(docRef.id).update({
        'id': docRef.id,
      });
      
      return docRef.id;
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }

  static Stream<List<app_order.Order>> getUserOrders(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => app_order.Order.fromFirestore(doc)).toList();
    });
  }

  static Stream<List<app_order.Order>> getAllOrders() {
    return ordersCollection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => app_order.Order.fromFirestore(doc)).toList();
    });
  }
}