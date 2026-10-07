import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => auth.currentUser?.id;

  static String get url => dotenv.env['SUPABASE_URL'] ?? 'https://gymauechavhjvjtpziaj.supabase.co';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = url;
    final supabaseAnonKey = anonKey;

    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
  }
}
