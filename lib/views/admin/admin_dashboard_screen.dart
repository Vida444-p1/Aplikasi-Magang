import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return ResponsiveScaffold(
      title: 'Dashboard Admin & Koordinator Magang',
      currentRoute: '/admin/dashboard',
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 18 : 28),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.shieldCheck, size: 12, color: Color(0xFFA5B4FC)),
                              SizedBox(width: 6),
                              Text(
                                'Koordinator Program Magang & MBKM Kampus',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFFE0E7FF), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pusat Kendali Koordinator Magang',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kelola pendaftaran kemitraan industri, pantau akumulasi jam logbook mahasiswa, dan verifikasi kelayakan program magang.',
                          style: TextStyle(fontSize: 13.5, color: Color(0xFFC7D2FE), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Grid (PRD 5.H Admin)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;
                final isPhone = constraints.maxWidth < 600;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: isPhone ? 12 : 16,
                  mainAxisSpacing: isPhone ? 12 : 16,
                  childAspectRatio: isWide ? 1.8 : (isPhone ? 1.08 : 1.35),
                  children: const [
                    StatCard(
                      title: 'Total Mahasiswa',
                      value: '142 Org',
                      subtitle: '89 Aktif Magang',
                      icon: LucideIcons.graduationCap,
                      color: AppTheme.primary,
                    ),
                    StatCard(
                      title: 'Perusahaan Mitra',
                      value: '24 Mitra',
                      subtitle: '19 Terverifikasi',
                      icon: LucideIcons.building,
                      color: AppTheme.info,
                    ),
                    StatCard(
                      title: 'Lowongan Tersedia',
                      value: '38 Posisi',
                      subtitle: '75 Kuota Terbuka',
                      icon: LucideIcons.briefcase,
                      color: AppTheme.accent,
                    ),
                    StatCard(
                      title: 'Total Pendaftaran',
                      value: '215 Berkas',
                      subtitle: '62 Diproses',
                      icon: LucideIcons.fileText,
                      color: AppTheme.warning,
                    ),
                    StatCard(
                      title: 'Peserta Diterima',
                      value: '68 Peserta',
                      subtitle: 'Diterima 48%',
                      icon: LucideIcons.userCheck,
                      color: AppTheme.success,
                    ),
                    StatCard(
                      title: 'Logbook Masuk',
                      value: '520 Log',
                      subtitle: '94% On-Track',
                      icon: LucideIcons.calendarCheck,
                      color: AppTheme.danger,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Admin Quick Actions & Monitoring Shortcuts
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border(context)),
                boxShadow: AppTheme.getCardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akses Cepat Pengelolaan Sistem',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pintasan navigasi untuk mengelola data master, audit lowongan, dan rekapitulasi.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _adminShortcut(
                        context,
                        'Manajemen Pengguna',
                        'Lihat data mahasiswa & perusahaan',
                        LucideIcons.users,
                        '/admin/users',
                        AppTheme.primary,
                        isMobile,
                      ),
                      _adminShortcut(
                        context,
                        'Kelola Lowongan',
                        'Tinjau lowongan seluruh mitra',
                        LucideIcons.briefcase,
                        '/admin/lowongan',
                        AppTheme.info,
                        isMobile,
                      ),
                      _adminShortcut(
                        context,
                        'Monitoring Logbook',
                        'Pantau keaktifan peserta magang',
                        LucideIcons.clipboardList,
                        '/admin/monitoring',
                        AppTheme.success,
                        isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminShortcut(BuildContext context, String title, String desc, IconData icon, String route, Color accentColor, bool isMobile) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: isMobile ? double.infinity : 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppTheme.text(context))),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: 11.5, color: AppTheme.mutedText(context))),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.lightText(context)),
          ],
        ),
      ),
    );
  }
}
