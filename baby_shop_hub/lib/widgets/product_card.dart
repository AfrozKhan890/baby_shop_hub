// widgets/product_card.dart - SIMPLIFIED VERSION
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_theme.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 260,
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
          children: [
            // IMAGE SECTION - FIXED
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: _getCategoryColor(product.category),
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.customColors['textDark'],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  
                  // Brand
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.customColors['textLight'],
                    ),
                  ),
                  SizedBox(height: 6),
                  
                  // Rating
                  Row(
                    children: [
                      _buildRatingStars(product.rating),
                      SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.customColors['textLight'],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  
                  // Price and Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.customColors['babyBlue'],
                        ),
                      ),
                      
                      // Add to Cart Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.customColors['peach'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: onAddToCart,
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Try to load network image first
    if (product.imageUrl.startsWith('http')) {
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon();
        },
      );
    } 
    // Try local asset
    else if (product.imageUrl.startsWith('assets')) {
      try {
        return Image.asset(
          product.imageUrl,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return _buildPlaceholderIcon();
      }
    }
    // Use placeholder
    else {
      return _buildPlaceholderIcon();
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: _getCategoryColor(product.category),
      child: Center(
        child: Icon(
          _getCategoryIcon(product.category),
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
          size: 14,
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