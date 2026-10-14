import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Static list in-memory agar setiap notifikasi baru langsung reaktif dan tersimpan
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'notif-1',
      userId: 'user-1',
      judul: '🎉 Lamaran DITERIMA!',
      pesan: 'Selamat! Lamaran Anda untuk posisi Flutter & Mobile Developer di PT Teknologi Nusantara Digital telah DITERIMA.',
      tipe: 'success',
      isRead: false,
      linkTarget: '/peserta/pendaftaran',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-2',
      userId: 'user-1',
      judul: 'Pengingat Pengisian Logbook',
      pesan: 'Jangan lupa untuk mencatat kegiatan magang harian Anda hari ini.',
      tipe: 'info',
      isRead: true,
      linkTarget: '/peserta/kegiatan',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mengambil daftar notifikasi pengguna
  Future<List<NotificationModel>> getNotifications(String? userId) async {
    try {
      var query = _client.from('notifikasi').select('*');
      if (userId != null && userId.isNotEmpty && userId != 'current-user') {
        query = query.eq('user_id', userId);
      }
      final res = await query.order('created_at', ascending: false).timeout(const Duration(seconds: 3));
      final list = (res as List).map((e) => NotificationModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Error getNotifications Supabase: $e. Fallback ke notifikasi lokal.');
    }
    return List.from(_mockNotifications);
  }

  // Mengirim notifikasi baru (Simpan ke memori lokal & Supabase)
  Future<void> sendNotification({
    required String userId,
    required String judul,
    required String pesan,
    String tipe = 'info',
    String? linkTarget,
  }) async {
    final newNotif = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      judul: judul,
      pesan: pesan,
      tipe: tipe,
      isRead: false,
      linkTarget: linkTarget,
      createdAt: DateTime.now(),
    );

    // 1. Simpan ke memori lokal
    _mockNotifications.insert(0, newNotif);

    // 2. Upayakan simpan ke tabel notifikasi Supabase jika terkoneksi
    try {
      await _client.from('notifikasi').insert({
        'user_id': userId,
        'judul': judul,
        'pesan': pesan,
        'tipe': tipe,
        'is_read': false,
        'link_target': linkTarget,
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Supabase notifikasi insert notice: $e');
    }
  }

  // Tandai notifikasi sudah dibaca
  Future<void> markAsRead(String id) async {
    final idx = _mockNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = _mockNotifications[idx];
      _mockNotifications[idx] = NotificationModel(
        id: old.id,
        userId: old.userId,
        judul: old.judul,
        pesan: old.pesan,
        tipe: old.tipe,
        isRead: true,
        linkTarget: old.linkTarget,
        createdAt: old.createdAt,
      );
    }
    try {
      await _client.from('notifikasi').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('Error markAsRead: $e');
    }
  }

  // Tandai semua notifikasi sudah dibaca
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _mockNotifications.length; i++) {
      final old = _mockNotifications[i];
      _mockNotifications[i] = NotificationModel(
        id: old.id,
        userId: old.userId,
        judul: old.judul,
        pesan: old.pesan,
        tipe: old.tipe,
        isRead: true,
        linkTarget: old.linkTarget,
        createdAt: old.createdAt,
      );
    }
  }
}
