import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio_service.dart';
import '../level_data.dart';
import '../model.dart' as model;
import '../themed_providers.dart';
import '../utils.dart';
import 'puzzle_completed_widget.dart';

/// Pantalla del crucigrama temático completo
class ThemedCrosswordScreen extends ConsumerStatefulWidget {
  final LevelTheme theme;

  const ThemedCrosswordScreen({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<ThemedCrosswordScreen> createState() => _ThemedCrosswordScreenState();
}

class _ThemedCrosswordScreenState extends ConsumerState<ThemedCrosswordScreen> {
  WordWithClue? _selectedWord;
  model.Location? _selectedCell;  // Celda activa
  int _selectedCellIndex = 0;  // Índice en la palabra
  final FocusNode _gridFocus = FocusNode();  // Focus para capturar teclado
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocus = FocusNode();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _gridFocus.dispose();
    _answerController.dispose();
    _answerFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(themedPuzzleProvider(widget.theme.id.toString()));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.theme.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: widget.theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier).clearAnswers();
            },
            tooltip: 'Limpiar respuestas',
          ),
        ],
      ),
      body: puzzleAsync.when(
        data: (puzzleState) {
          if (puzzleState.isGenerating) {
            return _buildGeneratingView();
          }
          
          if (puzzleState.isCompleted) {
            return PuzzleCompletedWidget();
          }

          return _buildGameView(puzzleState);
        },
        loading: () => _buildGeneratingView(),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.theme.icon,
            size: 100,
            color: widget.theme.primaryColor,
          ),
          SizedBox(height: 30),
          CircularProgressIndicator(
            color: widget.theme.primaryColor,
          ),
          SizedBox(height: 20),
          Text(
            'Generando crucigrama...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(ThemedPuzzleState puzzleState) {
    // Detectar si es móvil o web/desktop
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Layout móvil: Crucigrama arriba, pistas abajo
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              puzzleState.stopwatch.elapsed.formatted,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          // Cuadrícula (arriba - más espacio)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: _buildGrid(puzzleState),
            ),
          ),
          
          // Separador visual
          Container(
            height: 2,
            color: widget.theme.primaryColor.withOpacity(0.2),
          ),
          
          // Pistas (abajo - menos espacio pero suficiente)
          Expanded(
            flex: 4,
            child: _buildCluesPanel(puzzleState),
          ),
        ],
      );
    } else {
      // Layout web/desktop: Crucigrama izquierda, pistas derecha
      return Row(
        children: [
          // Cuadrícula (izquierda)
          Expanded(
            flex: 2,
            child: _buildGrid(puzzleState),
          ),
          
          // Pistas (derecha)
          Expanded(
            flex: 1,
            child: _buildCluesPanel(puzzleState),
          ),
        ],
      );
    }
  }

  Widget _buildGrid(ThemedPuzzleState puzzleState) {
    if (puzzleState.crossword == null) return SizedBox();

    final crossword = puzzleState.crossword!;
    
    // Tamaño de celda adaptativo según dispositivo
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Calcular tamaño de celda para que el crucigrama ocupe el ancho disponible
    final availableWidth = isMobile ? screenWidth - 40 : screenWidth * 0.6;
    final cellSize = (availableWidth / crossword.width).clamp(25.0, 45.0);

    return Center(
      child: KeyboardListener(
        focusNode: _gridFocus,
        autofocus: true,
        onKeyEvent: (event) => _handleKeyPress(event, puzzleState),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 10 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(crossword.height, (y) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(crossword.width, (x) {
                      final location = model.Location.at(x, y);
                      final char = crossword.characters[location];
                      
                      return _buildCell(
                        location,
                        char,
                        puzzleState,
                        cellSize,
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    model.Location location,
    model.CrosswordCharacter? char,
    ThemedPuzzleState puzzleState,
    double size,
  ) {
    if (char == null) {
      return Container(
        width: size,
        height: size,
        margin: EdgeInsets.all(1),
      );
    }

    // Obtener número si es inicio de palabra
    int? number;
    for (final wordWithClue in puzzleState.wordsWithClues) {
      if (wordWithClue.word.location == location) {
        number = wordWithClue.number;
        break;
      }
    }

    // Obtener letra del usuario si existe
    String? userLetter;
    for (final wordWithClue in puzzleState.wordsWithClues) {
      final word = wordWithClue.word;
      final answer = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier).getAnswer(word);
      
      if (answer != null) {
        final wordLocations = _getWordLocations(word);
        final index = wordLocations.indexOf(location);
        if (index >= 0 && index < answer.length) {
          userLetter = answer[index];
          break;
        }
      }
    }

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Stack(
        children: [
          // Número
          if (number != null)
            Positioned(
              top: 1,
              left: 2,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: size * 0.25, // Proporcional al tamaño de celda
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
            ),
          
          // Letra del usuario
          Center(
            child: Text(
              userLetter?.toUpperCase() ?? '',
              style: GoogleFonts.poppins(
                fontSize: size * 0.55, // Proporcional al tamaño de celda
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<model.Location> _getWordLocations(model.CrosswordWord word) {
    final locations = <model.Location>[];
    var current = word.location;
    
    for (int i = 0; i < word.word.length; i++) {
      locations.add(current);
      current = word.direction == model.Direction.across
          ? current.right
          : current.down;
    }
    
    return locations;
  }

  Widget _buildCluesPanel(ThemedPuzzleState puzzleState) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Campo de respuesta (más compacto en móvil)
          if (_selectedWord != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 16,
              ),
              decoration: BoxDecoration(
                color: widget.theme.primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: widget.theme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedWord!.number}. ${_selectedWord!.word.direction == model.Direction.across ? "Horizontal" : "Vertical"}',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: widget.theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _selectedWord!.clue,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 11 : 13,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _answerController,
                    focusNode: _answerFocus,
                    decoration: InputDecoration(
                      hintText: 'Escribe...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isMobile ? 8 : 12,
                      ),
                      suffixIcon: Icon(
                        Icons.keyboard_return,
                        color: Colors.grey,
                        size: 20,
                      ),
                      isDense: true,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (value) => _handleAnswerSubmit(value, puzzleState),
                  ),
                ],
              ),
            ),
          
          // Lista de pistas (más compacta)
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(isMobile ? 10 : 16),
              children: [
                _buildCluesSection('HORIZONTAL', puzzleState.acrossWords),
                SizedBox(height: isMobile ? 12 : 20),
                _buildCluesSection('VERTICAL', puzzleState.downWords),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCluesSection(String title, List<WordWithClue> words) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 13 : 16,
            fontWeight: FontWeight.w800,
            color: widget.theme.primaryColor,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        ...words.map((wordWithClue) => _buildClueItem(wordWithClue)),
      ],
    );
  }

  Widget _buildClueItem(WordWithClue wordWithClue) {
    final isCorrect = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier)
        .isAnswerCorrect(wordWithClue.word);
    final isSelected = _selectedWord == wordWithClue;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedWord = wordWithClue;
          _answerController.text = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier)
              .getAnswer(wordWithClue.word) ?? '';
        });
        _answerFocus.requestFocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 6 : 8,
          horizontal: isMobile ? 10 : 12,
        ),
        margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.theme.primaryColor.withOpacity(0.15)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? widget.theme.primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${wordWithClue.number}.',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w700,
                color: widget.theme.primaryColor,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: Text(
                wordWithClue.clue,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11 : 13,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: isMobile ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCorrect)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: isMobile ? 18 : 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Manejar envío de respuesta con validación automática
  void _handleAnswerSubmit(String value, ThemedPuzzleState puzzleState) {
    if (_selectedWord == null || value.trim().isEmpty) return;

    final puzzleNotifier = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier);
    final correctAnswer = _selectedWord!.word.word.toLowerCase();
    final userAnswer = value.trim().toLowerCase();

    // Guardar respuesta
    puzzleNotifier.setAnswer(_selectedWord!.word, userAnswer);

    // Validar si es correcta
    if (userAnswer == correctAnswer) {
      // ✅ RESPUESTA CORRECTA
      AudioService().playSoundEffect(SoundEffect.wordCorrect);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ¡Correcto!'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 800),
        ),
      );
      
      // Limpiar campo
      _answerController.clear();
      
      // Auto-avanzar a siguiente pregunta sin responder
      _selectNextUnansweredClue(puzzleState);
    } else {
      // ❌ RESPUESTA INCORRECTA
      AudioService().playSoundEffect(SoundEffect.wordWrong);
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Incorrecto. Intenta de nuevo'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
      
      // Limpiar campo para reintentar
      _answerController.clear();
      
      // Mantener la misma pregunta seleccionada
      _answerFocus.requestFocus();
    }
  }

  /// Seleccionar siguiente pista sin responder
  void _selectNextUnansweredClue(ThemedPuzzleState puzzleState) {
    final puzzleNotifier = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier);
    
    // Buscar siguiente pista sin responder
    WordWithClue? nextWord;
    
    // Primero buscar en horizontales
    for (final wordWithClue in puzzleState.acrossWords) {
      if (!puzzleNotifier.isAnswerCorrect(wordWithClue.word)) {
        nextWord = wordWithClue;
        break;
      }
    }
    
    // Si no hay horizontales, buscar en verticales
    if (nextWord == null) {
      for (final wordWithClue in puzzleState.downWords) {
        if (!puzzleNotifier.isAnswerCorrect(wordWithClue.word)) {
          nextWord = wordWithClue;
          break;
        }
      }
    }
    
    // Actualizar selección
    setState(() {
      _selectedWord = nextWord;
      if (nextWord != null) {
        _answerController.text = puzzleNotifier.getAnswer(nextWord.word) ?? '';
        _answerFocus.requestFocus();
      }
    });
  }

  /// Manejar presión de tecla para navegación
  void _handleKeyPress(KeyEvent event, ThemedPuzzleState puzzleState) {
    if (event is! KeyDownEvent) return;

    // Si hay una celda seleccionada, manejar entrada de letra
    if (_selectedCell != null && _selectedWord != null) {
      final key = event.logicalKey;
      
      if (key == LogicalKeyboardKey.backspace) {
        // Borrar letra actual
        final puzzleNotifier = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier);
        final currentAnswer = puzzleNotifier.getAnswer(_selectedWord!.word) ?? '';
        if (currentAnswer.isNotEmpty && _selectedCellIndex > 0) {
          final newAnswer = currentAnswer.substring(0, _selectedCellIndex - 1) +
              currentAnswer.substring(_selectedCellIndex);
          puzzleNotifier.setAnswer(_selectedWord!.word, newAnswer);
          setState(() {
            _selectedCellIndex--;
          });
        }
      } else if (key.keyLabel.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(key.keyLabel)) {
        // Ingresar letra
        final letter = key.keyLabel.toUpperCase();
        final puzzleNotifier = ref.read(themedPuzzleProvider(widget.theme.id.toString()).notifier);
        final currentAnswer = puzzleNotifier.getAnswer(_selectedWord!.word) ?? '';
        
        if (_selectedCellIndex < _selectedWord!.word.word.length) {
          final newAnswer = currentAnswer.padRight(_selectedWord!.word.word.length, ' ')
              .replaceRange(_selectedCellIndex, _selectedCellIndex + 1, letter);
          puzzleNotifier.setAnswer(_selectedWord!.word, newAnswer.trimRight());
          
          setState(() {
            if (_selectedCellIndex < _selectedWord!.word.word.length - 1) {
              _selectedCellIndex++;
            }
          });
        }
      }
    }
  }
}
