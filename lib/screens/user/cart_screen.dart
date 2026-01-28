import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/bottom_navbar.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  String formatCurrency(double value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleUpdateQty(String? productId, int qty) async {
    if (productId == null) return;
    try {
      await context.read<CartProvider>().updateQty(productId, qty);
    } catch (e) {
      _showMessage('Gagal memperbarui jumlah: $e');
    }
  }

  Future<void> _handleRemove(String? productId) async {
    if (productId == null) return;
    try {
      await context.read<CartProvider>().removeFromCart(productId);
      _showMessage('Produk dihapus dari keranjang');
    } catch (e) {
      _showMessage('Gagal menghapus produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    Widget body;
    if (cartProvider.isLoading && cartProvider.cart.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cartProvider.errorMessage != null && cartProvider.cart.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              cartProvider.errorMessage ?? 'Gagal memuat keranjang',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: cartProvider.loadCart,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    } else if (cartProvider.cart.isEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.shopping_basket,
              size: 100,
              color: Color(0xFF5D4037),
            ),
            SizedBox(height: 16),
            Text(
              'Keranjang Anda Kosong!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: cartProvider.cart.length,
        itemBuilder: (context, index) {
          final product = cartProvider.cart[index];
          final productId = product['id']?.toString();
          final int qty = product['qty'] ?? 1;
          final int stock = product['stock'] ?? 0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product['image_url'] != null
                    ? Image.network(
                        product['image_url'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 32),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 32),
                      ),
              ),
              title: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      product['name'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['description'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(product['price']?.toDouble() ?? 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: qty > 1
                        ? () => _handleUpdateQty(productId, qty - 1)
                        : null,
                  ),
                  Text(
                    stock == 0 ? '0' : '$qty',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5D4037)),
                    onPressed: stock > qty
                        ? () => _handleUpdateQty(productId, qty + 1)
                        : null,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _handleRemove(productId),
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: const Color(0xFFF4F7FB),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Keranjang',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: body,
        bottomNavigationBar: const BottomNavbar(currentIndex: 2),
        persistentFooterButtons: cartProvider.cart.isNotEmpty
            ? [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(cartItems: cartProvider.cart),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Checkout'),
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
