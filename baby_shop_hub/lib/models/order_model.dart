import 'package:flutter/material.dart';
import 'cart_model.dart'; 
import 'user_model.dart';

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
}

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
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
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}