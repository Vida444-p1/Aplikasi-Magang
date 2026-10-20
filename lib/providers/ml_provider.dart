import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_service.dart';

final mlServiceProvider = Provider<MLService>((ref) {
  return MLService();
});

final mlHealthProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(mlServiceProvider);
  return await service.checkHealth();
});
