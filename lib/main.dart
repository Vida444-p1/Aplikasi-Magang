import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/supabase_config.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale bahasa Indonesia untuk formatting tanggal
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (_) {}

  // Inisialisasi Supabase & Environment (dengan graceful catch jika kredensial belum diisi)
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase initialisation notice: $e (Aplikasi berjalan dalam mode demonstrasi prototype).');
  }

  runApp(
    const ProviderScope(
      child: AplikasiMagangApp(),
    ),
  );
}

class AplikasiMagangApp extends ConsumerWidget {
  const AplikasiMagangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Aplikasi Magang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
