import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:convert';

class ProductVariant {
  final String id;
  final String size;
  final String color;
  final double price;
  final int stock;
  final String? sku;

  ProductVariant({
    required this.id,
    required this.size,
    required this.color,
    required this.price,
    required this.stock,
    this.sku,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'size': size,
      'color': color,
      'price': price,
      'stock': stock,
      'sku': sku,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] ?? '',
      size: map['size'] ?? '',
      color: map['color'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      sku: map['sku'],
    );
  }

  ProductVariant copyWith({
    String? id,
    String? size,
    String? color,
    double? price,
    int? stock,
    String? sku,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      size: size ?? this.size,
      color: color ?? this.color,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String category;
  final String brand;
  final List<ProductVariant> variants;
  final double basePrice;
  final DateTime createdAt;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final Map<String, dynamic> specifications;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.brand,
    required this.variants,
    required this.basePrice,
    required this.createdAt,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    this.specifications = const {},
  });

  double get minPrice {
    if (variants.isEmpty) return basePrice;
    return variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxPrice {
    if (variants.isEmpty) return basePrice;
    return variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  int get totalStock {
    return variants.fold(0, (sum, variant) => sum + variant.stock);
  }

  List<String> get availableSizes {
    return variants.map((v) => v.size).toSet().toList();
  }

  List<String> get availableColors {
    return variants.map((v) => v.color).toSet().toList();
  }

  // For backward compatibility
  double get price => minPrice;
  int get stock => totalStock;
  String get imageUrl => images.isNotEmpty ? images.first : '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'category': category,
      'brand': brand,
      'variants': variants.map((v) => v.toMap()).toList(),
      'basePrice': basePrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'specifications': specifications,
    };
  }

  // For backward compatibility
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': minPrice,
      'imageUrl': images.isNotEmpty ? images.first : '',
      'category': category,
      'stock': totalStock,
      'createdAt': Timestamp.fromDate(createdAt),
      'rating': rating,
      'reviewCount': reviewCount,
      'brand': brand,
      'isFeatured': isFeatured,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Timestamp? timestamp = data['createdAt'];
    DateTime createdAt = timestamp?.toDate() ?? DateTime.now();

    List<ProductVariant> variants = [];
    if (data['variants'] != null) {
      variants = (data['variants'] as List)
          .map((v) => ProductVariant.fromMap(v))
          .toList();
    }

    List<String> images = [];
    if (data['images'] != null) {
      images = List<String>.from(data['images']);
    } else if (data['imageUrl'] != null) {
      images = [data['imageUrl'] as String];
    }

    return Product(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      images: images,
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      variants: variants,
      basePrice: (data['basePrice'] ?? data['price'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      isFeatured: data['isFeatured'] ?? false,
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
    );
  }

  // Legacy constructor for backward compatibility
  factory Product.fromLegacyMap({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    required int stock,
    required DateTime createdAt,
    required double rating,
    required int reviewCount,
    required String brand,
    required bool isFeatured,
  }) {
    return Product(
      id: id,
      name: name,
      description: description,
      images: [imageUrl],
      category: category,
      brand: brand,
      variants: [
        ProductVariant(
          id: 'default',
          size: 'One Size',
          color: 'Default',
          price: price,
          stock: stock,
        )
      ],
      basePrice: price,
      createdAt: createdAt,
      rating: rating,
      reviewCount: reviewCount,
      isFeatured: isFeatured,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    String? category,
    String? brand,
    List<ProductVariant>? variants,
    double? basePrice,
    DateTime? createdAt,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      variants: variants ?? this.variants,
      basePrice: basePrice ?? this.basePrice,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      specifications: specifications ?? this.specifications,
    );
  }

  // Method to decode base64 image
  Uint8List? getFirstImageAsBytes() {
    if (images.isEmpty) return null;
    
    final String image = images.first;
    if (image.startsWith('data:image')) {
      try {
        final String data = image.split(',').last;
        return base64.decode(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if image is base64
  bool get hasBase64Image {
    if (images.isEmpty) return false;
    return images.first.startsWith('data:image');
  }
}