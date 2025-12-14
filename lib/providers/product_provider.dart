import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../data/dummy_data.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  bool _useFirebase = false;
  bool _firebaseInitialized = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useFirebase => _useFirebase;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductProvider() {
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check Firebase connectivity
      try {
        await _firestore.collection('products').limit(1).get();
        _useFirebase = true;
        _firebaseInitialized = true;
        print("✅ Firebase connected successfully");
        await _loadProductsFromFirebase();
      } catch (firebaseError) {
        print("❌ Firebase not available: $firebaseError");
        _useFirebase = false;
        _loadDummyProducts();
      }
    } catch (e) {
      print("❌ Error initializing products: $e");
      _useFirebase = false;
      _loadDummyProducts();
    }
  }

  Future<void> _loadProductsFromFirebase() async {
    try {
      // Set up real-time listener
      _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _processFirebaseSnapshot(snapshot);
      }, onError: (error) {
        print("❌ Firebase stream error: $error");
        _loadDummyProducts();
      });

      // Also load initial data
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();
      
      _processFirebaseSnapshot(snapshot);
    } catch (e) {
      print("❌ Error loading from Firebase: $e");
      _loadDummyProducts();
    }
  }

  void _processFirebaseSnapshot(QuerySnapshot snapshot) {
    try {
      final List<Product> loadedProducts = snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();

      // Update main products list
      _products = loadedProducts;
      
      // Synchronize with DummyData for offline use
      DummyData.clearAllProducts();
      for (var product in _products) {
        DummyData.addProduct(product);
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
      
      print("✅ Loaded ${_products.length} products from Firebase");
    } catch (e) {
      print("❌ Error processing Firebase snapshot: $e");
      _loadDummyProducts();
    }
  }

  void _loadDummyProducts() {
    print("⚠️ Using local dummy data");
    _products = DummyData.getProducts();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirebase && _firebaseInitialized) {
        // Add to Firebase
        final docRef = await _firestore.collection('products').add(product.toMap());
        await _firestore.collection('products').doc(docRef.id).update({
          'id': docRef.id,
        });
        
        // Create new product with correct ID
        final newProduct = product.copyWith(id: docRef.id);
        
        // Add to DummyData
        DummyData.addProduct(newProduct);
        
        // Add to local list
        _products.insert(0, newProduct);
      } else {
        // Use DummyData only
        DummyData.addProduct(product);
        _products.insert(0, product);
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      
      print("✅ Product added successfully");
    } catch (e) {
      _error = 'Failed to add product: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, Product updatedProduct) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirebase && _firebaseInitialized) {
        await _firestore.collection('products').doc(productId).update(updatedProduct.toMap());
      }
      
      // Always update DummyData
      DummyData.updateProduct(productId, updatedProduct);
      
      // Update local list
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      
      print("✅ Product updated successfully");
    } catch (e) {
      _error = 'Failed to update product: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirebase && _firebaseInitialized) {
        await _firestore.collection('products').doc(productId).delete();
      }
      
      // Always delete from DummyData
      DummyData.deleteProduct(productId);
      
      // Delete from local list
      _products.removeWhere((p) => p.id == productId);

      _error = null;
      _isLoading = false;
      notifyListeners();
      
      print("✅ Product deleted successfully");
    } catch (e) {
      _error = 'Failed to delete product: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return DummyData.getProductById(id);
    }
  }

  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return _products;
    return _products
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<Product> get featuredProducts {
    return _products.where((product) => product.isFeatured).toList();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.brand.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _isLoading = true;
    notifyListeners();
    
    if (_useFirebase && _firebaseInitialized) {
      try {
        final snapshot = await _firestore
            .collection('products')
            .orderBy('createdAt', descending: true)
            .get();
        _processFirebaseSnapshot(snapshot);
      } catch (e) {
        _loadDummyProducts();
      }
    } else {
      _loadDummyProducts();
    }
  }

  List<Product> getProductsByBrand(String brand) {
    return _products.where((product) => product.brand == brand).toList();
  }

  List<String> getAllBrands() {
    return _products.map((p) => p.brand).toSet().toList();
  }

  List<String> getSizesByCategory(String category) {
    final categoryProducts = getProductsByCategory(category);
    final allSizes = <String>{};
    
    for (var product in categoryProducts) {
      allSizes.addAll(product.availableSizes);
    }
    
    return allSizes.toList();
  }
}