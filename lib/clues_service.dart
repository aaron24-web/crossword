import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'database_service.dart';
import 'model.dart';
import 'providers.dart'; // For AppMode

/// Servicio para manejar las pistas/definiciones en español
class CluesService {
  final DatabaseService _dbService;
  final AppMode _appMode;

  CluesService(this._dbService, this._appMode);

  Map<String, String> _clues = {};
  bool _isLoaded = false;

  /// Cargar el diccionario de pistas
  Future<void> loadClues() async {
    if (_isLoaded) return;

    if (_appMode == AppMode.online) {
      await _loadCluesFromSupabase();
    } else {
      await _loadCluesFromLocal();
    }
  }

  Future<void> _loadCluesFromSupabase() async {
    try {
      final List<Word> wordsWithClues = await _dbService.getWords(); // Assuming getWords() fetches all words with clues
      _clues.clear(); // Clear previous clues if any
      for (final word in wordsWithClues) {
        _clues[word.word.toLowerCase().trim()] = word.clue;
      }
      _isLoaded = true;
      debugPrint('✅ Loaded ${_clues.length} clues from Supabase');
    } catch (e) {
      debugPrint('❌ Error loading clues from Supabase: $e');
      // Fallback to local if Supabase fails even in online mode
      await _loadCluesFromLocal();
    }
  }

  Future<void> _loadCluesFromLocal() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/clues_spanish.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _clues = jsonData.map((key, value) => MapEntry(key, value.toString()));
      _isLoaded = true;
      
      debugPrint('✅ Loaded ${_clues.length} clues in Spanish from local file');
    } catch (e) {
      debugPrint('❌ Error loading clues from local file: $e');
      _clues = {};
    }
  }

  /// Obtener pista para una palabra
  String getClue(String word) {
    final normalizedWord = word.toLowerCase().trim();
    
    // Si existe en el diccionario, retornarla
    if (_clues.containsKey(normalizedWord)) {
      return _clues[normalizedWord]!;
    }
    
    // Si no existe, generar pista genérica
    return _generateGenericClue(normalizedWord);
  }

  /// Generar pista genérica cuando no existe en el diccionario
  String _generateGenericClue(String word) {
    final length = word.length;
    final firstLetter = word[0].toUpperCase();
    
    return 'Palabra de $length letras que empieza con "$firstLetter"';
  }

  /// Verificar si existe pista para una palabra
  bool hasClue(String word) {
    return _clues.containsKey(word.toLowerCase().trim());
  }

  /// Agregar pista manualmente (útil para testing)
  void addClue(String word, String clue) {
    _clues[word.toLowerCase().trim()] = clue;
  }

  /// Obtener todas las pistas
  Map<String, String> getAllClues() {
    return Map.unmodifiable(_clues);
  }

  /// Limpiar cache
  void clear() {
    _clues.clear();
    _isLoaded = false;
  }
}
