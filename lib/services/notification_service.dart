import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Mengambil daftar notifikasi pengguna
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final res = await _client
          .from('notifikasi')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (res as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getNotifications: $e. Fallback to mock.');
      return _getMockNotifications();
    }
  }

  // Tandai notifikasi sudah dibaca
  Future<void> markAsRead(String id) async {
    try {
      await _client.from('notifikasi').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('Error markAsRead: $e');
    }
  }

  List<NotificationModel> _getMockNotifications() {
    return [
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
  }
}
