import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; // Tambahkan ini
import 'product/add_product_screen.dart';
import 'product/manage_product_screen.dart';
import 'user/manage_user_screen.dart';
import 'transaction/manage_transaction_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: const SafeArea(
        child: AdminDashboardContent(),
      ),
    );
  }
}

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  Future<List<Map<String, dynamic>>> _fetchSalesStats() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('transactions')
          .select('created_at, total');
      // print response untuk debug
      print('Supabase response: $response');
      final Map<String, double> dateTotals = {};
      for (final row in response) {
        try {
          // Gunakan UTC agar tanggal tidak bergeser
          final date = DateTime.parse(row['created_at']); // Hapus .toLocal()
          final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final total = (row['total'] ?? 0).toDouble();
          dateTotals[dateStr] = (dateTotals[dateStr] ?? 0) + total;
        } catch (e) {
          print('Error parsing row: $row, error: $e');
        }
      }
      final sorted = dateTotals.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return sorted.map((e) => {'date': e.key, 'total': e.value}).toList();
    } catch (e) {
      print('Fetch sales stats error: $e');
      throw Exception('Gagal memuat data user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.directions_bike, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Selamat Datang, Admin!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GridView untuk fitur
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                  context,
                  title: 'Tambah Produk',
                  icon: Icons.pedal_bike,
                  color: const Color(0xFF5D4037),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  title: 'Kelola Produk',
                  icon: Icons.inventory_2,
                  color: const Color(0xFF8D6E63),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageProductScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Card Laporan Transaksi panjang di bawah grid
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageTransactionScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF5D4037).withOpacity(0.08),
                        radius: 32,
                        child: const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF5D4037),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Laporan Transaksi',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242), // Warna teks abu-abu gelap
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Statistik Penjualan
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Statistik Penjualan (Bar Chart)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchSalesStats(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Gagal memuat statistik'));
                          }
                          final data = snapshot.data ?? [];
                          if (data.isEmpty) {
                            return const Center(child: Text('Belum ada data penjualan'));
                          }
                          // Batasi max 7 bar terakhir
                          final lastData = data.length > 7 ? data.sublist(data.length - 7) : data;
                          return BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.start,
                              maxY: lastData.map((e) => e['total'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= lastData.length) return const SizedBox();
                                      final date = lastData[idx]['date'] as String;
                                      // Tampilkan hanya tanggal (dd/MM)
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          date.substring(8, 10) + '/' + date.substring(5, 7),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(lastData.length, (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (lastData[i]['total'] as double),
                                      color: const Color(0xFF5D4037),
                                      borderRadius: BorderRadius.circular(6),
                                      width: 18,
                                    ),
                                  ],
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 30,
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242), // Warna teks abu-abu gelap
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}