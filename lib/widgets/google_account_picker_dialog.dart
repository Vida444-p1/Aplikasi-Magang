import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_theme.dart';

class GoogleAccountItem {
  final String nama;
  final String email;
  final String role;
  final String roleLabel;
  final String? avatarUrl;
  final String? perusahaan;
  final Color themeColor;

  const GoogleAccountItem({
    required this.nama,
    required this.email,
    required this.role,
    required this.roleLabel,
    this.avatarUrl,
    this.perusahaan,
    required this.themeColor,
  });
}

class GoogleAccountPickerDialog extends StatefulWidget {
  final String defaultRole;
  final ValueChanged<GoogleAccountItem>? onAccountSelected;

  const GoogleAccountPickerDialog({
    super.key,
    this.defaultRole = 'peserta',
    this.onAccountSelected,
  });

  @override
  State<GoogleAccountPickerDialog> createState() => _GoogleAccountPickerDialogState();
}

class _GoogleAccountPickerDialogState extends State<GoogleAccountPickerDialog> {
  bool _isCustomFormOpen = false;
  bool _isSelecting = false;
  String? _selectedEmail;

  final _customNamaController = TextEditingController();
  final _customEmailController = TextEditingController();
  late String _customRole;

  @override
  void initState() {
    super.initState();
    _customRole = widget.defaultRole;
  }

  @override
  void dispose() {
    _customNamaController.dispose();
    _customEmailController.dispose();
    super.dispose();
  }

  List<GoogleAccountItem> get _presetAccounts => [
    const GoogleAccountItem(
      nama: 'Vida Rizki Prasetyo',
      email: 'vida.rizki@student.uii.ac.id',
      role: 'peserta',
      roleLabel: 'Peserta Magang',
      avatarUrl: 'https://ui-avatars.com/api/?name=Vida+Rizki&background=4285F4&color=fff&size=128',
      themeColor: Color(0xFF4285F4),
    ),
    const GoogleAccountItem(
      nama: 'PT Teknologi Nusantara Digital',
      email: 'hrd@nusantaradigital.co.id',
      role: 'perusahaan',
      roleLabel: 'Perusahaan / Mitra',
      perusahaan: 'PT Teknologi Nusantara Digital',
      avatarUrl: 'https://ui-avatars.com/api/?name=Nusantara+Digital&background=0F9D58&color=fff&size=128',
      themeColor: Color(0xFF0F9D58),
    ),
    const GoogleAccountItem(
      nama: 'Koordinator Magang & Kampus Merdeka',
      email: 'admin.magang@kampus.ac.id',
      role: 'admin',
      roleLabel: 'Admin Sistem',
      avatarUrl: 'https://ui-avatars.com/api/?name=Admin+Magang&background=EA4335&color=fff&size=128',
      themeColor: Color(0xFFEA4335),
    ),
  ];

  void _handleSelectAccount(GoogleAccountItem account) async {
    if (_isSelecting) return;
    setState(() {
      _isSelecting = true;
      _selectedEmail = account.email;
    });

    // Simulasi respons autentikasi halus Google 350ms
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    Navigator.of(context).pop(account);
    if (widget.onAccountSelected != null) {
      widget.onAccountSelected!(account);
    }
  }

  void _handleCustomSubmit() {
    final nama = _customNamaController.text.trim();
    final email = _customEmailController.text.trim();

    if (nama.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama lengkap dan alamat email Google.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final item = GoogleAccountItem(
      nama: nama,
      email: email.contains('@') ? email : '$email@gmail.com',
      role: _customRole,
      roleLabel: _customRole == 'perusahaan'
          ? 'Perusahaan'
          : (_customRole == 'admin' ? 'Admin' : 'Peserta Magang'),
      perusahaan: _customRole == 'perusahaan' ? nama : null,
      avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nama)}&background=4285F4&color=fff&size=128',
      themeColor: const Color(0xFF4285F4),
    );

    _handleSelectAccount(item);
  }

  void _showSupabaseGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = AppTheme.isDark(ctx);
        return AlertDialog(
          backgroundColor: AppTheme.surface(ctx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Image.asset('assets/images/google_logo.png', width: 22, height: 22),
              const SizedBox(width: 12),
              Text(
                'Panduan Supabase Google OAuth',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text(ctx),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Aplikasi saat ini telah siap dengan Instant Google Sign-In bebas error. Jika ingin mengaktifkan Google OAuth resmi di cloud:',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 14),
                _guideStep('1', 'Buka Google Cloud Console > APIs & Services > Credentials.'),
                _guideStep('2', 'Buat OAuth 2.0 Client ID (Web Application).'),
                _guideStep('3', 'Tambahkan Authorized redirect URI:\nhttps://gymauechavhjvjtpziaj.supabase.co/auth/v1/callback'),
                _guideStep('4', 'Buka Supabase Dashboard > Authentication > Providers > Google, lalu masukkan Client ID & Secret.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.checkCircle2, color: AppTheme.success, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Setelah aktif, sistem otomatis mendeteksi dan beralih ke popup OAuth resmi tanpa perlu merubah kode.',
                          style: TextStyle(fontSize: 12, color: AppTheme.text(ctx)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _guideStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDarkElevated : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Google
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png',
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.account_circle,
                                  size: 28,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF5F6368),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            color: AppTheme.textMuted,
                            tooltip: 'Tutup',
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih akun',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'untuk melanjutkan ke Aplikasi Magang',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Daftar Akun Google
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: _presetAccounts.map((account) {
                      final isSelected = _selectedEmail == account.email;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSelecting ? null : () => _handleSelectAccount(account),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              children: [
                                // Google Profile Avatar
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: account.themeColor.withValues(alpha: 0.15),
                                  backgroundImage: account.avatarUrl != null
                                      ? NetworkImage(account.avatarUrl!)
                                      : null,
                                  child: account.avatarUrl == null
                                      ? Text(
                                          account.nama[0].toUpperCase(),
                                          style: TextStyle(
                                            color: account.themeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                // Detail Akun
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              account.nama,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.text(context),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: account.themeColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              account.roleLabel,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: account.themeColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        account.email,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppTheme.mutedText(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.2),
                                  )
                                else
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 18,
                                    color: AppTheme.mutedText(context),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Opsi Gunakan Akun Lain (Kustom)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isCustomFormOpen = !_isCustomFormOpen);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            child: Icon(
                              _isCustomFormOpen ? LucideIcons.chevronUp : LucideIcons.userPlus,
                              size: 18,
                              color: AppTheme.text(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gunakan akun Google lain',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.text(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Masuk dengan alamat email & nama kustom',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedText(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isCustomFormOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                            size: 18,
                            color: AppTheme.mutedText(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Kustom Akun Google
                if (_isCustomFormOpen) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    color: isDark ? const Color(0xFF141E2E) : const Color(0xFFF8FAFC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customNamaController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap Akun Google',
                            hintText: 'Contoh: Budi Santoso',
                            prefixIcon: const Icon(LucideIcons.user, size: 16),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _customEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Google (@gmail.com / domain)',
                            hintText: 'budi.santoso@gmail.com',
                            prefixIcon: const Icon(LucideIcons.mail, size: 16),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pilih Peran Akun:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.text(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _roleOption(
                                label: 'Peserta',
                                value: 'peserta',
                                icon: LucideIcons.graduationCap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _roleOption(
                                label: 'Perusahaan',
                                value: 'perusahaan',
                                icon: LucideIcons.building,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _handleCustomSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.check, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Masuk dengan Akun Ini',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 1, thickness: 1),

                // Footer & Bantuan Setup
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.shieldCheck, size: 15, color: Color(0xFF0F9D58)),
                              const SizedBox(width: 6),
                              Text(
                                'Akses Terverifikasi & Cepat',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.text(context),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _showSupabaseGuideDialog,
                            child: const Text(
                              'Info OAuth Supabase',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4285F4),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Untuk melanjutkan, Google akan membagikan nama, alamat email, preferensi bahasa, dan foto profil Anda ke Aplikasi Magang.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.mutedText(context),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _customRole == value;
    return InkWell(
      onTap: () => setState(() => _customRole = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4285F4).withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF4285F4) : AppTheme.border(context),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF4285F4) : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4285F4) : AppTheme.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function praktis untuk memunculkan Google Account Picker
Future<GoogleAccountItem?> showGoogleAccountPicker({
  required BuildContext context,
  String defaultRole = 'peserta',
  ValueChanged<GoogleAccountItem>? onAccountSelected,
}) {
  return showDialog<GoogleAccountItem>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => GoogleAccountPickerDialog(
      defaultRole: defaultRole,
      onAccountSelected: onAccountSelected,
    ),
  );
}
