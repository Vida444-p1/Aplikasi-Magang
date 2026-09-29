import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11.5,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    Color bg;
    Color fg;
    Color dotColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'diterima':
      case 'selesai':
      case 'aktif':
        dotColor = const Color(0xFF10B981);
        bg = isDark ? dotColor.withValues(alpha: 0.15) : const Color(0xFFF0FDF4);
        fg = isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
        break;
      case 'diproses':
      case 'berjalan':
      case 'hybrid':
        dotColor = const Color(0xFFF472B6);
        bg = isDark ? dotColor.withValues(alpha: 0.15) : const Color(0xFFFDF2F8);
        fg = isDark ? const Color(0xFFFBCFE8) : const Color(0xFFDB2777);
        break;
      case 'menunggu':
      case 'wfh':
        dotColor = const Color(0xFFF59E0B);
        bg = isDark ? dotColor.withValues(alpha: 0.15) : const Color(0xFFFFFBEB);
        fg = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
        break;
      case 'ditolak':
      case 'ditutup':
        dotColor = const Color(0xFFF43F5E);
        bg = isDark ? dotColor.withValues(alpha: 0.15) : const Color(0xFFFFF1F2);
        fg = isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C);
        break;
      case 'wfo':
      default:
        dotColor = const Color(0xFF94A3B8);
        bg = isDark ? dotColor.withValues(alpha: 0.15) : const Color(0xFFF8FAFC);
        fg = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: isDark ? 0.35 : 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.5,
              height: 6.5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
