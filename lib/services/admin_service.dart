import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('products')
          .add(product.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    });
  }
}