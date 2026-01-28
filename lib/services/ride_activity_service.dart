import 'package:supabase_flutter/supabase_flutter.dart';

class RideActivityService {
  RideActivityService() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>> addRideActivity({
    required double distanceKm,
    required double durationMinutes,
    required double calories,
    required double weightKg,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login.');
    }

    final data = {
      'user_id': user.id,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'calories': calories,
      'weight_kg': weightKg,
    };

    final response = await _supabase.from('ride_activities').insert(data).select().single();
    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchRideActivities() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login.');
    }

    final response = await _supabase
        .from('ride_activities')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
