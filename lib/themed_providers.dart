import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'clues_service.dart';
import 'isolates.dart';
import 'level_data.dart';
import 'model.dart' as model;

part 'themed_providers.g.dart';

/// Provider para cargar palabras de un tema específico
/// Solo incluye palabras que tienen pista en el diccionario
@riverpod
Future<BuiltSet<String>> themedWordList(
  ThemedWordListRef ref,
  String themeId,
) async {
  final level = GameLevels.getLevelById(themeId);
  if (level == null) {
    return BuiltSet<String>();
  }

  // Cargar pistas primero
  await CluesService().loadClues();
  
  final data = await rootBundle.loadString(level.wordListAsset);
  final allWords = data
      .split('\n')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.length > 2)
      .toSet();

  // Filtrar solo palabras que tienen pista educativa (no genérica)
  final wordsWithClues = allWords.where((word) {
    final clue = CluesService().getClue(word);
    // Verificar que no sea una pista genérica
    return !clue.startsWith('Palabra de ');
  }).toSet();

  return BuiltSet<String>(wordsWithClues);
}

/// Provider para generar crucigrama temático
@riverpod
Stream<model.WorkQueue> themedWorkQueue(
  ThemedWorkQueueRef ref,
  String themeId,
) async* {
  // Cargar palabras del tema
  final wordListAsync = await ref.watch(themedWordListProvider(themeId).future);
  
  // Cargar pistas
  await CluesService().loadClues();

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
  model.Crossword? _crossword;
  Map<String, String> _userAnswers = {};
  List<WordWithClue> _wordsWithClues = [];

  @override
  Future<ThemedPuzzleState> build(String themeId) async {
    // Retornar estado inicial de generación
    // El crucigrama se cargará desde la UI usando el stream provider
    return ThemedPuzzleState(
      crossword: null,
      wordsWithClues: [],
      userAnswers: {},
      isCompleted: false,
      isGenerating: true,
    );
  }
  
  /// Inicializar puzzle con un crucigrama generado
  void initializeWithCrossword(model.Crossword crossword) {
    _crossword = crossword;
    _generateWordsWithClues();
    
    state = AsyncValue.data(ThemedPuzzleState(
      crossword: _crossword,
      wordsWithClues: _wordsWithClues,
      userAnswers: _userAnswers,
      isCompleted: false,
      isGenerating: false,
    ));
  }

  void _generateWordsWithClues() {
    if (_crossword == null) return;

    final words = _crossword!.words.toList();
    words.sort((a, b) {
      final compareY = a.location.y.compareTo(b.location.y);
      if (compareY != 0) return compareY;
      return a.location.x.compareTo(b.location.x);
    });

    _wordsWithClues = [];
    int number = 1;
    final numberedPositions = <String, int>{};

    for (final word in words) {
      final key = '${word.location.x},${word.location.y}';
      
      if (!numberedPositions.containsKey(key)) {
        numberedPositions[key] = number++;
      }

      final wordNumber = numberedPositions[key]!;
      final clue = CluesService().getClue(word.word);

      _wordsWithClues.add(WordWithClue(
        word: word,
        clue: clue,
        number: wordNumber,
      ));
    }
  }

  /// Escribir respuesta para una palabra (solo si es correcta)
  void setAnswer(model.CrosswordWord word, String answer) {
    final key = _getWordKey(word);
    final cleanAnswer = answer.toLowerCase().trim();
    
    // Solo guardar si la respuesta es correcta
    if (cleanAnswer == word.word.toLowerCase()) {
      _userAnswers[key] = cleanAnswer;
    } else {
      // Si es incorrecta, eliminar cualquier respuesta previa
      _userAnswers.remove(key);
    }
    
    // Verificar si el puzzle está completo
    final isCompleted = _checkIfCompleted();
    
    state = AsyncValue.data(ThemedPuzzleState(
      crossword: _crossword,
      wordsWithClues: _wordsWithClues,
      userAnswers: _userAnswers,
      isCompleted: isCompleted,
      isGenerating: false,
    ));
  }

  /// Obtener respuesta del usuario para una palabra
  String? getAnswer(model.CrosswordWord word) {
    final key = _getWordKey(word);
    return _userAnswers[key];
  }

  /// Verificar si una respuesta es correcta
  bool isAnswerCorrect(model.CrosswordWord word) {
    final answer = getAnswer(word);
    if (answer == null || answer.isEmpty) return false;
    return answer == word.word.toLowerCase();
  }

  /// Verificar si el puzzle está completado
  bool _checkIfCompleted() {
    if (_crossword == null) return false;
    
    for (final word in _crossword!.words) {
      if (!isAnswerCorrect(word)) {
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
    final wordWithClue = _wordsWithClues.firstWhere(
      (w) => w.word == word,
      orElse: () => WordWithClue(word: word, clue: '', number: 0),
    );
    return wordWithClue.number > 0 ? wordWithClue.number : null;
  }

  /// Limpiar todas las respuestas
  void clearAnswers() {
    _userAnswers.clear();
    state = AsyncValue.data(ThemedPuzzleState(
      crossword: _crossword,
      wordsWithClues: _wordsWithClues,
      userAnswers: _userAnswers,
      isCompleted: false,
      isGenerating: false,
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

  ThemedPuzzleState({
    required this.crossword,
    required this.wordsWithClues,
    required this.userAnswers,
    required this.isCompleted,
    required this.isGenerating,
  });

  List<WordWithClue> get acrossWords =>
      wordsWithClues.where((w) => w.word.direction == model.Direction.across).toList();

  List<WordWithClue> get downWords =>
      wordsWithClues.where((w) => w.word.direction == model.Direction.down).toList();
}
