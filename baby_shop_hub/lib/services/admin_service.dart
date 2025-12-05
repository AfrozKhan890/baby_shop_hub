import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/admin_model.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && (userDoc.data()?['isAdmin'] ?? false);
  }

  // Get admin statistics
  Stream<AdminStats> getAdminStats() {
    return _firestore
        .collection('admin_stats')
        .doc('overview')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return AdminStats(
          totalProducts: 0,
          totalOrders: 0,
          totalUsers: 0,
          totalRevenue: 0,
          weeklyRevenue: [],
        );
      }
      
      final data = snapshot.data()!;
      return AdminStats(
        totalProducts: data['totalProducts'] ?? 0,
        totalOrders: data['totalOrders'] ?? 0,
        totalUsers: data['totalUsers'] ?? 0,
        totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
        weeklyRevenue: (data['weeklyRevenue'] as List? ?? [])
            .map((item) => DailyRevenue(
                  date: DateTime.fromMillisecondsSinceEpoch(item['date']),
                  revenue: (item['revenue'] ?? 0).toDouble(),
                  orders: item['orders'] ?? 0,
                ))
            .toList(),
      );
    });
  }

  // Get all products for admin
  Stream<List<Product>> getAllProductsForAdmin() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .update(updates);
  }

  // Delete product (soft delete)
  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .update({'isActive': false});
  }

  // Get recent orders
  Stream<List<RecentOrder>> getRecentOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return RecentOrder(
                id: doc.id,
                customerName: data['customerName'] ?? 'Unknown',
                amount: (data['totalAmount'] ?? 0).toDouble(),
                date: DateTime.fromMillisecondsSinceEpoch(data['orderDate'] ?? 0),
                status: data['status'] ?? 'pending',
              );
            })
            .toList());
  }

  // Get all users
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['name'] ?? '',
                'email': data['email'] ?? '',
                'phone': data['phone'] ?? '',
                'createdAt': DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
                'orderCount': data['orderCount'] ?? 0,
                'totalSpent': (data['totalSpent'] ?? 0).toDouble(),
              };
            })
            .toList());
  }
}