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

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
    this.role = 'user',
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
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    Timestamp? createdAt = data['createdAt'];
    Timestamp? updatedAt = data['updatedAt'];

    return AppUser(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      addresses: (data['addresses'] as List? ?? [])
          .map((addr) => Address.fromMap(addr))
          .toList(),
      createdAt: createdAt?.toDate() ?? DateTime.now(),
      updatedAt: updatedAt?.toDate() ?? DateTime.now(),
      role: data['role'] ?? 'user',
    );
  }

  bool get isAdmin => role == 'admin';
}