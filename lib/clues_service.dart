import 'dart:convert';
import 'package:flutter/services.dart';

/// Servicio para manejar las pistas/definiciones en español
class CluesService {
  static final CluesService _instance = CluesService._internal();
  factory CluesService() => _instance;
  CluesService._internal();

  Map<String, String> _clues = {};
  bool _isLoaded = false;

  /// Cargar el diccionario de pistas desde el JSON
  Future<void> loadClues() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/clues_spanish.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _clues = jsonData.map((key, value) => MapEntry(key, value.toString()));
      _isLoaded = true;
      
      print('✅ Loaded ${_clues.length} clues in Spanish');
    } catch (e) {
      print('❌ Error loading clues: $e');
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
