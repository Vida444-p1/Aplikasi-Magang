import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';

final activityServiceProvider = Provider<ActivityService>((ref) => ActivityService());

final myActivitiesProvider = FutureProvider.family<List<ActivityModel>, String>((ref, pesertaId) async {
  final service = ref.watch(activityServiceProvider);
  return service.getMyActivities(pesertaId);
});

final allActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  final service = ref.watch(activityServiceProvider);
  return service.getAllActivities();
});

final logbookSummaryProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, pesertaId) async {
  final service = ref.watch(activityServiceProvider);
  return service.getLogbookSummary(pesertaId);
});
