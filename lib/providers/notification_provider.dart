import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final notificationsListProvider = FutureProvider.family<List<NotificationModel>, String?>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(userId);
});

final unreadNotificationsCountProvider = Provider.family<int, String?>((ref, userId) {
  final notifs = ref.watch(notificationsListProvider(userId)).valueOrNull ?? [];
  return notifs.where((n) => !n.isRead).length;
});
