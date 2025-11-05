import 'package:flutter/material.dart';

/// Definición de un nivel temático
class LevelTheme {
  final String id;
  final String name;
  final String description;
  final String wordListAsset;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final int levelNumber;

  const LevelTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.wordListAsset,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.levelNumber,
  });
}

/// Los 5 niveles temáticos del juego
class GameLevels {
  static const List<LevelTheme> levels = [
    LevelTheme(
      id: 'animales',
      name: 'Animales',
      description: 'Descubre el reino animal',
      wordListAsset: 'assets/words_animales.txt',
      icon: Icons.pets,
      primaryColor: Color(0xFF2196F3), // Azul claro
      secondaryColor: Color(0xFF1976D2),
      levelNumber: 1,
    ),
    LevelTheme(
      id: 'comida',
      name: 'Comida',
      description: 'Explora el mundo gastronómico',
      wordListAsset: 'assets/words_comida.txt',
      icon: Icons.restaurant,
      primaryColor: Color(0xFF03A9F4), // Azul cielo
      secondaryColor: Color(0xFF0288D1),
      levelNumber: 2,
    ),
    LevelTheme(
      id: 'deportes',
      name: 'Deportes',
      description: 'Conoce diferentes disciplinas',
      wordListAsset: 'assets/words_deportes.txt',
      icon: Icons.sports_soccer,
      primaryColor: Color(0xFF00BCD4), // Azul verdoso
      secondaryColor: Color(0xFF0097A7),
      levelNumber: 3,
    ),
    LevelTheme(
      id: 'paises',
      name: 'Países',
      description: 'Viaja por el mundo',
      wordListAsset: 'assets/words_paises.txt',
      icon: Icons.public,
      primaryColor: Color(0xFF009688), // Azul azulado
      secondaryColor: Color(0xFF00796B),
      levelNumber: 4,
    ),
    LevelTheme(
      id: 'ciencia',
      name: 'Ciencia',
      description: 'Descubre el universo científico',
      wordListAsset: 'assets/words_ciencia.txt',
      icon: Icons.science,
      primaryColor: Color(0xFF3F51B5), // Azul índigo
      secondaryColor: Color(0xFF303F9F),
      levelNumber: 5,
    ),
  ];

  /// Obtener nivel por ID
  static LevelTheme? getLevelById(String id) {
    try {
      return levels.firstWhere((level) => level.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener nivel por número
  static LevelTheme? getLevelByNumber(int number) {
    try {
      return levels.firstWhere((level) => level.levelNumber == number);
    } catch (e) {
      return null;
    }
  }
}
