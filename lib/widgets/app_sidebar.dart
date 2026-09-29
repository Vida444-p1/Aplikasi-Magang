import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AppSidebar extends ConsumerWidget {
  final String currentRoute;

  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final activeRole = authState.activeRole;
    final isDark = AppTheme.isDark(context);

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(right: BorderSide(color: AppTheme.border(context), width: 1.1)),
      ),
      child: Column(
        children: [
          // App Logo & Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.briefcase, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aplikasi Magang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            activeRole == 'admin'
                                ? 'Portal Koordinator'
                                : activeRole == 'perusahaan'
                                    ? 'Portal Mitra Industri'
                                    : 'Portal Mahasiswa',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mutedText(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.borderSubtleColor(context), height: 1),

          // Interactive Role Switcher Segmented Control
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border(context), width: 1),
            ),
            child: Row(
              children: [
                _roleTab(ref, 'Peserta', 'peserta', activeRole, context),
                _roleTab(ref, 'Perusahaan', 'perusahaan', activeRole, context),
                _roleTab(ref, 'Admin', 'admin', activeRole, context),
              ],
            ),
          ),

          // Menu Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  child: Text(
                    'NAVIGASI UTAMA',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightText(context),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ..._buildMenuItems(context, activeRole),
              ],
            ),
          ),

          Divider(color: AppTheme.borderSubtleColor(context), height: 1),

          // Dark Mode & Light Mode Switcher Tile
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? LucideIcons.moon : LucideIcons.sun,
                      size: 16,
                      color: isDark ? const Color(0xFFFBBF24) : AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'Mode Gelap' : 'Mode Terang',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text(context),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ),
          ),

          // User Profile Card at Bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (authState.userProfile?.namaLengkap.isNotEmpty ?? false)
                        ? authState.userProfile!.namaLengkap[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.userProfile?.namaLengkap ?? 'Pengguna',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        activeRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: activeRole == 'admin'
                              ? AppTheme.danger
                              : activeRole == 'perusahaan'
                                  ? AppTheme.info
                                  : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.logOut, size: 17, color: AppTheme.mutedText(context)),
                  tooltip: 'Keluar',
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleTab(WidgetRef ref, String label, String roleKey, String activeRole, BuildContext context) {
    final isSelected = activeRole == roleKey;
    final isDark = AppTheme.isDark(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(authProvider.notifier).switchDemoRole(roleKey);
          if (roleKey == 'peserta') {
            context.go('/peserta/dashboard');
          } else if (roleKey == 'perusahaan') {
            context.go('/perusahaan/dashboard');
          } else {
            context.go('/admin/dashboard');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.surfaceDarkElevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.mutedText(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, String role) {
    if (role == 'peserta') {
      return [
        _menuTile(context, LucideIcons.layoutDashboard, 'Dashboard', '/peserta/dashboard'),
        _menuTile(context, LucideIcons.search, 'Cari Lowongan', '/peserta/lowongan'),
        _menuTile(context, LucideIcons.fileCheck, 'Lamaran Saya', '/peserta/pendaftaran'),
        _menuTile(context, LucideIcons.calendarCheck, 'Logbook Kegiatan', '/peserta/kegiatan'),
        _menuTile(context, LucideIcons.user, 'Profil Saya', '/peserta/profil'),
        _menuTile(context, LucideIcons.bell, 'Notifikasi', '/notifikasi'),
      ];
    } else if (role == 'perusahaan') {
      return [
        _menuTile(context, LucideIcons.layoutDashboard, 'Dashboard', '/perusahaan/dashboard'),
        _menuTile(context, LucideIcons.briefcase, 'Kelola Lowongan', '/perusahaan/lowongan'),
        _menuTile(context, LucideIcons.users, 'Data Pendaftar', '/perusahaan/pelamar'),
        _menuTile(context, LucideIcons.activity, 'Monitoring Peserta', '/perusahaan/monitoring'),
        _menuTile(context, LucideIcons.bell, 'Notifikasi', '/notifikasi'),
      ];
    } else {
      return [
        _menuTile(context, LucideIcons.layoutDashboard, 'Dashboard Admin', '/admin/dashboard'),
        _menuTile(context, LucideIcons.users, 'Manajemen Pengguna', '/admin/users'),
        _menuTile(context, LucideIcons.building, 'Manajemen Lowongan', '/admin/lowongan'),
        _menuTile(context, LucideIcons.clipboardList, 'Monitoring Logbook', '/admin/monitoring'),
        _menuTile(context, LucideIcons.bell, 'Notifikasi', '/notifikasi'),
      ];
    }
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String route) {
    final isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 3.5,
                    height: 18,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppTheme.primary : AppTheme.mutedText(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : AppTheme.text(context),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(LucideIcons.chevronRight, size: 14, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
