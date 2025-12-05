import 'product_model.dart'; 

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class Cart {
  List<CartItem> items = [];
  String? userId;

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(Product product) {
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      items[existingIndex].quantity++;
    } else {
      items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
      ));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
    }
  }

  void clear() {
    items.clear();
  }
}