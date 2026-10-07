import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
      if (currentProfile != null && !currentProfile.id.contains('peserta-001')) {
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

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 20),

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
