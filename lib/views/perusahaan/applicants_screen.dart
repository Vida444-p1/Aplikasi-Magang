import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/application_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class ApplicantsScreen extends ConsumerStatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  ConsumerState<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends ConsumerState<ApplicantsScreen> {
  String _selectedFilter = 'semua';

  @override
  Widget build(BuildContext context) {
    final applicantsAsync = ref.watch(applicantsByVacancyProvider('vac-1'));

    return ResponsiveScaffold(
      title: 'Data Pendaftar Magang',
      currentRoute: '/perusahaan/pelamar',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Pelamar',
          onPressed: () => ref.invalidate(applicantsByVacancyProvider('vac-1')),
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
                        'Seleksi & Peninjauan Berkas Pelamar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tinjau portofolio, Curriculum Vitae, dan tentukan status seleksi pendaftar magang.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.users, size: 15, color: AppTheme.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Posisi: Semua Lowongan',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterPill(context, 'semua', 'Semua Berkas'),
                  const SizedBox(width: 8),
                  _filterPill(context, 'menunggu', 'Menunggu Review'),
                  const SizedBox(width: 8),
                  _filterPill(context, 'diproses', 'Sedang Diproses'),
                  const SizedBox(width: 8),
                  _filterPill(context, 'diterima', 'Diterima 🎉'),
                  const SizedBox(width: 8),
                  _filterPill(context, 'ditolak', 'Ditolak'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            applicantsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (applicants) {
                final filtered = applicants.where((a) {
                  if (_selectedFilter == 'semua') return true;
                  return a.status.toLowerCase() == _selectedFilter;
                }).toList();

                if (filtered.isEmpty) {
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
                            child: Icon(LucideIcons.userX, size: 36, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'semua'
                                ? 'Belum ada berkas pelamar yang masuk'
                                : 'Tidak ada pelamar dengan status "$_selectedFilter"',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Berkas yang didaftarkan mahasiswa akan otomatis muncul di sini.',
                            style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final app = filtered[index];
                    final name = app.namaPeserta ?? 'Vida Rizki Prasetyo';
                    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'P';

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
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primary, AppTheme.primaryLight],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstLetter,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.text(context),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Melamar untuk: ${app.vacancy?.posisi ?? 'Flutter Developer Intern'}',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        app.emailPeserta ?? 'vidar@student.uii.ac.id',
                                        style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: app.status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(LucideIcons.calendar, size: 14, color: AppTheme.lightText(context)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Mendaftar: ${DateFormat('dd MMMM yyyy, HH:mm').format(app.tanggalDaftar)} WIB',
                                      style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/perusahaan/pelamar/${app.id}'),
                                  icon: const Icon(LucideIcons.fileSearch, size: 15),
                                  label: const Text('Review Berkas & Keputusan'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
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

  Widget _filterPill(BuildContext context, String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border(context),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.mutedText(context),
          ),
        ),
      ),
    );
  }
}
