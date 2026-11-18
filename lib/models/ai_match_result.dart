/// Model hasil evaluasi AI Matcher otomatis per-pelamar.
/// Mengandung skor dari SVM, Logistic Regression, Naive Bayes, dan skor komposit akhir.
class AIMatchResult {
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String vacancyPosition;
  final String vacancyId;

  // Skor Skill Matching (otomatis dihitung dari keahlian peserta vs persyaratan lowongan)
  final int matchedSkillsCount;
  final int totalRequiredSkills;
  final double skillMatchPercentage;
  final List<String> matchedSkills;
  final List<String> missingSkills;

  // Hasil SVM
  final String svmTier; // 'Sangat Cocok', 'Cukup Sesuai', 'Kurang Sesuai'
  final double svmConfidence;

  // Hasil Logistic Regression
  final double acceptanceProbability; // 0.0 - 100.0
  final bool isLikelyAccepted;

  // Hasil Naive Bayes
  final String predictedDomain;
  final double domainConfidence;

  // Skor Komposit Akhir (weighted average)
  final double compositeScore; // 0 - 100
  final String compositeLabel; // 'Sangat Direkomendasikan', 'Direkomendasikan', 'Perlu Pertimbangan'

  // Data Profil Peserta (untuk tampilan)
  final double? ipk;
  final String? programStudi;
  final String? universitas;
  final List<String> keahlian;

  AIMatchResult({
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.vacancyPosition,
    required this.vacancyId,
    required this.matchedSkillsCount,
    required this.totalRequiredSkills,
    required this.skillMatchPercentage,
    required this.matchedSkills,
    required this.missingSkills,
    required this.svmTier,
    required this.svmConfidence,
    required this.acceptanceProbability,
    required this.isLikelyAccepted,
    required this.predictedDomain,
    required this.domainConfidence,
    required this.compositeScore,
    required this.compositeLabel,
    this.ipk,
    this.programStudi,
    this.universitas,
    this.keahlian = const [],
  });
}

