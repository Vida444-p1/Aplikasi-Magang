import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class VacancyDetailScreen extends ConsumerWidget {
  final String vacancyId;

  const VacancyDetailScreen({super.key, required this.vacancyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacancyAsync = ref.watch(vacancyDetailProvider(vacancyId));

    return ResponsiveScaffold(
      title: 'Detail Lowongan Magang',
      currentRoute: '/peserta/lowongan',
      body: vacancyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat detail: $err')),
        data: (v) {
          if (v == null) {
            return const Center(child: Text('Lowongan tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => context.go('/peserta/lowongan'),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.arrowLeft, size: 16, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Kembali ke Daftar Lowongan', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(LucideIcons.building2, size: 36, color: AppTheme.primary),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.posisi,
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v.namaPerusahaan ?? 'Perusahaan Mitra',
                                        style: const TextStyle(fontSize: 15, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.textLight),
                                          const SizedBox(width: 4),
                                          Text(v.lokasi, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted)),
                                          const SizedBox(width: 12),
                                          StatusBadge(status: v.sistemKerja),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Divider(color: AppTheme.border(context)),
                            const SizedBox(height: 16),

                            // Specifications Grid
                            Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                _specItem(context, 'Durasi', '${v.durasiBulan} Bulan', LucideIcons.calendar),
                                _specItem(context, 'Kuota', '${v.kuota} Orang', LucideIcons.users),
                                _specItem(context, 'Batas Daftar', DateFormat('dd MMMM yyyy').format(v.batasPendaftaran), LucideIcons.alarmClock),
                                _specItem(context, 'Jadwal', v.jadwal ?? 'Senin - Jumat', LucideIcons.clock),
                              ],
                            ),
                            const SizedBox(height: 24),

                            ElevatedButton.icon(
                              onPressed: () => context.go('/peserta/daftar/${v.id}'),
                              icon: const Icon(LucideIcons.send, size: 18),
                              label: const Text('Daftar Magang Sekarang', style: TextStyle(fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Job Description Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deskripsi Pekerjaan',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              v.deskripsi,
                              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
                            ),
                            if (v.tanggungJawab != null && v.tanggungJawab!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                'Tanggung Jawab Utama',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                v.tanggungJawab!,
                                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              'Persyaratan Peserta',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              v.persyaratan,
                              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _specItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.text(context))),
          ],
        ),
      ],
    );
  }
}
