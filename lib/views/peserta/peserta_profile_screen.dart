import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PesertaProfileScreen extends ConsumerStatefulWidget {
  const PesertaProfileScreen({super.key});

  @override
  ConsumerState<PesertaProfileScreen> createState() => _PesertaProfileScreenState();
}

class _PesertaProfileScreenState extends ConsumerState<PesertaProfileScreen> {
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _univCtrl = TextEditingController();
  final _prodiCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _cvCtrl = TextEditingController();
  final _keahlianCtrl = TextEditingController();
  List<String> _keahlianList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).userProfile;
    final peserta = profile?.pesertaDetails;

    _namaCtrl.text = profile?.namaLengkap ?? '';
    _nimCtrl.text = peserta?.nim ?? '25523013';
    _univCtrl.text = peserta?.universitas ?? 'Universitas Islam Indonesia';
    _prodiCtrl.text = peserta?.programStudi ?? 'Teknik Informatika';
    _telpCtrl.text = profile?.nomorTelepon ?? '081234567890';
    _alamatCtrl.text = peserta?.alamat ?? 'Yogyakarta, Indonesia';
    _cvCtrl.text = peserta?.cvUrl ?? 'https://storage.supabase.co/documents/cv-vidar.pdf';
    _keahlianList = List.from(peserta?.keahlian ?? ['Flutter', 'Dart', 'Supabase', 'Figma', 'UI/UX']);
  }

  void _addSkill() {
    final text = _keahlianCtrl.text.trim();
    if (text.isNotEmpty && !_keahlianList.contains(text)) {
      setState(() {
        _keahlianList.add(text);
        _keahlianCtrl.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _keahlianList.remove(skill);
    });
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil peserta berhasil diperbarui!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.userProfile;

    return ResponsiveScaffold(
      title: 'Profil Mahasiswa',
      currentRoute: '/peserta/profil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header profile card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user?.namaLengkap ?? 'P').isNotEmpty ? (user?.namaLengkap ?? 'P')[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.namaLengkap ?? 'Peserta Magang',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.text(context),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.badgeCheck, size: 13, color: AppTheme.success),
                                      SizedBox(width: 4),
                                      Text(
                                        'Terverifikasi',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_nimCtrl.text} • ${_prodiCtrl.text}',
                              style: TextStyle(fontSize: 13.5, color: AppTheme.mutedText(context)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _univCtrl.text,
                              style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Edit Form Container
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.getCardShadow(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.userCheck, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Pribadi & Kontak',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pastikan data kontak selalu mutakhir agar perusahaan dapat menghubungi Anda.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        label: 'Nama Lengkap',
                        controller: _namaCtrl,
                        prefixIcon: Icon(LucideIcons.user, size: 18, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'NIM (Nomor Induk Mahasiswa)',
                              controller: _nimCtrl,
                              prefixIcon: Icon(LucideIcons.creditCard, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Nomor WhatsApp / HP',
                              controller: _telpCtrl,
                              prefixIcon: Icon(LucideIcons.phone, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(LucideIcons.graduationCap, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Data Akademik & Kampus',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Universitas / Institut',
                              controller: _univCtrl,
                              prefixIcon: Icon(LucideIcons.building, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Program Studi',
                              controller: _prodiCtrl,
                              prefixIcon: Icon(LucideIcons.bookOpen, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Alamat Domisili',
                        controller: _alamatCtrl,
                        maxLines: 2,
                        prefixIcon: Icon(LucideIcons.mapPin, size: 18, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Icon(LucideIcons.sparkles, size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Keahlian & Dokumen Portofolio',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Tautan Berkas CV (PDF / Cloud Link)',
                        controller: _cvCtrl,
                        prefixIcon: Icon(LucideIcons.fileText, size: 18, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 18),

                      Text('Keahlian (Skills & Technologies)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _keahlianList.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.primaryLight),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _removeSkill(skill),
                                  child: const Icon(LucideIcons.x, size: 13, color: AppTheme.primaryLight),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _keahlianCtrl,
                              onSubmitted: (_) => _addSkill(),
                              decoration: InputDecoration(
                                hintText: 'Ketik keahlian (misal: Flutter, Supabase, Figma)...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                filled: true,
                                fillColor: AppTheme.surfaceElevated(context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppTheme.border(context)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppTheme.border(context)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _addSkill,
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Tambah'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      CustomButton(
                        text: 'Simpan Perubahan Profil',
                        isLoading: _isLoading,
                        icon: LucideIcons.check,
                        width: double.infinity,
                        onPressed: _handleSave,
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
}
