import 'package:flutter/material.dart';

import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;
  final List<Map<String, dynamic>> _cart = [];
  final Set<String> _selectedIds = {};

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);
  Set<String> get selectedIds => _selectedIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _cartService.fetchCartItems();
      _cart
        ..clear()
        ..addAll(items);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Map<String, dynamic> product, {int qty = 1}) async {
    try {
      final productId = product['id']?.toString();
      if (productId == null) {
        throw Exception('Produk tidak valid.');
      }

      await _cartService.addToCart(productId, qty: qty);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromCart(String id) async {
    try {
      await _cartService.removeFromCart(id);
      await loadCart();
      _selectedIds.remove(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void toggleSelect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cart.clear();
      _selectedIds.clear();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateQty(String productId, int newQty) async {
    try {
      await _cartService.updateQty(productId, newQty);
      await loadCart();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
