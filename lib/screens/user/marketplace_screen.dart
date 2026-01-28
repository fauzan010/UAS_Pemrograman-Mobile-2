import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_navbar.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';
import 'package:intl/intl.dart'; // Import untuk format angka
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class MarketplaceScreen extends StatefulWidget {
  final String? initialCategory;
  const MarketplaceScreen({super.key, this.initialCategory});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String searchQuery = '';
  String? selectedCategory;
  double? minPrice;
  double? maxPrice;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final List<String> staticCategories = [
    'Sepeda Gunung',
    'Sepeda Balap',
    'Sepeda Lipat',
    'Sepeda Anak',
    'Aksesoris',
  ];

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  void _showBuyBottomSheet(Map<String, dynamic> product) {
    int qty = 1;
    final int stock = product['stock'] ?? 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product['image_url'] != null
                            ? Image.network(
                                product['image_url'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, size: 40),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 40),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1565C0),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Stok: $stock",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(product['price']?.toDouble() ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: qty > 1
                            ? () => setModalState(() => qty--)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF1565C0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$qty',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5D4037)),
                        onPressed: qty < stock
                            ? () => setModalState(() => qty++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: stock > 0
                          ? () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    cartItems: [
                                      {
                                        ...product,
                                        'qty': qty,
                                      }
                                    ],
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Beli'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).loadProducts());
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    return products.where((product) {
      final nameMatch = product['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final productCategory = (product['category'] ?? '').toString().trim().toLowerCase();
      final selectedCategoryTrimmed = (selectedCategory ?? '').trim().toLowerCase();
      final categoryMatch = selectedCategory == null
          ? true
          : (productCategory.isNotEmpty && productCategory == selectedCategoryTrimmed);
      final price = (product['price'] is int)
          ? (product['price'] as int).toDouble()
          : (product['price'] is double)
              ? product['price'] as double
              : 0.0;
      final minMatch = minPrice == null || price >= minPrice!;
      final maxMatch = maxPrice == null || price <= maxPrice!;
      return nameMatch && categoryMatch && minMatch && maxMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = staticCategories;
    final filteredProducts = _filterProducts(productProvider.products);

    if (selectedCategory != null &&
        !categories.map((e) => e.toLowerCase()).contains(selectedCategory?.toLowerCase())) {
      selectedCategory = null;
    }

    return Container(
      color: const Color(0xFFF4F7FB),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Marketplace Sepeda',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : productProvider.products.isEmpty
                ? const Center(child: Text('Belum ada produk tersedia.'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.pedal_bike, color: Color(0xFF5D4037)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Temukan sepeda dan aksesoris terbaik untuk perjalananmu.',
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Cari produk...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                              ),
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                underline: const SizedBox(),
                                hint: const Text('Kategori'),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Semua'),
                                  ),
                                  ...categories.map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Harga Min',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    minPrice = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _maxPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Harga Max',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    maxPrice = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? const Center(child: Text('Produk tidak ditemukan.'))
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.5,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    final stock = product['stock'] ?? 0;
                                    return Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            child: product['image_url'] != null
                                                ? Image.network(
                                                    product['image_url'],
                                                    height: 120,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      height: 120,
                                                      color: Colors.grey[200],
                                                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 120,
                                                    color: Colors.grey[200],
                                                    child: const Center(child: Icon(Icons.image, size: 40)),
                                                  ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'] ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1565C0),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    product['category'] ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  formatCurrency(product['price']?.toDouble() ?? 0),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5D4037),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  product['description'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF616161),
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.shopping_cart,
                                                        color: Color(0xFF5D4037),
                                                      ),
                                                      onPressed: stock > 0
                                                          ? () async {
                                                              try {
                                                                await Provider.of<CartProvider>(context, listen: false)
                                                                    .addToCart(product);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text('Produk dimasukkan ke keranjang'),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text('Gagal menambah ke keranjang: $e'),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: const Color(0xFF5D4037),
                                                          side: const BorderSide(color: Color(0xFF5D4037)),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                        ),
                                                        onPressed: stock > 0
                                                            ? () {
                                                                _showBuyBottomSheet(product);
                                                              }
                                                            : null,
                                                        child: stock > 0
                                                            ? const Text('Beli')
                                                            : const Text('Habis', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }
}
