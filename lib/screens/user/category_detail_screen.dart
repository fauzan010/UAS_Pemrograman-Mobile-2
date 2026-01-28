import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini
import '../../widgets/bottom_navbar.dart';
import 'marketplace_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final ScrollController scrollController = ScrollController();

  final Map<String, dynamic> categories = {
    'Mountain Bike': {
      'icon': Icons.terrain,
      'title': 'Sepeda Gunung',
      'description':
          'Sepeda gunung dirancang untuk medan berat seperti tanah, bebatuan, dan jalur pegunungan. Ciri khasnya ada pada rangka yang kuat, ban tebal dengan grip kasar, serta sistem suspensi yang membantu meredam guncangan saat melewati jalan tidak rata. Sepeda ini cocok untuk pengguna yang suka tantangan, petualangan alam, dan aktivitas outdoor.',
    },
    'Road Bike': {
      'icon': Icons.directions_bike,
      'title': 'Sepeda Balap',
      'description':
          'Sepeda balap dirancang untuk kecepatan dan efisiensi di jalan beraspal. Bobotnya ringan, bannya tipis, dan posisi berkendaranya lebih condong ke depan untuk mengurangi hambatan angin.',
    },
    'Folding Bike': {
      'icon': Icons.luggage,
      'title': 'Sepeda Lipat',
      'description':
          'Sepeda lipat adalah solusi praktis bagi pengguna perkotaan. Sepeda ini dapat dilipat sehingga mudah dibawa ke transportasi umum, disimpan di kantor, atau di rumah dengan ruang terbatas.',
    },
    'Kids Bike': {
      'icon': Icons.child_care,
      'title': 'Sepeda Anak',
      'description':
          'Sepeda anak dirancang khusus dengan memperhatikan keamanan dan kenyamanan anak. Ukurannya disesuaikan dengan tinggi badan, dilengkapi roda bantu, dan desain yang menarik agar anak lebih semangat bersepeda.',
    },
    'Accessories': {
      'icon': Icons.build,
      'title': 'Aksesoris',
      'description':
          'Aksesoris sepeda berperan penting dalam meningkatkan keamanan, kenyamanan, dan pengalaman berkendara. Beberapa aksesoris umum meliputi helm, lampu, sarung tangan, botol minum, pompa, dan kunci pengaman.',
    },
  };

  // Mapping label kategori ke nama kategori marketplace/database
  String? _getMarketplaceCategory(String label) {
    switch (label) {
      case 'Sepeda Gunung':
        return 'Sepeda Gunung';
      case 'Sepeda Balap':
        return 'Sepeda Balap';
      case 'Sepeda Lipat':
        return 'Sepeda Lipat';
      case 'Sepeda Anak':
        return 'Sepeda Anak';
      case 'Aksesoris': // Pastikan ini sama dengan di database
        return 'Aksesoris';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _getCategoryIndex(widget.category);
      if (index != -1) {
        scrollController.animateTo(
          index * 200.0, // Perkiraan tinggi setiap kategori
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  int _getCategoryIndex(String label) {
    // Map label dari home_screen ke key di sini
    switch (label) {
      case 'Sepeda Gunung':
        return categories.keys.toList().indexOf('Mountain Bike');
      case 'Sepeda Balap':
        return categories.keys.toList().indexOf('Road Bike');
      case 'Sepeda Lipat':
        return categories.keys.toList().indexOf('Folding Bike');
      case 'Sepeda Anak':
        return categories.keys.toList().indexOf('Kids Bike');
      case 'Aksesoris':
        return categories.keys.toList().indexOf('Accessories');
      default:
        return categories.keys.toList().indexOf(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F7FB),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Detail Kategori',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.entries.map((entry) {
              final data = entry.value;
              const color = Color(0xFF5D4037);
              // Dapatkan label kategori marketplace dari data['title']
              final marketplaceCategory = _getMarketplaceCategory(data['title']);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFE8F5E9),
                          child: Icon(data['icon'], color: color, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['description'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF424242),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MarketplaceScreen(
                                        initialCategory: marketplaceCategory,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Belanja Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 0), // Tambahkan navbar
      ),
    );
  }
}
