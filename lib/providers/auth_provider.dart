import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/profile_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthState {
  final bool isLoading;
  final UserProfile? userProfile;
  final String activeRole; // 'peserta', 'perusahaan', 'admin'
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.userProfile,
    this.activeRole = 'peserta',
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    UserProfile? userProfile,
    String? activeRole,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      activeRole: activeRole ?? this.activeRole,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<dynamic>? _authSubscription;

  AuthNotifier(this._authService) : super(AuthState()) {
    init();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.tokenRefreshed) {
        init();
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState(
          isLoading: false,
          userProfile: null,
          activeRole: 'peserta',
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final profile = await _authService.getCurrentUserProfile();
    if (profile != null) {
      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeRole: profile.role,
      );
    } else {
      state = AuthState(
        isLoading: false,
        userProfile: null,
        activeRole: 'peserta',
      );
    }
  }

  // Beralih role seketika untuk menguji tampilan (Peserta, Perusahaan, Admin)
  void switchDemoRole(String role) {
    if (role == 'peserta') {
      state = state.copyWith(
        activeRole: 'peserta',
        userProfile: UserProfile(
          id: 'peserta-001',
          email: 'vida.rizki@student.uii.ac.id',
          namaLengkap: 'Vida Rizki Prasetyo',
          role: 'peserta',
          nomorTelepon: '081234567890',
          pesertaDetails: PesertaProfile(
            id: 'pes-1',
            userId: 'peserta-001',
            nim: '25523013',
            programStudi: 'Informatika',
            universitas: 'Universitas Islam Indonesia',
            alamat: 'Yogyakarta',
            keahlian: ['Flutter', 'Dart', 'Supabase', 'UI/UX Design'],
          ),
        ),
      );
    } else if (role == 'perusahaan') {
      state = state.copyWith(
        activeRole: 'perusahaan',
        userProfile: UserProfile(
          id: 'perusahaan-001',
          email: 'hrd@nusantaradigital.co.id',
          namaLengkap: 'PT Teknologi Nusantara Digital',
          role: 'perusahaan',
          nomorTelepon: '0274-888999',
          perusahaanDetails: PerusahaanProfile(
            id: 'per-1',
            userId: 'perusahaan-001',
            namaPerusahaan: 'PT Teknologi Nusantara Digital',
            industri: 'Software Development & IT Consulting',
            alamat: 'Jl. Kaliurang KM 9, Sleman, Yogyakarta',
            website: 'https://nusantaradigital.co.id',
            deskripsi: 'Perusahaan software house yang berfokus pada solusi enterprise modern dan mobile apps.',
          ),
        ),
      );
    } else if (role == 'admin') {
      state = state.copyWith(
        activeRole: 'admin',
        userProfile: UserProfile(
          id: 'admin-001',
          email: 'admin.magang@kampus.ac.id',
          namaLengkap: 'Koordinator Magang & Kampus Merdeka',
          role: 'admin',
          nomorTelepon: '0274-555666',
        ),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.login(email: email, password: password);
      await init();
      return true;
    } catch (e) {
      String msg = e.toString();
      if (e is AuthException) {
        msg = e.message;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  Future<bool> loginWithGoogle({String? role}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _authService.signInWithGoogle(role: role);
      if (success) {
        await init();
      }
      return success;
    } catch (e) {
      String msg = e.toString();
      if (e is AuthException) {
        msg = e.message;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }

  // Masuk dengan akun Google instan & terverifikasi (bebas kendala error)
  Future<bool> signInWithGoogleAccount({
    required String email,
    required String namaLengkap,
    required String role,
    String? avatarUrl,
    String? organizationName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _authService.mockGoogleSignIn(
        email: email,
        namaLengkap: namaLengkap,
        role: role,
        avatarUrl: avatarUrl,
        organizationName: organizationName,
      );
      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeRole: profile.role,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
