import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/activity_model.dart';

class ActivityService {
  final SupabaseClient _client = SupabaseConfig.client;

  // In-memory static storage agar logbook baru langsung tersimpan & reaktif
  static final List<ActivityModel> _mockActivities = [
    ActivityModel(
      id: 'act-1',
      pesertaId: 'pes-1',
      lowonganId: 'vac-1',
      tanggal: DateTime(2026, 10, 1),
      judulKegiatan: 'Orientasi & Pengenalan Lingkungan Kerja',
      deskripsiKegiatan: 'Mengenal tim pengembang, kultur kerja perusahaan, setup environment Flutter dan repositori proyek.',
      durasiJam: 8.0,
      statusKegiatan: 'selesai',
      catatanPembimbing: 'Setup berjalan lancar. Terus pertahankan kedisiplinan.',
      namaPeserta: 'Vida Rizki Prasetyo',
      nimPeserta: '25523013',
    ),
    ActivityModel(
      id: 'act-2',
      pesertaId: 'pes-1',
      lowonganId: 'vac-1',
      tanggal: DateTime(2026, 10, 2),
      judulKegiatan: 'Membuat Desain UI & Wireframe Modul Auth',
      deskripsiKegiatan: 'Merancang antarmuka login, registrasi, dan pemilihan role sesuai dengan PRD v1.0.',
      durasiJam: 8.0,
      statusKegiatan: 'selesai',
      catatanPembimbing: 'Desain sangat bersih dan mengikuti Material 3.',
      namaPeserta: 'Vida Rizki Prasetyo',
      nimPeserta: '25523013',
    ),
    ActivityModel(
      id: 'act-3',
      pesertaId: 'pes-1',
      lowonganId: 'vac-1',
      tanggal: DateTime(2026, 10, 3),
      judulKegiatan: 'Implementasi Halaman Login & Integrasi Supabase',
      deskripsiKegiatan: 'Menghubungkan klien Supabase Auth, validasi form, dan penanganan session token pengguna.',
      durasiJam: 7.5,
      statusKegiatan: 'berjalan',
      catatanPembimbing: 'Pastikan validasi email dan pesan error ditampilkan dengan jelas ke pengguna.',
      namaPeserta: 'Vida Rizki Prasetyo',
      nimPeserta: '25523013',
    ),
  ];

  // Catat kegiatan baru oleh peserta
  Future<void> createActivity(ActivityModel activity) async {
    _mockActivities.insert(0, activity);

    try {
      await _client
          .from('kegiatan_magang')
          .insert(activity.toJson())
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('createActivity notice: $e');
    }
  }

  // Mengambil daftar kegiatan milik peserta
  Future<List<ActivityModel>> getMyActivities(String pesertaId) async {
    try {
      final res = await _client
          .from('kegiatan_magang')
          .select('*, peserta:peserta_id(nim, profiles(nama_lengkap))')
          .eq('peserta_id', pesertaId)
          .order('tanggal', ascending: false)
          .timeout(const Duration(seconds: 2));

      final list = (res as List).map((e) => ActivityModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('getMyActivities notice: $e');
    }
    return List.from(_mockActivities);
  }

  // Mengambil semua kegiatan untuk monitoring oleh Admin / Pembimbing Perusahaan
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      final res = await _client
          .from('kegiatan_magang')
          .select('*, peserta:peserta_id(nim, profiles(nama_lengkap))')
          .order('tanggal', ascending: false)
          .timeout(const Duration(seconds: 2));

      final list = (res as List).map((e) => ActivityModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('getAllActivities notice: $e');
    }
    return List.from(_mockActivities);
  }

  // Mendapatkan ringkasan aktivitas dari Edge Function Supabase: generate-logbook-summary
  Future<Map<String, dynamic>> getLogbookSummary(String pesertaId) async {
    try {
      final res = await _client.functions.invoke(
        'generate-logbook-summary',
        body: {'peserta_id': pesertaId},
      ).timeout(const Duration(seconds: 2));

      if (res.status == 200 && res.data != null) {
        final data = res.data;
        if (data is Map<String, dynamic> && data['summary'] != null) {
          return data['summary'];
        }
      }
    } catch (e) {
      debugPrint('getLogbookSummary notice: $e');
    }

    // Fallback kalkulasi lokal instan
    final logs = _mockActivities;
    final totalHours = logs.fold<double>(0.0, (acc, item) => acc + item.durasiJam);
    const targetHours = 480.0;
    final progress = ((totalHours / targetHours) * 100).clamp(0, 100).toInt();

    return {
      'total_kegiatan': logs.length,
      'kegiatan_selesai': logs.where((e) => e.statusKegiatan == 'selesai').length,
      'kegiatan_berjalan': logs.where((e) => e.statusKegiatan == 'berjalan').length,
      'total_jam': totalHours,
      'target_jam': targetHours.toInt(),
      'persentase_selesai': progress,
      'kegiatan_terbaru': logs.take(3).toList(),
    };
  }

  // Tambahkan catatan/feedback pembimbing
  Future<void> addPembimbingFeedback(String activityId, String notes) => addMentorNotes(activityId, notes);

  Future<void> addMentorNotes(String activityId, String notes) async {
    final idx = _mockActivities.indexWhere((a) => a.id == activityId);
    if (idx != -1) {
      final old = _mockActivities[idx];
      _mockActivities[idx] = ActivityModel(
        id: old.id,
        pesertaId: old.pesertaId,
        lowonganId: old.lowonganId,
        tanggal: old.tanggal,
        judulKegiatan: old.judulKegiatan,
        deskripsiKegiatan: old.deskripsiKegiatan,
        durasiJam: old.durasiJam,
        statusKegiatan: old.statusKegiatan,
        catatanPembimbing: notes,
        lampiranUrl: old.lampiranUrl,
        namaPeserta: old.namaPeserta,
        nimPeserta: old.nimPeserta,
      );
    }

    try {
      await _client.from('kegiatan_magang').update({
        'catatan_pembimbing': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', activityId).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('addMentorNotes notice: $e');
    }
  }
}
