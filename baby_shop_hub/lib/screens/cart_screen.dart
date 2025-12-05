import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../utils/app_theme.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  late Cart _cart;

  @override
  void initState() {
    super.initState();
    _cart = _cartService.cart;
    _cartService.addListener(_onCartUpdated);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartUpdated);
    super.dispose();
  }

  void _onCartUpdated() {
    setState(() {
      _cart = _cartService.cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      // appBar: AppBar(
      //   title: Text('Shopping Cart'),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   elevation: 0,
      //   actions: [
      //     if (_cart.items.isNotEmpty)
      //       IconButton(
      //         icon: Icon(Icons.delete_outline),
      //         onPressed: _clearCart,
      //         tooltip: 'Clear Cart',
      //       ),
      //   ],
      // ),
      body: _cart.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartWithItems(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppTheme.customColors['textLight'],
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Add some baby products to get started!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.customColors['peach'],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _cart.items.length,
            itemBuilder: (context, index) {
              final item = _cart.items[index];
              return _buildCartItem(item);
            },
          ),
        ),

        // Checkout Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Order Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '\$${_cart.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Free',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_cart.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: AppTheme.customColors['babyBlue'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkout,
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.customColors['babyBlue'],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.product.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.product.category),
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppTheme.customColors['babyBlue'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: AppTheme.customColors['softCream'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18),
                    onPressed: () => _updateQuantity(item.product.id, item.quantity - 1),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36),
                  ),
                  Container(
                    width: 30,
                    alignment: Alignment.center,
                    child: Text(
                      item.quantity.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18),
                    onPressed: () => _updateQuantity(item.product.id, item.quantity + 1),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36),
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(item.product.id),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(productId);
    } else {
      _cartService.updateQuantity(productId, newQuantity);
    }
  }

  void _removeItem(String productId) {
    _cartService.removeFromCart(productId);
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart'),
        content: Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cartService.clearCart();
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    // TODO: Navigate to checkout screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout functionality coming soon!'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return AppTheme.customColors['babyBlue']!;
      case 'food':
        return AppTheme.customColors['peach']!;
      case 'diapers':
        return AppTheme.customColors['yellow']!;
      case 'toys':
        return Color(0xFFB6E6FF);
      case 'bath':
        return Color(0xFFFFE4E9);
      case 'carriers':
        return AppTheme.customColors['babyBlue']!;
      default:
        return AppTheme.customColors['babyBlue']!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return Icons.face;
      case 'food':
        return Icons.restaurant;
      case 'diapers':
        return Icons.child_care;
      case 'toys':
        return Icons.toys;
      case 'bath':
        return Icons.bathtub;
      case 'carriers':
        return Icons.backpack;
      default:
        return Icons.shopping_bag;
    }
  }
}