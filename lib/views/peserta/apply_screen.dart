import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final String vacancyId;

  const ApplyScreen({super.key, required this.vacancyId});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _cvController = TextEditingController(text: 'https://storage.supabase.co/documents/cv-vidar.pdf');
  final _suratController = TextEditingController(text: 'https://storage.supabase.co/documents/surat-kampus.pdf');
  final _portfolioController = TextEditingController(text: 'https://github.com/vidar');
  bool _isLoading = false;

  void _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final pesertaId = authState.userProfile?.pesertaDetails?.id ?? 'pes-1';
      final vacancy = ref.read(vacancyDetailProvider(widget.vacancyId)).value;

      await ref.read(applicationServiceProvider).submitApplication(
        lowonganId: widget.vacancyId,
        pesertaId: pesertaId,
        cvUrl: _cvController.text.trim(),
        suratPengantarUrl: _suratController.text.trim(),
        portofolioUrl: _portfolioController.text.trim(),
        vacancy: vacancy,
      );

      // Invalidate provider agar halaman Lamaran Saya langsung menampilkan data terbaru
      ref.invalidate(myApplicationsProvider(pesertaId));
      ref.invalidate(applicantsByVacancyProvider(widget.vacancyId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil dikirim! Status awal: MENUNGGU.'),
          backgroundColor: AppTheme.success,
        ),
      );

      context.go('/peserta/pendaftaran');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kendala: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacancyAsync = ref.watch(vacancyDetailProvider(widget.vacancyId));
    final authState = ref.watch(authProvider);
    final user = authState.userProfile;
    final peserta = user?.pesertaDetails;

    return ResponsiveScaffold(
      title: 'Formulir Pendaftaran Magang',
      currentRoute: '/peserta/lowongan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lowongan Ringkasan
                vacancyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                  data: (v) {
                    if (v == null) return const SizedBox();
                    return Card(
                      color: AppTheme.primaryLight.withValues(alpha: AppTheme.isDark(context) ? 0.15 : 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.briefcase, color: AppTheme.primary, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.posisi,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.text(context)),
                                  ),
                                  Text(
                                    '${v.namaPerusahaan ?? 'Perusahaan'} • ${v.lokasi} (${v.sistemKerja.toUpperCase()})',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
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
                const SizedBox(height: 20),

                // Data Peserta (Auto-filled from Profile)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Data Diri Pelamar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                        ),
                        const SizedBox(height: 16),
                        _readOnlyField(context, 'Nama Lengkap', user?.namaLengkap ?? '-'),
                        _readOnlyField(context, 'NIM', peserta?.nim ?? '25523013'),
                        _readOnlyField(context, 'Universitas', peserta?.universitas ?? 'Universitas Islam Indonesia'),
                        _readOnlyField(context, 'Program Studi', peserta?.programStudi ?? 'Teknik Informatika'),
                        _readOnlyField(context, 'Email', user?.email ?? '-'),
                        _readOnlyField(context, 'Nomor Telepon', user?.nomorTelepon ?? '081234567890'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Upload & Dokumen Pendaftaran (PRD 5.E)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. Dokumen & Tautan Pendukung',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text(context)),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Link Dokumen CV (Curriculum Vitae)*',
                          hint: 'https://storage... atau Google Drive URL',
                          controller: _cvController,
                          prefixIcon: const Icon(LucideIcons.fileText, size: 18, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Link Surat Pengantar Kampus (Opsional)',
                          hint: 'Tautan surat rekomendasi atau pengantar universitas',
                          controller: _suratController,
                          prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Link Portofolio (GitHub / Figma / Website)',
                          hint: 'https://github.com/... atau https://behance.net/...',
                          controller: _portfolioController,
                          prefixIcon: const Icon(LucideIcons.globe, size: 18, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.isDark(context) ? const Color(0xFF451A03).withValues(alpha: 0.5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.info, color: Color(0xFFF59E0B), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Setelah formulir dikirim, status pendaftaran awal Anda akan berstatus "Menunggu" hingga ditinjau oleh pihak perusahaan.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.isDark(context) ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Kirim Pendaftaran Magang',
                          isLoading: _isLoading,
                          icon: LucideIcons.send,
                          width: double.infinity,
                          onPressed: _handleSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
          ),
        ],
      ),
    );
  }
}
