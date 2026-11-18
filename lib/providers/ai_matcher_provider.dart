import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_match_result.dart';
import '../services/ai_matcher_service.dart';
import '../services/application_service.dart';
import '../services/vacancy_service.dart';

final aiMatcherServiceProvider = Provider<AIMatcherService>((ref) {
  return AIMatcherService();
});

/// Provider yang mengevaluasi seluruh pelamar untuk suatu lowongan secara otomatis.
/// Parameter: lowonganId (String)
/// Mengembalikan list AIMatchResult yang sudah diurutkan berdasarkan skor komposit.
final aiMatchResultsProvider = FutureProvider.family<List<AIMatchResult>, String>((ref, lowonganId) async {
  final matcherService = ref.watch(aiMatcherServiceProvider);
  final appService = ApplicationService();
  final vacService = VacancyService();

  // 1. Ambil data pelamar untuk lowongan ini
  final applicants = await appService.getApplicantsByVacancyId(lowonganId);
  if (applicants.isEmpty) return [];

  // 2. Ambil data lowongan
  final vacancy = await vacService.getVacancyById(lowonganId);
  if (vacancy == null) return [];

  // 3. Jalankan evaluasi batch otomatis
  return matcherService.evaluateAllApplicants(
    applicants: applicants,
    vacancy: vacancy,
  );
});

/// Provider untuk evaluasi AI satu pelamar spesifik (digunakan di halaman detail).
/// Parameter: Record (applicantId, lowonganId)
final singleAIMatchProvider = FutureProvider.family<AIMatchResult?, ({String applicantId, String lowonganId})>((ref, params) async {
  final results = await ref.watch(aiMatchResultsProvider(params.lowonganId).future);
  final match = results.where((r) => r.applicantId == params.applicantId);
  return match.isNotEmpty ? match.first : null;
});
