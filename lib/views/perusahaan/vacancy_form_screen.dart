import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/vacancy_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vacancy_provider.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class VacancyFormScreen extends ConsumerStatefulWidget {
  const VacancyFormScreen({super.key});

  @override
  ConsumerState<VacancyFormScreen> createState() => _VacancyFormScreenState();
}

class _VacancyFormScreenState extends ConsumerState<VacancyFormScreen> {
  final _posisiCtrl = TextEditingController();
  final _bidangCtrl = TextEditingController(text: 'Teknologi Informasi');
  final _deskripsiCtrl = TextEditingController();
  final _tanggungJawabCtrl = TextEditingController();
  final _persyaratanCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController(text: 'Yogyakarta');
  final _durasiCtrl = TextEditingController(text: '6');
  final _kuotaCtrl = TextEditingController(text: '2');
  String _sistemKerja = 'hybrid';
  DateTime _batasPendaftaran = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  void _saveVacancy() async {
    if (_posisiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posisi magang wajib diisi!'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final perusahaanId = authState.userProfile?.perusahaanDetails?.id ?? 'per-1';
      final companyName = authState.userProfile?.perusahaanDetails?.namaPerusahaan ??
          authState.userProfile?.namaLengkap ??
          'PT Teknologi Nusantara Digital';
      final companyAddress = authState.userProfile?.perusahaanDetails?.alamat ??
          _lokasiCtrl.text.trim();

      final newVac = VacancyModel(
        id: 'vac-${DateTime.now().millisecondsSinceEpoch}',
        perusahaanId: perusahaanId,
        posisi: _posisiCtrl.text.trim(),
        bidang: _bidangCtrl.text.trim(),
        deskripsi: _deskripsiCtrl.text.trim(),
        tanggungJawab: _tanggungJawabCtrl.text.trim(),
        persyaratan: _persyaratanCtrl.text.trim(),
        lokasi: _lokasiCtrl.text.trim(),
        sistemKerja: _sistemKerja,
        durasiBulan: int.tryParse(_durasiCtrl.text) ?? 3,
        kuota: int.tryParse(_kuotaCtrl.text) ?? 1,
        batasPendaftaran: _batasPendaftaran,
        status: 'aktif',
        namaPerusahaan: companyName,
        alamatPerusahaan: companyAddress,
        createdAt: DateTime.now(),
      );

      await ref.read(vacancyServiceProvider).createVacancy(newVac);
      ref.invalidate(vacancyListProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lowongan baru berhasil dipublikasikan!'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/perusahaan/lowongan');
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
    return ResponsiveScaffold(
      title: 'Buat Lowongan Magang Baru',
      currentRoute: '/perusahaan/lowongan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go('/perusahaan/lowongan'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.arrowLeft, size: 16, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text('Kembali ke Daftar Lowongan', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.briefcase, color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Posisi & Kriteria Magang',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text(context)),
                              ),
                              Text(
                                'Isi rincian lengkap untuk menarik calon peserta mahasiswa yang kompeten',
                                style: TextStyle(fontSize: 12.5, color: AppTheme.mutedText(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Divider(color: AppTheme.borderSubtleColor(context), height: 1),
                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'Posisi Magang*',
                        hint: 'Contoh: Mobile App Developer Intern (Flutter)',
                        controller: _posisiCtrl,
                        prefixIcon: Icon(LucideIcons.briefcase, size: 18, color: AppTheme.mutedText(context)),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Bidang / Industri',
                              hint: 'Teknologi Informasi, Desain Produk, dll.',
                              controller: _bidangCtrl,
                              prefixIcon: Icon(LucideIcons.tag, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Kota / Lokasi Kantor',
                              hint: 'Yogyakarta, Jakarta, dll.',
                              controller: _lokasiCtrl,
                              prefixIcon: Icon(LucideIcons.mapPin, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sistem Kerja & Durasi
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sistem Kerja*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _sistemKerja,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  items: const [
                                    DropdownMenuItem(value: 'hybrid', child: Text('Hybrid (Campuran)')),
                                    DropdownMenuItem(value: 'wfo', child: Text('WFO (Kerja dari Kantor)')),
                                    DropdownMenuItem(value: 'wfh', child: Text('WFH (Kerja dari Rumah)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _sistemKerja = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: CustomTextField(
                              label: 'Durasi Magang (Bulan)',
                              controller: _durasiCtrl,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(LucideIcons.clock, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Kuota Penerimaan (Orang)',
                              controller: _kuotaCtrl,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(LucideIcons.users, size: 18, color: AppTheme.mutedText(context)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Batas Akhir Pendaftaran*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _batasPendaftaran,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 180)),
                                    );
                                    if (picked != null) setState(() => _batasPendaftaran = picked);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.border(context)),
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppTheme.surfaceElevated(context),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd MMMM yyyy').format(_batasPendaftaran), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                                        const Icon(LucideIcons.calendar, size: 17, color: AppTheme.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Deskripsi Singkat*',
                        hint: 'Jelaskan tujuan posisi magang ini dan tim tempat peserta akan bergabung...',
                        controller: _deskripsiCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Tanggung Jawab Pekerjaan',
                        hint: '• Mengembangkan fitur aplikasi...\n• Berpartisipasi dalam daily standup...',
                        controller: _tanggungJawabCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Persyaratan Kualifikasi*',
                        hint: '• Mahasiswa aktif jurusan Informatika / Ilmu Komputer\n• Memahami dasar Flutter & Git...',
                        controller: _persyaratanCtrl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 26),

                      CustomButton(
                        text: 'Publikasikan Lowongan Sekarang',
                        isLoading: _isLoading,
                        icon: LucideIcons.check,
                        width: double.infinity,
                        onPressed: _saveVacancy,
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
