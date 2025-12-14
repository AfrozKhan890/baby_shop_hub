import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import '../services/cart_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  
  const CategoryProductsScreen({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _categoryProducts = [];
  List<String> _brands = ['All Brands'];
  List<String> _sizes = ['All Sizes'];
  String? _selectedBrand;
  String? _selectedSize;
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _currentMinPrice = 0;
  double _currentMaxPrice = 1000;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  void _loadCategoryProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final allProducts = productProvider.products;
    
    // Filter by category
    _categoryProducts = allProducts
        .where((product) => product.category.toLowerCase() == widget.category.toLowerCase())
        .toList();

    // Extract unique brands
    final uniqueBrands = _categoryProducts
        .map((p) => p.brand)
        .toSet()
        .toList();
    _brands = ['All Brands', ...uniqueBrands];

    // Extract unique sizes based on category
    _sizes = _getSizesForCategory(widget.category);
    
    // Set price range
    if (_categoryProducts.isNotEmpty) {
      _minPrice = _categoryProducts.map((p) => p.minPrice).reduce((a, b) => a < b ? a : b);
      _maxPrice = _categoryProducts.map((p) => p.maxPrice).reduce((a, b) => a > b ? a : b);
      _currentMinPrice = _minPrice;
      _currentMaxPrice = _maxPrice;
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<String> _getSizesForCategory(String category) {
    final sizes = <String>{'All Sizes'};
    
    for (var product in _categoryProducts) {
      sizes.addAll(product.availableSizes);
    }
    
    return sizes.toList();
  }

  List<Product> _getFilteredProducts() {
    List<Product> filtered = _categoryProducts;

    // Filter by brand
    if (_selectedBrand != null && _selectedBrand != 'All Brands') {
      filtered = filtered.where((p) => p.brand == _selectedBrand).toList();
    }

    // Filter by size
    if (_selectedSize != null && _selectedSize != 'All Sizes') {
      filtered = filtered.where((p) {
        return p.availableSizes.contains(_selectedSize);
      }).toList();
    }

    // Filter by price
    filtered = filtered.where((p) {
      return p.minPrice >= _currentMinPrice && p.maxPrice <= _currentMaxPrice;
    }).toList();

    return filtered;
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Brand Filter
          Row(
            children: [
              Icon(Icons.branding_watermark, size: 20, color: AppTheme.customColors['babyBlue']),
              SizedBox(width: 8),
              Text('Brand:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedBrand ?? 'All Brands',
                  items: _brands.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  },
                  isExpanded: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Size Filter (only show if category has sizes)
          if (_sizes.length > 1)
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, size: 20, color: AppTheme.customColors['babyBlue']),
                    SizedBox(width: 8),
                    Text('Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedSize ?? 'All Sizes',
                        items: _sizes.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                        },
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),

          // Price Range Filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price Range:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(_currentMinPrice, _currentMaxPrice),
                min: _minPrice,
                max: _maxPrice,
                divisions: 20,
                labels: RangeLabels(
                  '\$${_currentMinPrice.toStringAsFixed(0)}',
                  '\$${_currentMaxPrice.toStringAsFixed(0)}',
                ),
                onChanged: (values) {
                  setState(() {
                    _currentMinPrice = values.start;
                    _currentMaxPrice = values.end;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_currentMinPrice.toStringAsFixed(0)}'),
                  Text('\$${_currentMaxPrice.toStringAsFixed(0)}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Products Count
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} Products Found',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBrand = null;
                      _selectedSize = null;
                      _currentMinPrice = _minPrice;
                      _currentMaxPrice = _maxPrice;
                    });
                  },
                  child: Text('Clear Filters'),
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-detail',
                                arguments: product,
                              );
                            },
                            onAddToCart: () {
final cartService = Provider.of<CartService>(context, listen: false);

                              cartService.addToCart(product);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart!'),
                                  backgroundColor: AppTheme.customColors['babyBlue'],
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}