class ActivityModel {
  final String id;
  final String pesertaId;
  final String? lowonganId;
  final DateTime tanggal;
  final String judulKegiatan;
  final String deskripsiKegiatan;
  final double durasiJam;
  final String statusKegiatan; // 'berjalan', 'selesai'
  final String? catatanPembimbing;
  final String? lampiranUrl;
  final String? namaPeserta;
  final String? nimPeserta;

  ActivityModel({
    required this.id,
    required this.pesertaId,
    this.lowonganId,
    required this.tanggal,
    required this.judulKegiatan,
    required this.deskripsiKegiatan,
    required this.durasiJam,
    required this.statusKegiatan,
    this.catatanPembimbing,
    this.lampiranUrl,
    this.namaPeserta,
    this.nimPeserta,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    String? nama;
    String? nim;
    if (json['peserta'] != null && json['peserta'] is Map) {
      nim = json['peserta']['nim'];
      if (json['peserta']['profiles'] != null && json['peserta']['profiles'] is Map) {
        nama = json['peserta']['profiles']['nama_lengkap'];
      }
    }

    return ActivityModel(
      id: json['id'] as String,
      pesertaId: json['peserta_id'] as String,
      lowonganId: json['lowongan_id'] as String?,
      tanggal: DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now(),
      judulKegiatan: json['judul_kegiatan'] as String? ?? '',
      deskripsiKegiatan: json['deskripsi_kegiatan'] as String? ?? '',
      durasiJam: (json['durasi_jam'] != null) ? double.tryParse(json['durasi_jam'].toString()) ?? 8.0 : 8.0,
      statusKegiatan: json['status_kegiatan'] as String? ?? 'selesai',
      catatanPembimbing: json['catatan_pembimbing'] as String?,
      lampiranUrl: json['lampiran_url'] as String?,
      namaPeserta: nama,
      nimPeserta: nim,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peserta_id': pesertaId,
      'lowongan_id': lowonganId,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'judul_kegiatan': judulKegiatan,
      'deskripsi_kegiatan': deskripsiKegiatan,
      'durasi_jam': durasiJam,
      'status_kegiatan': statusKegiatan,
      'catatan_pembimbing': catatanPembimbing,
      'lampiran_url': lampiranUrl,
    };
  }
}
