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
  String _selectedRoleFilter = 'all';

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          final idx = _tabController.index;
          if (idx == 0) {
            _selectedRoleFilter = 'all';
          } else if (idx == 1 || idx == 2) {
            _selectedRoleFilter = 'mahasiswa';
          } else if (idx == 3) {
            _selectedRoleFilter = 'koordinator';
          } else if (idx == 4) {
            _selectedRoleFilter = 'perusahaan';
          }
        });
      }
    });
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

            const SizedBox(height: 16),

            // Role / Job Filter Bar
            _buildRoleFilterBar(context),

            const SizedBox(height: 16),

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
                  Tab(icon: Icon(LucideIcons.layoutGrid, size: 16), text: 'Semua (Ringkasan Eksekutif)'),
                  Tab(icon: Icon(LucideIcons.trendingUp, size: 16), text: '1. Prediksi Uang Saku [Mahasiswa]'),
                  Tab(icon: Icon(LucideIcons.checkCircle2, size: 16), text: '2. Peluang Lolos Seleksi [Mahasiswa]'),
                  Tab(icon: Icon(LucideIcons.messageSquareText, size: 16), text: '3. Klasifikasi & Sentimen [Koordinator]'),
                  Tab(icon: Icon(LucideIcons.shieldCheck, size: 16), text: '4. Evaluasi Kecocokan [Perusahaan]'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Tab Content
            SizedBox(
              height: 900,
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
          // 1. ROLE MAHASISWA SECTION
          _buildRoleSectionHeader(
            context,
            title: 'Job Mahasiswa (Persiapan & Pengajuan Magang)',
            subtitle: 'Fitur pendukung calon peserta untuk riset kompensasi dan evaluasi diri sebelum melamar',
            icon: LucideIcons.graduationCap,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMiniCard(
                context,
                title: 'Prediksi Uang Saku',
                subtitle: 'Linear Regression',
                roleTag: 'Mahasiswa',
                roleColor: const Color(0xFF2563EB),
                value: lr?['formatted_stipend'] ?? 'Rp 4.500.000',
                detail: 'Rekomendasi stipend bulanan',
                icon: LucideIcons.trendingUp,
                color: AppTheme.primary,
              ),
              _buildMiniCard(
                context,
                title: 'Peluang Lolos Seleksi',
                subtitle: 'Logistic Regression',
                roleTag: 'Mahasiswa',
                roleColor: const Color(0xFF2563EB),
                value: '${log?['percentage'] ?? 88.5}% (${log?['status'] ?? 'Diterima'})',
                detail: 'Probabilitas kelolosan seleksi',
                icon: LucideIcons.checkCircle2,
                color: (log?['status'] == 'Diterima') ? AppTheme.success : AppTheme.danger,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. ROLE MITRA INDUSTRI / PERUSAHAAN SECTION
          _buildRoleSectionHeader(
            context,
            title: 'Job Mitra Perusahaan (Screening & Rekrutmen Pelamar)',
            subtitle: 'Fitur pendukung tim HR industri untuk menyaring dan memeringkat kandidat terbaik',
            icon: LucideIcons.building2,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMiniCard(
                context,
                title: 'Evaluasi Kecocokan',
                subtitle: 'Support Vector Machine',
                roleTag: 'Mitra Industri',
                roleColor: const Color(0xFF10B981),
                value: svm?['match_tier'] ?? 'Sangat Cocok',
                detail: 'Confidence: ${( (svm?['confidence'] ?? 0.95) * 100).toStringAsFixed(1)}%',
                icon: LucideIcons.shieldCheck,
                color: const Color(0xFF10B981),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. ROLE KOORDINATOR KAMPUS SECTION
          _buildRoleSectionHeader(
            context,
            title: 'Job Koordinator Kampus (Monitoring & Evaluasi Bimbingan)',
            subtitle: 'Fitur pemantauan otomatis catatan kegiatan logbook dan sentimen kendala mahasiswa',
            icon: LucideIcons.userCheck,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMiniCard(
                context,
                title: 'Klasifikasi & Sentimen',
                subtitle: 'Naive Bayes (NLP)',
                roleTag: 'Koordinator',
                roleColor: const Color(0xFF8B5CF6),
                value: nb?['bidang_minat']?['predicted_domain'] ?? 'Mobile Dev',
                detail: 'Sentimen Logbook: ${nb?['analisis_logbook']?['sentiment'] ?? 'Positif'}',
                icon: LucideIcons.messageSquareText,
                color: const Color(0xFF8B5CF6),
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
                  title: '1. [Job Mahasiswa] Prediksi Uang Saku (Linear Regression):',
                  body: lr?['analysis'] ?? 'Kandidat diprediksi layak menerima stipend optimal berbasis jam kerja dan industri.',
                ),
                _buildInsightBullet(
                  context,
                  title: '2. [Job Mahasiswa] Peluang Lolos Seleksi (Logistic Regression):',
                  body: 'Prediksi status [${log?['status']}] dengan tingkat keyakinan ${log?['percentage']}%. Rekomendasi: ${(log?['recommendation'] as List?)?.join(", ") ?? "Lolos kualifikasi utama."}',
                ),
                _buildInsightBullet(
                  context,
                  title: '3. [Job Koordinator] Klasifikasi Minat & Sentimen Logbook (Naive Bayes):',
                  body: 'Spesialisasi terdeteksi: ${nb?['bidang_minat']?['predicted_domain']}. Analisis jurnal harian terakhir: "${nb?['analisis_logbook']?['sentiment']}" — ${nb?['analisis_logbook']?['advice'] ?? ""}',
                ),
                _buildInsightBullet(
                  context,
                  title: '4. [Job Mitra Perusahaan] Evaluasi Kecocokan Kandidat (SVM):',
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
            title: 'Prediksi Uang Saku (Linear Regression)',
            purpose: 'Memprediksi nilai numerik kontinu: Estimasi Uang Saku / Salary Magang',
            formula: 'Y = β₀ + β₁(Durasi) + β₂(Jam/Minggu) + β₃(Skills) + β₄(Industri) + β₅(Sistem Kerja) + ε',
            roleTag: 'JOB MAHASISWA (PERENCANAAN & EKSPLORASI)',
            roleIcon: LucideIcons.graduationCap,
            roleColor: const Color(0xFF2563EB),
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
                        initialValue: _lrIndustri,
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
                        initialValue: _lrTipe,
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
                    label: const Text('Hitung Prediksi Uang Saku'),
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
            title: 'Peluang Lolos Seleksi (Logistic Regression)',
            purpose: 'Klasifikasi biner & probabilitas kelulusan seleksi pelamar: Lolos (1) vs Ditolak (0)',
            formula: 'P(Y=1) = 1 / (1 + e^(-z)), di mana z = w₀ + w₁(IPK) + w₂(Jurusan) + w₃(Skills) + w₄(Portofolio)',
            roleTag: 'JOB MAHASISWA (SELF-ASSESSMENT SEBELUM MELAMAR)',
            roleIcon: LucideIcons.graduationCap,
            roleColor: const Color(0xFF2563EB),
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
            title: 'Klasifikasi Minat & Sentimen Jurnal (Naive Bayes)',
            purpose: '1. Klasifikasi kategori minat/posisi dari teks profil/CV. 2. Analisis sentimen jurnal/logbook harian.',
            formula: 'P(Kelas|Teks) ∝ P(Kelas) · ∏ P(Kata_i|Kelas)',
            roleTag: 'JOB KOORDINATOR & DOSEN PEMBIMBING (MONITORING LOGBOOK)',
            roleIcon: LucideIcons.userCheck,
            roleColor: const Color(0xFF8B5CF6),
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
                    onPressed: _nbLoading ? null : _runNaiveBayes,
                    icon: _nbLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(LucideIcons.sparkle),
                    label: const Text('Analisis Klasifikasi & Sentimen'),
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
            title: 'Evaluasi Kecocokan Kandidat (Support Vector Machine)',
            purpose: 'Evaluasi Kecocokan Multidimensi & Margin Hyperplane: Sangat Cocok, Cukup Sesuai, atau Kurang Sesuai',
            formula: 'f(x) = sign(∑ α_i · y_i · K(x_i, x) + b), Kernel RBF: K(x, x\') = exp(-γ ||x - x\'||²)',
            roleTag: 'JOB MITRA INDUSTRI / PERUSAHAAN (SCREENING REKRUTMEN)',
            roleIcon: LucideIcons.building2,
            roleColor: const Color(0xFF10B981),
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
                    label: const Text('Hitung Evaluasi Kecocokan'),
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
  Widget _buildRoleFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.briefcase, size: 15, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'Pilah Sesuai Job / Role:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text(context),
                ),
              ),
            ],
          ),
          _buildRoleFilterChip(
            context,
            label: 'Semua Job (5)',
            roleId: 'all',
            icon: LucideIcons.layoutGrid,
            targetTabIndex: 0,
          ),
          _buildRoleFilterChip(
            context,
            label: '🎓 Job Mahasiswa (2)',
            roleId: 'mahasiswa',
            icon: LucideIcons.graduationCap,
            color: const Color(0xFF2563EB),
            targetTabIndex: 1,
          ),
          _buildRoleFilterChip(
            context,
            label: '🏢 Job Mitra Perusahaan (1)',
            roleId: 'perusahaan',
            icon: LucideIcons.building2,
            color: const Color(0xFF10B981),
            targetTabIndex: 4,
          ),
          _buildRoleFilterChip(
            context,
            label: '👨‍🏫 Job Koordinator Kampus (1)',
            roleId: 'koordinator',
            icon: LucideIcons.userCheck,
            color: const Color(0xFF8B5CF6),
            targetTabIndex: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(
    BuildContext context, {
    required String label,
    required String roleId,
    required IconData icon,
    required int targetTabIndex,
    Color? color,
  }) {
    final isSelected = _selectedRoleFilter == roleId;
    final activeColor = color ?? AppTheme.primary;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRoleFilter = roleId;
        });
        _tabController.animateTo(targetTabIndex);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : activeColor.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : activeColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text(context),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.mutedText(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlgoHeader(
    BuildContext context, {
    required String title,
    required String purpose,
    required String formula,
    String? roleTag,
    IconData? roleIcon,
    Color? roleColor,
  }) {
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
          if (roleTag != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (roleColor ?? AppTheme.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (roleColor ?? AppTheme.primary).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleIcon ?? LucideIcons.badgeCheck, size: 14, color: roleColor ?? AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    roleTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: roleColor ?? AppTheme.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
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
    String? roleTag,
    Color? roleColor,
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
              if (roleTag != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (roleColor ?? color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roleTag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: roleColor ?? color,
                    ),
                  ),
                ),
              ],
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
