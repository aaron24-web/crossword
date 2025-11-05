import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database_service.dart';
import 'isolates.dart';
import 'level_data.dart';
import 'model.dart' as model;
import 'supabase_service.dart';

part 'providers.g.dart';

enum AppMode { online, offline }

final appModeProvider = StateProvider<AppMode>((ref) => AppMode.online);

final playerProvider = StateProvider<model.Player?>((ref) => null);

final selectedThemeProvider = StateProvider<LevelTheme?>((ref) => null);

const backgroundWorkerCount = 4;

// Default local categories for offline mode or Supabase fallback
final _defaultLocalCategories = <model.Category>[
  model.Category((b) => b..id = 1..name = 'Animales'),
  model.Category((b) => b..id = 2..name = 'Comida'),
  model.Category((b) => b..id = 3..name = 'Deportes'),
  model.Category((b) => b..id = 4..name = 'Países'),
  model.Category((b) => b..id = 5..name = 'Ciencia'),
];

final categoriesProvider = FutureProvider<List<model.Category>>((ref) async {
  final appMode = ref.watch(appModeProvider);

  if (appMode == AppMode.online) {
    try {
      final dbService = DatabaseService(SupabaseService.client);
      final categoriesFromSupabase = await dbService.getCategories();
      if (categoriesFromSupabase.isNotEmpty) {
        debugPrint('✅ Categories loaded from Supabase');
        return categoriesFromSupabase;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load categories from Supabase, falling back to local: $e');
      // Fallback to local categories if Supabase fails
    }
  }
  debugPrint('✅ Categories loaded from local defaults');
  return _defaultLocalCategories;
});

/// A provider for the wordlist to use when generating the crossword.
@riverpod
Future<BuiltSet<String>> wordList(WordListRef ref) async {
  final appMode = ref.watch(appModeProvider);
  final re = RegExp(r'^[a-z]+$');

  BuiltSet<String> wordsSet;

  if (appMode == AppMode.online) {
    try {
      final dbService = DatabaseService(SupabaseService.client);
      final wordsFromSupabase = await dbService.getWords();
      wordsSet = wordsFromSupabase
          .map((word) => word.word.toLowerCase().trim())
          .where((word) => word.length > 2)
          .where((word) => re.hasMatch(word))
          .toBuiltSet();
      if (wordsSet.isNotEmpty) {
        debugPrint('✅ Words loaded from Supabase');
        return wordsSet;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load words from Supabase, falling back to local assets: $e');
      // Fallback to local assets if Supabase fails
    }
  }

  // Load from local assets
  final words = await rootBundle.loadString('assets/words.txt');
  wordsSet = const LineSplitter()
      .convert(words)
      .toBuiltSet()
      .rebuild(
        (b) => b
          ..map((word) => word.toLowerCase().trim())
          ..where((word) => word.length > 2)
          ..where((word) => re.hasMatch(word)),
      );
  debugPrint('✅ Words loaded from local assets');
  return wordsSet;
}

/// An enumeration for different sizes of [model.Crossword]s.
enum CrosswordSize {
  small(width: 20, height: 11),
  medium(width: 40, height: 22),
  large(width: 80, height: 44),
  xlarge(width: 160, height: 88),
  xxlarge(width: 500, height: 500);

  const CrosswordSize({required this.width, required this.height});

  final int width;
  final int height;
  String get label => '$width x $height';
}

/// A provider that holds the current size of the crossword to generate.
@Riverpod(keepAlive: true)
class Size extends _$Size {
  var _size = CrosswordSize.medium;

  @override
  CrosswordSize build() => _size;

  void setSize(CrosswordSize size) {
    _size = size;
    ref.invalidateSelf();
  }
}

@riverpod
Stream<model.WorkQueue> workQueue(WorkQueueRef ref) async* {
  final size = ref.watch(sizeProvider);
  final wordListAsync = ref.watch(wordListProvider);
  final emptyCrossword = model.Crossword.crossword(
    width: size.width,
    height: size.height,
  );
  final emptyWorkQueue = model.WorkQueue.from(
    crossword: emptyCrossword,
    candidateWords: BuiltSet<String>(),
    startLocation: model.Location.at(0, 0),
  );

  yield* wordListAsync.when(
    data: (wordList) => exploreCrosswordSolutions(
      crossword: emptyCrossword,
      wordList: wordList,
      maxWorkerCount: backgroundWorkerCount,
    ),
    error: (error, stackTrace) async* {
      debugPrint('Error loading word list: $error');
      yield emptyWorkQueue;
    },
    loading: () async* {
      yield emptyWorkQueue;
    },
  );
}

@riverpod
class Puzzle extends _$Puzzle {
  model.CrosswordPuzzleGame _puzzle = model.CrosswordPuzzleGame.from(
    crossword: model.Crossword.crossword(width: 0, height: 0),
    candidateWords: BuiltSet<String>(),
  );

  @override
  model.CrosswordPuzzleGame build() {
    final size = ref.watch(sizeProvider);
    final wordList = ref.watch(wordListProvider).value;
    final workQueue = ref.watch(workQueueProvider).value;

    if (wordList != null &&
        workQueue != null &&
        workQueue.isCompleted &&
        (_puzzle.crossword.height != size.height ||
            _puzzle.crossword.width != size.width ||
            _puzzle.crossword != workQueue.crossword)) {
      compute(_puzzleFromCrosswordTrampoline, (
        workQueue.crossword,
        wordList,
      )).then((puzzle) {
        _puzzle = puzzle;
        ref.invalidateSelf();
      });
    }

    return _puzzle;
  }

  Future<void> selectWord({
    required model.Location location,
    required String word,
    required model.Direction direction,
  }) async {
    final candidate = await compute(_puzzleSelectWordTrampoline, (
      _puzzle,
      location,
      word,
      direction,
    ));

    if (candidate != null) {
      _puzzle = candidate;
      ref.invalidateSelf();
    } else {
      debugPrint('Invalid word selection: $word');
    }
  }

  bool canSelectWord({
    required model.Location location,
    required String word,
    required model.Direction direction,
  }) {
    return _puzzle.canSelectWord(
      location: location,
      word: word,
      direction: direction,
    );
  }
}

// Trampoline functions to disentangle these Isolate target calls from the
// unsendable reference to the [Puzzle] provider.

Future<model.CrosswordPuzzleGame> _puzzleFromCrosswordTrampoline(
  (model.Crossword, BuiltSet<String>) args,
) async =>
    model.CrosswordPuzzleGame.from(crossword: args.$1, candidateWords: args.$2);

model.CrosswordPuzzleGame? _puzzleSelectWordTrampoline(
  (model.CrosswordPuzzleGame, model.Location, String, model.Direction) args,
) => args.$1.selectWord(location: args.$2, word: args.$3, direction: args.$4);
