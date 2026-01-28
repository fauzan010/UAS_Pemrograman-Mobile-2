import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC, descC, priceC, stockC, imageC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.product['name']);
    descC = TextEditingController(text: widget.product['description']);
    priceC = TextEditingController(text: widget.product['price'].toString());
    stockC = TextEditingController(text: widget.product['stock'].toString());
    imageC = TextEditingController(text: widget.product['image_url']);
  }

  @override
  void dispose() {
    nameC.dispose();
    descC.dispose();
    priceC.dispose();
    stockC.dispose();
    imageC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: descC,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              TextFormField(
                controller: priceC,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (double.tryParse(v) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              TextFormField(
                controller: stockC,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              TextFormField(
                controller: imageC,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !Uri.parse(v).isAbsolute) {
                    return 'URL tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'name': nameC.text,
                      'description': descC.text,
                      'price': double.tryParse(priceC.text) ?? 0,
                      'stock': int.tryParse(stockC.text) ?? 0, // Perbarui stok
                      'image_url': imageC.text,
                    };
                    try {
                      await Provider.of<ProductProvider>(context, listen: false)
                          .updateProduct(widget.product['id'], data); // Panggil updateProduct
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produk berhasil diperbarui!')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui produk: $e')),
                      );
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
