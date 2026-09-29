import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/supabase_config.dart';
import '../models/vacancy_model.dart';

class VacancyService {
  final SupabaseClient _client = SupabaseConfig.client;

  // In-memory static storage agar data lowongan baru langsung tersimpan & tampil di mode prototipe
  static final List<VacancyModel> _mockVacancies = [
    VacancyModel(
      id: 'vac-1',
      perusahaanId: 'per-1',
      posisi: 'Flutter & Mobile Developer Intern',
      bidang: 'Teknologi Informasi',
      deskripsi: 'Mengembangkan dan merawat aplikasi mobile berbasis Flutter dengan integrasi Supabase dan arsitektur MVVM/Clean Architecture.',
      tanggungJawab: '• Mengembangkan widget responsif\n• Mengintegrasikan Supabase Auth & REST API\n• Melakukan unit testing dan debugging',
      persyaratan: '• Mahasiswa tingkat akhir jurusan Teknik Informatika/Sistem Informasi\n• Memahami dasar Dart & Flutter\n• Terbiasa dengan Git/GitHub',
      lokasi: 'Yogyakarta',
      sistemKerja: 'hybrid',
      durasiBulan: 6,
      jadwal: 'Senin - Jumat (09:00 - 17:00)',
      kuota: 3,
      batasPendaftaran: DateTime.now().add(const Duration(days: 20)),
      status: 'aktif',
      namaPerusahaan: 'PT Teknologi Nusantara Digital',
      alamatPerusahaan: 'Jl. Kaliurang KM 9, Sleman, DI Yogyakarta',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VacancyModel(
      id: 'vac-2',
      perusahaanId: 'per-2',
      posisi: 'UI/UX Designer Intern',
      bidang: 'Desain Grafis & Kreatif',
      deskripsi: 'Membantu perancangan antarmuka pengguna (UI) dan riset pengalaman pengguna (UX) untuk produk web dan mobile.',
      tanggungJawab: '• Membuat wireframe, user flow, dan interactive prototype di Figma\n• Melakukan usability testing bersama mentor\n• Menyusun design system',
      persyaratan: '• Menguasai Figma dan prinsip dasar Design System\n• Memiliki portofolio UI/UX\n• Komunikatif dan kreatif',
      lokasi: 'Jakarta Selatan',
      sistemKerja: 'wfh',
      durasiBulan: 3,
      jadwal: 'Fleksibel 20 jam/minggu',
      kuota: 2,
      batasPendaftaran: DateTime.now().add(const Duration(days: 14)),
      status: 'aktif',
      namaPerusahaan: 'Inovasi Kreatif Studio',
      alamatPerusahaan: 'TB Simatupang, Cilandak, Jakarta Selatan',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    VacancyModel(
      id: 'vac-3',
      perusahaanId: 'per-3',
      posisi: 'Backend Engineer (Node.js & Supabase)',
      bidang: 'Teknologi Informasi',
      deskripsi: 'Membangun API performa tinggi, edge functions, serta mengoptimalkan skema database PostgreSQL.',
      tanggungJawab: '• Merancang skema tabel dan Row Level Security\n• Menulis Edge Functions serverless\n• Menangani integrasi pihak ketiga',
      persyaratan: '• Memahami SQL & PostgreSQL\n• Menguasai JavaScript/TypeScript\n• Paham konsep RESTful API',
      lokasi: 'Bandung',
      sistemKerja: 'wfo',
      durasiBulan: 6,
      jadwal: 'Senin - Jumat (08:30 - 16:30)',
      kuota: 4,
      batasPendaftaran: DateTime.now().add(const Duration(days: 25)),
      status: 'aktif',
      namaPerusahaan: 'PT Solusi Data Dinamis',
      alamatPerusahaan: 'Dago, Coblong, Kota Bandung',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // Mengambil daftar lowongan dengan filter & pencarian (timeout 2 detik jika network offline/gagal)
  Future<List<VacancyModel>> getVacancies({
    String? keyword,
    String? lokasi,
    String? bidang,
    String? sistemKerja,
  }) async {
    try {
      var query = _client.from('lowongan').select('*, perusahaan:perusahaan_id(nama_perusahaan, alamat)');

      if (keyword != null && keyword.trim().isNotEmpty) {
        query = query.or('posisi.ilike.%$keyword%,deskripsi.ilike.%$keyword%');
      }
      if (lokasi != null && lokasi.trim().isNotEmpty && lokasi != 'Semua') {
        query = query.ilike('lokasi', '%$lokasi%');
      }
      if (bidang != null && bidang.trim().isNotEmpty && bidang != 'Semua') {
        query = query.eq('bidang', bidang);
      }
      if (sistemKerja != null && sistemKerja.trim().isNotEmpty && sistemKerja != 'Semua') {
        query = query.eq('sistem_kerja', sistemKerja.toLowerCase());
      }

      final res = await query.order('created_at', ascending: false).timeout(const Duration(seconds: 2));
      final list = (res as List).map((e) => VacancyModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('Supabase getVacancies notice: $e. Menggunakan data memori lokal.');
    }
    return _filterMock(keyword: keyword, lokasi: lokasi, bidang: bidang, sistemKerja: sistemKerja);
  }

  // Mengambil detail lowongan berdasarkan ID
  Future<VacancyModel?> getVacancyById(String id) async {
    try {
      final res = await _client
          .from('lowongan')
          .select('*, perusahaan:perusahaan_id(nama_perusahaan, alamat)')
          .eq('id', id)
          .maybeSingle()
          .timeout(const Duration(seconds: 2));

      if (res != null) {
        return VacancyModel.fromJson(res);
      }
    } catch (e) {
      debugPrint('getVacancyById notice: $e');
    }
    return _mockVacancies.firstWhere(
      (element) => element.id == id,
      orElse: () => _mockVacancies.first,
    );
  }

  // Mengambil lowongan milik perusahaan tertentu
  Future<List<VacancyModel>> getCompanyVacancies(String perusahaanId) async {
    try {
      final res = await _client
          .from('lowongan')
          .select('*, perusahaan:perusahaan_id(nama_perusahaan, alamat)')
          .eq('perusahaan_id', perusahaanId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 2));

      final list = (res as List).map((e) => VacancyModel.fromJson(e)).toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('getCompanyVacancies notice: $e');
    }
    return List.from(_mockVacancies);
  }

  // Tambah lowongan baru (Cepat, aman, tidak akan stuck)
  Future<void> createVacancy(VacancyModel vacancy) async {
    // 1. Simpan langsung ke memori lokal
    _mockVacancies.insert(0, vacancy);

    // 2. Upayakan simpan ke Supabase jika terhubung (maksimum 2 detik)
    try {
      await _client
          .from('lowongan')
          .insert(vacancy.toJson())
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Penyimpanan online Supabase dilewati (mode offline/mock aktif): $e');
    }
  }

  // Perbarui lowongan
  Future<void> updateVacancy(String id, VacancyModel vacancy) async {
    final idx = _mockVacancies.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _mockVacancies[idx] = vacancy;
    }
    try {
      await _client
          .from('lowongan')
          .update(vacancy.toJson())
          .eq('id', id)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('updateVacancy notice: $e');
    }
  }

  // Hapus lowongan
  Future<void> deleteVacancy(String id) async {
    _mockVacancies.removeWhere((v) => v.id == id);
    try {
      await _client
          .from('lowongan')
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('deleteVacancy notice: $e');
    }
  }

  // Helper filter data lokal
  List<VacancyModel> _filterMock({String? keyword, String? lokasi, String? bidang, String? sistemKerja}) {
    var result = List<VacancyModel>.from(_mockVacancies);

    if (keyword != null && keyword.trim().isNotEmpty) {
      final q = keyword.toLowerCase();
      result = result.where((v) =>
        v.posisi.toLowerCase().contains(q) ||
        (v.namaPerusahaan ?? '').toLowerCase().contains(q) ||
        v.deskripsi.toLowerCase().contains(q)
      ).toList();
    }
    if (sistemKerja != null && sistemKerja != 'Semua' && sistemKerja.trim().isNotEmpty) {
      result = result.where((v) => v.sistemKerja.toLowerCase() == sistemKerja.toLowerCase()).toList();
    }
    if (lokasi != null && lokasi != 'Semua' && lokasi.trim().isNotEmpty) {
      result = result.where((v) => v.lokasi.toLowerCase().contains(lokasi.toLowerCase())).toList();
    }
    if (bidang != null && bidang != 'Semua' && bidang.trim().isNotEmpty) {
      result = result.where((v) => v.bidang.toLowerCase() == bidang.toLowerCase()).toList();
    }
    return result;
  }
}
