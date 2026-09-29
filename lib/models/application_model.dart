import 'package:aplikasi_magang/models/profile_model.dart';
import 'package:aplikasi_magang/models/vacancy_model.dart';

class ApplicationModel {
  final String id;
  final String lowonganId;
  final String pesertaId;
  final DateTime tanggalDaftar;
  final String cvUrl;
  final String? suratPengantarUrl;
  final String? portofolioUrl;
  final String status; // 'menunggu', 'diproses', 'diterima', 'ditolak'
  final String? catatanPerusahaan;
  final VacancyModel? vacancy;
  final PesertaProfile? peserta;
  final String? namaPeserta;
  final String? emailPeserta;

  ApplicationModel({
    required this.id,
    required this.lowonganId,
    required this.pesertaId,
    required this.tanggalDaftar,
    required this.cvUrl,
    this.suratPengantarUrl,
    this.portofolioUrl,
    required this.status,
    this.catatanPerusahaan,
    this.vacancy,
    this.peserta,
    this.namaPeserta,
    this.emailPeserta,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    VacancyModel? vac;
    if (json['lowongan'] != null && json['lowongan'] is Map<String, dynamic>) {
      vac = VacancyModel.fromJson(json['lowongan']);
    }

    PesertaProfile? pes;
    String? nama;
    String? email;
    if (json['peserta'] != null && json['peserta'] is Map<String, dynamic>) {
      pes = PesertaProfile.fromJson(json['peserta']);
      if (json['peserta']['profiles'] != null && json['peserta']['profiles'] is Map<String, dynamic>) {
        nama = json['peserta']['profiles']['nama_lengkap'];
        email = json['peserta']['profiles']['email'];
      }
    }

    return ApplicationModel(
      id: json['id'] as String,
      lowonganId: json['lowongan_id'] as String,
      pesertaId: json['peserta_id'] as String,
      tanggalDaftar: DateTime.tryParse(json['tanggal_daftar'].toString()) ?? DateTime.now(),
      cvUrl: json['cv_url'] as String? ?? '',
      suratPengantarUrl: json['surat_pengantar_url'] as String?,
      portofolioUrl: json['portofolio_url'] as String?,
      status: json['status'] as String? ?? 'menunggu',
      catatanPerusahaan: json['catatan_perusahaan'] as String?,
      vacancy: vac,
      peserta: pes,
      namaPeserta: nama,
      emailPeserta: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowongan_id': lowonganId,
      'peserta_id': pesertaId,
      'cv_url': cvUrl,
      'surat_pengantar_url': suratPengantarUrl,
      'portofolio_url': portofolioUrl,
      'status': status,
    };
  }
}
