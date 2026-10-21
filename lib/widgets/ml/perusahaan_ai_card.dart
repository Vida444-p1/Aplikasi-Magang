import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ml_provider.dart';

class PerusahaanAICard extends ConsumerStatefulWidget {
  const PerusahaanAICard({super.key});

  @override
  ConsumerState<PerusahaanAICard> createState() => _PerusahaanAICardState();
}

class _PerusahaanAICardState extends ConsumerState<PerusahaanAICard> {
  // SVM Candidate Matcher State
  double _svmSkillMatch = 85.0;
  double _svmTeknis = 80.0;
  double _svmWawancara = 85.0;
  int _svmProyek = 3;
  double _svmIpk = 3.7;
  Map<String, dynamic>? _svmResult;
  bool _svmLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSVM();
    });
  }

  Future<void> _runSVM() async {
    setState(() => _svmLoading = true);
    final service = ref.read(mlServiceProvider);
    final res = await service.evaluateCandidateSVM(
      skillMatchScore: _svmSkillMatch,
      tesTeknisScore: _svmTeknis,
      wawancaraScore: _svmWawancara,
      jumlahProyekRelevan: _svmProyek,
      ipk: _svmIpk,
    );
    if (mounted) setState(() { _svmResult = res; _svmLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

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
          Row(
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
                    Row(
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Job Mitra Perusahaan',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Model SVM (Support Vector Machine) untuk seleksi & pemeringkatan kecocokan pelamar',
                      style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.borderSubtleColor(context), height: 1),
          const SizedBox(height: 16),

          // Two-column simulation: controls & result
          isMobile
              ? Column(
                  children: [
                    _buildControls(),
                    const SizedBox(height: 14),
                    _buildResultBox(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildControls()),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildResultBox(context)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderRow('Kesesuaian Skill:', '${_svmSkillMatch.round()}%', _svmSkillMatch, 30, 100, (v) {
          setState(() => _svmSkillMatch = v.roundToDouble());
        }),
        _buildSliderRow('Tes Teknis / Kuis:', '${_svmTeknis.round()}%', _svmTeknis, 30, 100, (v) {
          setState(() => _svmTeknis = v.roundToDouble());
        }),
        _buildSliderRow('Wawancara / Soft-skill:', '${_svmWawancara.round()}%', _svmWawancara, 30, 100, (v) {
          setState(() => _svmWawancara = v.roundToDouble());
        }),
        _buildSliderRow('Jumlah Proyek:', '$_svmProyek Proyek', _svmProyek.toDouble(), 0, 8, (v) {
          setState(() => _svmProyek = v.round());
        }),
        _buildSliderRow('IPK Pelamar:', _svmIpk.toStringAsFixed(2), _svmIpk, 2.0, 4.0, (v) {
          setState(() => _svmIpk = double.parse(v.toStringAsFixed(2)));
        }),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _svmLoading ? null : _runSVM,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          ),
          icon: _svmLoading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(LucideIcons.shieldCheck, size: 15),
          label: const Text('Hitung Evaluasi Kecocokan (SVM)'),
        ),
      ],
    );
  }

  Widget _buildResultBox(BuildContext context) {
    if (_svmResult == null) {
      return const SizedBox();
    }

    final isMatch = _svmResult!['match_tier'] == 'Sangat Cocok';
    final accentColor = isMatch ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.award, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hasil Pemeringkatan SVM:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(
                      _svmResult!['match_tier'] ?? 'Sangat Cocok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _svmResult!['summary'] ?? 'Kandidat memiliki profil yang sangat selaras dengan kualifikasi magang perusahaan.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context), height: 1.4),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Margin Decision Boundary: ${((_svmResult!['confidence'] ?? 0.95) * 100).toStringAsFixed(1)}% Confidence',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, String valueStr, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 155,
            child: Text('$label $valueStr', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                activeColor: const Color(0xFF10B981),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
