import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/activity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_text_field.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  void _openAddActivityDialog(String pesertaId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '8.0');
    DateTime selectedDate = DateTime.now();
    String selectedStatus = 'selesai';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.calendarPlus, color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catat Kegiatan Magang',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                              ),
                              Text(
                                'Dokumentasikan aktivitas harian magang Anda',
                                style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(LucideIcons.x, size: 18, color: AppTheme.mutedText(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                  const SizedBox(height: 20),

                  // Date Picker Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Kegiatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setDialogState(() => selectedDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.border(context)),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppTheme.surfaceElevated(context),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.calendar, size: 16, color: AppTheme.primary),
                                    const SizedBox(width: 10),
                                    Text(
                                      DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          label: 'Durasi (Jam Kerja)',
                          hint: '8.0',
                          controller: durationCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Judul Aktivitas / Tugas',
                    hint: 'Contoh: Pengembangan UI Dashboard Mahasiswa',
                    controller: titleCtrl,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Deskripsi Rinci Pekerjaan',
                    hint: 'Jelaskan tugas yang diselesaikan, kendala yang dihadapi, serta hasil capaian...',
                    controller: descCtrl,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Kegiatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: AppTheme.surfaceElevated(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppTheme.border(context)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppTheme.border(context)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'selesai', child: Text('Selesai Dikerjakan')),
                          DropdownMenuItem(value: 'berjalan', child: Text('Sedang Berjalan (In Progress)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) return;

                          final newActivity = ActivityModel(
                            id: 'act-${DateTime.now().millisecondsSinceEpoch}',
                            pesertaId: pesertaId,
                            tanggal: selectedDate,
                            judulKegiatan: titleCtrl.text.trim(),
                            deskripsiKegiatan: descCtrl.text.trim(),
                            durasiJam: double.tryParse(durationCtrl.text) ?? 8.0,
                            statusKegiatan: selectedStatus,
                          );

                          await ref.read(activityServiceProvider).createActivity(newActivity);
                          ref.invalidate(myActivitiesProvider(pesertaId));
                          ref.invalidate(logbookSummaryProvider(pesertaId));

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kegiatan berhasil ditambahkan ke logbook!'),
                                backgroundColor: AppTheme.success,
                              ),
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Simpan Logbook'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final pesertaId = authState.userProfile?.pesertaDetails?.id ?? 'pes-1';
    final activitiesAsync = ref.watch(myActivitiesProvider(pesertaId));
    final summaryAsync = ref.watch(logbookSummaryProvider(pesertaId));
    final isDark = AppTheme.isDark(context);

    return ResponsiveScaffold(
      title: 'Monitoring Kegiatan (Logbook)',
      currentRoute: '/peserta/kegiatan',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Logbook',
          onPressed: () {
            ref.invalidate(myActivitiesProvider(pesertaId));
            ref.invalidate(logbookSummaryProvider(pesertaId));
          },
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddActivityDialog(pesertaId),
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Catat Kegiatan'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logbook & Monitoring Magang',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Catat dan laporkan progres kerja harian sebagai bukti kegiatan serta bahan evaluasi mentor industri.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _openAddActivityDialog(pesertaId),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Tambah Entri Baru'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logbook Summary Metric Strip
            summaryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (summary) {
                final totalJam = (summary['total_jam'] ?? 128.0) as num;
                final targetJam = 320.0;
                final progress = (totalJam / targetJam).clamp(0.0, 1.0);
                final totalKegiatan = summary['total_kegiatan'] ?? 16;
                final verified = summary['kegiatan_selesai'] ?? 14;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Row(
                    children: [
                      // Total hours with circular indicator
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.clock, color: AppTheme.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${totalJam.toStringAsFixed(0)} Jam',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '/ ${targetJam.toInt()} Jam Target',
                                        style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.surfaceElevated(context),
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: AppTheme.border(context), margin: const EdgeInsets.symmetric(horizontal: 20)),
                      // Total entries
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalKegiatan Entri',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                            ),
                            const SizedBox(height: 2),
                            Text('Total Aktivitas Magang', style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context))),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: AppTheme.border(context), margin: const EdgeInsets.symmetric(horizontal: 20)),
                      // Verified entries
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Disetujui',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.success),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.checkCheck, size: 16, color: AppTheme.success),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('Feedback Diterima: $verified', style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Activity timeline list
            activitiesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Gagal memuat logbook: $err')),
              data: (activities) {
                if (activities.isEmpty) {
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
                            child: Icon(LucideIcons.calendarX, size: 36, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Entri Logbook',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.text(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mulai mencatat kegiatan hari pertama magang Anda untuk dipantau oleh pembimbing.',
                            style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _openAddActivityDialog(pesertaId),
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Catat Kegiatan Pertama'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date badge column
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border(context)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('dd').format(act.tanggal),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.text(context)),
                                  ),
                                  Text(
                                    DateFormat('MMM').format(act.tanggal).toUpperCase(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),

                            // Main Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              act.judulKegiatan,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.text(context),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(LucideIcons.clock, size: 12, color: AppTheme.mutedText(context)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${act.durasiJam} Jam Kerja',
                                                  style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context), fontWeight: FontWeight.w500),
                                                ),
                                                const SizedBox(width: 8),
                                                Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormat('EEEE, yyyy', 'id_ID').format(act.tanggal),
                                                  style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(status: act.statusKegiatan),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Activity description
                                  Text(
                                    act.deskripsiKegiatan,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: AppTheme.textSecondary(context),
                                      height: 1.5,
                                    ),
                                  ),

                                  // Supervisor Feedback (if exists)
                                  if (act.catatanPembimbing != null && act.catatanPembimbing!.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: const Border(
                                          left: BorderSide(color: AppTheme.success, width: 3.5),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(LucideIcons.checkCheck, size: 14, color: AppTheme.success),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Feedback Pembimbing / Supervisor Lapangan:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            act.catatanPembimbing!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
