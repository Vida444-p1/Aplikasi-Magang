import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'vida.rizki@student.uii.ac.id');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan email dan password.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Coba login ke Supabase Auth sesungguhnya
    final success = await ref.read(authProvider.notifier).login(email, password);

    if (success) {
      if (!mounted) return;
      final role = ref.read(authProvider).activeRole;
      if (role == 'perusahaan') {
        context.go('/perusahaan/dashboard');
      } else if (role == 'admin') {
        context.go('/admin/dashboard');
      } else {
        context.go('/peserta/dashboard');
      }
    } else {
      if (!mounted) return;
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Login gagal.';

      // Jika akun adalah akun contoh demo bawaan, berikan fallback otomatis
      final isDemoAccount = email == 'vida.rizki@student.uii.ac.id' ||
          email == 'hrd@nusantaradigital.co.id' ||
          email == 'admin.magang@kampus.ac.id';

      if (isDemoAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun demo belum terdaftar di Supabase. Masuk melalui Mode Simulasi.'),
            backgroundColor: AppTheme.warning,
            duration: Duration(seconds: 2),
          ),
        );
        if (email.contains('perusahaan') || email.contains('hrd')) {
          ref.read(authProvider.notifier).switchDemoRole('perusahaan');
          context.go('/perusahaan/dashboard');
        } else if (email.contains('admin')) {
          ref.read(authProvider.notifier).switchDemoRole('admin');
          context.go('/admin/dashboard');
        } else {
          ref.read(authProvider.notifier).switchDemoRole('peserta');
          context.go('/peserta/dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg.contains('Email not confirmed')
                  ? 'Email belum dikonfirmasi di Supabase. Matikan opsi "Confirm email" di menu Authentication > Providers > Email pada Supabase Dashboard.'
                  : 'Login gagal: $errorMsg',
            ),
            backgroundColor: AppTheme.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
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
                constraints: BoxConstraints(maxWidth: isDesktop ? 960 : 480),
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border(context)),
                  boxShadow: AppTheme.getCardShadow(context),
                ),
                child: Row(
                  children: [
                // Left Brand Presentation Banner (Desktop only)
                if (isDesktop)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(LucideIcons.briefcase, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Platform Terpadu\nProgram Magang',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Cari lowongan impian, daftar berkas secara terorganisir, dan pantau aktivitas harian magang dalam satu sistem terintegrasi.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFC7D2FE),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 36),
                          _featureItem(LucideIcons.search, 'Pencarian lowongan mudah & transparan'),
                          const SizedBox(height: 12),
                          _featureItem(LucideIcons.checkCircle, 'Pelacakan status pendaftaran real-time'),
                          const SizedBox(height: 12),
                          _featureItem(LucideIcons.clipboardCheck, 'Logbook & monitoring kegiatan terstruktur'),
                        ],
                      ),
                    ),
                  ),

                // Right Form Panel
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 48 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Masuk ke Akun',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih role demo cepat atau masukkan email terdaftar:',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),

                        // Quick Demo Role Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(LucideIcons.graduationCap, size: 16, color: AppTheme.primary),
                              label: const Text('Peserta', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _emailController.text = 'vida.rizki@student.uii.ac.id';
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(LucideIcons.building, size: 16, color: AppTheme.info),
                              label: const Text('Perusahaan', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _emailController.text = 'hrd@nusantaradigital.co.id';
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(LucideIcons.shieldCheck, size: 16, color: AppTheme.danger),
                              label: const Text('Admin', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _emailController.text = 'admin.magang@kampus.ac.id';
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          label: 'Email',
                          hint: 'nama@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Masuk Sekarang',
                          isLoading: _isLoading,
                          icon: LucideIcons.logIn,
                          width: double.infinity,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Belum punya akun? ', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Daftar Akun Baru',
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
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _featureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF472B6), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}
