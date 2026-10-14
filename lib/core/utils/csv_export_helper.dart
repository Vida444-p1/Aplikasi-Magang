import 'dart:convert';
import 'package:intl/intl.dart';
import '../../models/application_model.dart';
import 'csv_download_stub.dart' if (dart.library.html) 'csv_download_web.dart';

class CsvExportHelper {
  /// Ekspor data pendaftar magang ke format CSV/Excel
  static void exportApplicantsCsv({
    required String namaPerusahaan,
    required List<ApplicationModel> applicants,
  }) {
    final buffer = StringBuffer();

    // BOM for UTF-8 Excel compatibility
    buffer.write('\uFEFF');

    // Header CSV
    buffer.writeln('No,Nama Mahasiswa,Email,Posisi Magang,Tanggal Daftar,Status,Catatan Perusahaan,Link CV,Link Portofolio');

    // Baris Data
    for (int i = 0; i < applicants.length; i++) {
      final app = applicants[i];
      final no = (i + 1).toString();
      final nama = _escapeCsv(app.namaPeserta ?? 'Vida Rizki Prasetyo');
      final email = _escapeCsv(app.emailPeserta ?? '-');
      final posisi = _escapeCsv(app.vacancy?.posisi ?? 'Web Developer');
      final tgl = _escapeCsv(DateFormat('yyyy-MM-dd HH:mm').format(app.tanggalDaftar));
      final status = _escapeCsv(app.status.toUpperCase());
      final catatan = _escapeCsv(app.catatanPerusahaan ?? '-');
      final cv = _escapeCsv(app.cvUrl);
      final portofolio = _escapeCsv(app.portofolioUrl ?? '-');

      buffer.writeln('$no,$nama,$email,$posisi,$tgl,$status,$catatan,$cv,$portofolio');
    }

    final bytes = utf8.encode(buffer.toString());
    final fileName = 'Data_Pendaftar_Magang_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';

    triggerDownload(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv;charset=utf-8',
    );
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
