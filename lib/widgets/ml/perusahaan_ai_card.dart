import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_match_result.dart';
import '../../providers/ai_matcher_provider.dart';

class PerusahaanAICard extends ConsumerStatefulWidget {
  const PerusahaanAICard({super.key});

  @override
  ConsumerState<PerusahaanAICard> createState() => _PerusahaanAICardState();
}

class _PerusahaanAICardState extends ConsumerState<PerusahaanAICard> {
  // ID lowongan yang sedang di-evaluasi (default: lowongan pertama)
  String _selectedVacancyId = 'vac-1';
  // Index pelamar yang sedang di-expand untuk detail
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final matchResultsAsync = ref.watch(aiMatchResultsProvider(_selectedVacancyId));

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context), width: 1.1),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 16),
          Divider(color: AppTheme.borderSubtleColor(context), height: 1),
          const SizedBox(height: 16),

          // Content
          matchResultsAsync.when(
            loading: () => _buildLoadingState(context),
            error: (err, _) => _buildErrorState(context, err.toString()),
            data: (results) => results.isEmpty
                ? _buildEmptyState(context)
                : _buildResultsList(context, results, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF10B981), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    'AI Smart Candidate Matcher',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.text(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.zap, size: 10, color: Color(0xFF10B981)),
                        SizedBox(width: 3),
                        Text(
                          'Otomatis',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Evaluasi otomatis kecocokan pelamar berdasarkan data profil riil dengan SVM, Logistic Regression & Naive Bayes',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Refresh button
        IconButton(
          onPressed: () => ref.invalidate(aiMatchResultsProvider(_selectedVacancyId)),
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          tooltip: 'Evaluasi ulang semua pelamar',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
            foregroundColor: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFF10B981),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI sedang mengevaluasi pelamar...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mencocokkan keahlian, menghitung skor SVM, Logistic Regression, dan Naive Bayes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppTheme.lightText(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gagal mengevaluasi pelamar: $error',
              style: const TextStyle(fontSize: 12.5, color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.users, size: 36, color: AppTheme.lightText(context)),
            const SizedBox(height: 10),
            Text(
              'Belum ada pelamar untuk dievaluasi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<AIMatchResult> results, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary bar
        _buildSummaryBar(context, results),
        const SizedBox(height: 14),

        // Ranked list
        ...List.generate(results.length, (index) {
          final result = results[index];
          final isExpanded = _expandedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildApplicantCard(context, result, index + 1, isExpanded, isMobile, () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            }),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryBar(BuildContext context, List<AIMatchResult> results) {
    final sangatRekomen = results.where((r) => r.compositeLabel == 'Sangat Direkomendasikan').length;
    final rekomen = results.where((r) => r.compositeLabel == 'Direkomendasikan').length;
    final perlu = results.where((r) => r.compositeLabel == 'Perlu Pertimbangan').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.barChart3, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 10),
          Text(
            '${results.length} Pelamar Dievaluasi AI',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          _buildMiniStat('⭐', '$sangatRekomen', const Color(0xFF10B981)),
          const SizedBox(width: 10),
          _buildMiniStat('✓', '$rekomen', const Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          _buildMiniStat('?', '$perlu', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(
          count,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildApplicantCard(
    BuildContext context,
    AIMatchResult result,
    int rank,
    bool isExpanded,
    bool isMobile,
    VoidCallback onTap,
  ) {
    final tierColor = _getTierColor(result.compositeLabel);
    final scoreColor = _getScoreColor(result.compositeScore);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isExpanded
            ? tierColor.withValues(alpha: 0.06)
            : AppTheme.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? tierColor.withValues(alpha: 0.4) : AppTheme.border(context),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Main row (always visible)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? tierColor.withValues(alpha: 0.15)
                          : AppTheme.bgSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: rank <= 3 ? tierColor : AppTheme.mutedText(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & position
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.applicantName,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${result.matchedSkillsCount}/${result.totalRequiredSkills} Skill Cocok • ${result.predictedDomain}',
                          style: TextStyle(fontSize: 11, color: AppTheme.mutedText(context)),
                        ),
                      ],
                    ),
                  ),

                  // Score circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scoreColor.withValues(alpha: 0.12),
                      border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        result.compositeScore.round().toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      result.compositeLabel == 'Sangat Direkomendasikan'
                          ? '⭐ Sangat Cocok'
                          : (result.compositeLabel == 'Direkomendasikan'
                              ? '✓ Cocok'
                              : '? Pertimbangan'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: AppTheme.mutedText(context),
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail panel
          if (isExpanded) ...[
            Divider(color: AppTheme.borderSubtleColor(context), height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _buildExpandedDetail(context, result, isMobile),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(BuildContext context, AIMatchResult result, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Model scores in a grid
        isMobile
            ? Column(
                children: [
                  _buildModelScoreCard(
                    context,
                    icon: LucideIcons.shieldCheck,
                    title: 'SVM Matcher',
                    value: result.svmTier,
                    subtitle: 'Confidence: ${(result.svmConfidence * 100).toStringAsFixed(1)}%',
                    color: _getTierColor(result.svmTier == 'Sangat Cocok'
                        ? 'Sangat Direkomendasikan'
                        : (result.svmTier == 'Cukup Sesuai' ? 'Direkomendasikan' : 'Perlu Pertimbangan')),
                  ),
                  const SizedBox(height: 8),
                  _buildModelScoreCard(
                    context,
                    icon: LucideIcons.checkCircle2,
                    title: 'Logistic Regression',
                    value: '${result.acceptanceProbability.round()}% Peluang',
                    subtitle: result.isLikelyAccepted ? 'Prediksi: Layak Diterima' : 'Prediksi: Perlu Peningkatan',
                    color: result.isLikelyAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 8),
                  _buildModelScoreCard(
                    context,
                    icon: LucideIcons.compass,
                    title: 'Naive Bayes',
                    value: result.predictedDomain,
                    subtitle: 'Confidence: ${(result.domainConfidence * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildModelScoreCard(
                      context,
                      icon: LucideIcons.shieldCheck,
                      title: 'SVM Matcher',
                      value: result.svmTier,
                      subtitle: 'Confidence: ${(result.svmConfidence * 100).toStringAsFixed(1)}%',
                      color: _getTierColor(result.svmTier == 'Sangat Cocok'
                          ? 'Sangat Direkomendasikan'
                          : (result.svmTier == 'Cukup Sesuai' ? 'Direkomendasikan' : 'Perlu Pertimbangan')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModelScoreCard(
                      context,
                      icon: LucideIcons.checkCircle2,
                      title: 'Logistic Reg.',
                      value: '${result.acceptanceProbability.round()}% Peluang',
                      subtitle: result.isLikelyAccepted ? 'Layak Diterima' : 'Perlu Peningkatan',
                      color: result.isLikelyAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModelScoreCard(
                      context,
                      icon: LucideIcons.compass,
                      title: 'Naive Bayes',
                      value: result.predictedDomain,
                      subtitle: 'Conf: ${(result.domainConfidence * 100).toStringAsFixed(1)}%',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),

        const SizedBox(height: 12),

        // Skill match detail
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
                    'Analisis Kecocokan Keahlian (${result.skillMatchPercentage.round()}%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.skillMatchPercentage / 100,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  color: _getScoreColor(result.skillMatchPercentage),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              if (result.matchedSkills.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: result.matchedSkills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '✓ $skill',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                    ),
                  )).toList(),
                ),
              ],
              if (result.missingSkills.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: result.missingSkills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '✗ $skill',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Profil info
        if (result.universitas != null || result.programStudi != null)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.graduationCap, size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${result.programStudi ?? ""}${result.universitas != null ? " • ${result.universitas}" : ""} • Est. IPK: ${result.ipk?.toStringAsFixed(2) ?? "-"}',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModelScoreCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.mutedText(context)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: AppTheme.lightText(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String label) {
    switch (label) {
      case 'Sangat Direkomendasikan':
        return const Color(0xFF10B981);
      case 'Direkomendasikan':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
