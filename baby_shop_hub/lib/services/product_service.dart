import '../data/dummy_data.dart';
import '../models/product_model.dart';

class ProductService {
  // Get all products
  List<Product> getAllProducts() {
    return DummyData.products;
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') {
      return DummyData.products;
    }
    return DummyData.products.where((product) => product.category == category).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return DummyData.products;
    
    return DummyData.products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase()) ||
      product.brand.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get featured products
  List<Product> getFeaturedProducts() {
    return DummyData.products.where((product) => product.rating >= 4.5).toList();
  }

  // Get product by ID
  Product? getProductById(String id) {
    try {
      return DummyData.products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}