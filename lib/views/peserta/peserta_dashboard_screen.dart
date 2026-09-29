import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class PesertaDashboardScreen extends ConsumerWidget {
  const PesertaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.userProfile;
    final pesertaId = user?.pesertaDetails?.id ?? 'pes-1';

    final summaryAsync = ref.watch(logbookSummaryProvider(pesertaId));
    final applicationsAsync = ref.watch(myApplicationsProvider(pesertaId));

    return ResponsiveScaffold(
      title: 'Dashboard Peserta',
      currentRoute: '/peserta/dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Hero Banner Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.sparkles, color: Color(0xFFFDE047), size: 13),
                              SizedBox(width: 6),
                              Text(
                                'PROGRAM MAGANG TERPADU 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Halo, ${user?.namaLengkap ?? 'Peserta Magang'}! 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pantau perkembangan status lamaran Anda, catat kegiatan harian logbook magang, dan konsultasikan tugas bersama pembimbing lapangan.',
                          style: TextStyle(fontSize: 13.5, color: Color(0xFFC7D2FE), height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/peserta/lowongan'),
                              icon: const Icon(LucideIcons.search, size: 16),
                              label: const Text('Cari Lowongan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryDark,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/peserta/kegiatan'),
                              icon: const Icon(LucideIcons.calendarCheck, size: 16, color: Colors.white),
                              label: const Text('Isi Logbook Harian', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
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

            // Internship Summary Section
            summaryAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Error: $err'),
              data: (summary) {
                final percent = summary['persentase_selesai'] ?? 0;
                final totalHours = summary['total_jam'] ?? 0;
                final targetHours = summary['target_jam'] ?? 480;
                final totalLogs = summary['total_kegiatan'] ?? 0;

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        return GridView.count(
                          crossAxisCount: isWide ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isWide ? 1.55 : 1.25,
                          children: [
                            StatCard(
                              title: 'Progres Jam Kerja',
                              value: '$percent%',
                              subtitle: '$totalHours / $targetHours Jam',
                              icon: LucideIcons.pieChart,
                              color: AppTheme.primary,
                            ),
                            StatCard(
                              title: 'Kegiatan Dicatat',
                              value: '$totalLogs Log',
                              subtitle: '${summary['kegiatan_selesai']} Selesai Divalidasi',
                              icon: LucideIcons.calendarCheck,
                              color: AppTheme.success,
                            ),
                            const StatCard(
                              title: 'Status Penerimaan',
                              value: 'DITERIMA',
                              subtitle: 'Aktif Magang',
                              icon: LucideIcons.checkCircle2,
                              color: AppTheme.info,
                            ),
                            const StatCard(
                              title: 'Mitra Magang',
                              value: 'PT Teknologi',
                              subtitle: 'Mobile App Developer',
                              icon: LucideIcons.building,
                              color: AppTheme.accent,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Progress Visual Bar Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border(context), width: 1.1),
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
                                    'Penyelesaian Jam Magang (Standar Target 3 Bulan)',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.text(context)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Akumulasi durasi seluruh logbook yang telah dicatat dan disetujui',
                                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$percent% ($totalHours / $targetHours Jam)',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary, fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: (percent as int) / 100.0,
                                backgroundColor: AppTheme.surfaceElevated(context),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Two-column layout for Recent Activities & Active Applications
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Activities
                    Expanded(
                      flex: isWide ? 6 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border(context), width: 1.1),
                          boxShadow: AppTheme.getCardShadow(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kegiatan Magang Terbaru',
                                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                                ),
                                TextButton.icon(
                                  onPressed: () => context.go('/peserta/kegiatan'),
                                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                                  label: const Text('Buka Logbook', style: TextStyle(fontSize: 12.5)),
                                ),
                              ],
                            ),
                            Divider(color: AppTheme.borderSubtleColor(context), height: 16),
                            summaryAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const SizedBox(),
                              data: (summary) {
                                final activities = (summary['kegiatan_terbaru'] as List? ?? []);
                                if (activities.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Center(
                                      child: Text('Belum ada logbook yang dicatat.', style: TextStyle(color: AppTheme.mutedText(context))),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: activities.length,
                                  separatorBuilder: (_, __) => Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                                  itemBuilder: (context, idx) {
                                    final act = activities[idx];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(LucideIcons.fileText, color: AppTheme.primary, size: 17),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  act.judulKegiatan,
                                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppTheme.text(context)),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${DateFormat('dd MMM yyyy').format(act.tanggal)} • ${act.durasiJam} Jam',
                                                  style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          StatusBadge(status: act.statusKegiatan),
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
                    ),
                    if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                    // Active Applications Status
                    Expanded(
                      flex: isWide ? 4 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border(context), width: 1.1),
                          boxShadow: AppTheme.getCardShadow(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status Lamaran',
                                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                                ),
                                TextButton.icon(
                                  onPressed: () => context.go('/peserta/pendaftaran'),
                                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                                  label: const Text('Detail', style: TextStyle(fontSize: 12.5)),
                                ),
                              ],
                            ),
                            Divider(color: AppTheme.borderSubtleColor(context), height: 16),
                            applicationsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (_, __) => const SizedBox(),
                              data: (apps) {
                                if (apps.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text('Belum ada lamaran magang.', style: TextStyle(color: AppTheme.mutedText(context))),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: apps.take(3).length,
                                  separatorBuilder: (_, __) => Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                                  itemBuilder: (context, index) {
                                    final app = apps[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  app.vacancy?.posisi ?? 'Posisi Magang',
                                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppTheme.text(context)),
                                                ),
                                              ),
                                              StatusBadge(status: app.status),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            app.vacancy?.namaPerusahaan ?? 'Perusahaan Mitra',
                                            style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
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
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
