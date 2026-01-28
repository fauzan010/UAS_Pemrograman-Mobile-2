import 'package:flutter/material.dart';
import '../services/product_service.dart';
import 'package:image_picker/image_picker.dart'; // Gunakan XFile

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      products = await _service.fetchProducts();
    } catch (e) {
      products = [];
      debugPrint('Error loading products: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Map<String, dynamic> data, XFile image) async {
    try {
      await _service.addProduct(data, image);
      await loadProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateProduct(id, data); // Panggil service untuk update produk
      await loadProducts(); // Muat ulang produk setelah update
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    await loadProducts();
  }
}