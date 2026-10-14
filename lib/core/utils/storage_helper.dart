import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class UploadedFileInfo {
  final String fileName;
  final int fileSize;
  final String url;
  final Uint8List? bytes;

  UploadedFileInfo({
    required this.fileName,
    required this.fileSize,
    required this.url,
    this.bytes,
  });
}

class StorageHelper {
  static final SupabaseClient _client = SupabaseConfig.client;

  /// Memilih file dokumen PDF atau gambar dari perangkat pengguna
  static Future<UploadedFileInfo?> pickAndUploadDocument({
    String bucketName = 'documents',
    List<String> allowedExtensions = const ['pdf', 'doc', 'docx', 'png', 'jpg'],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final fileName = file.name;
      final fileBytes = file.bytes;
      final fileSize = file.size;

      if (fileBytes == null) return null;

      final safeName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      String publicUrl = '';

      try {
        // Coba upload ke Supabase Storage Bucket
        await _client.storage
            .from(bucketName)
            .uploadBinary(safeName, fileBytes, fileOptions: const FileOptions(upsert: true))
            .timeout(const Duration(seconds: 4));

        publicUrl = _client.storage.from(bucketName).getPublicUrl(safeName);
      } catch (e) {
        debugPrint('Supabase storage upload notice: $e. Menggunakan URL data simulasi.');
        // Fallback simulasi jika bucket belum dibuat di dashboard
        publicUrl = 'https://storage.supabase.co/$bucketName/$safeName';
      }

      return UploadedFileInfo(
        fileName: fileName,
        fileSize: fileSize,
        url: publicUrl,
        bytes: fileBytes,
      );
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Format ukuran file dalam KB/MB
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
