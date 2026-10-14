import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    setState(() => _isLoading = true);
    final list = await _service.getNotifications(null);
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() async {
    await _service.markAllAsRead();
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai telah dibaca.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Pusat Notifikasi',
      currentRoute: '/notifikasi',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Segarkan Notifikasi',
          onPressed: _loadNotifications,
        ),
        TextButton.icon(
          onPressed: _notifications.isEmpty ? null : _markAllAsRead,
          icon: const Icon(LucideIcons.checkCheck, size: 16),
          label: const Text('Tandai Dibaca'),
        ),
      ],
      body: _isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.bellOff, size: 48, color: AppTheme.mutedText(context)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada notifikasi baru',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemberitahuan terkait status lamaran dan aktivitas magang akan muncul di sini.',
                          style: TextStyle(fontSize: 13, color: AppTheme.mutedText(context)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _service.markAsRead(notif.id);
                          setState(() {
                            _notifications[index] = NotificationModel(
                              id: notif.id,
                              userId: notif.userId,
                              judul: notif.judul,
                              pesan: notif.pesan,
                              tipe: notif.tipe,
                              isRead: true,
                              linkTarget: notif.linkTarget,
                              createdAt: notif.createdAt,
                            );
                          });
                          if (notif.linkTarget != null && notif.linkTarget!.isNotEmpty) {
                            context.go(notif.linkTarget!);
                          }
                        },
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
                                        Expanded(
                                          child: Text(
                                            notif.judul,
                                            style: TextStyle(
                                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 14.5,
                                              color: AppTheme.text(context),
                                            ),
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
                                    if (notif.linkTarget != null && notif.linkTarget!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'Klik untuk melihat detail',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(LucideIcons.arrowRight, size: 13, color: AppTheme.primary),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
