import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // Fungsi untuk memformat angka menjadi format harga
  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  Future<List<Map<String, dynamic>>> _fetchOrderHistory(String userId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('transactions')
          .select('''
            id, 
            total, 
            status, 
            created_at, 
            address,
            payment_method,
            payment_detail,
            transaction_items:transaction_items!fk_transaction_items_transaction(
              quantity, 
              price, 
              products(name, image_url)
            )
          ''')
          .order('created_at', ascending: false); // Urutkan berdasarkan waktu transaksi

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat riwayat pemesanan: $e');
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    try {
      final rawItems = order['transaction_items'] as List<dynamic>? ?? [];
      final items = rawItems.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      final status = (order['status'] ?? '').toString();
      final bool isSuccess = status.toLowerCase() == 'berhasil';
      final Color statusColor = isSuccess ? const Color(0xFF5D4037) : Colors.red;
      final String orderId = (order['id'] ?? '').toString();
      final DateTime? createdAt = DateTime.tryParse(order['created_at']?.toString() ?? '');

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan #$orderId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      isSuccess ? Icons.check_circle : Icons.error_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(status),
                    backgroundColor: statusColor,
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order['address'] != null && order['address'].toString().isNotEmpty)
                Text(
                  'Alamat: ${order['address']}',
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
              if (order['payment_method'] != null)
                Text(
                  'Metode Pembayaran: ${order['payment_method']}'
                  '${order['payment_detail'] != null ? ' (${order['payment_detail']})' : ''}',
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
              const SizedBox(height: 8),
              ...items.map((item) {
                final product = item['products'];
                return Row(
                  children: [
                    if (product != null && product['image_url'] != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          product['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 24),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        '${item['quantity']}x ${product?['name'] ?? 'Produk tidak ditemukan'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 8),
              Text(
                'Total: ${formatCurrency(order['total'])}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 8),
              if (createdAt != null)
                Text(
                  'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(createdAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Order card error: $e\n$st');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text('Gagal menampilkan pesanan: $e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      appBar: AppBar(
        title: Text(
          'Riwayat Pemesanan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Silakan login untuk melihat riwayat pemesanan.'))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchOrderHistory(user.id), // Kirim user.id ke fungsi
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat pemesanan.'));
                }
                final totalOrders = orders.length;
                final successOrders =
                    orders.where((o) => (o['status'] ?? '').toString().toLowerCase() == 'berhasil').length;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.receipt_long, color: Color(0xFF5D4037)),
                                  const SizedBox(height: 4),
                                  Text('$totalOrders',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('Total Pesanan', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.teal),
                                  const SizedBox(height: 4),
                                  Text('$successOrders',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('Berhasil', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}
