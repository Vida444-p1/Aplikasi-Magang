import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class AdminMonitoringScreen extends ConsumerWidget {
  const AdminMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    return ResponsiveScaffold(
      title: 'Monitoring & Rekap Logbook Magang',
      currentRoute: '/admin/monitoring',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan Rekapitulasi Kegiatan Magang berhasil diexport ke CSV/PDF.'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          icon: const Icon(LucideIcons.downloadCloud, size: 15),
          label: const Text('Export Laporan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengawasan Aktivitas Magang Mahasiswa',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Koordinator dapat memantau kedisiplinan pengisian logbook harian seluruh peserta magang.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.checkCheck, size: 15, color: AppTheme.success),
                      SizedBox(width: 8),
                      Text(
                        'Rekapitulasi SKS Terpadu',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            activitiesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (activities) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final act = activities[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: AppTheme.getCardShadow(context),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(LucideIcons.user, size: 16, color: AppTheme.primary),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${act.namaPeserta ?? 'Vida Rizki Prasetyo'} (NIM: ${act.nimPeserta ?? '25523013'})',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.text(context)),
                                    ),
                                  ],
                                ),
                                StatusBadge(status: act.statusKegiatan),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              act.judulKegiatan,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5, color: AppTheme.text(context)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act.deskripsiKegiatan,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.45),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 13, color: AppTheme.textLight),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('dd MMMM yyyy').format(act.tanggal),
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                                const SizedBox(width: 10),
                                const Text('•', style: TextStyle(color: AppTheme.textLight)),
                                const SizedBox(width: 10),
                                const Icon(LucideIcons.clock, size: 13, color: AppTheme.textLight),
                                const SizedBox(width: 5),
                                Text(
                                  '${act.durasiJam} Jam Kerja Diakui',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
