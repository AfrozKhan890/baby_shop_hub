import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';
import 'product_model.dart';
import 'address_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final Address shippingAddress;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.index,
      'shippingAddress': shippingAddress.toMap(),
      'paymentMethod': paymentMethod,
    };
  }

  // Create from Firestore Document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Timestamp? orderTimestamp = data['orderDate'];
    DateTime orderDate = orderTimestamp?.toDate() ?? DateTime.now();

    // Convert items list
    List<CartItem> items = [];
    List<dynamic> itemsData = data['items'] ?? [];
    for (var itemData in itemsData) {
      try {
        // Create product from item data
        Map<String, dynamic> productData = itemData['product'] ?? {};
        
        // Handle both old and new product structure
        List<String> images = [];
        if (productData['images'] != null) {
          images = List<String>.from(productData['images']);
        } else if (productData['imageUrl'] != null) {
          images = [productData['imageUrl'] as String];
        }
        
        List<ProductVariant> variants = [];
        if (productData['variants'] != null) {
          variants = (productData['variants'] as List)
              .map((v) => ProductVariant.fromMap(v))
              .toList();
        } else {
          // Create default variant from legacy data
          variants.add(ProductVariant(
            id: 'default',
            size: 'One Size',
            color: 'Default',
            price: (productData['price'] ?? 0.0).toDouble(),
            stock: (productData['stock'] ?? 0).toInt(),
          ));
        }
        
        Product product = Product(
          id: productData['id'] ?? '',
          name: productData['name'] ?? '',
          description: productData['description'] ?? '',
          images: images,
          category: productData['category'] ?? '',
          brand: productData['brand'] ?? '',
          variants: variants,
          basePrice: (productData['basePrice'] ?? productData['price'] ?? 0.0).toDouble(),
          createdAt: (productData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          rating: (productData['rating'] ?? 0.0).toDouble(),
          reviewCount: (productData['reviewCount'] ?? 0).toInt(),
          isFeatured: productData['isFeatured'] ?? false,
        );
        
        items.add(CartItem(
          product: product,
          quantity: itemData['quantity'] ?? 1,
        ));
      } catch (e) {
        print('Error parsing cart item: $e');
      }
    }

    return Order(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      orderDate: orderDate,
      status: OrderStatus.values[data['status'] ?? 0],
      shippingAddress: Address.fromMap(data['shippingAddress'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? '',
    );
  }
}