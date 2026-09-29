import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/responsive_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    final list = await _service.getNotifications('current-user');
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        judul: n.judul,
        pesan: n.pesan,
        tipe: n.tipe,
        isRead: true,
        linkTarget: n.linkTarget,
        createdAt: n.createdAt,
      )).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi ditandai telah dibaca.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Pusat Notifikasi',
      currentRoute: '/notifikasi',
      actions: [
        TextButton.icon(
          onPressed: _markAllAsRead,
          icon: const Icon(LucideIcons.checkCheck, size: 16),
          label: const Text('Tandai Dibaca'),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Tidak ada notifikasi baru.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isSuccess = notif.tipe == 'success';
                    final isWarning = notif.tipe == 'warning';

                    return Card(
                      color: notif.isRead
                          ? AppTheme.surface(context)
                          : (AppTheme.isDark(context) ? AppTheme.primaryLight.withValues(alpha: 0.12) : const Color(0xFFF0FDF4)),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isSuccess
                                        ? AppTheme.success
                                        : isWarning
                                            ? AppTheme.warning
                                            : AppTheme.primary)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isSuccess
                                    ? LucideIcons.checkCircle
                                    : isWarning
                                        ? LucideIcons.alertTriangle
                                        : LucideIcons.bell,
                                color: isSuccess
                                    ? AppTheme.success
                                    : isWarning
                                        ? AppTheme.warning
                                        : AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notif.judul,
                                        style: TextStyle(
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                          fontSize: 14.5,
                                          color: AppTheme.text(context),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM, HH:mm').format(notif.createdAt),
                                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textLight),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.pesan,
                                    style: TextStyle(fontSize: 13, color: AppTheme.isDark(context) ? AppTheme.textDarkBody : AppTheme.textMuted, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
