import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/dummy_data.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/firebase_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _featuredProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _useFirebase = false;
  String _connectionStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkFirebaseAndLoadProducts();
  }

  void _checkFirebaseAndLoadProducts() async {
    print('🏠 HomeScreen: Checking Firebase...');
    
    // Check if Firebase is available
    if (_firebaseService.isInitialized) {
      print('✅ Firebase is initialized');
      setState(() {
        _useFirebase = true;
        _connectionStatus = 'Connecting...';
      });
      _loadProductsFromFirebase();
    } else {
      print('⚠️ Firebase not initialized, using dummy data');
      setState(() {
        _connectionStatus = 'Offline Mode';
      });
      _loadProductsFromDummy();
    }
  }

  void _loadProductsFromFirebase() {
    print('🔥 Loading products from Firebase...');
    
    // Listen to products stream from Firebase
    _firebaseService.getProducts().listen((products) {
      print('📊 Firebase returned ${products.length} products'); 
      
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
          _connectionStatus = 'Live Database';
        });
      }
    }, onError: (error) {
      print('❌ Firebase error: $error');
      setState(() {
        _connectionStatus = 'Connection Failed';
      });
      _loadProductsFromDummy();
    });

    // Listen to featured products
    _firebaseService.getFeaturedProducts().listen((featuredProducts) {
      if (mounted) {
        setState(() {
          _featuredProducts = featuredProducts;
        });
      }
    }, onError: (error) {
      print('❌ Featured products error: $error');
    });
  }

  void _loadProductsFromDummy() {
    print('📱 Loading dummy products...');
    setState(() {
      _products = _productService.getAllProducts();
      _filteredProducts = _products;
      _featuredProducts = _productService.getFeaturedProducts();
      _isLoading = false;
      _connectionStatus = 'Offline Mode';
    });
  }

  void _filterProducts() {
    if (_useFirebase) {
      // Firebase will handle filtering through streams
      return;
    }

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
    
    if (_useFirebase && category != 'All') {
      // Use Firebase category filtering
      _firebaseService.getProductsByCategory(category).listen((products) {
        if (mounted) {
          setState(() {
            _filteredProducts = products;
          });
        }
      });
    } else if (_useFirebase) {
      // Get all products from Firebase
      _firebaseService.getProducts().listen((products) {
        if (mounted) {
          setState(() {
            _filteredProducts = products;
          });
        }
      });
    } else {
      _filterProducts();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (_useFirebase && query.isNotEmpty) {
      // Use Firebase search
      _firebaseService.searchProducts(query).listen((products) {
        if (mounted) {
          setState(() {
            _filteredProducts = products;
          });
        }
      });
    } else if (_useFirebase) {
      // Get all products when search is cleared
      _firebaseService.getProducts().listen((products) {
        if (mounted) {
          setState(() {
            _filteredProducts = products;
          });
        }
      });
    } else {
      _filterProducts();
    }
  }

  void _onProductTap(Product product) {
    Navigator.pushNamed(
      context,
      '/product_detail',
      arguments: product,
    );
  }

  void _onAddToCart(Product product) {
    _cartService.addToCart(product);
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
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppTheme.customColors['textDark'],
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
            'Categories',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: AppTheme.customColors['textDark'],
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: DummyData.categories.length,
            itemBuilder: (context, index) {
              final category = DummyData.categories[index];
              return CategoryChip(
                category: category,
                isSelected: _selectedCategory == category,
                onTap: () => _onCategorySelected(category),
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
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppTheme.customColors['textDark'],
                ),
              ),
              Text(
                '${_filteredProducts.length} items',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.customColors['textLight'],
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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              _connectionStatus,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppTheme.customColors['textLight'],
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
              color: AppTheme.customColors['textLighter'],
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              _useFirebase 
                ? 'Firebase: $_connectionStatus'
                : 'Try different search terms or categories',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (_useFirebase && _connectionStatus.contains('Failed'))
              ElevatedButton(
                onPressed: _loadProductsFromDummy,
                child: Text('Use Offline Mode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.customColors['peach'],
                  foregroundColor: Colors.white,
                ),
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Admin Access
            SliverAppBar(
              backgroundColor: AppTheme.customColors['babyBlue'],
              expandedHeight: 100,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'BabyShopHub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  color: AppTheme.customColors['babyBlue'],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        _connectionStatus,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Admin Access Button - Long Press
                GestureDetector(
                  onLongPress: () {
                    Navigator.pushNamed(context, '/admin_login');
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
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