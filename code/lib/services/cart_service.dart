import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartService extends ChangeNotifier { 
  Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Product product) {
    _cart.addItem(product);
    notifyListeners();   
  }

  void removeFromCart(String productId) {
    _cart.removeItem(productId);
    notifyListeners();   
  }

  void updateQuantity(String productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    notifyListeners();   
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();   
  }
}