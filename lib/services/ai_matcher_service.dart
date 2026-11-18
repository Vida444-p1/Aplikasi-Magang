import '../models/ai_match_result.dart';
import '../models/application_model.dart';
import '../models/vacancy_model.dart';
import 'ml_service.dart';

/// Service yang menghubungkan data pelamar riil dengan model Machine Learning
/// untuk menghasilkan evaluasi kecocokan otomatis (tanpa input slider manual).
class AIMatcherService {
  final MLService _mlService = MLService();

  /// Ekstrak kata kunci keahlian dari teks persyaratan lowongan.
  /// Contoh input: "• Memahami Dart & Flutter\n• Terbiasa dengan Git/GitHub"
  /// Output: ['dart', 'flutter', 'git', 'github']
  List<String> _extractSkillKeywords(String persyaratan) {
    // Daftar kata kunci teknis yang umum digunakan dalam lowongan magang
    const techKeywords = [
      'flutter', 'dart', 'kotlin', 'java', 'swift', 'python', 'javascript',
      'typescript', 'react', 'vue', 'angular', 'node', 'nodejs', 'express',
      'django', 'flask', 'laravel', 'php', 'ruby', 'go', 'golang', 'rust',
      'c++', 'c#', 'sql', 'postgresql', 'mysql', 'mongodb', 'firebase',
      'supabase', 'aws', 'gcp', 'azure', 'docker', 'kubernetes', 'git',
      'github', 'gitlab', 'figma', 'sketch', 'adobe', 'photoshop',
      'illustrator', 'html', 'css', 'sass', 'tailwind', 'bootstrap',
      'rest', 'api', 'graphql', 'mvvm', 'mvc', 'clean architecture',
      'riverpod', 'bloc', 'redux', 'getx', 'provider',
      'machine learning', 'deep learning', 'tensorflow', 'pytorch',
      'data science', 'data analysis', 'tableau', 'power bi',
      'ui', 'ux', 'design system', 'wireframe', 'prototype',
      'agile', 'scrum', 'jira', 'trello', 'ci/cd', 'devops',
      'linux', 'unix', 'networking', 'security', 'penetration testing',
      'android', 'ios', 'mobile', 'web', 'desktop', 'embedded',
      'portofolio', 'komunikatif', 'kreatif', 'analitis', 'problem solving',
    ];

    final lower = persyaratan.toLowerCase();
    final found = <String>[];

    for (final keyword in techKeywords) {
      if (lower.contains(keyword) && !found.contains(keyword)) {
        found.add(keyword);
      }
    }

    // Jika tidak ada keyword yang cocok, pecah manual dari bullet points
    if (found.isEmpty) {
      final lines = persyaratan.split(RegExp(r'[•\n\r,;]'));
      for (final line in lines) {
        final trimmed = line.trim().toLowerCase();
        if (trimmed.isNotEmpty && trimmed.length > 2 && trimmed.length < 50) {
          found.add(trimmed);
        }
      }
    }

    return found;
  }

  /// Hitung kecocokan antara keahlian peserta dan persyaratan lowongan.
  /// Mengembalikan {matched: [...], missing: [...], percentage: double}
  Map<String, dynamic> _computeSkillMatch({
    required List<String> pesertaSkills,
    required String persyaratan,
  }) {
    final requiredSkills = _extractSkillKeywords(persyaratan);
    final pesertaLower = pesertaSkills.map((s) => s.toLowerCase()).toList();

    final matched = <String>[];
    final missing = <String>[];

    for (final req in requiredSkills) {
      bool found = false;
      for (final skill in pesertaLower) {
        if (skill.contains(req) || req.contains(skill)) {
          found = true;
          break;
        }
      }
      if (found) {
        matched.add(req);
      } else {
        missing.add(req);
      }
    }

    final total = requiredSkills.isNotEmpty ? requiredSkills.length : 1;
    final percentage = (matched.length / total * 100).clamp(0.0, 100.0);

    return {
      'matched': matched,
      'missing': missing,
      'total': total,
      'percentage': percentage,
    };
  }

  /// Estimasi IPK berdasarkan profil (jika tersedia dari data peserta, 
  /// atau default heuristik dari jumlah skill dan kelengkapan profil).
  double _estimateIpk({
    required List<String> keahlian,
    required bool hasPortofolio,
    required bool hasSuratPengantar,
    required String? programStudi,
  }) {
    // Base IPK 3.0
    double ipk = 3.0;

    // Bonus per skill (maks +0.5)
    ipk += (keahlian.length * 0.08).clamp(0.0, 0.5);

    // Bonus jika punya portofolio (+0.15)
    if (hasPortofolio) ipk += 0.15;

    // Bonus jika punya surat pengantar (+0.1)
    if (hasSuratPengantar) ipk += 0.1;

    // Bonus jika program studi terisi (+0.1)
    if (programStudi != null && programStudi.isNotEmpty) ipk += 0.1;

    return ipk.clamp(2.0, 4.0);
  }

  /// Cek apakah program studi peserta linier/relevan dengan bidang lowongan.
  bool _isJurusanRelevant(String? programStudi, String bidangLowongan) {
    if (programStudi == null || programStudi.isEmpty) return false;

    final prodiLower = programStudi.toLowerCase();
    final bidangLower = bidangLowongan.toLowerCase();

    // Mapping relevansi
    const relevanceMap = {
      'teknologi informasi': ['informatika', 'komputer', 'sistem informasi', 'teknologi', 'it', 'software', 'data'],
      'desain': ['desain', 'design', 'kreatif', 'multimedia', 'komunikasi visual', 'dkv'],
      'bisnis': ['manajemen', 'bisnis', 'ekonomi', 'akuntansi', 'marketing', 'administrasi'],
      'teknik': ['teknik', 'engineering', 'mesin', 'elektro', 'sipil', 'industri'],
    };

    for (final entry in relevanceMap.entries) {
      if (bidangLower.contains(entry.key)) {
        for (final keyword in entry.value) {
          if (prodiLower.contains(keyword)) return true;
        }
      }
    }

    // Fallback: cek apakah ada substring yang overlap
    final prodiWords = prodiLower.split(RegExp(r'\s+'));
    final bidangWords = bidangLower.split(RegExp(r'\s+'));
    for (final pw in prodiWords) {
      if (pw.length > 3) {
        for (final bw in bidangWords) {
          if (bw.contains(pw) || pw.contains(bw)) return true;
        }
      }
    }

    return false;
  }

  /// Hitung skor portofolio berdasarkan kelengkapan berkas yang diunggah.
  double _computePortfolioScore({
    required String cvUrl,
    required String? portofolioUrl,
    required String? suratPengantarUrl,
    required int skillCount,
  }) {
    double score = 40.0; // Base score (punya CV)

    if (portofolioUrl != null && portofolioUrl.isNotEmpty) {
      score += 25.0; // Punya portofolio
      // Bonus jika GitHub/GitLab
      if (portofolioUrl.contains('github') || portofolioUrl.contains('gitlab')) {
        score += 10.0;
      }
    }

    if (suratPengantarUrl != null && suratPengantarUrl.isNotEmpty) {
      score += 10.0; // Punya surat pengantar
    }

    // Bonus per skill (maks +15)
    score += (skillCount * 3.0).clamp(0.0, 15.0);

    return score.clamp(0.0, 100.0);
  }

  /// Evaluasi satu pelamar secara otomatis menggunakan semua model ML.
  Future<AIMatchResult> evaluateApplicant({
    required ApplicationModel application,
    required VacancyModel vacancy,
  }) async {
    final peserta = application.peserta;
    final keahlian = peserta?.keahlian ?? [];
    final programStudi = peserta?.programStudi;
    final universitas = peserta?.universitas;
    final applicantName = application.namaPeserta ?? 'Pelamar';
    final applicantEmail = application.emailPeserta ?? '';

    // 1. Hitung Skill Match otomatis
    final skillMatch = _computeSkillMatch(
      pesertaSkills: keahlian,
      persyaratan: vacancy.persyaratan,
    );
    final matchedSkills = List<String>.from(skillMatch['matched']);
    final missingSkills = List<String>.from(skillMatch['missing']);
    final totalRequired = skillMatch['total'] as int;
    final skillMatchPct = skillMatch['percentage'] as double;

    // 2. Estimasi parameter yang tidak tersedia langsung
    final ipk = _estimateIpk(
      keahlian: keahlian,
      hasPortofolio: application.portofolioUrl != null && application.portofolioUrl!.isNotEmpty,
      hasSuratPengantar: application.suratPengantarUrl != null && application.suratPengantarUrl!.isNotEmpty,
      programStudi: programStudi,
    );

    final kesesuaianJurusan = _isJurusanRelevant(programStudi, vacancy.bidang);

    final skorPortofolio = _computePortfolioScore(
      cvUrl: application.cvUrl,
      portofolioUrl: application.portofolioUrl,
      suratPengantarUrl: application.suratPengantarUrl,
      skillCount: keahlian.length,
    );

    // 3. Jalankan semua model ML secara paralel
    final results = await Future.wait([
      // SVM - Evaluasi Kecocokan Kandidat
      _mlService.evaluateCandidateSVM(
        skillMatchScore: skillMatchPct,
        tesTeknisScore: skorPortofolio,
        wawancaraScore: kesesuaianJurusan ? 82.0 : 65.0,
        jumlahProyekRelevan: keahlian.length.clamp(0, 15),
        ipk: ipk,
      ),
      // Logistic Regression - Probabilitas Kelulusan
      _mlService.predictLogisticRegression(
        ipk: ipk,
        kesesuaianJurusan: kesesuaianJurusan,
        matchingSkillsCount: matchedSkills.length,
        skorPortofolio: skorPortofolio,
        pengalamanOrganisasi: (keahlian.length / 2).round().clamp(0, 10),
      ),
      // Naive Bayes - Klasifikasi Domain
      _mlService.classifyDomainNaiveBayes(
        '${vacancy.posisi} ${vacancy.bidang} ${keahlian.join(" ")}',
      ),
    ]);

    final svmResult = results[0];
    final logResult = results[1];
    final domainResult = results[2];

    // 4. Hitung Skor Komposit (weighted)
    final svmScore = svmResult['match_tier'] == 'Sangat Cocok'
        ? 95.0
        : (svmResult['match_tier'] == 'Cukup Sesuai' ? 70.0 : 40.0);
    final logScore = (logResult['percentage'] as num?)?.toDouble() ?? 50.0;
    final compositeScore = (svmScore * 0.35) + (logScore * 0.30) + (skillMatchPct * 0.35);

    String compositeLabel;
    if (compositeScore >= 75) {
      compositeLabel = 'Sangat Direkomendasikan';
    } else if (compositeScore >= 55) {
      compositeLabel = 'Direkomendasikan';
    } else {
      compositeLabel = 'Perlu Pertimbangan';
    }

    return AIMatchResult(
      applicantId: application.id,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      vacancyPosition: vacancy.posisi,
      vacancyId: vacancy.id,
      matchedSkillsCount: matchedSkills.length,
      totalRequiredSkills: totalRequired,
      skillMatchPercentage: skillMatchPct,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      svmTier: svmResult['match_tier'] ?? 'Kurang Sesuai',
      svmConfidence: (svmResult['confidence'] as num?)?.toDouble() ?? 0.5,
      acceptanceProbability: logScore,
      isLikelyAccepted: logResult['is_accepted'] == true,
      predictedDomain: domainResult['predicted_domain'] ?? 'Umum',
      domainConfidence: (domainResult['confidence'] as num?)?.toDouble() ?? 0.5,
      compositeScore: compositeScore,
      compositeLabel: compositeLabel,
      ipk: ipk,
      programStudi: programStudi,
      universitas: universitas,
      keahlian: keahlian,
    );
  }

  /// Evaluasi batch seluruh pelamar untuk satu lowongan.
  /// Mengembalikan list AIMatchResult yang sudah diurutkan berdasarkan compositeScore (terbaik dulu).
  Future<List<AIMatchResult>> evaluateAllApplicants({
    required List<ApplicationModel> applicants,
    required VacancyModel vacancy,
  }) async {
    if (applicants.isEmpty) return [];

    final futures = applicants.map((app) => evaluateApplicant(
      application: app,
      vacancy: vacancy,
    ));

    final results = await Future.wait(futures);

    // Urutkan berdasarkan compositeScore (descending)
    results.sort((a, b) => b.compositeScore.compareTo(a.compositeScore));

    return results;
  }
}

