import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart'; // Import halaman riwayat pemesanan
import 'ride_tracking_screen.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Anda akan logout. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result == true) {
      Provider.of<AuthProvider>(context, listen: false).logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser ?? {};

    final bool hasName = (user['name'] ?? '').toString().trim().isNotEmpty;
    final bool hasEmail = (user['email'] ?? '').toString().trim().isNotEmpty;
    final bool hasPhoto = (user['photo_url'] ?? '').toString().trim().isNotEmpty;
    int completedSteps = 0;
    if (hasName) completedSteps++;
    if (hasEmail) completedSteps++;
    if (hasPhoto) completedSteps++;
    const int totalSteps = 3;
    final double profileProgress = completedSteps / totalSteps;
    String profileStatusText;
    if (profileProgress >= 1.0) {
      profileStatusText = 'Profil lengkap, siap gowes!';
    } else if (profileProgress >= 0.67) {
      profileStatusText = 'Hampir lengkap, lengkapi sedikit lagi.';
    } else {
      profileStatusText = 'Lengkapi profil agar pengalaman belanja lebih nyaman.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient di atas
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Baris atas: avatar, nama/email, tombol edit
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'profile-avatar',
                          child: Material(
                            color: Colors.transparent,
                            child: CircleAvatar(
                              radius: 36,
                                backgroundColor: Color(0xFFF0E4D7),
                              backgroundImage: user['photo_url'] != null
                                  ? NetworkImage(user['photo_url'])
                                  : null,
                              child: user['photo_url'] == null
                                  ? const Icon(Icons.person, size: 44, color: Color(0xFF5D4037))
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5D4037).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.terrain, size: 14, color: Color(0xFF5D4037)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Mountain Rider',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF5D4037),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Akun WorldBike",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user['email'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              // Refresh tampilan jika perlu
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profil diperbarui!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit, size: 24, color: Color(0xFF5D4037)),
                          
                          tooltip: 'Edit Profil',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress profil sederhana
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress Profil',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            Text(
                              '${(profileProgress * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: profileProgress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: const Color(0xFF8D6E63).withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5D4037)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profileStatusText,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 0,
                ),
                const SizedBox(height: 8),
                // Tambahkan ilustrasi/icon di atas fitur-fitur
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(Icons.verified_user, size: 48, color: Color(0xFF5D4037)),
                      
                      const SizedBox(height: 4),
                      Text(
                        "Kelola akun dan fitur aplikasi",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Fitur-fitur lain
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.history, color: Color(0xFF5D4037)),
                            title: const Text('Riwayat Pemesanan'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.directions_bike, color: Color(0xFF5D4037)),
                            title: const Text('Riwayat Bersepeda'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RideTrackingScreen()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline, color: Color(0xFF5D4037)),
                            title: const Text('Tentang Aplikasi'),
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'WorldBike',
                                applicationVersion: '1.0.0',
                                applicationIcon: const Icon(Icons.directions_bike, color: Color(0xFF5D4037)),
                                children: [
                                  const Text('Aplikasi marketplace sepeda dan aksesoris.\nDibuat dengan Flutter & Supabase.'),
                                ],
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.help_outline, color: Color(0xFF5D4037)),
                            title: const Text('Bantuan & Kontak'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Kontak Admin'),
                                  content: const Text('WhatsApp: 0897819571\nEmail: admin@worldbike.com'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}
