import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/ride_activity_service.dart';

class RideEntry {
  RideEntry({
    required this.distanceKm,
    required this.durationMinutes,
    required this.calories,
    required this.weightKg,
    required this.createdAt,
  });

  final double distanceKm;
  final double durationMinutes;
  final double calories;
  final double weightKg;
  final DateTime createdAt;
}

class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(text: '70');

  final RideActivityService _rideService = RideActivityService();
  final List<RideEntry> _history = [];
  bool _loadingHistory = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _calculateCalories({required double distanceKm, required double durationMinutes, required double weightKg}) {
    final double durationHours = durationMinutes / 60.0;
    // Perkiraan kecepatan rata-rata (km/jam) untuk menentukan intensitas.
    final double speed = durationHours > 0 ? distanceKm / durationHours : 0;
    double met;
    if (speed < 16) {
      met = 6.0; // pelan
    } else if (speed < 20) {
      met = 8.0; // sedang
    } else if (speed < 25) {
      met = 10.0; // cepat
    } else {
      met = 12.0; // sangat cepat
    }
    // Rumus kalori (kcal) berdasarkan MET.
    final double calories = met * 3.5 * weightKg / 200.0 * durationMinutes;
    return calories;
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingHistory = true;
    });

    try {
      final rows = await _rideService.fetchRideActivities();
      final mapped = rows.map(_mapToEntry).toList();
      setState(() {
        _history
          ..clear()
          ..addAll(mapped);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  RideEntry _mapToEntry(Map<String, dynamic> row) {
    final DateTime created = row['created_at'] != null
        ? DateTime.parse(row['created_at'])
        : DateTime.now();
    return RideEntry(
      distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0,
      durationMinutes: (row['duration_minutes'] as num?)?.toDouble() ?? 0,
      calories: (row['calories'] as num?)?.toDouble() ?? 0,
      weightKg: (row['weight_kg'] as num?)?.toDouble() ?? 0,
      createdAt: _toJakartaTime(created),
    );
  }

  DateTime _toJakartaTime(DateTime dt) {
    return dt.toUtc().add(const Duration(hours: 7));
  }

  Future<void> _handleSave() async {
    final double? distanceKm = double.tryParse(_distanceController.text);
    final double? durationMinutes = double.tryParse(_durationController.text);
    final double? weightKg = double.tryParse(_weightController.text);

    if (distanceKm == null || distanceKm <= 0 || durationMinutes == null || durationMinutes <= 0 || weightKg == null || weightKg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jarak, durasi, dan berat yang valid.')),
      );
      return;
    }

    final double calories = _calculateCalories(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      weightKg: weightKg,
    );

    setState(() {
      _saving = true;
    });

    try {
      await _rideService.addRideActivity(
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        calories: calories,
        weightKg: weightKg,
      );

      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktivitas tersimpan.')),
        );
      }

      _distanceController.clear();
      _durationController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan aktivitas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  double get _totalDistance => _history.fold(0, (sum, e) => sum + e.distanceKm);
  double get _totalCalories => _history.fold(0, (sum, e) => sum + e.calories);
  double get _totalDuration => _history.fold(0, (sum, e) => sum + e.durationMinutes);

  @override
  Widget build(BuildContext context) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern('id_ID');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          'Tracking Bersepeda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(numberFormat),
            const SizedBox(height: 12),
            _buildInputCard(numberFormat),
            const SizedBox(height: 16),
            _buildHistoryList(numberFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat numberFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(label: 'Jarak', value: '${numberFormat.format(_totalDistance)} km'),
              _buildSummaryItem(label: 'Durasi', value: '${numberFormat.format(_totalDuration)} mnt'),
              _buildSummaryItem(label: 'Kalori', value: '${numberFormat.format(_totalCalories)} kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
        ),
      ],
    );
  }

  Widget _buildInputCard(NumberFormat numberFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catat Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(label: 'Jarak (km)', hint: 'misal 12.5'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(label: 'Durasi (menit)', hint: 'misal 45'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(label: 'Berat Badan (kg)', hint: 'default 70'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saving ? null : _handleSave,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Hitung & Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required String hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildHistoryList(NumberFormat numberFormat) {
    if (_loadingHistory) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.08)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.08)),
        ),
        child: const Text(
          'Belum ada aktivitas tersimpan. Mulai catat perjalanan pertamamu!',
          style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Aktivitas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
        ),
        const SizedBox(height: 8),
        ..._history.map((entry) {
          final String dateLabel = DateFormat('dd MMM yyyy, HH:mm').format(entry.createdAt);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bike, color: Color(0xFF5D4037)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF616161))),
                      const SizedBox(height: 6),
                      Text(
                        '${numberFormat.format(entry.distanceKm)} km · ${numberFormat.format(entry.durationMinutes)} mnt',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kalori: ${numberFormat.format(entry.calories)} kcal · Berat: ${numberFormat.format(entry.weightKg)} kg',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
