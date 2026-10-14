import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pdf_export_helper.dart';
import '../../models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';

class InternMonitoringScreen extends ConsumerStatefulWidget {
  const InternMonitoringScreen({super.key});

  @override
  ConsumerState<InternMonitoringScreen> createState() => _InternMonitoringScreenState();
}

class _InternMonitoringScreenState extends ConsumerState<InternMonitoringScreen> {
  void _openEvaluationDialog() {
    double disiplin = 90;
    double teknis = 92;
    double softSkill = 88;
    final catatanCtrl = TextEditingController(
      text: 'Mahasiswa menunjukkan etos kerja yang sangat baik, cepat beradaptasi dengan stack Flutter & Supabase, dan proaktif dalam tim.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final nilaiAkhir = (disiplin * 0.3 + teknis * 0.4 + softSkill * 0.3).round();
          final predikat = nilaiAkhir >= 85
              ? 'Sangat Memuaskan (A)'
              : (nilaiAkhir >= 75 ? 'Memuaskan (B+)' : 'Cukup (B)');

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 560,
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
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.award, color: Colors.amber, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Evaluasi & Sertifikat Magang',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                                ),
                                Text(
                                  'Peserta: Vida Rizki Prasetyo (NIM: 25523013)',
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

                    // Rangkuman Nilai Akhir Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.1),
                            AppTheme.primaryLight.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nilai Evaluasi Akhir:', style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context))),
                              const SizedBox(height: 4),
                              Text('$nilaiAkhir / 100', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Predikat: $predikat',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Slider 1: Kedisiplinan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1. Kedisiplinan & Presensi (30%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
                        Text('${disiplin.toInt()} / 100', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    Slider(
                      value: disiplin,
                      min: 50,
                      max: 100,
                      divisions: 50,
                      onChanged: (val) => setDialogState(() => disiplin = val),
                    ),
                    const SizedBox(height: 8),

                    // Slider 2: Teknis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('2. Keterampilan Teknis (Hard Skill) (40%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
                        Text('${teknis.toInt()} / 100', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    Slider(
                      value: teknis,
                      min: 50,
                      max: 100,
                      divisions: 50,
                      onChanged: (val) => setDialogState(() => teknis = val),
                    ),
                    const SizedBox(height: 8),

                    // Slider 3: Soft Skill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('3. Komunikasi & Kerjasama (Soft Skill) (30%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
                        Text('${softSkill.toInt()} / 100', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                    Slider(
                      value: softSkill,
                      min: 50,
                      max: 100,
                      divisions: 50,
                      onChanged: (val) => setDialogState(() => softSkill = val),
                    ),
                    const SizedBox(height: 14),

                    Text('Catatan Evaluasi / Rekomendasi Mentor:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: catatanCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tuliskan catatan apresiasi, saran pengembangan...',
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Tutup'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await PdfExportHelper.exportCertificatePdf(
                              namaMahasiswa: 'Vida Rizki Prasetyo',
                              namaPerusahaan: 'PT Teknologi Nusantara Digital',
                              posisiMagang: 'Flutter & Mobile Developer Intern',
                              durasiBulan: '6',
                              nilaiAkhir: nilaiAkhir.toString(),
                              predikat: predikat,
                              tanggalSelesai: DateFormat('dd MMMM yyyy').format(DateTime.now()),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sertifikat Magang Digital berhasil diterbitkan!'),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            }
                          },
                          icon: const Icon(LucideIcons.award, size: 16),
                          label: const Text('Simpan & Cetak Sertifikat (PDF)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                      ],
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

  void _openFeedbackDialog(ActivityModel act) {
    final feedbackCtrl = TextEditingController(text: act.catatanPembimbing ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.messageSquare, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Berikan Catatan & Evaluasi',
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                      ),
                      Text(
                        'Catatan akan langsung terlihat oleh mahasiswa di logbook mereka',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: AppTheme.borderSubtleColor(context), height: 1),
              const SizedBox(height: 16),

              Text(
                'Kegiatan: ${act.judulKegiatan}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.text(context)),
              ),
              const SizedBox(height: 4),
              Text(
                'Peserta: ${act.namaPeserta ?? 'Vida Rizki Prasetyo'} • ${DateFormat('dd MMMM yyyy').format(act.tanggal)}',
                style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: feedbackCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan evaluasi, pujian, atau saran pengembangan kerja...',
                  contentPadding: const EdgeInsets.all(14),
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
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newNote = feedbackCtrl.text.trim();
                      if (newNote.isNotEmpty) {
                        await ref.read(activityServiceProvider).addPembimbingFeedback(act.id, newNote);
                        ref.invalidate(allActivitiesProvider);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Catatan pembimbing berhasil disimpan!'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: const Text('Simpan Feedback'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(allActivitiesProvider);
    final isDark = AppTheme.isDark(context);

    return ResponsiveScaffold(
      title: 'Monitoring Logbook Peserta',
      currentRoute: '/perusahaan/monitoring',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Logbook',
          onPressed: () => ref.invalidate(allActivitiesProvider),
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
                        'Aktivitas Harian Peserta Magang',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.text(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pantau riwayat kerja mahasiswa secara berkala, validasi jam kerja, dan berikan bimbingan langsung.',
                        style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openEvaluationDialog,
                      icon: const Icon(LucideIcons.award, size: 15),
                      label: const Text('Evaluasi & Sertifikat Magang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.activity, size: 15, color: AppTheme.success),
                          SizedBox(width: 8),
                          Text(
                            'Status: Monitoring Aktif',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.success),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                            'Belum Ada Aktivitas Logbook Masuk',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.text(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Entri kegiatan yang diinput mahasiswa magang akan otomatis terpampang di sini.',
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
                                    color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.user, size: 20, color: AppTheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        act.judulKegiatan,
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
                                          Text(
                                            'Peserta: ${act.namaPeserta ?? 'Vida Rizki Prasetyo'}',
                                            style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(NIM: ${act.nimPeserta ?? '25523013'})',
                                            style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: AppTheme.lightText(context))),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(act.tanggal)} • ${act.durasiJam} Jam',
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
                            Text(
                              act.deskripsiKegiatan,
                              style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary(context), height: 1.5),
                            ),
                            const SizedBox(height: 14),

                            if (act.catatanPembimbing != null && act.catatanPembimbing!.isNotEmpty) ...[
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
                                          'Catatan Pembimbing Anda:',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      act.catatanPembimbing!,
                                      style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534), height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => _openFeedbackDialog(act),
                                icon: const Icon(LucideIcons.messageSquare, size: 14),
                                label: Text(
                                  act.catatanPembimbing != null && act.catatanPembimbing!.isNotEmpty
                                      ? 'Ubah Catatan / Feedback'
                                      : 'Beri Catatan / Feedback',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                ),
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
