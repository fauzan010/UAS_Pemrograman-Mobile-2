import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  CartService() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;

  String _requireUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login.');
    }
    return user.id;
  }

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final userId = _requireUserId();

    final response = await _supabase
        .from('cart')
        .select(
          'id, qty, product:products(id, name, description, price, stock, image_url)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response).map((row) {
      final product = (row['product'] as Map<String, dynamic>?) ?? {};

      return {
        'cart_id': row['id'],
        'id': product['id'],
        'name': product['name'],
        'description': product['description'],
        'price': (product['price'] as num?)?.toDouble() ?? 0,
        'stock': product['stock'] ?? 0,
        'qty': (row['qty'] as num?)?.toInt() ?? 1,
        'image_url': product['image_url'],
        'product': product,
      };
    }).toList();
  }

  Future<void> addToCart(String productId, {int qty = 1}) async {
    final userId = _requireUserId();
    final normalizedQty = qty < 1 ? 1 : qty;

    final existing = await _supabase
        .from('cart')
        .select('id, qty')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .limit(1);

    if (existing.isNotEmpty) {
      final current = existing.first;
      final currentQty = (current['qty'] as num?)?.toInt() ?? 0;
      await _supabase
          .from('cart')
          .update({'qty': currentQty + normalizedQty}).eq('id', current['id']);
    } else {
      await _supabase.from('cart').insert({
        'user_id': userId,
        'product_id': productId,
        'qty': normalizedQty,
      });
    }
  }

  Future<void> updateQty(String productId, int qty) async {
    final userId = _requireUserId();

    if (qty <= 0) {
      await removeFromCart(productId);
      return;
    }

    await _supabase
        .from('cart')
        .update({'qty': qty})
        .match({'user_id': userId, 'product_id': productId});
  }

  Future<void> removeFromCart(String productId) async {
    final userId = _requireUserId();

    await _supabase
        .from('cart')
        .delete()
        .match({'user_id': userId, 'product_id': productId});
  }

  Future<void> clearCart() async {
    final userId = _requireUserId();
    await _supabase.from('cart').delete().eq('user_id', userId);
  }
}
