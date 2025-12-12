import 'product_model.dart';

class CartItem {
  final Product product;
  final ProductVariant? selectedVariant; // ADD THIS LINE
  int quantity;

  CartItem({
    required this.product,
    this.selectedVariant, // ADD THIS
    this.quantity = 1,
  });

  double get totalPrice {
    // Use variant price if available, otherwise use product minPrice
    final price = selectedVariant?.price ?? product.price;
    return price * quantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'selectedVariant': selectedVariant?.toMap(), // ADD THIS
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    ProductVariant? variant;
    if (map['selectedVariant'] != null) {
      variant = ProductVariant.fromMap(map['selectedVariant']);
    }
    
    return CartItem(
      product: product,
      selectedVariant: variant, // ADD THIS
      quantity: map['quantity'] ?? 1,
    );
  }
}

class Cart {
  List<CartItem> items = [];

  double get totalAmount {
    double total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  void addItem(Product product, {ProductVariant? selectedVariant}) {
    for (var item in items) {
      if (item.product.id == product.id) {
        // Check if variant is same
        if ((item.selectedVariant?.id ?? 'default') == (selectedVariant?.id ?? 'default')) {
          item.quantity++;
          return;
        }
      }
    }
    items.add(CartItem(product: product, selectedVariant: selectedVariant));
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    for (var item in items) {
      if (item.product.id == productId) {
        if (newQuantity <= 0) {
          items.removeWhere((item) => item.product.id == productId);
        } else {
          item.quantity = newQuantity;
        }
        return;
      }
    }
  }

  void clear() {
    items.clear();
  }

  List<Map<String, dynamic>> toMapList() {
    return items.map((item) => item.toMap()).toList();
  }
}