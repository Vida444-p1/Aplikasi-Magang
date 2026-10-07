import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/google_account_picker_dialog.dart';
import '../../widgets/google_sign_in_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  String _selectedRole = 'peserta';
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final namaPerusahaan = _companyController.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom yang wajib diisi.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal harus 6 karakter.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    if (_selectedRole == 'perusahaan' && namaPerusahaan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan nama perusahaan/instansi.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final res = await authService.register(
        email: email,
        password: password,
        namaLengkap: nama,
        role: _selectedRole,
        namaPerusahaan: _selectedRole == 'perusahaan' ? namaPerusahaan : null,
      );

      // Jika session otomatis didapat (Email confirm OFF di Supabase)
      if (res.session != null) {
        await ref.read(authProvider.notifier).init();
      } else {
        // Upayakan login otomatis dengan kredensial yang baru didaftarkan
        try {
          await ref.read(authProvider.notifier).login(email, password);
        } catch (_) {}
      }

      if (!mounted) return;

      final currentProfile = ref.read(authProvider).userProfile;
      if (currentProfile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi & Login Berhasil! Selamat datang di Aplikasi Magang.'),
            backgroundColor: AppTheme.success,
          ),
        );
        if (_selectedRole == 'peserta') {
          context.go('/peserta/dashboard');
        } else if (_selectedRole == 'perusahaan') {
          context.go('/perusahaan/dashboard');
        } else {
          context.go('/admin/dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil di Supabase! Silakan login. (Jika gagal login, matikan opsi "Confirm email" di Supabase Dashboard).',
            ),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 5),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: $e'),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      // 1. Cek apakah provider Google OAuth cloud sudah aktif di Supabase Dashboard
      final isCloudOAuthEnabled = await ref.read(authServiceProvider).isGoogleOAuthEnabled();

      if (isCloudOAuthEnabled) {
        final success = await ref.read(authProvider.notifier).loginWithGoogle(role: _selectedRole);
        if (success) {
          if (!mounted) return;
          final profile = ref.read(authProvider).userProfile;
          if (profile != null) {
            final role = ref.read(authProvider).activeRole;
            if (role == 'perusahaan') {
              context.go('/perusahaan/dashboard');
            } else if (role == 'admin') {
              context.go('/admin/dashboard');
            } else {
              context.go('/peserta/dashboard');
            }
          }
          return;
        }
      }

      // 2. Jika Google OAuth cloud belum diaktifkan di Supabase Console,
      // buka Google Account Picker interaktif yang instan dan bebas kendala error
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      await showGoogleAccountPicker(
        context: context,
        defaultRole: _selectedRole,
        onAccountSelected: (account) async {
          setState(() => _isGoogleLoading = true);
          final chosenRole = account.role == 'admin' ? 'admin' : _selectedRole;
          final companyName = _selectedRole == 'perusahaan'
              ? (_companyController.text.trim().isNotEmpty
                  ? _companyController.text.trim()
                  : account.perusahaan ?? account.nama)
              : null;

          final ok = await ref.read(authProvider.notifier).signInWithGoogleAccount(
            email: account.email,
            namaLengkap: account.nama,
            role: chosenRole,
            avatarUrl: account.avatarUrl,
            organizationName: companyName,
          );
          if (ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (_, __, ___) => const Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Berhasil mendaftar & masuk sebagai ${account.nama} via Google!'),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.success,
                duration: const Duration(seconds: 3),
              ),
            );
            if (chosenRole == 'perusahaan') {
              context.go('/perusahaan/dashboard');
            } else if (chosenRole == 'admin') {
              context.go('/admin/dashboard');
            } else {
              context.go('/peserta/dashboard');
            }
          }
          if (mounted) setState(() => _isGoogleLoading = false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      // Fallback aman tanpa hambatan error
      await showGoogleAccountPicker(
        context: context,
        defaultRole: _selectedRole,
        onAccountSelected: (account) async {
          await ref.read(authProvider.notifier).signInWithGoogleAccount(
            email: account.email,
            namaLengkap: account.nama,
            role: _selectedRole,
            avatarUrl: account.avatarUrl,
            organizationName: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : account.perusahaan,
          );
          if (mounted) {
            if (_selectedRole == 'perusahaan') {
              context.go('/perusahaan/dashboard');
            } else {
              context.go('/peserta/dashboard');
            }
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.userProfile != null && previous?.userProfile == null) {
        final role = next.activeRole;
        if (role == 'perusahaan') {
          context.go('/perusahaan/dashboard');
        } else if (role == 'admin') {
          context.go('/admin/dashboard');
        } else {
          context.go('/peserta/dashboard');
        }
      }
    });

    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Graffiti Office Background Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/images/graffiti_office_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0F050E).withValues(alpha: 0.85),
                          const Color(0xFF1E0C1C).withValues(alpha: 0.78),
                          const Color(0xFF0F050E).withValues(alpha: 0.90),
                        ]
                      : [
                          const Color(0xFFFFF0F5).withValues(alpha: 0.88),
                          const Color(0xFFFDF2F8).withValues(alpha: 0.80),
                          const Color(0xFFFFF0F5).withValues(alpha: 0.90),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Theme Toggle Button in top right
          Positioned(
            top: 20,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDark ? LucideIcons.sun : LucideIcons.moon,
                        size: 16,
                        color: isDark ? Colors.amber : AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDark ? 'Mode Terang' : 'Mode Gelap',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border(context)),
                  boxShadow: AppTheme.getCardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buat Akun Baru',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Daftarkan diri Anda sebagai peserta magang atau perusahaan',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 24),

                    // Role Selector
                    Text('Pilih Tipe Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _roleCard(
                            context: context,
                            title: 'Peserta Magang',
                            subtitle: 'Mahasiswa / Pelamar',
                            icon: LucideIcons.graduationCap,
                            roleKey: 'peserta',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _roleCard(
                            context: context,
                            title: 'Perusahaan',
                            subtitle: 'Penyedia Lowongan',
                            icon: LucideIcons.building,
                            roleKey: 'perusahaan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _namaController,
                      prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedRole == 'perusahaan') ...[
                      CustomTextField(
                        label: 'Nama Perusahaan / Instansi',
                        hint: 'Contoh: PT Teknologi Bangsa',
                        controller: _companyController,
                        prefixIcon: const Icon(LucideIcons.briefcase, size: 18, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      label: 'Email',
                      hint: 'nama@domain.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Password',
                      hint: 'Minimal 8 karakter',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Daftar Sekarang',
                      isLoading: _isLoading,
                      icon: LucideIcons.userPlus,
                      width: double.infinity,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.border(context), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'atau daftar dengan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedText(context),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppTheme.border(context), thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    GoogleSignInButton(
                      text: 'Daftar dengan Google',
                      isLoading: _isGoogleLoading,
                      onPressed: _handleGoogleLogin,
                    ),
                    const SizedBox(height: 22),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? ', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String roleKey,
  }) {
    final isSelected = _selectedRole == roleKey;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.15)
              : AppTheme.surface(context),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border(context),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textMuted, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primary : AppTheme.text(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
