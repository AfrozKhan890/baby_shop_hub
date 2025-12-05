import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String brand;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    required this.brand,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'brand': brand,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore Document - TYPO FIX: DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      inStock: data['inStock'] ?? true,
      brand: data['brand'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  // Old methods (for backward compatibility)
  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  // For dummy data - createdAt add karen
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      inStock: map['inStock'],
      brand: map['brand'],
      createdAt: DateTime.now(),
    );
  }
}