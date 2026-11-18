import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_match_result.dart';
import '../../providers/application_provider.dart';
import '../../providers/ai_matcher_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  final String applicantId;

  const ApplicantDetailScreen({super.key, required this.applicantId});

  @override
  ConsumerState<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  final _catatanCtrl = TextEditingController(text: 'Profil dan portofolio sangat sesuai dengan kualifikasi yang dicari.');
  String _selectedStatus = 'diterima';
  bool _isLoading = false;
  bool _initialized = false;

  void _updateStatus() async {
    setState(() => _isLoading = true);

    final success = await ref.read(applicationServiceProvider).updateApplicationStatus(
      pendaftaranId: widget.applicantId,
      newStatus: _selectedStatus,
      catatan: _catatanCtrl.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      // Invalidate semua provider pelamar & pendaftaran agar UI langsung ter-refresh
      ref.invalidate(applicantsByVacancyProvider);
      ref.invalidate(myApplicationsProvider);
      ref.invalidate(applicationDetailProvider(widget.applicantId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pelamar berhasil diubah menjadi: ${_selectedStatus.toUpperCase()}! Notifikasi otomatis terkirim.'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/perusahaan/pelamar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appAsync = ref.watch(applicationDetailProvider(widget.applicantId));
    final app = appAsync.valueOrNull;

    if (app != null && !_initialized) {
      _selectedStatus = app.status;
      if (app.catatanPerusahaan != null && app.catatanPerusahaan!.isNotEmpty) {
        _catatanCtrl.text = app.catatanPerusahaan!;
      }
      _initialized = true;
    }

    final name = app?.namaPeserta ?? 'Vida Rizki Prasetyo';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';
    final posisi = app?.vacancy?.posisi ?? 'Web Developer';
    final currentStatus = app?.status ?? _selectedStatus;

    return ResponsiveScaffold(
      title: 'Review Berkas Pelamar',
      currentRoute: '/perusahaan/pelamar',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                InkWell(
                  onTap: () => context.go('/perusahaan/pelamar'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.arrowLeft, size: 16, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text('Kembali ke Daftar Pelamar', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Profile Pelamar
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.text(context), letterSpacing: -0.3),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Melamar untuk: $posisi',
                                  style: const TextStyle(fontSize: 13.5, color: AppTheme.primary, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  app?.emailPeserta ?? 'vidar@student.uii.ac.id',
                                  style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: currentStatus),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(LucideIcons.fileText, size: 17, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text('Dokumen & Berkas Persyaratan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppTheme.text(context))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _documentItem(context, LucideIcons.fileText, 'Curriculum Vitae (CV Pelamar)', app?.cvUrl.split('/').last ?? 'cv-vidar.pdf', app?.cvUrl ?? ''),
                      const SizedBox(height: 10),
                      _documentItem(context, LucideIcons.mail, 'Surat Pengantar Magang Kampus', app?.suratPengantarUrl?.split('/').last ?? 'surat-kampus.pdf', app?.suratPengantarUrl ?? ''),
                      const SizedBox(height: 10),
                      _documentItem(context, LucideIcons.globe, 'Portofolio Online & Proyek GitHub', app?.portofolioUrl ?? 'github.com/vidar', app?.portofolioUrl ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // AI Match Score Card (Otomatis)
                _buildAIScoreCard(context, ref, app?.lowonganId ?? 'vac-1'),
                const SizedBox(height: 22),

                // Decision Form Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.scale, size: 18, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keputusan Seleksi Calon Magang',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                              ),
                              Text(
                                'Perubahan status akan diproses oleh Supabase Edge Function dan diteruskan via notifikasi.',
                                style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      Text('Tentukan Status Keputusan:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          _statusOption(context, 'menunggu', 'Menunggu', LucideIcons.clock, AppTheme.warning),
                          _statusOption(context, 'diproses', 'Sedang Diproses', LucideIcons.loader, AppTheme.info),
                          _statusOption(context, 'diterima', 'Diterima Magang 🎉', LucideIcons.checkCircle2, AppTheme.success),
                          _statusOption(context, 'ditolak', 'Ditolak', LucideIcons.xCircle, AppTheme.danger),
                        ],
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'Catatan / Alasan untuk Mahasiswa',
                        hint: 'Tuliskan catatan hasil review, instruksi onboarding, atau arahan persiapan...',
                        controller: _catatanCtrl,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Simpan Keputusan & Kirim Notifikasi',
                        isLoading: _isLoading,
                        icon: LucideIcons.send,
                        width: double.infinity,
                        onPressed: _updateStatus,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIScoreCard(BuildContext context, WidgetRef ref, String lowonganId) {
    final aiAsync = ref.watch(singleAIMatchProvider((applicantId: widget.applicantId, lowonganId: lowonganId)));

    return aiAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border(context)),
          boxShadow: AppTheme.getCardShadow(context),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 14),
            Text('AI sedang mengevaluasi kandidat...', style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context))),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) return const SizedBox.shrink();
        return _buildAIScoreContent(context, result);
      },
    );
  }

  Widget _buildAIScoreContent(BuildContext context, AIMatchResult result) {
    final tierColor = result.compositeLabel == 'Sangat Direkomendasikan'
        ? const Color(0xFF10B981)
        : (result.compositeLabel == 'Direkomendasikan'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444));

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tierColor.withValues(alpha: 0.35)),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.sparkles, size: 18, color: tierColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Evaluasi AI Otomatis',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            result.compositeLabel,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: tierColor),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Skor komposit dari SVM, Logistic Regression, dan Naive Bayes',
                      style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                    ),
                  ],
                ),
              ),
              // Skor bulat besar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tierColor.withValues(alpha: 0.12),
                  border: Border.all(color: tierColor, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    result.compositeScore.round().toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: tierColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: AppTheme.borderSubtleColor(context), height: 1),
          const SizedBox(height: 14),

          // 3 Model scores side by side
          Row(
            children: [
              Expanded(
                child: _buildMiniModelScore(context,
                  icon: LucideIcons.shieldCheck,
                  label: 'SVM',
                  value: result.svmTier,
                  color: result.svmTier == 'Sangat Cocok'
                      ? const Color(0xFF10B981)
                      : (result.svmTier == 'Cukup Sesuai' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniModelScore(context,
                  icon: LucideIcons.checkCircle2,
                  label: 'Logistic Reg.',
                  value: '${result.acceptanceProbability.round()}%',
                  color: result.isLikelyAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniModelScore(context,
                  icon: LucideIcons.compass,
                  label: 'Naive Bayes',
                  value: result.predictedDomain,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Skill match bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.puzzle, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Kecocokan Skill: ${result.matchedSkillsCount}/${result.totalRequiredSkills} (${result.skillMatchPercentage.round()}%)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: result.skillMatchPercentage / 100,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    color: result.skillMatchPercentage >= 70
                        ? const Color(0xFF10B981)
                        : (result.skillMatchPercentage >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ...result.matchedSkills.map((s) => _buildSkillChip(s, true)),
                    ...result.missingSkills.map((s) => _buildSkillChip(s, false)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniModelScore(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.mutedText(context)), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, bool matched) {
    final color = matched ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: matched ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${matched ? "✓" : "✗"} $skill',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _documentItem(BuildContext context, IconData icon, String title, String filename, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
                const SizedBox(height: 2),
                Text(filename, style: TextStyle(color: AppTheme.mutedText(context), fontSize: 11.5)),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.externalLink, size: 13),
            label: const Text('Buka', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusOption(BuildContext context, String value, String label, IconData icon, Color color) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.surface(context),
          border: Border.all(
            color: isSelected ? color : AppTheme.border(context),
            width: isSelected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : AppTheme.mutedText(context)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppTheme.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
