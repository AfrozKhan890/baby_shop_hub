// models/address_model.dart

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode; // Changed from 'pincode' to 'zipCode'
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isDefault,
  });

  // No 'type', 'phone', 'pincode' getters - using these instead:
  String get fullAddress => '$street, $city, $state $zipCode';
  
  // You can add type as needed
  String get type => name; // Using name as type, or add type field

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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}