import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/application_model.dart';
import '../models/vacancy_model.dart';
import 'vacancy_service.dart';

class ApplicationService {
  final SupabaseClient _client = SupabaseConfig.client;

  // In-memory static storage agar data pendaftaran langsung reaktif & tidak hang di mode prototype
  static final List<ApplicationModel> _mockApplications = [
    ApplicationModel(
      id: 'app-1',
      lowonganId: 'vac-1',
      pesertaId: 'pes-1',
      tanggalDaftar: DateTime.now().subtract(const Duration(days: 3)),
      cvUrl: 'https://storage.supabase.co/documents/cv-vidar.pdf',
      suratPengantarUrl: 'https://storage.supabase.co/documents/surat_kampus.pdf',
      portofolioUrl: 'https://github.com/vidar',
      status: 'diterima',
      catatanPerusahaan: 'Selamat! Hasil portofolio Flutter Anda sangat memuaskan.',
      namaPeserta: 'Vida Rizki Prasetyo',
      emailPeserta: 'vidar@student.uii.ac.id',
      vacancy: VacancyModel(
        id: 'vac-1',
        perusahaanId: 'per-1',
        posisi: 'Flutter & Mobile Developer Intern',
        bidang: 'Teknologi Informasi',
        deskripsi: 'Pengembangan aplikasi mobile Flutter terintegrasi Supabase.',
        persyaratan: 'Dasar Dart, Flutter, Git',
        lokasi: 'Yogyakarta',
        sistemKerja: 'hybrid',
        durasiBulan: 6,
        kuota: 3,
        batasPendaftaran: DateTime.now().add(const Duration(days: 20)),
        status: 'aktif',
        namaPerusahaan: 'PT Teknologi Nusantara Digital',
        alamatPerusahaan: 'Jl. Kaliurang KM 9, Sleman',
      ),
    ),
    ApplicationModel(
      id: 'app-2',
      lowonganId: 'vac-2',
      pesertaId: 'pes-1',
      tanggalDaftar: DateTime.now().subtract(const Duration(days: 6)),
      cvUrl: 'https://storage.supabase.co/documents/cv-vidar.pdf',
      status: 'diproses',
      catatanPerusahaan: 'Berkas sedang direview oleh Head of Design.',
      namaPeserta: 'Vida Rizki Prasetyo',
      emailPeserta: 'vidar@student.uii.ac.id',
      vacancy: VacancyModel(
        id: 'vac-2',
        perusahaanId: 'per-2',
        posisi: 'UI/UX Designer Intern',
        bidang: 'Desain Grafis',
        deskripsi: 'Merancang wireframe & prototype produk.',
        persyaratan: 'Figma, Portofolio',
        lokasi: 'Jakarta Selatan',
        sistemKerja: 'wfh',
        durasiBulan: 3,
        kuota: 2,
        batasPendaftaran: DateTime.now().add(const Duration(days: 14)),
        status: 'aktif',
        namaPerusahaan: 'Inovasi Kreatif Studio',
        alamatPerusahaan: 'TB Simatupang, Jakarta',
      ),
    ),
  ];

  // Mengirim pendaftaran magang baru
  Future<void> submitApplication({
    required String lowonganId,
    required String pesertaId,
    required String cvUrl,
    String? suratPengantarUrl,
    String? portofolioUrl,
    VacancyModel? vacancy,
  }) async {
    // 1. Dapatkan detail lowongan jika belum tersedia
    final resolvedVacancy = vacancy ?? await VacancyService().getVacancyById(lowonganId);

    // 2. Simpan langsung ke memori lokal
    final newApp = ApplicationModel(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      lowonganId: lowonganId,
      pesertaId: pesertaId,
      tanggalDaftar: DateTime.now(),
      cvUrl: cvUrl,
      suratPengantarUrl: suratPengantarUrl,
      portofolioUrl: portofolioUrl,
      status: 'menunggu',
      namaPeserta: 'Vida Rizki Prasetyo',
      emailPeserta: 'vidar@student.uii.ac.id',
      vacancy: resolvedVacancy,
    );
    _mockApplications.insert(0, newApp);

    // 3. Upayakan simpan ke Supabase jika terhubung
    try {
      await _client.from('pendaftaran').insert({
        'lowongan_id': lowonganId,
        'peserta_id': pesertaId,
        'cv_url': cvUrl,
        'surat_pengantar_url': suratPengantarUrl,
        'portofolio_url': portofolioUrl,
        'status': 'menunggu',
      }).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('submitApplication notice: $e');
    }
  }

  // Mengambil daftar lamaran milik peserta saat ini
  Future<List<ApplicationModel>> getMyApplications(String pesertaId) async {
    try {
      final res = await _client
          .from('pendaftaran')
          .select('*, lowongan(*, perusahaan:perusahaan_id(nama_perusahaan, alamat))')
          .eq('peserta_id', pesertaId)
          .order('tanggal_daftar', ascending: false)
          .timeout(const Duration(seconds: 4));

      final list = (res as List).map((e) => ApplicationModel.fromJson(e)).toList();
      return list;
    } catch (e) {
      debugPrint('getMyApplications notice: $e');
    }
    if (pesertaId.contains('pes-')) {
      return List.from(_mockApplications);
    }
    return [];
  }

  // Mengambil pendaftar untuk suatu lowongan (Role Perusahaan)
  Future<List<ApplicationModel>> getApplicantsByVacancyId(String lowonganId) async {
    try {
      final res = await _client
          .from('pendaftaran')
          .select('*, peserta:peserta_id(*, profiles(nama_lengkap, email, nomor_telepon))')
          .eq('lowongan_id', lowonganId)
          .order('tanggal_daftar', ascending: false)
          .timeout(const Duration(seconds: 2));

      final list = (res as List).map((e) => ApplicationModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('getApplicantsByVacancyId notice: $e');
    }
    return List.from(_mockApplications);
  }

  // Mengubah status pendaftaran melalui Supabase Edge Function
  Future<bool> updateApplicationStatus({
    required String pendaftaranId,
    required String newStatus, // 'menunggu', 'diproses', 'diterima', 'ditolak'
    String? catatan,
  }) async {
    // 1. Perbarui data lokal secara instan
    final idx = _mockApplications.indexWhere((a) => a.id == pendaftaranId);
    if (idx != -1) {
      final old = _mockApplications[idx];
      _mockApplications[idx] = ApplicationModel(
        id: old.id,
        lowonganId: old.lowonganId,
        pesertaId: old.pesertaId,
        tanggalDaftar: old.tanggalDaftar,
        cvUrl: old.cvUrl,
        suratPengantarUrl: old.suratPengantarUrl,
        portofolioUrl: old.portofolioUrl,
        status: newStatus,
        catatanPerusahaan: catatan,
        vacancy: old.vacancy,
        peserta: old.peserta,
        namaPeserta: old.namaPeserta,
        emailPeserta: old.emailPeserta,
      );
    }

    // 2. Coba eksekusi Edge Function
    try {
      final response = await _client.functions.invoke(
        'update-application-status',
        body: {
          'pendaftaran_id': pendaftaranId,
          'new_status': newStatus,
          'catatan': catatan,
        },
      ).timeout(const Duration(seconds: 2));

      if (response.status == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Edge function invoke notice: $e');
    }

    return true;
  }
}
