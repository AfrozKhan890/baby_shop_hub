// models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
    this.role = 'user',
    this.isEmailVerified = false,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'role': role,
      'isEmailVerified': isEmailVerified,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp to DateTime
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    DateTime? lastLogin;
    
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }
    
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    }
    
    if (data['lastLogin'] != null && data['lastLogin'] is Timestamp) {
      lastLogin = (data['lastLogin'] as Timestamp).toDate();
    }
    
    List<Address> addresses = [];
    if (data['addresses'] != null && data['addresses'] is List) {
      addresses = (data['addresses'] as List)
          .map((addr) => Address.fromMap(addr))
          .toList();
    }

    return AppUser(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      addresses: addresses,
      createdAt: createdAt,
      updatedAt: updatedAt,
      role: data['role'] ?? 'user',
      isEmailVerified: data['isEmailVerified'] ?? false,
      lastLogin: lastLogin,
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    bool? isEmailVerified,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  bool get isAdmin => role == 'admin';
}