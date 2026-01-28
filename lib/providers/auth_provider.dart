import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? get currentUser => _currentUser;

  // REGISTER menggunakan Supabase Auth
  Future<String?> register(String name, String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (res.user != null) {
        _currentUser = {
          'id': res.user!.id,
          'email': res.user!.email,
          'name': name,
          'role': 'user', // Default role user
        };
        notifyListeners();
        return null;
      } else {
        return "Failed to register.";
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN menggunakan Supabase Auth
  Future<String?> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        String role = 'user';
        if (res.user!.email == 'admin@worldbike.com') {
          role = 'admin';
        }
        _currentUser = {
          'id': res.user!.id,
          'email': res.user!.email,
          'name': res.user!.userMetadata?['name'] ?? 'User',
          'photo_url': res.user!.userMetadata?['photo_url'] ?? null,
          'role': role,
        };
        print('LOGIN SUCCESS: $_currentUser');
        notifyListeners();
        return null;
      } else {
        return "Email atau password salah.";
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Gagal login: ${e.toString()}";
    }
  }

  void logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Tambahkan method untuk refresh user dari Supabase Auth
  Future<void> refreshCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _currentUser = {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'] ?? 'User',
        'photo_url': user.userMetadata?['photo_url'] ?? null,
        'role': user.email == 'admin@worldbike.com' ? 'admin' : 'user',
      };
      print('REFRESH USER: $_currentUser');
      notifyListeners();
    }
  }
}