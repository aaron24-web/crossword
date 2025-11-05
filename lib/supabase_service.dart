import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://localhost:1';
  static const String supabaseAnnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqeGV1dXZtcWh6Y3VweG1odmhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTkxMjIsImV4cCI6MjA3NzIzNTEyMn0.bREKQHREsCv7O16AwDXHBckqV2dN5WVwgilECOEt5Uw';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> addScore({
    required String playerId,
    required int time,
    required int categoryId,
  }) async {
    try {
      await client.from('scores').insert({
        'player_id': playerId,
        'time': time,
        'category_id': categoryId,
      });
    } catch (e) {
      // For now, just print the error. In a real app, you might want to handle this more gracefully.
      print('Error saving score: $e');
      rethrow;
    }
  }
}
