import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class ManageTransactionScreen extends StatelessWidget {
  const ManageTransactionScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('transactions')
          .select('id, total, status, created_at')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat transaksi: $e');
    }
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Transaksi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5D4037),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final status = (transaction['status'] ?? '').toString();
              final bool isSuccess = status.toLowerCase() == 'berhasil';
              final Color statusColor =
                  isSuccess ? const Color(0xFF5D4037) : Colors.red;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF0E4D7),
                    child: Icon(
                      Icons.receipt_long,
                      color: statusColor,
                    ),
                  ),
                  title: Text(
                    'Transaksi #${transaction['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ${formatCurrency(transaction['total']?.toDouble() ?? 0)}'),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Chip(
                            label: Text(status),
                            backgroundColor: statusColor,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(transaction['created_at']))}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
