import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vacancy_model.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class ManageVacanciesScreen extends ConsumerWidget {
  const ManageVacanciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(vacancyListProvider);

    return ResponsiveScaffold(
      title: 'Manajemen Lowongan Magang',
      currentRoute: '/perusahaan/lowongan',
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
                        'Daftar Lowongan Perusahaan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Publikasikan posisi baru, perbarui persyaratan kualifikasi, atau pantau kuota mahasiswa pendaftar.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/perusahaan/lowongan/tambah'),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Buat Lowongan Baru'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                if (vacancies.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border(context)),
                      boxShadow: AppTheme.getCardShadow(context),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.briefcase, size: 36, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Lowongan yang Dipublikasi',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.text(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buat lowongan magang pertama untuk mulai menerima pendaftar mahasiswa.',
                            style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/perusahaan/lowongan/tambah'),
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Buat Lowongan Sekarang'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vacancies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
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
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.text(context),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.layers, size: 12.5, color: AppTheme.mutedText(context)),
                                          const SizedBox(width: 4),
                                          Text(v.bidang, style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context))),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                          const SizedBox(width: 8),
                                          Icon(LucideIcons.mapPin, size: 12.5, color: AppTheme.mutedText(context)),
                                          const SizedBox(width: 4),
                                          Text(v.lokasi, style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context))),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceElevated(context),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppTheme.border(context)),
                                            ),
                                            child: Text(
                                              'Kuota: ${v.kuota} Orang',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: v.status),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              v.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context), height: 1.45),
                            ),
                            const SizedBox(height: 16),
                            Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(LucideIcons.calendarClock, size: 13.5, color: AppTheme.lightText(context)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Batas Pendaftaran: ${DateFormat('dd MMMM yyyy').format(v.batasPendaftaran)}',
                                      style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => context.go('/perusahaan/pelamar'),
                                      icon: const Icon(LucideIcons.users, size: 14),
                                      label: const Text('Lihat Pelamar (5)'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Membuka editor lowongan...')),
                                        );
                                      },
                                      icon: const Icon(LucideIcons.edit2, size: 14),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.danger),
                                      tooltip: 'Kelola / Hapus Lowongan',
                                      onPressed: () => _showManageVacancyDialog(context, ref, v),
                                    ),
                                  ],
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

  void _showManageVacancyDialog(BuildContext context, WidgetRef ref, VacancyModel vacancy) {
    final isAktif = vacancy.status.toLowerCase() == 'aktif';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kelola Lowongan Magang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tindakan untuk posisi "${vacancy.posisi}":',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isAktif ? LucideIcons.eyeOff : LucideIcons.eye, size: 15, color: isAktif ? Colors.orange : Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        isAktif ? 'Nonaktifkan / Tutup Lowongan' : 'Aktifkan Kembali Lowongan',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAktif
                        ? 'Lowongan akan ditutup dan disembunyikan dari pencarian mahasiswa magang.'
                        : 'Lowongan akan kembali aktif dan dapat didaftar oleh mahasiswa.',
                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                  ),
                  const Divider(height: 18),
                  Row(
                    children: const [
                      Icon(LucideIcons.trash2, size: 15, color: AppTheme.danger),
                      SizedBox(width: 8),
                      Text(
                        'Hapus Permanen',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Menghapus lowongan sepenuhnya dari sistem sehingga langsung hilang.',
                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          OutlinedButton.icon(
            icon: Icon(isAktif ? LucideIcons.eyeOff : LucideIcons.eye, size: 14),
            label: Text(isAktif ? 'Tutup Lowongan' : 'Aktifkan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isAktif ? Colors.orange.shade700 : Colors.green.shade700,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final newStatus = isAktif ? 'ditutup' : 'aktif';
              final updated = vacancy.copyWith(status: newStatus);
              await ref.read(vacancyServiceProvider).updateVacancy(vacancy.id, updated);
              ref.invalidate(vacancyListProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAktif ? 'Lowongan berhasil dinonaktifkan (ditutup).' : 'Lowongan berhasil diaktifkan kembali.'),
                    backgroundColor: isAktif ? Colors.orange.shade800 : Colors.green.shade700,
                  ),
                );
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.trash2, size: 14),
            label: const Text('Hapus Permanen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(vacancyServiceProvider).deleteVacancy(vacancy.id);
              ref.invalidate(vacancyListProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lowongan berhasil dihapus dari daftar.'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
