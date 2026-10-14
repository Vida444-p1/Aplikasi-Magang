import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/activity_model.dart';

class PdfExportHelper {
  /// Ekspor rekap Logbook kegiatan harian ke dokumen PDF resmi
  static Future<void> exportLogbookPdf({
    required String namaMahasiswa,
    required String nim,
    required String universitas,
    required String namaPerusahaan,
    required String posisiMagang,
    required List<ActivityModel> activities,
  }) async {
    final pdf = pw.Document();

    final totalJam = activities.fold<double>(
      0,
      (prev, element) => prev + element.durasiJam,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAPORAN LOGBOOK KEGIATAN MAGANG',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Platform Terpadu Manajemen Magang (Magangin)',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey400),
              pw.SizedBox(height: 10),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Metadata Mahasiswa & Perusahaan
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _metaRow('Nama Mahasiswa', namaMahasiswa),
                      _metaRow('NIM / Identitas', nim),
                      _metaRow('Perguruan Tinggi', universitas),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _metaRow('Mitra Industri', namaPerusahaan),
                      _metaRow('Posisi Magang', posisiMagang),
                      _metaRow('Total Durasi', '${totalJam.toStringAsFixed(1)} Jam Kerja'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Judul Tabel
            pw.Text(
              'Daftar Catatan Kegiatan Harian:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // Tabel Kegiatan
            pw.TableHelper.fromTextArray(
              headers: ['No', 'Tanggal', 'Judul Aktivitas', 'Rincian Kegiatan', 'Durasi', 'Status'],
              data: List<List<String>>.generate(activities.length, (index) {
                final act = activities[index];
                return [
                  (index + 1).toString(),
                  DateFormat('dd/MM/yyyy').format(act.tanggal),
                  act.judulKegiatan,
                  act.deskripsiKegiatan,
                  '${act.durasiJam.toStringAsFixed(1)} Jam',
                  act.statusKegiatan.toUpperCase(),
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.pink700),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.topLeft,
              columnWidths: {
                0: const pw.FixedColumnWidth(24),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FixedColumnWidth(110),
                3: const pw.FlexColumnWidth(),
                4: const pw.FixedColumnWidth(48),
                5: const pw.FixedColumnWidth(55),
              },
            ),
            pw.SizedBox(height: 24),

            // Tanda Tangan
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mahasiswa Magang,', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 48),
                    pw.Text(namaMahasiswa, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('NIM: $nim', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Pembimbing / Mentor Perusahaan,', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 48),
                    pw.Text(namaPerusahaan, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Divisi Pembimbing Lapangan', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Logbook_Magang_${namaMahasiswa.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Ekspor Sertifikat Magang Digital
  static Future<void> exportCertificatePdf({
    required String namaMahasiswa,
    required String namaPerusahaan,
    required String posisiMagang,
    required String durasiBulan,
    required String nilaiAkhir,
    required String predikat,
    required String tanggalSelesai,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber800, width: 4),
              borderRadius: pw.BorderRadius.circular(12),
              color: PdfColors.white,
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.amber600, width: 1.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'SERTIFIKAT KELULUSAN PROGRAM MAGANG',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                      color: PdfColors.pink800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'CERTIFICATE OF INTERNSHIP COMPLETION',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    'Diberikan dengan bangga kepada:',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    namaMahasiswa.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Container(
                    width: 320,
                    height: 1,
                    color: PdfColors.amber800,
                    margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                    child: pw.Text(
                      'Telah sukses dan berhasil menyelesaikan Program Magang Industri di $namaPerusahaan '
                      'sebagai $posisiMagang selama kurun waktu $durasiBulan bulan, dengan capaian evaluasi kompetensi akhir:',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 12, height: 1.4, color: PdfColors.grey800),
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.pink50,
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(color: PdfColors.pink700),
                    ),
                    child: pw.Text(
                      'Nilai Evaluasi: $nilaiAkhir / 100 (Predikat: $predikat)',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.pink900,
                      ),
                    ),
                  ),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Nomor: MAGANG/CERT/${DateTime.now().year}/${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                          pw.Text('Terverifikasi Sistem Magangin Nasional', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey500)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(tanggalSelesai, style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 30),
                          pw.Text(namaPerusahaan, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Pimpinan / Head of Human Capital', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Sertifikat_Magang_${namaMahasiswa.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _metaRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
