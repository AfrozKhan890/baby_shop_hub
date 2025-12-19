import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../data/dummy_data.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _featuredProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    setState(() {
      _isLoading = productProvider.isLoading;
    });
    
    // Listen to product provider changes
    productProvider.addListener(() {
      if (mounted) {
        setState(() {
          _products = productProvider.products;
          _filteredProducts = _products;
          _featuredProducts = productProvider.featuredProducts;
          _isLoading = productProvider.isLoading;
        });
      }
    });
    
    // Initial load
    setState(() {
      _products = productProvider.products;
      _filteredProducts = _products;
      _featuredProducts = productProvider.featuredProducts;
      _isLoading = productProvider.isLoading;
    });
  }

  void _filterProducts() {
    setState(() {
      if (_selectedCategory == 'All' && _searchQuery.isEmpty) {
        _filteredProducts = _products;
      } else if (_selectedCategory != 'All' && _searchQuery.isEmpty) {
        _filteredProducts = _productService.getProductsByCategory(_selectedCategory);
      } else if (_selectedCategory == 'All' && _searchQuery.isNotEmpty) {
        _filteredProducts = _productService.searchProducts(_searchQuery);
      } else {
        var categoryProducts = _productService.getProductsByCategory(_selectedCategory);
        _filteredProducts = categoryProducts.where((product) =>
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterProducts();
  }

  void _onProductTap(Product product) {
    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: product,
    );
  }

  void _onAddToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        backgroundColor: AppTheme.customColors['babyBlue'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    if (_featuredProducts.isEmpty || _isLoading) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.customColors['textDark'],
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.customColors['babyBlue'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Hot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featuredProducts.length,
            itemBuilder: (context, index) {
              final product = _featuredProducts[index];
              return Container(
                width: 180,
                margin: EdgeInsets.only(right: 16),
                child: ProductCard(
                  product: product,
                  onTap: () => _onProductTap(product),
                  onAddToCart: () => _onAddToCart(product),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Shop by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.customColors['textDark'],
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: DummyData.categories.length,
            itemBuilder: (context, index) {
              final category = DummyData.categories[index];
              return GestureDetector(
                onTap: () {
                  if (category != 'All') {
                    Navigator.pushNamed(
                      context,
                      '/category-products',
                      arguments: category,
                    );
                  } else {
                    _onCategorySelected(category);
                  }
                },
                child: Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(category),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.customColors['textDark'],
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                '${_filteredProducts.length} items',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.customColors['textLight'],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _isLoading 
            ? _buildLoadingState()
            : _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductsGrid(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.customColors['babyBlue'],
            ),
            SizedBox(height: 16),
            Text(
              'Loading Products...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.customColors['textLight'],
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different search terms or categories',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.60,
      ),
      itemCount: _filteredProducts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => _onProductTap(product),
          onAddToCart: () => _onAddToCart(product),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all': return Color(0xFF89CFF0);
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
      case 'all': return Icons.category;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom AppBar - FIXED HEADER
            SliverAppBar(
              backgroundColor: AppTheme.customColors['babyBlue'],
              expandedHeight: 80,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'BabyShopHub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                background: Container(
                  color: AppTheme.customColors['babyBlue'],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 30),
                      Text(
                        'Find the best for your baby',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white, size: 22),
                  onPressed: () {
                    // Search focus logic
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for baby products...',
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                      prefixIcon: Icon(Icons.search, color: AppTheme.customColors['textLight']),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
            ),

            // Featured Products Section
            if (!_isLoading && _featuredProducts.isNotEmpty)
              SliverToBoxAdapter(child: _buildFeaturedSection()),

            // Categories Section
            SliverToBoxAdapter(child: _buildCategorySection()),

            // Products Grid Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24, bottom: 24),
                child: _buildProductsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}