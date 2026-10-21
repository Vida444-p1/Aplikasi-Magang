import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ml_provider.dart';

class AdminAICard extends ConsumerStatefulWidget {
  const AdminAICard({super.key});

  @override
  ConsumerState<AdminAICard> createState() => _AdminAICardState();
}

class _AdminAICardState extends ConsumerState<AdminAICard> {
  final TextEditingController _logbookController = TextEditingController(
    text: 'Hari ini berhasil menyelesaikan implementasi modul machine learning dan seluruh unit testing berjalan lancar.',
  );
  Map<String, dynamic>? _sentimentResult;
  Map<String, dynamic>? _domainResult;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  @override
  void dispose() {
    _logbookController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    setState(() => _loading = true);
    final service = ref.read(mlServiceProvider);
    final text = _logbookController.text.trim();
    final sent = await service.analyzeSentimentNaiveBayes(text);
    final dom = await service.classifyDomainNaiveBayes(text);
    if (mounted) {
      setState(() {
        _sentimentResult = sent;
        _domainResult = dom;
        _loading = false;
      });
    }
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.messageSquareText, color: Color(0xFF8B5CF6), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AI Logbook & Sentiment Analytics',
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
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Job Koordinator Magang',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Model Naive Bayes untuk klasifikasi bidang minat & monitoring otomatis sentimen jurnal mahasiswa',
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

          // Two-column simulation
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputSection(context),
                    const SizedBox(height: 14),
                    _buildResultBox(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildInputSection(context)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _buildResultBox(context)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uji Catatan Logbook / Jurnal Mahasiswa:',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _logbookController,
          maxLines: 3,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ketik aktivitas kegiatan logbook...',
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        // Preset sample chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildSampleChip(
              'Preset Positif',
              'Hari ini implementasi fitur selesai tepat waktu dan mentor sangat puas dengan progres kerja.',
            ),
            _buildSampleChip(
              'Preset Kendala',
              'Mengalami kendala error server database berulang kali sehingga penyelesaian tugas tertunda.',
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _loading ? null : _runAnalysis,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          icon: _loading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(LucideIcons.sparkle, size: 14),
          label: const Text('Analisis Klasifikasi & Sentimen'),
        ),
      ],
    );
  }

  Widget _buildSampleChip(String label, String text) {
    return InkWell(
      onTap: () {
        _logbookController.text = text;
        _runAnalysis();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.bgSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context)),
        ),
      ),
    );
  }

  Widget _buildResultBox(BuildContext context) {
    if (_sentimentResult == null) {
      return const SizedBox();
    }

    final sentiment = _sentimentResult!['sentiment'] ?? 'Netral';
    final isKendala = sentiment == 'Kendala';
    final isPositif = sentiment == 'Positif';
    final accentColor = isKendala ? AppTheme.danger : (isPositif ? AppTheme.success : AppTheme.info);

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
              Icon(
                isKendala ? LucideIcons.alertTriangle : (isPositif ? LucideIcons.smile : LucideIcons.meh),
                color: accentColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hasil Sentimen Jurnal:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(
                      sentiment,
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
          const SizedBox(height: 10),
          Text(
            _sentimentResult!['advice'] ?? '',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context), height: 1.4),
          ),
          if (_domainResult != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.compass, size: 14, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Spesialisasi Terdeteksi: ${_domainResult!['predicted_domain']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
