import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class VacancyListScreen extends ConsumerWidget {
  const VacancyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(vacancyListProvider);
    final filter = ref.watch(vacancyFilterProvider);

    return ResponsiveScaffold(
      title: 'Eksplorasi Lowongan Magang',
      currentRoute: '/peserta/lowongan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter Panel Card (PRD 5.C)
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
                  // Search Field
                  TextField(
                    onChanged: (val) {
                      ref.read(vacancyFilterProvider.notifier).state = filter.copyWith(keyword: val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari posisi magang, keahlian, atau nama perusahaan mitra...',
                      prefixIcon: Icon(LucideIcons.search, size: 18, color: AppTheme.mutedText(context)),
                      suffixIcon: filter.keyword.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () {
                                ref.read(vacancyFilterProvider.notifier).state = filter.copyWith(keyword: '');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips: Sistem Kerja
                  Row(
                    children: [
                      Text(
                        'Sistem Kerja: ',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Semua', 'WFO', 'WFH', 'Hybrid'].map((item) {
                              final isSelected = filter.sistemKerja.toLowerCase() == item.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(item, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      ref.read(vacancyFilterProvider.notifier).state =
                                          filter.copyWith(sistemKerja: item);
                                    }
                                  },
                                  selectedColor: AppTheme.primary,
                                  backgroundColor: AppTheme.surfaceElevated(context),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primary : AppTheme.border(context),
                                    width: 1,
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textSecondary(context),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vacancy List Results
            vacanciesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
              data: (vacancies) {
                if (vacancies.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.searchX, size: 36, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada lowongan ditemukan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Coba ubah kata kunci pencarian atau sesuaikan filter sistem kerja Anda.',
                            style: TextStyle(color: AppTheme.mutedText(context), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menampilkan ${vacancies.length} lowongan magang aktif',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.mutedText(context)),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        final isMobile = constraints.maxWidth < 600;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 2 : 1,
                            childAspectRatio: isDesktop ? 1.75 : (isMobile ? 1.18 : 1.4),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: vacancies.length,
                          itemBuilder: (context, index) {
                            final v = vacancies[index];
                            final initial = (v.namaPerusahaan != null && v.namaPerusahaan!.isNotEmpty)
                                ? v.namaPerusahaan![0].toUpperCase()
                                : 'P';

                            return Container(
                              padding: EdgeInsets.all(isMobile ? 16 : 22),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              v.posisi,
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.text(context),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              v.namaPerusahaan ?? 'Perusahaan Mitra',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: AppTheme.mutedText(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(status: v.sistemKerja),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Short Description
                                  Expanded(
                                    child: Text(
                                      v.deskripsi,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context), height: 1.45),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Details Chips
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 6,
                                    children: [
                                      _infoTag(context, LucideIcons.mapPin, v.lokasi),
                                      _infoTag(context, LucideIcons.clock, '${v.durasiBulan} Bulan'),
                                      _infoTag(context, LucideIcons.users, 'Kuota: ${v.kuota}'),
                                      _infoTag(context, LucideIcons.calendar, 'Deadline: ${DateFormat('dd MMM').format(v.batasPendaftaran)}'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => context.go('/peserta/lowongan/${v.id}'),
                                          child: const Text('Detail Lengkap'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => context.go('/peserta/daftar/${v.id}'),
                                          child: const Text('Daftar Magang'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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

  Widget _infoTag(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: AppTheme.mutedText(context)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary(context), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
