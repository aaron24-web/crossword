import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import 'clues_service.dart';
import 'database_service.dart';
import 'isolates.dart';
import 'level_data.dart';
import 'model.dart' as model;
import 'providers.dart';
import 'supabase_service.dart';

part 'themed_providers.g.dart';

/// Provider para cargar palabras de un tema específico
/// Solo incluye palabras que tienen pista en el diccionario
@riverpod
Future<BuiltSet<String>> themedWordList(
  ThemedWordListRef ref,
  String themeId,
) async { // Added ')' and '{' and 'async'
  final appMode = ref.watch(appModeProvider);
  final dbService = DatabaseService(SupabaseService.client);
  final cluesService = CluesService(dbService, appMode);

  // Cargar pistas primero
  await cluesService.loadClues();
  
  final re = RegExp(r'^[a-z]+$');
  BuiltSet<String> wordsSet = BuiltSet<String>(); // Initialized wordsSet

  final level = GameLevels.getLevelById(int.parse(themeId));
  if (level == null) {
    return BuiltSet<String>();
  }

  if (appMode == AppMode.online) {
    try {
      final dbService = DatabaseService(SupabaseService.client);
      final wordsFromSupabase = await dbService.getWordsByCategory(int.parse(themeId));
      wordsSet = wordsFromSupabase
          .map((word) => word.word.toLowerCase().trim())
          .where((word) => word.length > 2)
          .where((word) => re.hasMatch(word))
          .toBuiltSet();
      
      final wordsWithClues = wordsSet;

      if (wordsWithClues.isNotEmpty) {
        debugPrint('✅ Themed words loaded from Supabase for theme $themeId');
        return wordsWithClues;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load themed words from Supabase for theme $themeId, falling back to local assets: $e');
      // Fallback to local assets if Supabase fails
    }
  }

  // Load from local assets
  final data = await rootBundle.loadString(level.wordListAsset);
  wordsSet = data
      .split('\n')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.length > 2)
      .where((word) => re.hasMatch(word))
      .toBuiltSet();

  final wordsWithClues = wordsSet;

  debugPrint('✅ Themed words loaded from local assets for theme $themeId');
  return wordsWithClues;
}

/// Provider para generar crucigrama temático
@riverpod
Stream<model.WorkQueue> themedWorkQueue(
  ThemedWorkQueueRef ref,
  String themeId,
) async* {
  // Cargar palabras del tema
  final wordListAsync = await ref.watch(themedWordListProvider(themeId).future);
  
  final appMode = ref.watch(appModeProvider);
  final dbService = DatabaseService(SupabaseService.client);
  final cluesService = CluesService(dbService, appMode);

  // Cargar pistas
  await cluesService.loadClues();

  // Tamaño fijo para niveles temáticos (más pequeño para mejor experiencia)
  const width = 10;
  const height = 10;

  final emptyCrossword = model.Crossword.crossword(
    width: width,
    height: height,
  );

  final emptyWorkQueue = model.WorkQueue.from(
    crossword: emptyCrossword,
    candidateWords: BuiltSet<String>(),
    startLocation: model.Location.at(0, 0),
  );

  if (wordListAsync.isEmpty) {
    yield emptyWorkQueue;
    return;
  }

  // Generar crucigrama con las palabras del tema
  yield* exploreCrosswordSolutions(
    crossword: emptyCrossword,
    wordList: wordListAsync,
    maxWorkerCount: 4,
  );
}

/// Modelo para una palabra con su pista
class WordWithClue {
  final model.CrosswordWord word;
  final String clue;
  final int number;

  WordWithClue({
    required this.word,
    required this.clue,
    required this.number,
  });
}

/// Provider para el crucigrama temático con pistas
@riverpod
class ThemedPuzzle extends _$ThemedPuzzle {
  final _stopwatch = Stopwatch();

  @override
  Future<ThemedPuzzleState> build(String themeId) async {
    final workQueue = await ref.watch(themedWorkQueueProvider(themeId).future);

    if (workQueue.isCompleted && workQueue.crossword.characters.isNotEmpty) {
      final crossword = workQueue.crossword;
      final words = crossword.words.toList();
      words.sort((a, b) {
        final compareY = a.location.y.compareTo(b.location.y);
        if (compareY != 0) return compareY;
        return a.location.x.compareTo(b.location.x);
      });

      final wordsWithClues = <WordWithClue>[];
      int number = 1;
      final numberedPositions = <String, int>{};

      final appMode = ref.watch(appModeProvider);
      final dbService = DatabaseService(SupabaseService.client);
      final cluesService = CluesService(dbService, appMode);

      for (final word in words) {
        final key = '${word.location.x},${word.location.y}';
        
        if (!numberedPositions.containsKey(key)) {
          numberedPositions[key] = number++;
        }

        final wordNumber = numberedPositions[key]!;
        final clue = cluesService.getClue(word.word);

        wordsWithClues.add(WordWithClue(
          word: word,
          clue: clue,
          number: wordNumber,
        ));
      }

      _stopwatch.start();

      return ThemedPuzzleState(
        crossword: crossword,
        wordsWithClues: wordsWithClues,
        userAnswers: {},
        isCompleted: false,
        isGenerating: false,
        stopwatch: _stopwatch,
      );
    }

    return ThemedPuzzleState(
      crossword: null,
      wordsWithClues: [],
      userAnswers: {},
      isCompleted: false,
      isGenerating: true,
      stopwatch: _stopwatch,
    );
  }

  /// Escribir respuesta para una palabra (solo si es correcta)
  void setAnswer(model.CrosswordWord word, String answer) {
    final key = _getWordKey(word);
    final cleanAnswer = answer.toLowerCase().trim();
    
    final currentState = state.value!;
    final userAnswers = Map<String, String>.from(currentState.userAnswers);

    // Solo guardar si la respuesta es correcta
    if (cleanAnswer == word.word.toLowerCase()) {
      userAnswers[key] = cleanAnswer;
    } else {
      // Si es incorrecta, eliminar cualquier respuesta previa
      userAnswers.remove(key);
    }
    
    // Verificar si el puzzle está completo
    final isCompleted = _checkIfCompleted(currentState.crossword!, userAnswers);
    if (isCompleted) {
      _stopwatch.stop();
    }
    
    state = AsyncValue.data(currentState.copyWith(
      userAnswers: userAnswers,
      isCompleted: isCompleted,
    ));
  }

  /// Obtener respuesta del usuario para una palabra
  String? getAnswer(model.CrosswordWord word) {
    final key = _getWordKey(word);
    return state.value?.userAnswers[key];
  }

  /// Verificar si una respuesta es correcta
  bool isAnswerCorrect(model.CrosswordWord word) {
    final answer = getAnswer(word);
    if (answer == null || answer.isEmpty) return false;
    return answer == word.word.toLowerCase();
  }

  /// Verificar si el puzzle está completado
  bool _checkIfCompleted(model.Crossword crossword, Map<String, String> userAnswers) {
    for (final word in crossword.words) {
      final key = _getWordKey(word);
      if (userAnswers[key] != word.word.toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  String _getWordKey(model.CrosswordWord word) {
    return '${word.location.x},${word.location.y},${word.direction.name}';
  }

  /// Obtener número de una palabra
  int? getWordNumber(model.CrosswordWord word) {
    return state.value?.wordsWithClues.firstWhere(
      (w) => w.word == word,
      orElse: () => WordWithClue(word: word, clue: '', number: 0),
    ).number;
  }

  /// Limpiar todas las respuestas
  void clearAnswers() {
    final currentState = state.value!;
    state = AsyncValue.data(currentState.copyWith(
      userAnswers: {},
      isCompleted: false,
    ));
  }
}

/// Estado del puzzle temático
class ThemedPuzzleState {
  final model.Crossword? crossword;
  final List<WordWithClue> wordsWithClues;
  final Map<String, String> userAnswers;
  final bool isCompleted;
  final bool isGenerating;
  final Stopwatch stopwatch;

  ThemedPuzzleState({
    required this.crossword,
    required this.wordsWithClues,
    required this.userAnswers,
    required this.isCompleted,
    required this.isGenerating,
    required this.stopwatch,
  });

  List<WordWithClue> get acrossWords =>
      wordsWithClues.where((w) => w.word.direction == model.Direction.across).toList();

  List<WordWithClue> get downWords =>
      wordsWithClues.where((w) => w.word.direction == model.Direction.down).toList();

  ThemedPuzzleState copyWith({
    model.Crossword? crossword,
    List<WordWithClue>? wordsWithClues,
    Map<String, String>? userAnswers,
    bool? isCompleted,
    bool? isGenerating,
    Stopwatch? stopwatch,
  }) {
    return ThemedPuzzleState(
      crossword: crossword ?? this.crossword,
      wordsWithClues: wordsWithClues ?? this.wordsWithClues,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      isGenerating: isGenerating ?? this.isGenerating,
      stopwatch: stopwatch ?? this.stopwatch,
    );
  }
}
