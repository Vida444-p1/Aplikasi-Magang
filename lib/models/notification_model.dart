class NotificationModel {
  final String id;
  final String userId;
  final String judul;
  final String pesan;
  final String tipe; // 'info', 'success', 'warning', 'error'
  final bool isRead;
  final String? linkTarget;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.isRead,
    this.linkTarget,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      judul: json['judul'] as String? ?? '',
      pesan: json['pesan'] as String? ?? '',
      tipe: json['tipe'] as String? ?? 'info',
      isRead: json['is_read'] as bool? ?? false,
      linkTarget: json['link_target'] as String?,
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }
}
