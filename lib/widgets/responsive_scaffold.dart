import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'app_sidebar.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final String currentRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      drawer: isDesktop ? null : Drawer(child: AppSidebar(currentRoute: currentRoute)),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: isDesktop ? 24 : 12,
        leading: isDesktop
            ? null
            : Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(LucideIcons.menu, color: AppTheme.text(context), size: 20),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.text(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button (Light/Dark Switcher)
          Container(
            margin: const EdgeInsets.only(right: 6),
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDarkElevated : AppTheme.bgSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                color: isDark ? const Color(0xFFFBBF24) : AppTheme.primary,
                size: 17,
              ),
              tooltip: isDark ? 'Beralih ke Light Mode' : 'Beralih ke Dark Mode',
              onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),

          // Notification Button with Unread Pulse Dot
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(LucideIcons.bell, color: AppTheme.mutedText(context), size: 19),
                tooltip: 'Pusat Notifikasi',
                onPressed: () => context.go('/notifikasi'),
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surface(context), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          if (actions != null) ...actions!,
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: AppTheme.borderSubtleColor(context), height: 1),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) AppSidebar(currentRoute: currentRoute),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Graffiti Office Wallpaper Layer
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/graffiti_office_bg.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // Adaptive Tint Overlay to preserve readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF0F050E).withValues(alpha: 0.88),
                                const Color(0xFF1E0C1C).withValues(alpha: 0.82),
                                const Color(0xFF0F050E).withValues(alpha: 0.92),
                              ]
                            : [
                                const Color(0xFFFFF0F5).withValues(alpha: 0.90),
                                const Color(0xFFFDF2F8).withValues(alpha: 0.84),
                                const Color(0xFFFFF0F5).withValues(alpha: 0.92),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Main Content
                Positioned.fill(
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
