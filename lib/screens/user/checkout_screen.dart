import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final TextEditingController _addressController = TextEditingController();
  String? selectedPaymentMethod;
  String? selectedSubPaymentMethod;

  bool _loadingCart = false;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    // Jika caller tidak mengirim cartItems, fallback fetch dari Supabase.
    if (widget.cartItems.isEmpty) {
      _loadCart();
    } else {
      _cartItems = widget.cartItems;
    }
  }

  final Map<String, List<String>> subPaymentOptions = {
    'Transfer Bank': ['BRI', 'BNI', 'Mandiri', 'BCA'],
    'E-Wallet': ['DANA', 'OVO', 'GoPay', 'ShopeePay'],
    'Kartu Kredit': ['Visa', 'MasterCard', 'JCB'], // Tambahkan sub-list untuk kartu kredit
  };

  Future<void> _saveTransaction() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final items = widget.cartItems.isNotEmpty ? widget.cartItems : _cartItems;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk melakukan transaksi.')),
      );
      return;
    }

    try {
      // Simpan transaksi ke tabel `transactions`
      final transactionResponse = await supabase.from('transactions').insert({
        'user_id': user.id, // Pastikan menggunakan user.id dari Supabase Auth
        'total': items.fold<double>(
          0,
          (sum, item) => sum + ((item['price'] ?? 0) * (item['qty'] ?? 1)),
        ),
        'status': 'Berhasil',
        'address': _addressController.text, // Simpan alamat
        'payment_method': selectedPaymentMethod, // Simpan metode pembayaran
        'payment_detail': selectedSubPaymentMethod, // Simpan detail metode (opsional)
      }).select().single();

      if (transactionResponse == null || transactionResponse['id'] == null) {
        throw Exception('Gagal menyimpan transaksi. ID transaksi tidak ditemukan.');
      }

      final transactionId = transactionResponse['id'];

      // Simpan detail produk ke tabel `transaction_items`
      for (var item in items) {
        await supabase.from('transaction_items').insert({
          'transaction_id': transactionId,
          'product_id': item['id'],
          'quantity': item['qty'] ?? 0,
          'price': item['price'] ?? 0,
        });

        // Ambil stok produk saat ini dari database
        final productResponse = await supabase
            .from('products')
            .select('stock')
            .eq('id', item['id'])
            .single();

        if (productResponse == null || productResponse['stock'] == null) {
          throw Exception('Produk tidak ditemukan atau stok tidak valid.');
        }

        final currentStock = productResponse['stock'] as int;

        // Kurangi stok produk berdasarkan kuantitas yang dibeli
        final updatedStock = currentStock - (item['qty'] ?? 0);

        if (updatedStock < 0) {
          throw Exception('Stok tidak mencukupi untuk produk: ${item['name']}');
        }

        // Update stok produk di database
        await supabase.from('products').update({
          'stock': updatedStock,
          if (updatedStock == 0) 'description': 'Produk Habis', // Tambahkan keterangan jika stok 0
        }).eq('id', item['id']);
      }

      await _cartService.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _loadingCart = true;
    });
    try {
      final rows = await _cartService.fetchCartItems();
      setState(() {
        _cartItems = rows
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat keranjang: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingCart = false;
        });
      }
    }
  }

  // Fungsi untuk memformat angka menjadi format harga
  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CART ITEMS (prop): ${widget.cartItems}');
    debugPrint('CART ITEMS (fetched): $_cartItems');
    final sourceItems = widget.cartItems.isNotEmpty ? widget.cartItems : _cartItems;

    final totalPrice = sourceItems.fold<double>(
      0,
      (sum, item) => sum + ((item['price'] ?? 0) * (item['qty'] ?? 1)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CheckoutStep(icon: Icons.location_on, label: 'Alamat', isActive: true),
                _CheckoutStep(icon: Icons.payment, label: 'Pembayaran', isActive: true),
                _CheckoutStep(icon: Icons.check_circle, label: 'Review', isActive: true),
              ],
            ),
            const SizedBox(height: 16),
            // Alamat Pengiriman
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan alamat lengkap Anda',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metode Pembayaran
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethod,
                      items: [
                        'Transfer Bank',
                        'Kartu Kredit',
                        'E-Wallet',
                        'COD (Bayar di Tempat)',
                      ]
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value;
                          selectedSubPaymentMethod = null; // Reset sub-payment
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pilih metode pembayaran',
                      ),
                    ),
                    if (selectedPaymentMethod != null &&
                        subPaymentOptions.containsKey(selectedPaymentMethod))
                      const SizedBox(height: 16),
                    if (selectedPaymentMethod != null &&
                        subPaymentOptions.containsKey(selectedPaymentMethod))
                      DropdownButtonFormField<String>(
                        value: selectedSubPaymentMethod,
                        items: subPaymentOptions[selectedPaymentMethod]!
                            .map((subMethod) => DropdownMenuItem(
                                  value: subMethod,
                                  child: Text(subMethod),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubPaymentMethod = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Pilih detail metode pembayaran',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ringkasan Belanja
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Belanja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loadingCart)
                      const Center(child: CircularProgressIndicator())
                    else if (sourceItems.isEmpty)
                      const Text(
                        'Keranjang kosong.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          // Max tinggi list agar tidak melar, tampilkan hingga 3 item lalu scroll kecil.
                          maxHeight: min(300, 88.0 * sourceItems.length + 16),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          itemCount: sourceItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 12, thickness: 0.6),
                          itemBuilder: (context, index) {
                            final item = sourceItems[index];
                            final product = item['product'] as Map<String, dynamic>?;
                            final name = item['name'] ?? product?['name'] ?? '-';
                            final imageUrl = item['image_url'] ?? product?['image_url'];
                            final price = (item['price'] as num?)?.toDouble() ?? 0;
                            final qty = (item['qty'] as num?)?.toInt() ?? 1;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 52,
                                          height: 52,
                                          color: const Color(0xFFF0E4D7),
                                          child: const Icon(Icons.broken_image, color: Color(0xFF5D4037)),
                                        ),
                                      )
                                    : Container(
                                        width: 52,
                                        height: 52,
                                        color: const Color(0xFFF0E4D7),
                                        child: const Icon(Icons.shopping_bag, color: Color(0xFF5D4037)),
                                      ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('${formatCurrency(price)} x $qty'),
                              trailing: Text(
                                formatCurrency(price * qty),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          formatCurrency(totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Harga belum termasuk ongkir. Estimasi pengiriman 2-4 hari kerja.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Bayar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_addressController.text.isEmpty ||
                      selectedPaymentMethod == null ||
                      (subPaymentOptions.containsKey(selectedPaymentMethod) &&
                          selectedSubPaymentMethod == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap lengkapi semua data')),
                    );
                    return;
                  }

                  await _saveTransaction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text('Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _CheckoutStep({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF5D4037);
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? activeColor : Colors.grey.shade300,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
