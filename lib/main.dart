import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_service.dart';
import 'database_service.dart';
import 'model.dart';
import 'providers.dart';
import 'supabase_service.dart';
import 'widgets/home_screen.dart';
import 'widgets/login_screen.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  // Inicializar servicio de audio
  try {
    await AudioService().initialize();
    await AudioService().playBackgroundMusic();
    debugPrint('✅ Audio initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Audio initialization failed: $e');
    // Continuar sin audio si falla
  }

  final prefs = await SharedPreferences.getInstance();
  final playerId = prefs.getInt('player_id');

  Widget home = const LoginScreen();
  Player? player;
  if (playerId != null) {
    final dbService = DatabaseService(SupabaseService.client);
    player = await dbService.getPlayerById(playerId);
    if (player != null) {
      home = const HomeScreen();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (player != null) playerProvider.overrideWith((ref) => player),
      ],
      child: MaterialApp(
        title: 'Crossword Puzzle',
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        showPerformanceOverlay: false,
        theme: ThemeData(
          // Paleta de colores estilo CodyCross
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF3B82F6), // Azul
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Botones redondeados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
        home: home,
      ),
    ),
  );
}
