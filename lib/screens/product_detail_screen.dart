import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_theme.dart';
import '../providers/cart_provider.dart'; 
import 'package:provider/provider.dart'; 
import 'dart:convert'; // Add this for base64 decoding
import 'dart:typed_data'; // Add this for Uint8List

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedVariant;

  @override
  void initState() {
    super.initState();
    // Set default variant if available
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first.id;
    }
  }

  ProductVariant? get _selectedVariantObj {
    if (_selectedVariant == null) return null;
    return widget.product.variants.firstWhere(
      (v) => v.id == _selectedVariant,
      orElse: () => widget.product.variants.first,
    );
  }

  // Method to decode base64 image
  Uint8List? _decodeBase64Image(String base64String) {
    if (!base64String.startsWith('data:image')) return null;
    
    try {
      final String data = base64String.split(',').last;
      return base64.decode(data);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  // Widget to display product image
  Widget _buildProductImage() {
    if (widget.product.images.isEmpty) {
      return Center(
        child: Icon(
          _getCategoryIcon(widget.product.category),
          size: 120,
          color: Colors.white,
        ),
      );
    }

    final String imageUrl = widget.product.images.first;
    
    // Check if it's a base64 image
    if (imageUrl.startsWith('data:image')) {
      final Uint8List? imageBytes = _decodeBase64Image(imageUrl);
      if (imageBytes != null) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    _getCategoryIcon(widget.product.category),
                    size: 120,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    
    // Regular network image
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                _getCategoryIcon(widget.product.category),
                size: 120,
                color: Colors.white,
              ),
            );
          },
        ),
      );
    }
    
    // Fallback to icon
    return Center(
      child: Icon(
        _getCategoryIcon(widget.product.category),
        size: 120,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.customColors['babyBlue'],
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
                  // Product Image
                  _buildProductImage(),
                  
                  // Rating Overlay
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
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(${widget.product.reviewCount})',
                            style: TextStyle(
                              color: AppTheme.customColors['textLight'],
                              fontFamily: 'Poppins',
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppTheme.customColors['textDark'],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${widget.product.brand}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.customColors['textLight'],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 16),

                  // Price Range (if multiple variants)
                  if (widget.product.variants.length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Range:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '\$${widget.product.minPrice.toStringAsFixed(2)} - \$${widget.product.maxPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppTheme.customColors['babyBlue'],
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    )
                  else if (_selectedVariantObj != null)
                    Text(
                      '\$${_selectedVariantObj!.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppTheme.customColors['babyBlue'],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  SizedBox(height: 16),

                  // Variants Selection (if multiple variants)
                  if (widget.product.variants.length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Variant:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppTheme.customColors['textDark'],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.product.variants.map((variant) {
                            return ChoiceChip(
                              label: Text('${variant.size} - ${variant.color}'),
                              selected: _selectedVariant == variant.id,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedVariant = variant.id;
                                });
                              },
                              selectedColor: AppTheme.customColors['babyBlue'],
                              backgroundColor: Colors.grey[200],
                              labelStyle: TextStyle(
                                color: _selectedVariant == variant.id 
                                    ? Colors.white 
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppTheme.customColors['textDark'],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 24),

                  // Available Sizes (if multiple)
                  if (widget.product.availableSizes.length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Sizes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppTheme.customColors['textDark'],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: widget.product.availableSizes.map((size) {
                            return Chip(
                              label: Text(size),
                              backgroundColor: AppTheme.customColors['softCream'],
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppTheme.customColors['textDark'],
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
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
      bottomNavigationBar: _buildBottomBar(cartProvider),
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider) {
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
              onPressed: () => _addToCart(cartProvider),
              icon: Icon(Icons.shopping_cart),
              label: Text(
                'Add to Cart',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
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
              onPressed: () => _buyNow(cartProvider),
              child: Text(
                'Buy Now',
                style: TextStyle(
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

  void _addToCart(CartProvider cartProvider) {
  cartProvider.addToCart(
    widget.product,
    selectedVariant: _selectedVariantObj, // PASS SELECTED VARIANT
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '${widget.product.name} added to cart!',
        style: TextStyle(fontFamily: 'Poppins'),
      ),
      backgroundColor: AppTheme.customColors['babyBlue'],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

  void _buyNow(CartProvider cartProvider) {
    _addToCart(cartProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout feature coming soon!',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppTheme.customColors['peach'],
      ),
    );
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share ${widget.product.name}',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
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