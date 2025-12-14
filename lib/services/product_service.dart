import '../models/product_model.dart';
import '../data/dummy_data.dart';

class ProductService {
  List<Product> getAllProducts() {
    return DummyData.getProducts();
  }

  List<Product> getFeaturedProducts() {
    return DummyData.getFeaturedProducts();
  }

  List<Product> getProductsByCategory(String category) {
    return DummyData.getProductsByCategory(category);
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();
    
    final lowerQuery = query.toLowerCase();
    return getAllProducts().where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.brand.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Product? getProductById(String id) {
    return getAllProducts().firstWhere((product) => product.id == id);
  }
}