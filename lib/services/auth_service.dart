import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/profile_model.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Mendapatkan profil pengguna saat ini
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client
          .from('profiles')
          .select('*, peserta_details(*), perusahaan_details(*)')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        return UserProfile.fromJson(res);
      }

      // Jika profile belum terisi oleh trigger database, buat secara programatik
      final meta = user.userMetadata ?? {};
      final role = meta['role']?.toString().toLowerCase() ?? 'peserta';
      final nama = meta['nama_lengkap']?.toString() ?? (user.email?.split('@').first ?? 'Pengguna');

      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email ?? '',
        'nama_lengkap': nama,
        'role': role,
      });

      if (role == 'peserta') {
        await _client.from('peserta_details').upsert({
          'user_id': user.id,
        }, onConflict: 'user_id');
      } else if (role == 'perusahaan') {
        await _client.from('perusahaan_details').upsert({
          'user_id': user.id,
          'nama_perusahaan': meta['nama_perusahaan']?.toString() ?? nama,
        }, onConflict: 'user_id');
      }

      final retryRes = await _client
          .from('profiles')
          .select('*, peserta_details(*), perusahaan_details(*)')
          .eq('id', user.id)
          .maybeSingle();

      if (retryRes != null) {
        return UserProfile.fromJson(retryRes);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user profile: $e');
      return null;
    }
  }

  // Registrasi Pengguna Baru
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String namaLengkap,
    required String role, // 'peserta' | 'perusahaan' | 'admin'
    String? namaPerusahaan,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nama_lengkap': namaLengkap,
        'role': role,
        if (namaPerusahaan != null) 'nama_perusahaan': namaPerusahaan,
      },
    );

    final user = response.user;
    if (user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': email,
          'nama_lengkap': namaLengkap,
          'role': role,
        });

        if (role == 'peserta') {
          await _client.from('peserta_details').upsert({
            'user_id': user.id,
          }, onConflict: 'user_id');
        } else if (role == 'perusahaan') {
          await _client.from('perusahaan_details').upsert({
            'user_id': user.id,
            'nama_perusahaan': namaPerusahaan ?? namaLengkap,
          }, onConflict: 'user_id');
        }
      } catch (e) {
        debugPrint('Upsert profile post-signup notice: $e');
      }
    }

    return response;
  }

  // Login Pengguna
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Update Data Profil Peserta
  Future<void> updatePesertaProfile({
    required String nim,
    required String programStudi,
    required String universitas,
    required String alamat,
    required List<String> keahlian,
    String? cvUrl,
    required String namaLengkap,
    String? nomorTelepon,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception("Tidak terautentikasi");

    // Update profiles
    await _client.from('profiles').update({
      'nama_lengkap': namaLengkap,
      'nomor_telepon': nomorTelepon,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);

    // Update peserta_details
    await _client.from('peserta_details').update({
      'nim': nim,
      'program_studi': programStudi,
      'universitas': universitas,
      'alamat': alamat,
      'keahlian': keahlian,
      if (cvUrl != null) 'cv_url': cvUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', uid);
  }

  // Update Data Profil Perusahaan
  Future<void> updatePerusahaanProfile({
    required String namaPerusahaan,
    String? industri,
    String? alamat,
    String? website,
    String? deskripsi,
    String? nomorTelepon,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception("Tidak terautentikasi");

    // Update profiles
    await _client.from('profiles').update({
      'nama_lengkap': namaPerusahaan,
      'nomor_telepon': nomorTelepon,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);

    // Update perusahaan_details
    await _client.from('perusahaan_details').update({
      'nama_perusahaan': namaPerusahaan,
      'industri': industri,
      'alamat': alamat,
      'website': website,
      'deskripsi': deskripsi,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', uid);
  }
}
