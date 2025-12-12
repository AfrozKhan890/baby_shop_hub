import '../models/product_model.dart';

class DummyData {
  static List<String> categories = [
    'All',
    'Clothing',
    'Food',
    'Diapers',
    'Toys',
    'Bath',
    'Carriers',
    'Feeding',
    'Nursery'
  ];

  static List<Product> _products = _initializeProducts();

  static List<Product> _initializeProducts() {
    return [
      Product(
        id: '1',
        name: 'Soft Cotton Baby Onesie',
        description: '100% cotton soft onesie for babies, comfortable and gentle on skin',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Clothing',
        brand: 'BabySoft',
        variants: [
          ProductVariant(id: '1-1', size: '0-3M', color: 'White', price: 12.99, stock: 15),
          ProductVariant(id: '1-2', size: '3-6M', color: 'White', price: 12.99, stock: 20),
          ProductVariant(id: '1-3', size: '6-12M', color: 'White', price: 13.99, stock: 10),
          ProductVariant(id: '1-4', size: '0-3M', color: 'Blue', price: 12.99, stock: 12),
          ProductVariant(id: '1-5', size: '3-6M', color: 'Blue', price: 12.99, stock: 18),
        ],
        basePrice: 12.99,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        rating: 4.2,
        reviewCount: 128,
        isFeatured: true,
      ),
      Product(
        id: '2',
        name: 'Organic Baby Food Jar',
        description: 'Pure organic baby food with no preservatives or additives',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Food',
        brand: 'OrganicKids',
        variants: [
          ProductVariant(id: '2-1', size: 'Stage 1', color: 'Carrot', price: 3.99, stock: 50),
          ProductVariant(id: '2-2', size: 'Stage 2', color: 'Apple', price: 4.99, stock: 40),
          ProductVariant(id: '2-3', size: 'Stage 3', color: 'Banana', price: 5.99, stock: 30),
        ],
        basePrice: 3.99,
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        rating: 4.4,
        reviewCount: 89,
        isFeatured: true,
      ),
      Product(
        id: '3',
        name: 'Premium Diapers Pack',
        description: 'Ultra-absorbent diapers for overnight protection',
        images: ['https://images.unsplash.com/photo-1584839404045-2c4b5d7c4f3a?w=400&h=400&fit=crop'],
        category: 'Diapers',
        brand: 'Pampers',
        variants: [
          ProductVariant(id: '3-1', size: 'Newborn', color: 'White', price: 24.99, stock: 25),
          ProductVariant(id: '3-2', size: 'S', color: 'White', price: 26.99, stock: 30),
          ProductVariant(id: '3-3', size: 'M', color: 'White', price: 28.99, stock: 35),
          ProductVariant(id: '3-4', size: 'L', color: 'White', price: 30.99, stock: 20),
          ProductVariant(id: '3-5', size: 'XL', color: 'White', price: 32.99, stock: 15),
        ],
        basePrice: 24.99,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        rating: 4.5,
        reviewCount: 203,
        isFeatured: false,
      ),
      Product(
        id: '4',
        name: 'Huggies Diapers',
        description: 'Soft and comfortable diapers with wetness indicator',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Diapers',
        brand: 'Huggies',
        variants: [
          ProductVariant(id: '4-1', size: 'S', color: 'White', price: 22.99, stock: 40),
          ProductVariant(id: '4-2', size: 'M', color: 'White', price: 24.99, stock: 45),
          ProductVariant(id: '4-3', size: 'L', color: 'White', price: 26.99, stock: 35),
        ],
        basePrice: 22.99,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        rating: 4.3,
        reviewCount: 156,
        isFeatured: true,
      ),
      Product(
        id: '5',
        name: 'Baby Denim Jacket',
        description: 'Stylish denim jacket for babies',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Clothing',
        brand: 'BabyStyle',
        variants: [
          ProductVariant(id: '5-1', size: '0-3M', color: 'Blue', price: 18.50, stock: 8),
          ProductVariant(id: '5-2', size: '3-6M', color: 'Blue', price: 19.50, stock: 12),
          ProductVariant(id: '5-3', size: '6-12M', color: 'Blue', price: 20.50, stock: 10),
        ],
        basePrice: 18.50,
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        rating: 4.7,
        reviewCount: 56,
        isFeatured: true,
      ),
      Product(
        id: '6',
        name: 'Baby Carrier',
        description: 'Ergonomic baby carrier for comfortable carrying',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Carriers',
        brand: 'CarryComfort',
        variants: [
          ProductVariant(id: '6-1', size: 'Standard', color: 'Black', price: 45.99, stock: 15),
          ProductVariant(id: '6-2', size: 'Standard', color: 'Gray', price: 45.99, stock: 12),
          ProductVariant(id: '6-3', size: 'Premium', color: 'Black', price: 59.99, stock: 8),
        ],
        basePrice: 45.99,
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        rating: 4.3,
        reviewCount: 39,
        isFeatured: false,
      ),
      Product(
        id: '7',
        name: 'Baby Feeding Bottle Set',
        description: 'BPA-free feeding bottles with anti-colic system',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Feeding',
        brand: 'FeedWell',
        variants: [
          ProductVariant(id: '7-1', size: '150ml', color: 'Clear', price: 8.75, stock: 40),
          ProductVariant(id: '7-2', size: '250ml', color: 'Clear', price: 10.75, stock: 35),
          ProductVariant(id: '7-3', size: '150ml', color: 'Pink', price: 9.75, stock: 25),
          ProductVariant(id: '7-4', size: '250ml', color: 'Blue', price: 11.75, stock: 20),
        ],
        basePrice: 8.75,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        rating: 4.1,
        reviewCount: 23,
        isFeatured: false,
      ),
      Product(
        id: '8',
        name: 'Baby Bath Set',
        description: 'Complete bath set including tub, shampoo, and towel',
        images: ['https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop'],
        category: 'Bath',
        brand: 'BubbleBaby',
        variants: [
          ProductVariant(id: '8-1', size: 'Standard', color: 'Blue', price: 29.99, stock: 20),
          ProductVariant(id: '8-2', size: 'Standard', color: 'Pink', price: 29.99, stock: 18),
          ProductVariant(id: '8-3', size: 'Deluxe', color: 'White', price: 39.99, stock: 12),
        ],
        basePrice: 29.99,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        rating: 4.6,
        reviewCount: 67,
        isFeatured: false,
      ),
    ];
  }

  static List<Product> getProducts() {
    return List.from(_products)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static void addProduct(Product product) {
    if (_products.any((p) => p.id == product.id)) {
      throw Exception('Product with ID ${product.id} already exists');
    }
    
    _products.add(product);
    print("✅ Product added to DummyData: ${product.name}");
  }

  static void updateProduct(String productId, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == productId);
    
    if (index == -1) {
      throw Exception('Product with ID $productId not found');
    }
    
    _products[index] = updatedProduct;
    print("✅ Product updated in DummyData: ${updatedProduct.name}");
  }

  static void deleteProduct(String productId) {
    final initialCount = _products.length;
    _products.removeWhere((p) => p.id == productId);
    
    if (_products.length == initialCount) {
      throw Exception('Product with ID $productId not found');
    }
    
    print("✅ Product deleted from DummyData: $productId");
  }

  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return getProducts();
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.brand.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<Product> getFeaturedProducts() {
    return _products.where((product) => product.isFeatured).toList();
  }

  static List<Product> getProductsByCategory(String category) {
    if (category == 'All') return getProducts();
    return _products.where((product) => product.category == category).toList();
  }

  static List<Product> getProductsByBrand(String brand) {
    return _products.where((product) => product.brand == brand).toList();
  }

  static List<Product> getLowStockProducts() {
    return _products.where((product) => product.totalStock < 20).toList();
  }

  static void refreshProducts() {
    _products = _initializeProducts();
  }

  static int get productCount => _products.length;

  static void clearAllProducts() {
    _products.clear();
  }

  static String generateNewId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static List<String> getBrandsByCategory(String category) {
    final products = getProductsByCategory(category);
    return products.map((p) => p.brand).toSet().toList();
  }
}