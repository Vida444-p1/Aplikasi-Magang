import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class AdminVacanciesScreen extends ConsumerWidget {
  const AdminVacanciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(vacancyListProvider);

    return ResponsiveScaffold(
      title: 'Manajemen Lowongan Seluruh Mitra',
      currentRoute: '/admin/lowongan',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Lowongan',
          onPressed: () => ref.invalidate(vacancyListProvider),
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
                        'Pengawasan Lowongan Magang Kampus',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tinjau lowongan yang dibuka oleh perusahaan mitra industri, validasi kuota, dan masa berlaku program.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 15, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Audit Lowongan Kampus',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            vacanciesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (vacancies) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vacancies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final v = vacancies[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: AppTheme.getCardShadow(context),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(LucideIcons.briefcase, color: AppTheme.primary, size: 22),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.posisi,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.text(context),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.building2, size: 13, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(v.namaPerusahaan ?? 'Perusahaan Mitra', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                                      const SizedBox(width: 8),
                                      const Text('•', style: TextStyle(color: AppTheme.textLight)),
                                      const SizedBox(width: 8),
                                      const Icon(LucideIcons.mapPin, size: 13, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(v.lokasi, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                                      const SizedBox(width: 8),
                                      const Text('•', style: TextStyle(color: AppTheme.textLight)),
                                      const SizedBox(width: 8),
                                      Text('Kuota: ${v.kuota} Orang', style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Batas Pendaftaran: ${DateFormat('dd MMMM yyyy').format(v.batasPendaftaran)}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.isDark(context) ? AppTheme.bgDark : AppTheme.bgLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.border(context)),
                                  ),
                                  child: const Text(
                                    'MAGANG',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: v.status),
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
