import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'supabase_service.dart';
import 'widgets/player_registration_screen.dart';

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

  runApp(
    ProviderScope(
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
        home: PlayerRegistrationScreen(),
      ),
    ),
  );
}
