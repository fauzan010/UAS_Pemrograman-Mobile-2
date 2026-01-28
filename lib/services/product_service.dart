import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProductService {
  final _supabase = Supabase.instance.client;

  // Upload Image to Supabase Storage
  Future<String> uploadImage(XFile image) async {
    // ✅ WAJIB: pastikan user login
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final fileBytes = await image.readAsBytes();

      // ✅ CARA BENAR upload (tidak cek response)
      await _supabase.storage.from('product-images').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
            ),
          );

      // Ambil public URL
      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Error saat mengunggah gambar: $e');
    }
  }

  // CREATE
  Future<void> addProduct(Map<String, dynamic> data, XFile image) async {
    try {
      print('Mulai mengunggah gambar...');
      final imageUrl = await uploadImage(image);
      print('Gambar berhasil diunggah: $imageUrl');

      data['image_url'] = imageUrl;

      // ✅ SDK v2: insert langsung, error otomatis throw
      await _supabase.from('products').insert(data);

      print('Produk berhasil ditambahkan');
    } catch (e) {
      print('Error addProduct: $e');
      throw Exception(e.toString());
    }
  }

  // READ
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('id, name, category, description, price, stock, image_url') // Pastikan 'category' disertakan
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error saat mengambil produk: $e');
    }
  }

  // UPDATE
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('products').update(data).eq('id', id); // Update produk di database
    } catch (e) {
      throw Exception('Error saat mengupdate produk: $e');
    }
  }

  // DELETE
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error saat menghapus produk: $e');
    }
  }
}
