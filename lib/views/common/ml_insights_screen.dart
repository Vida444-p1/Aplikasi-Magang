import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ml_provider.dart';
import '../../widgets/responsive_scaffold.dart';

class MLInsightsScreen extends ConsumerStatefulWidget {
  const MLInsightsScreen({super.key});

  @override
  ConsumerState<MLInsightsScreen> createState() => _MLInsightsScreenState();
}

class _MLInsightsScreenState extends ConsumerState<MLInsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Linear Regression State
  int _lrDurasi = 4;
  int _lrJam = 40;
  int _lrSkills = 5;
  String _lrIndustri = 'Teknologi';
  String _lrTipe = 'Hybrid';
  Map<String, dynamic>? _lrResult;
  bool _lrLoading = false;

  // 2. Logistic Regression State
  double _logIpk = 3.65;
  bool _logJurusan = true;
  int _logSkills = 5;
  double _logPortofolio = 85.0;
  int _logOrganisasi = 2;
  Map<String, dynamic>? _logResult;
  bool _logLoading = false;

  // 3. Naive Bayes State
  final TextEditingController _nbDomainController = TextEditingController(
    text: 'Pengembangan aplikasi mobile dengan Flutter, Riverpod, clean architecture, REST API, dan Supabase',
  );
  final TextEditingController _nbSentimentController = TextEditingController(
    text: 'Hari ini berhasil menyelesaikan implementasi modul machine learning dan seluruh unit testing berjalan lancar.',
  );
  Map<String, dynamic>? _nbDomainResult;
  Map<String, dynamic>? _nbSentimentResult;
  bool _nbLoading = false;

  // 4. SVM State
  double _svmSkillMatch = 85.0;
  double _svmTeknis = 80.0;
  double _svmWawancara = 85.0;
  int _svmProyek = 3;
  double _svmIpk = 3.7;
  Map<String, dynamic>? _svmResult;
  bool _svmLoading = false;

  // 5. Comprehensive All-in-One State
  Map<String, dynamic>? _compResult;
  bool _compLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Initial fetch on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runComprehensive();
      _runLinearRegression();
      _runLogisticRegression();
      _runNaiveBayes();
      _runSVM();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nbDomainController.dispose();
    _nbSentimentController.dispose();
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

  Future<void> _runNaiveBayes() async {
    setState(() => _nbLoading = true);
    final service = ref.read(mlServiceProvider);
    final domain = await service.classifyDomainNaiveBayes(_nbDomainController.text);
    final sent = await service.analyzeSentimentNaiveBayes(_nbSentimentController.text);
    if (mounted) {
      setState(() {
        _nbDomainResult = domain;
        _nbSentimentResult = sent;
        _nbLoading = false;
      });
    }
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

  Future<void> _runComprehensive() async {
    setState(() => _compLoading = true);
    final service = ref.read(mlServiceProvider);
    final res = await service.getComprehensiveInsight(
      namaKandidat: 'Ahmad Fauzi',
      posisiTujuan: 'Mobile App Developer',
      ipk: _logIpk,
      kesesuaianJurusan: _logJurusan,
      matchingSkillsCount: _logSkills,
      totalSkillsRequired: 6,
      skorPortofolio: _logPortofolio,
      pengalamanOrganisasi: _logOrganisasi,
      jamPerMinggu: _lrJam,
      durasiBulan: _lrDurasi,
      industri: _lrIndustri,
      tipeKerja: _lrTipe,
      coverLetter: _nbDomainController.text,
      catatanLogbookTerakhir: _nbSentimentController.text,
    );
    if (mounted) setState(() { _compResult = res; _compLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final healthAsync = ref.watch(mlHealthProvider);
    final isBackendOnline = healthAsync.value ?? false;

    return ResponsiveScaffold(
      title: 'Pusat Machine Learning (AI Insights)',
      currentRoute: '/ai-insights',
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            _buildHeroBanner(context, isBackendOnline, isMobile),

            const SizedBox(height: 20),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.mutedText(context),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(LucideIcons.layoutGrid, size: 16), text: 'Ringkasan Eksekutif'),
                  Tab(icon: Icon(LucideIcons.trendingUp, size: 16), text: '1. Linear Regression'),
                  Tab(icon: Icon(LucideIcons.checkCircle2, size: 16), text: '2. Logistic Regression'),
                  Tab(icon: Icon(LucideIcons.messageSquareText, size: 16), text: '3. Naive Bayes'),
                  Tab(icon: Icon(LucideIcons.shieldCheck, size: 16), text: '4. Support Vector Machine'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Tab Content
            SizedBox(
              height: 750,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExecutiveOverviewTab(context, isMobile),
                  _buildLinearRegressionTab(context, isMobile),
                  _buildLogisticRegressionTab(context, isMobile),
                  _buildNaiveBayesTab(context, isMobile),
                  _buildSVMTab(context, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HERO BANNER
  Widget _buildHeroBanner(BuildContext context, bool isOnline, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, color: Color(0xFFFDE047), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'AI & MACHINE LEARNING ENGINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Server Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF059669) : const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Microservice Python: Aktif (8000)' : 'Mode Lokal (Fallback)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Kecerdasan Buatan Terintegrasi Magangin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Menerapkan 4 algoritma inti Machine Learning: Regresi Linear (Uang Saku), Regresi Logistik (Probabilitas Kelolosan), Naive Bayes (NLP & Sentimen Jurnal), dan SVM (Pencocokan Kandidat).',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: EXECUTIVE OVERVIEW
  Widget _buildExecutiveOverviewTab(BuildContext context, bool isMobile) {
    if (_compLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _compResult;
    final lr = data?['linear_regression'];
    final log = data?['logistic_regression'];
    final nb = data?['naive_bayes'];
    final svm = data?['svm'];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // 4 Algorithm Cards Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMiniCard(
                context,
                title: 'Linear Regression',
                subtitle: 'Prediksi Uang Saku',
                value: lr?['formatted_stipend'] ?? 'Rp 4.500.000',
                detail: 'Rekomendasi stipend bulanan',
                icon: LucideIcons.trendingUp,
                color: AppTheme.primary,
              ),
              _buildMiniCard(
                context,
                title: 'Logistic Regression',
                subtitle: 'Peluang Lolos Seleksi',
                value: '${log?['percentage'] ?? 88.5}% (${log?['status'] ?? 'Diterima'})',
                detail: 'Probabilitas kelolosan seleksi',
                icon: LucideIcons.checkCircle2,
                color: (log?['status'] == 'Diterima') ? AppTheme.success : AppTheme.danger,
              ),
              _buildMiniCard(
                context,
                title: 'Naive Bayes (NLP)',
                subtitle: 'Klasifikasi Domain & Sentimen',
                value: nb?['bidang_minat']?['predicted_domain'] ?? 'Mobile Dev',
                detail: 'Sentimen Logbook: ${nb?['analisis_logbook']?['sentiment'] ?? 'Positif'}',
                icon: LucideIcons.messageSquareText,
                color: const Color(0xFF8B5CF6),
              ),
              _buildMiniCard(
                context,
                title: 'SVM (Support Vector)',
                subtitle: 'Peringkat Kecocokan',
                value: svm?['match_tier'] ?? 'Sangat Cocok',
                detail: 'Confidence: ${( (svm?['confidence'] ?? 0.95) * 100).toStringAsFixed(1)}%',
                icon: LucideIcons.shieldCheck,
                color: const Color(0xFF10B981),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Comprehensive Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.fileSpreadsheet, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Dossier Lengkap Hasil Analisis AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text(context),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _runComprehensive,
                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                      label: const Text('Perbarui Analisis'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Kandidat Uji: ${data?['kandidat'] ?? 'Ahmad Fauzi'} — Target: ${data?['posisi'] ?? 'Mobile App Developer'}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary(context)),
                ),
                const SizedBox(height: 12),
                _buildInsightBullet(
                  context,
                  title: '1. Model Regresi Linear (Uang Saku):',
                  body: lr?['analysis'] ?? 'Kandidat diprediksi layak menerima stipend optimal berbasis jam kerja dan industri.',
                ),
                _buildInsightBullet(
                  context,
                  title: '2. Model Regresi Logistik (Peluang Lolos):',
                  body: 'Prediksi status [${log?['status']}] dengan tingkat keyakinan ${log?['percentage']}%. Rekomendasi: ${(log?['recommendation'] as List?)?.join(", ") ?? "Lolos kualifikasi utama."}',
                ),
                _buildInsightBullet(
                  context,
                  title: '3. Model Naive Bayes (NLP & Sentimen):',
                  body: 'Spesialisasi terdeteksi: ${nb?['bidang_minat']?['predicted_domain']}. Analisis jurnal harian terakhir: "${nb?['analisis_logbook']?['sentiment']}" — ${nb?['analisis_logbook']?['advice'] ?? ""}',
                ),
                _buildInsightBullet(
                  context,
                  title: '4. Model Support Vector Machine (Pencocokan):',
                  body: svm?['summary'] ?? 'Kandidat berada dalam margin kelas Sangat Cocok.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: LINEAR REGRESSION
  Widget _buildLinearRegressionTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlgoHeader(
            context,
            title: 'Linear Regression (Regresi Linear)',
            purpose: 'Memprediksi nilai numerik kontinu: Estimasi Uang Saku / Salary Magang',
            formula: 'Y = β₀ + β₁(Durasi) + β₂(Jam/Minggu) + β₃(Skills) + β₄(Industri) + β₅(Sistem Kerja) + ε',
          ),
          const SizedBox(height: 16),
          // Interactive Sliders & Controls
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubah Parameter Simulasi:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                const SizedBox(height: 12),
                _buildSliderTile('Durasi Magang: $_lrDurasi Bulan', _lrDurasi.toDouble(), 1, 12, (v) {
                  setState(() => _lrDurasi = v.round());
                }),
                _buildSliderTile('Jam Kerja per Minggu: $_lrJam Jam', _lrJam.toDouble(), 15, 45, (v) {
                  setState(() => _lrJam = v.round());
                }),
                _buildSliderTile('Jumlah Keahlian (Skills): $_lrSkills Skill', _lrSkills.toDouble(), 1, 10, (v) {
                  setState(() => _lrSkills = v.round());
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _lrIndustri,
                        decoration: const InputDecoration(labelText: 'Industri Perusahaan', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'Pendidikan', child: Text('Pendidikan / Yayasan')),
                          DropdownMenuItem(value: 'Manufaktur', child: Text('Manufaktur / Retail')),
                          DropdownMenuItem(value: 'Teknologi', child: Text('Teknologi / Fintech')),
                        ],
                        onChanged: (v) => setState(() => _lrIndustri = v!),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _lrTipe,
                        decoration: const InputDecoration(labelText: 'Sistem Kerja', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'WFH', child: Text('WFH (Remote)')),
                          DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                          DropdownMenuItem(value: 'WFO', child: Text('WFO (Onsite)')),
                        ],
                        onChanged: (v) => setState(() => _lrTipe = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _runLinearRegression,
                    icon: _lrLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.calculator),
                    label: const Text('Hitung Prediksi Regresi Linear'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Output Result Box
          if (_lrResult != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.coins, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimasi Prediksi Uang Saku Bulanan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          _lrResult!['formatted_stipend'] ?? 'Rp 0',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(_lrResult!['analysis'] ?? '', style: const TextStyle(fontSize: 12)),
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

  // TAB 3: LOGISTIC REGRESSION
  Widget _buildLogisticRegressionTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlgoHeader(
            context,
            title: 'Logistic Regression (Regresi Logistik)',
            purpose: 'Klasifikasi biner & probabilitas kelulusan seleksi pelamar: Lolos (1) vs Ditolak (0)',
            formula: 'P(Y=1) = 1 / (1 + e^(-z)), di mana z = w₀ + w₁(IPK) + w₂(Jurusan) + w₃(Skills) + w₄(Portofolio)',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubah Profil Pelamar:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                const SizedBox(height: 12),
                _buildSliderTile('IPK Mahasiswa: ${_logIpk.toStringAsFixed(2)}', _logIpk, 2.0, 4.0, (v) {
                  setState(() => _logIpk = double.parse(v.toStringAsFixed(2)));
                }),
                _buildSliderTile('Skill yang Cocok: $_logSkills Skill', _logSkills.toDouble(), 0, 8, (v) {
                  setState(() => _logSkills = v.round());
                }),
                _buildSliderTile('Skor Kelayakan Portofolio: ${_logPortofolio.round()}%', _logPortofolio, 30, 100, (v) {
                  setState(() => _logPortofolio = v.roundToDouble());
                }),
                _buildSliderTile('Pengalaman Organisasi: $_logOrganisasi Kali', _logOrganisasi.toDouble(), 0, 5, (v) {
                  setState(() => _logOrganisasi = v.round());
                }),
                CheckboxListTile(
                  title: const Text('Jurusan Kuliah Linier / Relevan dengan Posisi Magang'),
                  value: _logJurusan,
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _logJurusan = v ?? true),
                ),
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _runLogisticRegression,
                    icon: _logLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.scanLine),
                    label: const Text('Prediksi Peluang Kelulusan'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_logResult != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (_logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (_logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _logResult!['is_accepted'] == true ? LucideIcons.checkCheck : LucideIcons.alertTriangle,
                        color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Status: ${_logResult!['status']} (${_logResult!['percentage']}%)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_logResult!['percentage'] as num).toDouble() / 100.0,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    color: _logResult!['is_accepted'] == true ? AppTheme.success : AppTheme.danger,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                  Text('Rekomendasi / Evaluasi:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                  Text(
                    ((_logResult!['recommendation'] as List?) ?? []).join('\n'),
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // TAB 4: NAIVE BAYES
  Widget _buildNaiveBayesTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlgoHeader(
            context,
            title: 'Multinomial Naive Bayes (NLP & Teorema Bayes)',
            purpose: '1. Klasifikasi kategori minat/posisi dari teks profil/CV. 2. Analisis sentimen jurnal/logbook harian.',
            formula: 'P(Kelas|Teks) ∝ P(Kelas) · ∏ P(Kata_i|Kelas)',
          ),
          const SizedBox(height: 16),
          // Sub-feature 1: Domain Matcher
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.fileText, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('1. Klasifikasi Bidang Pekerjaan dari Resume/Bio:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nbDomainController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Ketik deskripsi skill atau pengalaman pelamar...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (_nbDomainResult != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.bgSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Hasil Klasifikasi: ${_nbDomainResult!['predicted_domain']} (Tingkat Keyakinan: ${((_nbDomainResult!['confidence'] as num) * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sub-feature 2: Sentiment Logbook
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.messageCircleHeart, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('2. Analisis Sentimen Jurnal / Logbook Aktivitas Peserta:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nbSentimentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Ketik catatan kegiatan harian logbook...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _runNaiveBayes,
                    icon: const Icon(LucideIcons.sparkle),
                    label: const Text('Jalankan Klasifikasi Naive Bayes'),
                  ),
                ),
                if (_nbSentimentResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_nbSentimentResult!['sentiment'] == 'Kendala' ? AppTheme.danger : (_nbSentimentResult!['sentiment'] == 'Positif' ? AppTheme.success : AppTheme.info)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _nbSentimentResult!['sentiment'] == 'Kendala' ? LucideIcons.alertCircle : LucideIcons.smile,
                          color: _nbSentimentResult!['sentiment'] == 'Kendala' ? AppTheme.danger : AppTheme.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sentimen: ${_nbSentimentResult!['sentiment']}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              Text(_nbSentimentResult!['advice'] ?? '', style: const TextStyle(fontSize: 12)),
                            ],
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
    );
  }

  // TAB 5: SVM
  Widget _buildSVMTab(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlgoHeader(
            context,
            title: 'Support Vector Machine (SVM)',
            purpose: 'Evaluasi Kecocokan Multidimensi & Margin Hyperplane: Sangat Cocok, Cukup Sesuai, atau Kurang Sesuai',
            formula: 'f(x) = sign(∑ α_i · y_i · K(x_i, x) + b), Kernel RBF: K(x, x\') = exp(-γ ||x - x\'||²)',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ubah Skor Multi-Dimensi Kandidat:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                const SizedBox(height: 12),
                _buildSliderTile('Skor Kesesuaian Skill: ${_svmSkillMatch.round()}%', _svmSkillMatch, 30, 100, (v) {
                  setState(() => _svmSkillMatch = v.roundToDouble());
                }),
                _buildSliderTile('Skor Tes Teknis / Kuis: ${_svmTeknis.round()}%', _svmTeknis, 30, 100, (v) {
                  setState(() => _svmTeknis = v.roundToDouble());
                }),
                _buildSliderTile('Skor Wawancara / Soft-skill: ${_svmWawancara.round()}%', _svmWawancara, 30, 100, (v) {
                  setState(() => _svmWawancara = v.roundToDouble());
                }),
                _buildSliderTile('Jumlah Proyek Relevan: $_svmProyek Proyek', _svmProyek.toDouble(), 0, 8, (v) {
                  setState(() => _svmProyek = v.round());
                }),
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _runSVM,
                    icon: _svmLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.shieldCheck),
                    label: const Text('Hitung Klasifikasi SVM'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_svmResult != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (_svmResult!['match_tier'] == 'Sangat Cocok' ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (_svmResult!['match_tier'] == 'Sangat Cocok' ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _svmResult!['match_tier'] == 'Sangat Cocok' ? AppTheme.success : AppTheme.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.award, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Klasifikasi Margin SVM:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          _svmResult!['match_tier'] ?? 'Sangat Cocok',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _svmResult!['match_tier'] == 'Sangat Cocok' ? AppTheme.success : AppTheme.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_svmResult!['summary'] ?? '', style: const TextStyle(fontSize: 12.5)),
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

  // WIDGET HELPERS
  Widget _buildAlgoHeader(BuildContext context, {required String title, required String purpose, required String formula}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text(context))),
          const SizedBox(height: 4),
          Text(purpose, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.bgSubtle, borderRadius: BorderRadius.circular(8)),
            child: Text(formula, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMiniCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text(context))),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.mutedText(context))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(detail, style: TextStyle(fontSize: 11, color: AppTheme.mutedText(context))),
        ],
      ),
    );
  }

  Widget _buildInsightBullet(BuildContext context, {required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.text(context))),
          const SizedBox(height: 2),
          Text(body, style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(context))),
        ],
      ),
    );
  }
}
