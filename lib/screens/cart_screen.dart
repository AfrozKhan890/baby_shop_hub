import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../utils/app_theme.dart';
import '../providers/cart_provider.dart';
import 'dart:typed_data';
import 'dart:convert';


class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;

    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.customColors['babyBlue'],
        elevation: 0,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => _clearCart(cartProvider),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartWithItems(cart, cartProvider),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some baby products to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
              ).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Go to Home tab to browse products'),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            },
            child: Text(
              'Start Shopping',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.customColors['peach'],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(Cart cart, CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(item, cartProvider);
            },
          ),
        ),
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontFamily: 'Poppins',
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.customColors['babyBlue'],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkout(cartProvider),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
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

 Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
  final displayPrice = item.selectedVariant?.price ?? item.product.price;
  
  return Card(
    margin: EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getCategoryColor(item.product.category),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: item.product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProductImage(item.product.images.first),
                    )
                  : Icon(
                      _getCategoryIcon(item.product.category),
                      color: Colors.white,
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                
                // Variant info if available
                if (item.selectedVariant != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.selectedVariant!.size} - ${item.selectedVariant!.color}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2),
                    ],
                  ),
                
                Text(
                  '\$${displayPrice.toStringAsFixed(2)}', // USE VARIANT PRICE
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.customColors['babyBlue'],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.customColors['softCream'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18),
                  onPressed: () => _updateQuantity(item.product.id, item.quantity - 1, cartProvider),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 36),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text(
                    item.quantity.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18),
                  onPressed: () => _updateQuantity(item.product.id, item.quantity + 1, cartProvider),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 36),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeItem(item.product.id, cartProvider),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildProductImage(String imageUrl) {
    // Handle different types of image URLs
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            color: Colors.white,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('data:image')) {
      // Handle base64 images
      try {
        return Image.memory(
          _decodeBase64(imageUrl),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              color: Colors.white,
            );
          },
        );
      } catch (e) {
        return Icon(
          Icons.image_not_supported,
          color: Colors.white,
        );
      }
    } else {
      // Default icon for invalid images
      return Icon(
        Icons.shopping_bag,
        color: Colors.white,
      );
    }
  }

  Uint8List _decodeBase64(String base64String) {
    // Remove the data:image part
    final String data = base64String.split(',').last;
    return base64.decode(data);
  }

  void _updateQuantity(String productId, int newQuantity, CartProvider cartProvider) {
    if (newQuantity <= 0) {
      _removeItem(productId, cartProvider);
    } else {
      cartProvider.updateQuantity(productId, newQuantity);
    }
  }

  void _removeItem(String productId, CartProvider cartProvider) {
    cartProvider.removeFromCart(productId);
  }

  void _clearCart(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cart',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout(CartProvider cartProvider) {
    if (cartProvider.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Checkout',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Total: \$${cartProvider.cart.totalAmount.toStringAsFixed(2)}\n\nProceed with order?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              cartProvider.clearCart();
            },
            child: Text(
              'Confirm Order',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.customColors['babyBlue'],
            ),
          ),
        ],
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