import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? photoUrl;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    name = user?['name'] ?? '';
    email = user?['email'] ?? '';
    photoUrl = user?['photo_url'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadProfileImage(XFile image) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return null;
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await image.readAsBytes();
      await supabase.storage.from('profile-images').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      return supabase.storage.from('profile-images').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;
      String? uploadedUrl = photoUrl;
      if (_selectedImage != null) {
        uploadedUrl = await _uploadProfileImage(_selectedImage!);
        if (uploadedUrl == null) {
          throw Exception('Gagal upload foto profil');
        }
      }
      await supabase.auth.updateUser(UserAttributes(
        data: {
          'name': name,
          if (uploadedUrl != null) 'photo_url': uploadedUrl,
        },
      ));
      // Update provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshCurrentUser(); // Segarkan data user di provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update profil: $e')),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final joinDate = user?['created_at'] != null
        ? DateTime.tryParse(user!['created_at']) ?? null
        : null;

    return Container(
      color: const Color(0xFFF5F2EC),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Edit Profil',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFF0E4D7),
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!)
                            : (user?['photo_url'] != null
                                ? NetworkImage(user!['photo_url'])
                                : null),
                        child: (_imageBytes == null && (user?['photo_url'] == null))
                            ? const Icon(Icons.person, size: 50, color: Color(0xFF5D4037))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF5D4037), width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.camera_alt, size: 22, color: Color(0xFF5D4037)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Perubahan foto dan nama akan tersimpan setelah menekan "Simpan Perubahan".',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (v) => name = v,
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                if (joinDate != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF5D4037)),
                    title: Text(
                      'Bergabung sejak',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    subtitle: Text(
                      '${joinDate.day}/${joinDate.month}/${joinDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
