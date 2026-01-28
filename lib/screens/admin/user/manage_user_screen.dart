import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' as intl;

class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final supabase = Supabase.instance.client;
    try {
      // Ganti 'profiles' dengan nama tabel user Anda di Supabase
      final response = await supabase
          .from('profiles')
          .select('id, email, created_at')
          .order('created_at');
      // response sudah List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat data user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Kelola Pengguna Sepeda'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('Belum ada user.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? '-';
              final joined = user['created_at'] != null
                  ? intl.DateFormat('dd MMM yyyy').format(DateTime.parse(user['created_at']))
                  : '-';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.pedal_bike,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('Bergabung: $joined'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
