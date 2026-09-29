import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  String _selectedFilter = 'semua';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final pesertaId = authState.userProfile?.pesertaDetails?.id ?? 'pes-1';
    final applicationsAsync = ref.watch(myApplicationsProvider(pesertaId));
    final isDark = AppTheme.isDark(context);

    return ResponsiveScaffold(
      title: 'Status Lamaran Saya',
      currentRoute: '/peserta/pendaftaran',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Data',
          onPressed: () => ref.invalidate(myApplicationsProvider(pesertaId)),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(myApplicationsProvider(pesertaId)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title & description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Pendaftaran Magang',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppTheme.text(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pantau perkembangan status lamaran dari proses seleksi berkas hingga pengumuman penerimaan.',
                          style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/peserta/lowongan'),
                    icon: const Icon(LucideIcons.compass, size: 16),
                    label: const Text('Jelajah Lowongan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(context, 'semua', 'Semua Status'),
                    const SizedBox(width: 8),
                    _filterChip(context, 'menunggu', 'Menunggu'),
                    const SizedBox(width: 8),
                    _filterChip(context, 'diproses', 'Diproses'),
                    const SizedBox(width: 8),
                    _filterChip(context, 'diterima', 'Diterima 🎉'),
                    const SizedBox(width: 8),
                    _filterChip(context, 'ditolak', 'Ditolak'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              applicationsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('Gagal memuat lamaran: $err', style: const TextStyle(color: AppTheme.danger)),
                  ),
                ),
                data: (apps) {
                  final filteredApps = apps.where((app) {
                    if (_selectedFilter == 'semua') return true;
                    return app.status.toLowerCase() == _selectedFilter;
                  }).toList();

                  if (filteredApps.isEmpty) {
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
                              child: Icon(LucideIcons.inbox, size: 36, color: AppTheme.mutedText(context)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'semua'
                                  ? 'Belum ada berkas lamaran yang diajukan'
                                  : 'Tidak ada lamaran dengan status "$_selectedFilter"',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.text(context)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Cari peluang magang impian Anda dan kirimkan berkas lamaran sekarang.',
                              style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/peserta/lowongan'),
                              icon: const Icon(LucideIcons.search, size: 16),
                              label: const Text('Cari Lowongan Sekarang'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredApps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      final vac = app.vacancy;
                      final isAccepted = app.status.toLowerCase() == 'diterima';
                      final isRejected = app.status.toLowerCase() == 'ditolak';

                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAccepted
                                ? AppTheme.success.withValues(alpha: 0.4)
                                : isRejected
                                    ? AppTheme.danger.withValues(alpha: 0.3)
                                    : AppTheme.border(context),
                            width: isAccepted ? 1.5 : 1,
                          ),
                          boxShadow: AppTheme.getCardShadow(context),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar: Company info & status badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isAccepted
                                          ? AppTheme.success.withValues(alpha: 0.15)
                                          : AppTheme.primaryLight.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isAccepted
                                            ? AppTheme.success.withValues(alpha: 0.3)
                                            : AppTheme.primary.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isAccepted ? LucideIcons.checkCircle : LucideIcons.briefcase,
                                        color: isAccepted ? AppTheme.success : AppTheme.primary,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vac?.posisi ?? 'Posisi Magang',
                                          style: TextStyle(
                                            fontSize: 16.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.text(context),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(LucideIcons.building2, size: 13, color: AppTheme.mutedText(context)),
                                            const SizedBox(width: 5),
                                            Text(
                                              vac?.namaPerusahaan ?? 'Perusahaan Mitra',
                                              style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context), fontWeight: FontWeight.w500),
                                            ),
                                            if (vac?.lokasi != null) ...[
                                              const SizedBox(width: 10),
                                              Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                              const SizedBox(width: 10),
                                              Icon(LucideIcons.mapPin, size: 13, color: AppTheme.mutedText(context)),
                                              const SizedBox(width: 4),
                                              Text(
                                                vac!.lokasi,
                                                style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: app.status),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Pipeline Progress Tracker
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceElevated(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border(context)),
                                ),
                                child: _buildModernPipeline(context, app.status),
                              ),
                              const SizedBox(height: 16),

                              // If Accepted: Celebratory banner
                              if (isAccepted) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.success.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(LucideIcons.sparkles, color: AppTheme.success, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Selamat! Anda Diterima Magang',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Segera mulai pencatatan aktivitas kerja harian pada menu Logbook.',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => context.go('/peserta/kegiatan'),
                                        icon: const Icon(LucideIcons.bookOpen, size: 15),
                                        label: const Text('Buka Logbook'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.success,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Notes from company (if present)
                              if (app.catatanPerusahaan != null && app.catatanPerusahaan!.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isRejected
                                        ? (isDark ? const Color(0xFF4C0519).withValues(alpha: 0.3) : const Color(0xFFFFF1F2))
                                        : AppTheme.surfaceElevated(context),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isRejected ? AppTheme.danger.withValues(alpha: 0.3) : AppTheme.border(context),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isRejected ? LucideIcons.alertCircle : LucideIcons.messageSquare,
                                        size: 16,
                                        color: isRejected ? AppTheme.danger : AppTheme.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Catatan dari Perusahaan:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isRejected ? AppTheme.danger : AppTheme.text(context),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              app.catatanPerusahaan!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isRejected
                                                    ? (isDark ? const Color(0xFFFDA4AF) : const Color(0xFF9F1239))
                                                    : AppTheme.mutedText(context),
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Footer: submission timestamp & details
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(LucideIcons.clock, size: 13, color: AppTheme.lightText(context)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Diajukan pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(app.tanggalDaftar)} WIB',
                                        style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                      ),
                                    ],
                                  ),
                                  if (vac?.sistemKerja != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceElevated(context),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.border(context)),
                                      ),
                                      child: Text(
                                        vac!.sistemKerja.toUpperCase(),
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.mutedText(context)),
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
      ),
    );
  }

  Widget _filterChip(BuildContext context, String key, String label) {
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

  Widget _buildModernPipeline(BuildContext context, String currentStatus) {
    final isRejected = currentStatus.toLowerCase() == 'ditolak';

    int currentStepIndex = 0;
    if (currentStatus.toLowerCase() == 'diproses') currentStepIndex = 1;
    if (currentStatus.toLowerCase() == 'diterima') currentStepIndex = 2;

    if (isRejected) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.xCircle, color: AppTheme.danger, size: 16),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Status: Tidak lolos seleksi berkas/tahap akhir',
              style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _pipelineStep(context, '1. Berkas Diajukan', currentStepIndex >= 0, currentStepIndex == 0),
        _pipelineDivider(context, currentStepIndex >= 1),
        _pipelineStep(context, '2. Ditinjau HRD', currentStepIndex >= 1, currentStepIndex == 1),
        _pipelineDivider(context, currentStepIndex >= 2),
        _pipelineStep(context, '3. Diterima Magang', currentStepIndex >= 2, currentStepIndex == 2),
      ],
    );
  }

  Widget _pipelineStep(BuildContext context, String title, bool isDone, bool isCurrent) {
    final color = isDone
        ? (isCurrent ? AppTheme.primary : AppTheme.success)
        : AppTheme.lightText(context);

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? color : AppTheme.surfaceElevated(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? color : AppTheme.border(context),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              isDone ? LucideIcons.check : LucideIcons.circle,
              size: 12,
              color: isDone ? Colors.white : AppTheme.lightText(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            color: isDone ? AppTheme.text(context) : AppTheme.lightText(context),
          ),
        ),
      ],
    );
  }

  Widget _pipelineDivider(BuildContext context, bool isDone) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 2,
        decoration: BoxDecoration(
          color: isDone ? AppTheme.success : AppTheme.border(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
