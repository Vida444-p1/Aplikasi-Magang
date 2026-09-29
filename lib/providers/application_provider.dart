import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

final applicationServiceProvider = Provider<ApplicationService>((ref) => ApplicationService());

final myApplicationsProvider = FutureProvider.family<List<ApplicationModel>, String>((ref, pesertaId) async {
  final service = ref.watch(applicationServiceProvider);
  return service.getMyApplications(pesertaId);
});

final applicantsByVacancyProvider = FutureProvider.family<List<ApplicationModel>, String>((ref, lowonganId) async {
  final service = ref.watch(applicationServiceProvider);
  return service.getApplicantsByVacancyId(lowonganId);
});
