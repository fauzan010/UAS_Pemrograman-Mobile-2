import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // REGISTER MENGGUNAKAN SUPABASE AUTH
  Future<String?> register(String name, String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // name akan disimpan di user_metadata
      );
      // Tidak ada error property, cek user saja
      if (res.user == null) {
        return "Failed to register.";
      }
      return null; // null artinya sukses
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN MENGGUNAKAN SUPABASE AUTH
  Future<String?> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        return "Email atau password salah.";
      }
      return null; // null artinya sukses
    } catch (e) {
      return e.toString();
    }
  }
}