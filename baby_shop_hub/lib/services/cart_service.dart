import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Product product) {
    _cart.addItem(product);
    _notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeItem(productId);
    _notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    _notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cart.items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(String productId) {
    final item = _cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '', 
        product: Product(
          id: '', 
          name: '', 
          description: '', 
          price: 0, 
          imageUrl: '', 
          category: '', 
          brand: '',
          createdAt: DateTime.now(), // YEH ADD KAREN
        ), 
        quantity: 0
      ),
    );
    return item.quantity;
  }

  // Listeners for state management
  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}