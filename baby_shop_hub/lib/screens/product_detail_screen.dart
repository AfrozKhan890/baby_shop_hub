import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_theme.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.product.category),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(widget.product.category),
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.product.rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.customColors['textDark'],
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(${widget.product.reviewCount})',
                            style: TextStyle(
                              color: AppTheme.customColors['textLight'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Brand
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${widget.product.brand}',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppTheme.customColors['textLight'],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Price
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: AppTheme.customColors['babyBlue'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 24),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.customColors['babyBlue']!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _quantity > 1 ? _decrementQuantity : null,
                          color: AppTheme.customColors['babyBlue'],
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            _quantity.toString(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _incrementQuantity,
                          color: AppTheme.customColors['babyBlue'],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
      child: Row(
        children: [
          // Add to Cart Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: Icon(Icons.shopping_cart),
              label: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.customColors['peach'],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Buy Now Button
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: _buyNow,
              child: Text('Buy Now'),
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
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

  void _addToCart() {
    for (int i = 0; i < _quantity; i++) {
      _cartService.addToCart(widget.product);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!'),
        backgroundColor: AppTheme.customColors['babyBlue'],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _buyNow() {
    _addToCart();
    // TODO: Navigate to checkout screen
  }

  void _shareProduct() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${widget.product.name}'),
        backgroundColor: AppTheme.customColors['peach'],
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