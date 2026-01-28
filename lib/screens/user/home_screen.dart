import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini
import 'category_detail_screen.dart'; // Tambahkan ini
import 'ride_tracking_screen.dart';
import '../../widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('HOME SCREEN BUILD');
    return Container(
      color: const Color(0xFFF4F7FB),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Supaya warna Container terlihat
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Beranda',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(), // Hero Section
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRideTrackingCard(context),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(context), // Tambahkan context di sini
                    const SizedBox(height: 16),
                    _buildBenefitsGrid(), // Grid untuk Benefits of Cycling
                    const SizedBox(height: 16),
                    _buildMaintenanceTimeline(), // Step Timeline untuk Maintenance
                    const SizedBox(height: 16),
                    _buildSafetyTips(), // Icon List untuk Safety Tips
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 0), // Navbar dengan index 0 untuk Home
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF8D6E63)], // gradasi coklat seperti tanah/batu
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'WORLD BIKE',
            style: GoogleFonts.orbitron(
              textStyle: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Icon(
            Icons.directions_bike,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Jelajah dunia dengan sepeda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belajar, berpetualang, dan nikmati kebebasan di atas roda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideTrackingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes, color: Color(0xFF5D4037), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Aktivitas Bersepeda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tracking jarak, durasi, dan estimasi kalori secara praktis.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF616161), height: 1.4),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RideTrackingScreen()),
              );
            },
            child: const Text(
              'Mulai',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      {'icon': Icons.terrain, 'label': 'Sepeda Gunung'},
      {'icon': Icons.directions_bike, 'label': 'Sepeda Balap'},
      {'icon': Icons.luggage, 'label': 'Sepeda Lipat'},
      {'icon': Icons.child_care, 'label': 'Sepeda Anak'},
      {'icon': Icons.build, 'label': 'Aksesoris'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242), // Dark gray text
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Tinggi untuk horizontal scroll
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(
                context: context,
                icon: category['icon'] as IconData,
                label: category['label'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        // Pastikan parameter 'category' dikirim dengan benar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(category: label),
          ),
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1B5E20).withOpacity(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Icon(icon, size: 40, color: Color(0xFF5D4037)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    final benefits = [
      {
        'icon': Icons.favorite,
        'label': 'kesehatan Jantung',
        'subtitle': 'Menyehatkan',
        'description': 'Menjaga kesehatan jantung dan sirkulasi darah',
        'color': const Color(0xFF5D4037),
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Menguatkan Otot',
        'subtitle': 'Membangun daya tahan',
        'description': 'Memperkuat otot kaki dan tubuh',
        'color': const Color(0xFF5D4037),
      },
      {
        'icon': Icons.psychology,
        'label': 'Kesehatan Mental',
        'subtitle': 'Meredakan stres',
        'description': 'Mengurangi stres dan meningkatkan mood',
        'color': const Color(0xFF5D4037),
      },
      {
        'icon': Icons.eco,
        'label': 'Ramah Lingkungan',
        'subtitle': 'Nol emisi',
        'description': 'Ramah lingkungan tanpa polusi',
        'color': const Color(0xFF5D4037),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manfaat Bersepeda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242), // Dark gray text
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            final benefit = benefits[index];
            return _buildBenefitCard(
              icon: benefit['icon'] as IconData,
              label: benefit['label'] as String,
              subtitle: benefit['subtitle'] as String,
              description: benefit['description'] as String,
              color: benefit['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF5D4037)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14, 
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), 
          Text(
            description,
            style: const TextStyle(
              fontSize: 13, 
              color: Color(0xFF616161), 
              height: 1.4, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTimeline() {
    final steps = [
      {
        'icon': Icons.search,
        'label': 'Cek Tekanan Ban',
        'description': 'Periksa tekanan ban secara rutin untuk memastikan kenyamanan dan keamanan.',
      },
      {
        'icon': Icons.oil_barrel,
        'label': 'Lumasi Rantai',
        'description': 'Lumasi rantai sepeda untuk mencegah karat dan menjaga kelancaran.',
      },
      {
        'icon': Icons.stop_circle,
        'label': 'Periksa Rem',
        'description': 'Periksa rem untuk memastikan berfungsi dengan baik.',
      },
      {
        'icon': Icons.cleaning_services,
        'label': 'Bersihkan Sepeda',
        'description': 'Bersihkan sepeda secara berkala untuk menghilangkan kotoran dan debu.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perawatan Dasar Sepeda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242), 
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            return _buildStepItem(
              stepNumber: index + 1,
              icon: step['icon'] as IconData,
              label: step['label'] as String,
              description: step['description'] as String,
              isLast: index == steps.length - 1,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required IconData icon,
    required String label,
    required String description,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Step number and icon
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE8F5E9), 
              child: Icon(icon, color: const Color(0xFF5D4037)), 
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: const Color(0xFFE8F5E9), 
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step $stepNumber: $label',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242), 
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF616161), 
                  height: 1.4, 
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTips() {
    final tips = [
      {
        'icon': Icons.military_tech,
        'label': 'Menggunakan Helm',
        'description': 'Lindungi kepala Anda setiap saat',
      },
      {
        'icon': Icons.lightbulb,
        'label': 'Terlihat',
        'description': 'Gunakan lampu saat malam hari',
      },
      {
        'icon': Icons.traffic,
        'label': 'Ikuti Aturan',
        'description': 'Patuhi rambu lalu lintas',
      },
      {
        'icon': Icons.visibility,
        'label': 'Tetap Waspada',
        'description': 'Hindari gangguan saat berkendara',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips Keselamatan Berkendara',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242), 
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: tips.map((tip) {
            return _buildSafetyTipItem(
              icon: tip['icon'] as IconData,
              label: tip['label'] as String,
              description: tip['description'] as String,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSafetyTipItem({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F5E9), 
            child: Icon(icon, color: const Color(0xFF5D4037), size: 28), 
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242), // Dark gray text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161), // Medium gray text
                    height: 1.4, // Line height for better readability
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: Icon(icon, color: const Color(0xFF5D4037)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242), // Dark gray text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161), // Medium gray text
              ),
            ),
          ],
        ),
      ),
    );
  }
}