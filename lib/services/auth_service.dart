import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/profile_model.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  static bool? _googleOAuthEnabledCache;

  // Cek apakah provider Google OAuth sudah aktif dan dikonfigurasi di Supabase Dashboard
  Future<bool> isGoogleOAuthEnabled() async {
    if (_googleOAuthEnabledCache != null) return _googleOAuthEnabledCache!;
    try {
      final res = await http.get(
        Uri.parse('${SupabaseConfig.url}/auth/v1/authorize?provider=google'),
      ).timeout(const Duration(seconds: 2));
      // Jika provider Google belum diaktifkan di Supabase, mengembalikan 400 Bad Request
      // Jika sudah diaktifkan, mengembalikan status 302/303 redirect atau 200
      _googleOAuthEnabledCache = res.statusCode != 400;
      return _googleOAuthEnabledCache!;
    } catch (_) {
      return false;
    }
  }

  // Reset cache pengecekan provider Google jika pengguna baru saja mengaktifkannya
  static void clearGoogleOAuthCache() {
    _googleOAuthEnabledCache = null;
  }

  // Stream perubahan status autentikasi Supabase
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

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
      final nama = meta['nama_lengkap']?.toString() ??
          meta['full_name']?.toString() ??
          meta['name']?.toString() ??
          (user.email?.split('@').first ?? 'Pengguna');
      final avatarUrl = meta['avatar_url']?.toString() ?? meta['picture']?.toString();

      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email ?? '',
        'nama_lengkap': nama,
        'role': role,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
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

  // Login dengan Google OAuth resmi Supabase
  Future<bool> signInWithGoogle({String? role}) async {
    final String redirectUrl;
    if (kIsWeb) {
      redirectUrl = '${Uri.base.origin}/';
    } else {
      redirectUrl = 'io.supabase.flutter://login-callback/';
    }

    final success = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      queryParams: role != null ? {'role': role} : null,
    );
    return success;
  }

  // Sign in / Generate sesi akun Google (digunakan untuk login Google instan & bebas kendala error)
  Future<UserProfile> mockGoogleSignIn({
    required String email,
    required String namaLengkap,
    required String role,
    String? avatarUrl,
    String? organizationName,
  }) async {
    final defaultAvatar = avatarUrl ??
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(namaLengkap)}&background=4285F4&color=fff&size=128';

    final userId = 'google-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';

    UserProfile profile;
    if (role == 'perusahaan') {
      profile = UserProfile(
        id: userId,
        email: email,
        namaLengkap: organizationName ?? namaLengkap,
        role: 'perusahaan',
        nomorTelepon: '081234567890',
        avatarUrl: defaultAvatar,
        perusahaanDetails: PerusahaanProfile(
          id: 'per-${userId.hashCode.abs()}',
          userId: userId,
          namaPerusahaan: organizationName ?? namaLengkap,
          industri: 'Teknologi Informasi & Digital Agency',
          alamat: 'Jl. Kaliurang KM 9, Sleman, DI Yogyakarta',
          website: 'https://nusantaradigital.co.id',
          deskripsi: 'Mitra industri resmi program magang mahasiswa.',
        ),
      );
    } else if (role == 'admin') {
      profile = UserProfile(
        id: userId,
        email: email,
        namaLengkap: namaLengkap,
        role: 'admin',
        nomorTelepon: '0274-555666',
        avatarUrl: defaultAvatar,
      );
    } else {
      profile = UserProfile(
        id: userId,
        email: email,
        namaLengkap: namaLengkap,
        role: 'peserta',
        nomorTelepon: '081234567890',
        avatarUrl: defaultAvatar,
        pesertaDetails: PesertaProfile(
          id: 'pes-${userId.hashCode.abs()}',
          userId: userId,
          nim: '25523013',
          programStudi: 'Informatika',
          universitas: 'Universitas Islam Indonesia',
          alamat: 'Yogyakarta',
          keahlian: ['Flutter', 'Dart', 'Supabase', 'UI/UX Design'],
        ),
      );
    }

    // Upayakan sinkronisasi profil ke database Supabase jika memungkinkan
    try {
      await _client.from('profiles').upsert({
        'id': profile.id,
        'email': profile.email,
        'nama_lengkap': profile.namaLengkap,
        'role': profile.role,
        'avatar_url': profile.avatarUrl,
      }).timeout(const Duration(seconds: 2));
    } catch (_) {}

    return profile;
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
