import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.addresses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addresses': addresses.map((address) => address.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      addresses: (data['addresses'] as List? ?? [])
          .map((address) => Address.fromMap(address))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }
}

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      name: map['name'],
      street: map['street'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}