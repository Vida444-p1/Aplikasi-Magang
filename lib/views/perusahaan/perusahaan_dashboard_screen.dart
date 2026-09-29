import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class PerusahaanDashboardScreen extends ConsumerWidget {
  const PerusahaanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.userProfile;
    final companyName = user?.perusahaanDetails?.namaPerusahaan ?? user?.namaLengkap ?? 'PT Perusahaan Mitra';
    final vacanciesAsync = ref.watch(vacancyListProvider);

    return ResponsiveScaffold(
      title: 'Dashboard Perusahaan',
      currentRoute: '/perusahaan/dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Welcome Banner with rich SaaS gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Slate 900
                    Color(0xFF1E293B), // Slate 800
                    Color(0xFF334155), // Slate 700
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.18),
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
                              Icon(LucideIcons.building2, size: 12, color: Color(0xFF93C5FD)),
                              SizedBox(width: 6),
                              Text(
                                'Portal Mitra Industri & Rekrutmen',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Selamat Datang, $companyName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kelola publikasi lowongan magang, seleksi portofolio kandidat, dan pantau logbook aktivitas peserta secara real-time.',
                          style: TextStyle(fontSize: 13.5, color: Color(0xFFCBD5E1), height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/perusahaan/lowongan/tambah'),
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: const Text('Buat Lowongan Baru'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/perusahaan/pelamar'),
                              icon: const Icon(LucideIcons.users, size: 16, color: Colors.white),
                              label: const Text('Review Berkas Pelamar', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.6 : 1.3,
                  children: const [
                    StatCard(
                      title: 'Lowongan Aktif',
                      value: '3 Posisi',
                      subtitle: '9 Total Kuota Mahasiswa',
                      icon: LucideIcons.briefcase,
                      color: AppTheme.primary,
                    ),
                    StatCard(
                      title: 'Total Pelamar',
                      value: '18 Berkas',
                      subtitle: '5 Menunggu Peninjauan',
                      icon: LucideIcons.users,
                      color: AppTheme.info,
                    ),
                    StatCard(
                      title: 'Peserta Diterima',
                      value: '4 Orang',
                      subtitle: 'Sedang Aktif Magang',
                      icon: LucideIcons.userCheck,
                      color: AppTheme.success,
                    ),
                    StatCard(
                      title: 'Logbook Baru',
                      value: '6 Log',
                      subtitle: 'Perlu Validasi & Catatan',
                      icon: LucideIcons.calendarCheck,
                      color: AppTheme.warning,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Active Vacancies Overview Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border(context)),
                boxShadow: AppTheme.getCardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lowongan Magang yang Sedang Dibuka',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.text(context),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Daftar posisi magang yang aktif menerima pendaftaran mahasiswa',
                            style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/perusahaan/lowongan'),
                        icon: const Icon(LucideIcons.arrowRight, size: 15),
                        label: const Text('Kelola Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                  const SizedBox(height: 10),

                  vacanciesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (vacancies) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vacancies.length,
                        separatorBuilder: (_, __) => Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                        itemBuilder: (context, index) {
                          final v = vacancies[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.briefcase, color: AppTheme.primary, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.posisi,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppTheme.text(context)),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.mapPin, size: 12, color: AppTheme.mutedText(context)),
                                          const SizedBox(width: 4),
                                          Text(v.lokasi, style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context))),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                          const SizedBox(width: 8),
                                          Text('Kuota: ${v.kuota} Orang', style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context))),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceElevated(context),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppTheme.border(context)),
                                            ),
                                            child: Text(
                                              v.sistemKerja.toUpperCase(),
                                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.mutedText(context)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: v.status),
                                const SizedBox(width: 14),
                                OutlinedButton(
                                  onPressed: () => context.go('/perusahaan/pelamar'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  ),
                                  child: const Text('Lihat Pelamar', style: TextStyle(fontSize: 12.5)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
