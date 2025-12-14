import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/product_model.dart';
import '../utils/app_theme.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _selectedVariantId;
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    // Default variant select karo
    if (widget.product.variants.isNotEmpty) {
      _selectedVariantId = widget.product.variants.first.id;
      _selectedVariant = widget.product.variants.first;
    }
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

  // Get price to display - agar multiple variants hain to range show karo
  String _getPriceDisplay() {
    if (widget.product.variants.length == 1) {
      return '\$${widget.product.variants.first.price.toStringAsFixed(2)}';
    } else if (_selectedVariant != null) {
      return '\$${_selectedVariant!.price.toStringAsFixed(2)}';
    } else {
      // Price range for multiple variants
      return '\$${widget.product.minPrice.toStringAsFixed(2)} - \$${widget.product.maxPrice.toStringAsFixed(2)}';
    }
  }

  // Add to cart with selected variant
  void _addToCartWithVariant() {
    // Create a copy of product with selected variant
    final productToAdd = widget.product.copyWith(
      variants: _selectedVariant != null ? [_selectedVariant!] : widget.product.variants,
    );
    
    // Call the original onAddToCart callback
    widget.onAddToCart();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleVariants = widget.product.variants.length > 1;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 170,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // IMAGE SECTION
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: _getCategoryColor(widget.product.category),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _buildImage(),
              ),
            ),
            
            // PRODUCT INFO
            Expanded( 
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.customColors['textDark'],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          
                          // Brand
                          Text(
                            widget.product.brand,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.customColors['textLight'],
                            ),
                          ),
                          
                          // Variant indicator (if multiple)
                          if (hasMultipleVariants)
                            Container(
                              margin: EdgeInsets.only(top: 2),
                              child: Text(
                                '${widget.product.variants.length} variants',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Rating
                    Row(
                      children: [
                        _buildRatingStars(widget.product.rating),
                        SizedBox(width: 4),
                        Text(
                          '(${widget.product.reviewCount})',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.customColors['textLight'],
                          ),
                        ),
                      ],
                    ),
                    
                    // Price and Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price - Show based on variant
                        Flexible(
                          child: Text(
                            _getPriceDisplay(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.customColors['babyBlue'],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Add to Cart Button
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.customColors['peach'],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            onPressed: _addToCartWithVariant,
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 14,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.product.images.isEmpty) {
      return _buildPlaceholderIcon();
    }

    final String imageUrl = widget.product.images.first;
    
    // Check for base64 image
    if (imageUrl.startsWith('data:image')) {
      final Uint8List? imageBytes = _decodeBase64Image(imageUrl);
      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon();
          },
        );
      }
    }
    
    // Check for network image
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon();
        },
      );
    }
    
    // Check for asset image
    if (imageUrl.startsWith('assets/')) {
      try {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon();
          },
        );
      } catch (e) {
        return _buildPlaceholderIcon();
      }
    }
    
    // Default placeholder
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: _getCategoryColor(widget.product.category),
      child: Center(
        child: Icon(
          _getCategoryIcon(widget.product.category),
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 10,
        );
      }),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'clothing': return Color(0xFF89CFF0);
      case 'food': return Color(0xFFFFB6C1);
      case 'diapers': return Color(0xFFFFF9C4);
      case 'toys': return Color(0xFFB6E6FF);
      case 'bath': return Color(0xFFFFE4E9);
      case 'carriers': return Color(0xFFA5D8FF);
      case 'feeding': return Color(0xFFFFD6E0);
      case 'nursery': return Color(0xFFC8E6FF);
      default: return Color(0xFF89CFF0);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothing': return Icons.face;
      case 'food': return Icons.restaurant;
      case 'diapers': return Icons.child_care;
      case 'toys': return Icons.toys;
      case 'bath': return Icons.bathtub;
      case 'carriers': return Icons.backpack;
      case 'feeding': return Icons.restaurant_menu;
      case 'nursery': return Icons.crib;
      default: return Icons.shopping_bag;
    }
  }
}