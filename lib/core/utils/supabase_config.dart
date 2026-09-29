import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => auth.currentUser?.id;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'] ?? 'https://sample-project-id.supabase.co';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'sample-anon-key';

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
