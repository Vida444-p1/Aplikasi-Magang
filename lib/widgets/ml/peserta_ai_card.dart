import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ml_provider.dart';

class PesertaAICard extends ConsumerStatefulWidget {
  const PesertaAICard({super.key});

  @override
  ConsumerState<PesertaAICard> createState() => _PesertaAICardState();
}

class _PesertaAICardState extends ConsumerState<PesertaAICard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Linear Regression (Prediksi Uang Saku)
  int _lrDurasi = 4;
  int _lrJam = 40;
  int _lrSkills = 5;
  String _lrIndustri = 'Teknologi';
  String _lrTipe = 'Hybrid';
  Map<String, dynamic>? _lrResult;
  bool _lrLoading = false;

  // 2. Logistic Regression (Peluang Lolos Seleksi)
  double _logIpk = 3.65;
  bool _logJurusan = true;
  int _logSkills = 5;
  double _logPortofolio = 85.0;
  int _logOrganisasi = 2;
  Map<String, dynamic>? _logResult;
  bool _logLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runLinearRegression();
      _runLogisticRegression();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runLinearRegression() async {
    setState(() => _lrLoading = true);
    final service = ref.read(mlServiceProvider);
    final res = await service.predictLinearRegression(
      durasiBulan: _lrDurasi,
      jamPerMinggu: _lrJam,
      jumlahSkills: _lrSkills,
      industri: _lrIndustri,
      tipeKerja: _lrTipe,
    );
    if (mounted) setState(() { _lrResult = res; _lrLoading = false; });
  }

  Future<void> _runLogisticRegression() async {
    setState(() => _logLoading = true);
    final service = ref.read(mlServiceProvider);
    final res = await service.predictLogisticRegression(
      ipk: _logIpk,
      kesesuaianJurusan: _logJurusan,
      matchingSkillsCount: _logSkills,
      skorPortofolio: _logPortofolio,
      pengalamanOrganisasi: _logOrganisasi,
    );
    if (mounted) setState(() { _logResult = res; _logLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context), width: 1.1),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.sparkles, color: Color(0xFF2563EB), size: 18),
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
                                'AI Assistant Mahasiswa',
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
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Job Mahasiswa',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Simulasi estimasi uang saku magang & evaluasi mandiri peluang lolos seleksi',
                            style: TextStyle(fontSize: 12, color: AppTheme.mutedText(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Sub-tabs
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.mutedText(context),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    tabs: const [
                      Tab(
                        iconMargin: EdgeInsets.zero,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.trendingUp, size: 14),
                                SizedBox(width: 6),
                                Text('1. Prediksi Uang Saku'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        iconMargin: EdgeInsets.zero,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.checkCircle2, size: 14),
                                SizedBox(width: 6),
                                Text('2. Peluang Lolos Seleksi'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content Box
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: SizedBox(
              height: isMobile ? 470 : 410,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLinearRegressionView(context, isMobile),
                  _buildLogisticRegressionView(context, isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. LINEAR REGRESSION VIEW
  Widget _buildLinearRegressionView(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSliderRow('Durasi Magang:', '$_lrDurasi Bulan', _lrDurasi.toDouble(), 1, 12, (v) {
                      setState(() => _lrDurasi = v.round());
                    }, isMobile: isMobile),
                    _buildSliderRow('Jam Kerja / Minggu:', '$_lrJam Jam', _lrJam.toDouble(), 15, 45, (v) {
                      setState(() => _lrJam = v.round());
                    }, isMobile: isMobile),
                    _buildSliderRow('Jumlah Skill Dikuasai:', '$_lrSkills Skill', _lrSkills.toDouble(), 1, 10, (v) {
                      setState(() => _lrSkills = v.round());
                    }, isMobile: isMobile),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _lrIndustri,
                    decoration: const InputDecoration(
                      labelText: 'Industri',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pendidikan', child: Text('Pendidikan', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Manufaktur', child: Text('Manufaktur', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Teknologi', child: Text('Teknologi', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _lrIndustri = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _lrTipe,
                    decoration: const InputDecoration(
                      labelText: 'Sistem Kerja',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'WFH', child: Text('WFH (Remote)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'WFO', child: Text('WFO (Onsite)', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _lrTipe = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _lrLoading ? null : _runLinearRegression,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _lrLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(LucideIcons.calculator, size: 15),
                label: const Text('Hitung Estimasi Uang Saku', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _lrIndustri,
                    decoration: const InputDecoration(
                      labelText: 'Industri',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Pendidikan', child: Text('Pendidikan', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Manufaktur', child: Text('Manufaktur', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Teknologi', child: Text('Teknologi', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _lrIndustri = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _lrTipe,
                    decoration: const InputDecoration(
                      labelText: 'Sistem Kerja',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'WFH', child: Text('WFH (Remote)', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'WFO', child: Text('WFO (Onsite)', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _lrTipe = v!),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _lrLoading ? null : _runLinearRegression,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  icon: _lrLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.calculator, size: 14),
                  label: const Text('Hitung'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Output Result Box
          if (_lrResult != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.coins, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimasi Rekomendasi Uang Saku Bulanan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        Text(
                          _lrResult!['formatted_stipend'] ?? 'Rp 0',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lrResult!['analysis'] ?? '',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 2. LOGISTIC REGRESSION VIEW
  Widget _buildLogisticRegressionView(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSliderRow('IPK Mahasiswa:', _logIpk.toStringAsFixed(2), _logIpk, 2.0, 4.0, (v) {
                      setState(() => _logIpk = double.parse(v.toStringAsFixed(2)));
                    }, isMobile: isMobile),
                    _buildSliderRow('Skill yang Cocok:', '$_logSkills Skill', _logSkills.toDouble(), 0, 8, (v) {
                      setState(() => _logSkills = v.round());
                    }, isMobile: isMobile),
                    _buildSliderRow('Skor Portofolio:', '${_logPortofolio.round()}%', _logPortofolio, 30, 100, (v) {
                      setState(() => _logPortofolio = v.roundToDouble());
                    }, isMobile: isMobile),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile) ...[
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Jurusan Kuliah Linier dengan Posisi Magang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              value: _logJurusan,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _logJurusan = v ?? true),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logLoading ? null : _runLogisticRegression,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _logLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(LucideIcons.scanLine, size: 15),
                label: const Text('Cek Peluang Kelolosan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jurusan Kuliah Linier dengan Posisi Magang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    value: _logJurusan,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => _logJurusan = v ?? true),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _logLoading ? null : _runLogisticRegression,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: _logLoading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.scanLine, size: 14),
                  label: const Text('Cek Peluang'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),

          // Output Result Box
          if (_logResult != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (_logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _logResult!['is_accepted'] == true ? LucideIcons.checkCheck : LucideIcons.alertTriangle,
                        color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Peluang Kelolosan: ${_logResult!['status']} (${_logResult!['percentage']}%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (_logResult!['percentage'] as num).toDouble() / 100.0,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ((_logResult!['recommendation'] as List?) ?? []).join('\n'),
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, String valueStr, double value, double min, double max, ValueChanged<double> onChanged, {bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 130 : 145,
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
                activeColor: AppTheme.primary,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
