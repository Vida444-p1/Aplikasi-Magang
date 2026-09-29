class VacancyModel {
  final String id;
  final String perusahaanId;
  final String posisi;
  final String bidang;
  final String deskripsi;
  final String? tanggungJawab;
  final String persyaratan;
  final String lokasi;
  final String sistemKerja; // 'wfo', 'wfh', 'hybrid'
  final int durasiBulan;
  final String? jadwal;
  final int kuota;
  final DateTime batasPendaftaran;
  final String status; // 'aktif', 'ditutup'
  final String? namaPerusahaan;
  final String? alamatPerusahaan;
  final DateTime? createdAt;

  VacancyModel({
    required this.id,
    required this.perusahaanId,
    required this.posisi,
    required this.bidang,
    required this.deskripsi,
    this.tanggungJawab,
    required this.persyaratan,
    required this.lokasi,
    required this.sistemKerja,
    required this.durasiBulan,
    this.jadwal,
    required this.kuota,
    required this.batasPendaftaran,
    required this.status,
    this.namaPerusahaan,
    this.alamatPerusahaan,
    this.createdAt,
  });

  factory VacancyModel.fromJson(Map<String, dynamic> json) {
    String? nama;
    String? alamat;
    if (json['perusahaan'] != null) {
      if (json['perusahaan'] is Map) {
        nama = json['perusahaan']['nama_perusahaan'];
        alamat = json['perusahaan']['alamat'];
      }
    } else if (json['perusahaan_details'] != null && json['perusahaan_details'] is Map) {
      nama = json['perusahaan_details']['nama_perusahaan'];
      alamat = json['perusahaan_details']['alamat'];
    }

    return VacancyModel(
      id: json['id'] as String,
      perusahaanId: json['perusahaan_id'] as String,
      posisi: json['posisi'] as String? ?? '',
      bidang: json['bidang'] as String? ?? 'Umum',
      deskripsi: json['deskripsi'] as String? ?? '',
      tanggungJawab: json['tanggung_jawab'] as String?,
      persyaratan: json['persyaratan'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      sistemKerja: json['sistem_kerja'] as String? ?? 'wfo',
      durasiBulan: json['durasi_bulan'] as int? ?? 3,
      jadwal: json['jadwal'] as String?,
      kuota: json['kuota'] as int? ?? 1,
      batasPendaftaran: DateTime.tryParse(json['batas_pendaftaran'].toString()) ?? DateTime.now().add(const Duration(days: 30)),
      status: json['status'] as String? ?? 'aktif',
      namaPerusahaan: nama,
      alamatPerusahaan: alamat,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'perusahaan_id': perusahaanId,
      'posisi': posisi,
      'bidang': bidang,
      'deskripsi': deskripsi,
      'tanggung_jawab': tanggungJawab,
      'persyaratan': persyaratan,
      'lokasi': lokasi,
      'sistem_kerja': sistemKerja.toLowerCase(),
      'durasi_bulan': durasiBulan,
      'jadwal': jadwal,
      'kuota': kuota,
      'batas_pendaftaran': batasPendaftaran.toIso8601String().split('T').first,
      'status': status.toLowerCase(),
    };
  }
}
