import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController descC = TextEditingController();
  final TextEditingController priceC = TextEditingController();
  final TextEditingController stockC = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();
  String? selectedCategory;

  @override
  void dispose() {
    nameC.dispose();
    descC.dispose();
    priceC.dispose();
    stockC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Tambah Produk',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF5F2EC),
        child: Center(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Tambah Produk Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: nameC,
                          decoration: InputDecoration(
                            labelText: 'Nama Produk',
                            prefixIcon: const Icon(Icons.label, color: Color(0xFF5D4037)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: const [
                            'Sepeda Gunung',
                            'Sepeda Lipat',
                            'Sepeda Balap',
                            'Sepeda Anak',
                            'Aksesoris',
                          ]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => selectedCategory = v),
                          validator: (v) => v == null ? 'Pilih kategori' : null,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: const Icon(Icons.category, color: Color(0xFF5D4037)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: descC,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi',
                            prefixIcon: const Icon(Icons.description, color: Color(0xFF5D4037)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: priceC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga',
                            prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF5D4037)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Angka' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: stockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stok',
                            prefixIcon: const Icon(Icons.inventory, color: Color(0xFF5D4037)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) =>
                            int.tryParse(v ?? '') == null ? 'Angka' : null,
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E4D7),
                              border: Border.all(color: Color(0xFF5D4037).withOpacity(0.2), width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _imageBytes == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.image_outlined, size: 40, color: Color(0xFF5D4037)),
                                      SizedBox(height: 8),
                                      Text('Pilih Gambar', style: TextStyle(color: Color(0xFF78909C))),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 150,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              if (_selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pilih gambar')),
                                );
                                return;
                              }

                              final data = {
                                'name': nameC.text,
                                'category': selectedCategory,
                                'description': descC.text,
                                'price': double.parse(priceC.text),
                                'stock': int.parse(stockC.text),
                              };

                              await Provider.of<ProductProvider>(
                                context,
                                listen: false,
                              ).addProduct(data, _selectedImage!);

                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Tambah Produk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Pastikan warna teks putih
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D4037),
                              foregroundColor: Colors.white, // Pastikan semua teks/ikon putih
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
