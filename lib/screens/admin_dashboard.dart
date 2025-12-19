import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../data/dummy_data.dart';
import '../utils/app_theme.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'admin_users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'admin_users_screen.dart';
import 'admin_products_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;
  
  // Tabs for admin dashboard
  final List<Widget> _tabs = [
    ProductsTab(),
    UsersTab(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: AppTheme.customColors['babyBlue'],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _tabs[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        selectedItemColor: AppTheme.customColors['babyBlue'],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: () {
                // Add Product Dialog
                _showAddProductDialog(context);
              },
              backgroundColor: AppTheme.customColors['peach'],
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(),
    );
  }
}

// Products Tab
class ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Products (${products.length})',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: AppTheme.customColors['textDark'],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.customColors['babyBlue'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Manage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: productProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.customColors['babyBlue'],
                  ),
                )
              : products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first product',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(product: product);
                      },
                    ),
        ),
      ],
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(product.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProductImage(product.images.first),
                      )
                    : Icon(
                        _getCategoryIcon(product.category),
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '• ${product.brand}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppTheme.customColors['babyBlue'],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.totalStock > 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: product.totalStock > 0
                                ? Colors.green
                                : Colors.red,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Stock: ${product.totalStock}',
                          style: TextStyle(
                            fontSize: 10,
                            color: product.totalStock > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      if (product.variants.length > 1)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '${product.variants.length} variants',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditProductDialog(context, product);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, product);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
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
      );
    } else if (imageUrl.startsWith('data:image')) {
      try {
        final String data = imageUrl.split(',').last;
        final Uint8List bytes = base64.decode(data);
        return Image.memory(
          bytes,
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
      return Icon(
        Icons.image_not_supported,
        color: Colors.white,
      );
    }
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(product: product),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<ProductProvider>(context, listen: false)
                    .removeProduct(product.id);
                    
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Product deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Failed to delete product: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
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

// Add Product Dialog
class AddProductDialog extends StatefulWidget {
  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _brandController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'Clothing';
  double _rating = 4.5;
  bool _isFeatured = false;
  bool _isLoading = false;

  // Variants section
  List<Map<String, dynamic>> _variants = [];
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _variantPriceController = TextEditingController();
  final TextEditingController _variantStockController = TextEditingController();

  final List<String> _categories = [
    'Clothing',
    'Food',
    'Diapers',
    'Toys',
    'Bath',
    'Carriers',
    'Feeding',
    'Nursery'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _variantPriceController.dispose();
    _variantStockController.dispose();
    super.dispose();
  }

  // Method to build variants section
  Widget _buildVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Variants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            if (_variants.isNotEmpty)
              Text(
                '${_variants.length} variant(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        
        // Current Variants List
        if (_variants.isNotEmpty)
          Column(
            children: _variants.map((variant) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${variant['size']} - ${variant['color']}'),
                  subtitle: Text('\$${variant['price']} | Stock: ${variant['stock']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _variants.remove(variant);
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        
        // Add New Variant Form
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Add Variant',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sizeController,
                        decoration: InputDecoration(
                          labelText: 'Size',
                          hintText: 'e.g., M, L, XL',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          hintText: 'e.g., Blue, Pink',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _variantPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _variantStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addVariant,
                  child: Text('Add Variant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.customColors['peach'],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _addVariant() {
    if (_sizeController.text.isEmpty || 
        _variantPriceController.text.isEmpty || 
        _variantStockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all variant fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_variantPriceController.text);
    final stock = int.tryParse(_variantStockController.text);

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid price and stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _variants.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'size': _sizeController.text,
        'color': _colorController.text.isEmpty ? 'Default' : _colorController.text,
        'price': price,
        'stock': stock,
      });
      
      // Clear controllers
      _sizeController.clear();
      _colorController.clear();
      _variantPriceController.clear();
      _variantStockController.clear();
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create product variants
      List<ProductVariant> productVariants = _variants.map((v) {
        return ProductVariant(
          id: v['id'],
          size: v['size'],
          color: v['color'],
          price: v['price'],
          stock: v['stock'],
        );
      }).toList();

      // If no variants, create one default variant
      if (productVariants.isEmpty) {
        final price = double.tryParse(_priceController.text) ?? 0.0;
        final stock = int.tryParse(_stockController.text) ?? 10;
        
        productVariants.add(ProductVariant(
          id: 'default',
          size: 'One Size',
          color: 'Default',
          price: price,
          stock: stock,
        ));
      }

      final newProduct = Product(
        id: DummyData.generateNewId(),
        name: _nameController.text,
        description: _descriptionController.text,
        images: _imageUrlController.text.isNotEmpty 
            ? [_imageUrlController.text] 
            : ['https://via.placeholder.com/150'],
        category: _selectedCategory,
        brand: _brandController.text.isNotEmpty ? _brandController.text : 'Generic',
        variants: productVariants,
        basePrice: productVariants.first.price,
        createdAt: DateTime.now(),
        rating: _rating,
        reviewCount: 0,
        isFeatured: _isFeatured,
        specifications: {},
      );

      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to add product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Add New Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Product Name
                Text(
                  'Product Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Description
                Text(
                  'Description *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter product description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Default Price and Stock (for single variant products)
                Text(
                  'Default Price & Stock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    // Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              labelText: 'Price (\$)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                    // Stock
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '10',
                              labelText: 'Stock',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter stock';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid stock';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Brand
                Text(
                  'Brand',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    hintText: 'Enter brand name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category
                Text(
                  'Category *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Image URL
                Text(
                  'Image URL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Variants Section
                _buildVariantsSection(),

                // Rating and Featured
                Row(
                  children: [
                    // Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Slider(
                            value: _rating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                          Text(
                            '${_rating.toStringAsFixed(1)} ⭐',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                    // Featured
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8),
                          Switch(
                            value: _isFeatured,
                            onChanged: (value) {
                              setState(() {
                                _isFeatured = value;
                              });
                            },
                            activeColor: AppTheme.customColors['babyBlue'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.customColors['babyBlue'],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Edit Product Dialog
class EditProductDialog extends StatefulWidget {
  final Product product;

  const EditProductDialog({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _brandController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late double _rating;
  late bool _isFeatured;
  bool _isLoading = false;

  // Variants section
  late List<Map<String, dynamic>> _variants;
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _variantPriceController = TextEditingController();
  final TextEditingController _variantStockController = TextEditingController();

  final List<String> _categories = [
    'Clothing',
    'Food',
    'Diapers',
    'Toys',
    'Bath',
    'Carriers',
    'Feeding',
    'Nursery'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _brandController = TextEditingController(text: widget.product.brand);
    _imageUrlController = TextEditingController(
        text: widget.product.images.isNotEmpty ? widget.product.images.first : '');
    _selectedCategory = widget.product.category;
    _rating = widget.product.rating;
    _isFeatured = widget.product.isFeatured;
    
    // Convert variants to editable format
    _variants = widget.product.variants.map((variant) {
      return {
        'id': variant.id,
        'size': variant.size,
        'color': variant.color,
        'price': variant.price,
        'stock': variant.stock,
      };
    }).toList();
    
    // Set default price and stock from first variant
    if (widget.product.variants.isNotEmpty) {
      final firstVariant = widget.product.variants.first;
      _priceController = TextEditingController(text: firstVariant.price.toString());
      _stockController = TextEditingController(text: firstVariant.stock.toString());
    } else {
      _priceController = TextEditingController(text: '0.0');
      _stockController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _variantPriceController.dispose();
    _variantStockController.dispose();
    super.dispose();
  }

  // Method to build variants section for edit
  Widget _buildVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Variants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            if (_variants.isNotEmpty)
              Text(
                '${_variants.length} variant(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        
        // Current Variants List
        if (_variants.isNotEmpty)
          Column(
            children: _variants.map((variant) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${variant['size']} - ${variant['color']}'),
                  subtitle: Text('\$${variant['price']} | Stock: ${variant['stock']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _variants.remove(variant);
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        
        // Add New Variant Form
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Add New Variant',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sizeController,
                        decoration: InputDecoration(
                          labelText: 'Size',
                          hintText: 'e.g., M, L, XL',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          hintText: 'e.g., Blue, Pink',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _variantPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _variantStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addVariant,
                  child: Text('Add Variant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.customColors['peach'],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _addVariant() {
    if (_sizeController.text.isEmpty || 
        _variantPriceController.text.isEmpty || 
        _variantStockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all variant fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_variantPriceController.text);
    final stock = int.tryParse(_variantStockController.text);

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid price and stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _variants.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'size': _sizeController.text,
        'color': _colorController.text.isEmpty ? 'Default' : _colorController.text,
        'price': price,
        'stock': stock,
      });
      
      // Clear controllers
      _sizeController.clear();
      _colorController.clear();
      _variantPriceController.clear();
      _variantStockController.clear();
    });
  }
  
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create product variants
      List<ProductVariant> productVariants = _variants.map((v) {
        return ProductVariant(
          id: v['id'],
          size: v['size'],
          color: v['color'],
          price: v['price'],
          stock: v['stock'],
        );
      }).toList();

      // If no variants exist, keep at least one
      if (productVariants.isEmpty) {
        final price = double.tryParse(_priceController.text) ?? 0.0;
        final stock = int.tryParse(_stockController.text) ?? 10;
        
        productVariants.add(ProductVariant(
          id: 'default',
          size: 'One Size',
          color: 'Default',
          price: price,
          stock: stock,
        ));
      }

      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        description: _descriptionController.text,
        images: _imageUrlController.text.isNotEmpty 
            ? [_imageUrlController.text] 
            : (widget.product.images.isNotEmpty 
                ? widget.product.images 
                : ['https://via.placeholder.com/150']),
        category: _selectedCategory,
        brand: _brandController.text.isNotEmpty ? _brandController.text : 'Generic',
        variants: productVariants,
        basePrice: productVariants.first.price,
        createdAt: widget.product.createdAt,
        rating: _rating,
        reviewCount: widget.product.reviewCount,
        isFeatured: _isFeatured,
        specifications: widget.product.specifications,
      );

      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.product.id, updatedProduct);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to update product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Edit Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Product Name
                Text(
                  'Product Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Description
                Text(
                  'Description *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter product description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Default Price and Stock
                Text(
                  'Default Price & Stock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    // Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              labelText: 'Price (\$)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                    // Stock
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '10',
                              labelText: 'Stock',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter stock';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid stock';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Brand
                Text(
                  'Brand',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    hintText: 'Enter brand name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category
                Text(
                  'Category *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Image URL
                Text(
                  'Image URL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Variants Section
                _buildVariantsSection(),

                // Rating and Featured
                Row(
                  children: [
                    // Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Slider(
                            value: _rating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                          Text(
                            '${_rating.toStringAsFixed(1)} ⭐',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                    // Featured
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8),
                          Switch(
                            value: _isFeatured,
                            onChanged: (value) {
                              setState(() {
                                _isFeatured = value;
                              });
                            },
                            activeColor: AppTheme.customColors['babyBlue'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Update Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.customColors['peach'],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Other Tabs (Placeholders for now)
class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Orders Management\nComing Soon!',
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey[500],
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class UsersTab extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return AdminUsersScreen(); // ✅ Yahi change karo
  }
}

class AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Analytics Dashboard\nComing Soon!',
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey[500],
          fontFamily: 'Poppins',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

