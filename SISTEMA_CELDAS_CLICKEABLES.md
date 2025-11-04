# 🎯 SISTEMA DE CELDAS CLICKEABLES - Plan de Implementación

## 📋 **CAMBIOS NECESARIOS:**

### **1. Estado (Variables)**
```dart
// ANTES:
WordWithClue? _selectedWord;
TextEditingController _answerController;
FocusNode _answerFocus;

// AHORA:
WordWithClue? _selectedWord;
model.Location? _selectedCell;  // Celda activa
int _selectedCellIndex = 0;  // Índice en la palabra
FocusNode _gridFocus;  // Focus para capturar teclado
```

---

### **2. Grid con KeyboardListener**
```dart
KeyboardListener(
  focusNode: _gridFocus,
  autofocus: true,
  onKeyEvent: (event) => _handleKeyPress(event, puzzleState),
  child: // ... grid actual
)
```

---

### **3. Celdas Clickeables**
```dart
GestureDetector(
  onTap: () => _onCellTap(location, puzzleState),
  child: Container(
    decoration: BoxDecoration(
      color: _isCellSelected(location) 
        ? theme.primaryColor.withOpacity(0.3)  // Celda activa
        : _isCellInSelectedWord(location)
          ? theme.primaryColor.withOpacity(0.1)  // Palabra activa
          : Colors.white,
      border: Border.all(
        color: _isCellSelected(location)
          ? theme.primaryColor
          : Colors.grey.shade400,
        width: _isCellSelected(location) ? 2 : 1,
      ),
    ),
    child: // ... número y letra
  ),
)
```

---

### **4. Manejo de Teclas**
```dart
void _handleKeyPress(KeyEvent event, ThemedPuzzleState puzzleState) {
  if (event is! KeyDownEvent) return;
  if (_selectedWord == null || _selectedCell == null) return;

  final key = event.logicalKey;

  // Letra (A-Z)
  if (key.keyLabel.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(key.keyLabel)) {
    _enterLetter(key.keyLabel.toUpperCase(), puzzleState);
  }
  
  // Backspace
  else if (key == LogicalKeyboardKey.backspace) {
    _deleteLetter(puzzleState);
  }
  
  // Enter
  else if (key == LogicalKeyboardKey.enter) {
    _validateWord(puzzleState);
  }
  
  // Flechas
  else if (key == LogicalKeyboardKey.arrowLeft) {
    _moveToPreviousCell();
  }
  else if (key == LogicalKeyboardKey.arrowRight) {
    _moveToNextCell();
  }
}
```

---

### **5. Métodos Auxiliares**
```dart
// Entrar letra en celda activa
void _enterLetter(String letter, ThemedPuzzleState puzzleState) {
  final word = _selectedWord!.word;
  final locations = _getWordLocations(word);
  
  // Obtener respuesta actual
  final currentAnswer = ref.read(themedPuzzleProvider(widget.theme.id).notifier)
      .getAnswer(word) ?? '';
  
  // Construir nueva respuesta
  final answerList = currentAnswer.padRight(word.word.length, ' ').split('');
  answerList[_selectedCellIndex] = letter.toLowerCase();
  final newAnswer = answerList.join('').trimRight();
  
  // Guardar (sin validar aún)
  ref.read(themedPuzzleProvider(widget.theme.id).notifier)
      .setAnswerDirect(word, newAnswer);
  
  // Avanzar a siguiente celda
  if (_selectedCellIndex < locations.length - 1) {
    setState(() {
      _selectedCellIndex++;
      _selectedCell = locations[_selectedCellIndex];
    });
  } else {
    // Última letra → validar automáticamente
    _validateWord(puzzleState);
  }
}

// Borrar letra
void _deleteLetter(ThemedPuzzleState puzzleState) {
  final word = _selectedWord!.word;
  final currentAnswer = ref.read(themedPuzzleProvider(widget.theme.id).notifier)
      .getAnswer(word) ?? '';
  
  if (currentAnswer.isEmpty) return;
  
  // Borrar letra actual o retroceder
  if (_selectedCellIndex > 0) {
    final answerList = currentAnswer.padRight(word.word.length, ' ').split('');
    answerList[_selectedCellIndex - 1] = ' ';
    final newAnswer = answerList.join('').trimRight();
    
    ref.read(themedPuzzleProvider(widget.theme.id).notifier)
        .setAnswerDirect(word, newAnswer);
    
    setState(() {
      _selectedCellIndex--;
      _selectedCell = _getWordLocations(word)[_selectedCellIndex];
    });
  }
}

// Validar palabra completa
void _validateWord(ThemedPuzzleState puzzleState) {
  final word = _selectedWord!.word;
  final answer = ref.read(themedPuzzleProvider(widget.theme.id).notifier)
      .getAnswer(word) ?? '';
  
  if (answer.toLowerCase() == word.word.toLowerCase()) {
    // ✅ CORRECTA
    AudioService().playSoundEffect(SoundEffect.wordCorrect);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ¡Correcto!'),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 800),
      ),
    );
    _selectNextUnansweredClue(puzzleState);
  } else {
    // ❌ INCORRECTA
    AudioService().playSoundEffect(SoundEffect.wordWrong);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Incorrecto. Intenta de nuevo'),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}

// Click en celda
void _onCellTap(model.Location location, ThemedPuzzleState puzzleState) {
  // Buscar palabra que contiene esta celda
  for (final wordWithClue in puzzleState.wordsWithClues) {
    final locations = _getWordLocations(wordWithClue.word);
    final index = locations.indexOf(location);
    
    if (index >= 0) {
      setState(() {
        _selectedWord = wordWithClue;
        _selectedCell = location;
        _selectedCellIndex = index;
      });
      _gridFocus.requestFocus();
      break;
    }
  }
}

// Verificar si celda está seleccionada
bool _isCellSelected(model.Location location) {
  return _selectedCell == location;
}

// Verificar si celda está en palabra activa
bool _isCellInSelectedWord(model.Location location) {
  if (_selectedWord == null) return false;
  final locations = _getWordLocations(_selectedWord!.word);
  return locations.contains(location);
}
```

---

### **6. Modificar Provider**
Necesitamos un método `setAnswerDirect` que NO valide:

```dart
// En themed_providers.dart
void setAnswerDirect(model.CrosswordWord word, String answer) {
  final key = _getWordKey(word);
  _userAnswers[key] = answer.toLowerCase().trim();
  
  state = AsyncValue.data(ThemedPuzzleState(
    crossword: _crossword,
    wordsWithClues: _wordsWithClues,
    userAnswers: _userAnswers,
    isCompleted: _checkIfCompleted(),
    isGenerating: false,
  ));
}
```

---

### **7. Eliminar TextField**
Quitar completamente el panel de TextField del `_buildCluesPanel`.

---

## 🎯 **FLUJO DE USUARIO:**

```
1. Usuario hace clic en pista
   → Se resalta la palabra en el crucigrama
   → Primera celda se marca como activa

2. Usuario hace clic en una celda específica
   → Esa celda se marca como activa
   → Se selecciona la palabra que contiene esa celda

3. Usuario escribe letra "G"
   → Aparece "G" en la celda activa
   → Auto-avanza a siguiente celda

4. Usuario escribe "A", "T", "O"
   → Van apareciendo en las celdas
   → Al completar última letra → valida automáticamente

5. Si correcta:
   → Sonido de éxito
   → Mensaje verde
   → Auto-selecciona siguiente palabra

6. Si incorrecta:
   → Sonido de error
   → Mensaje rojo
   → Permite reintentar

7. Usuario puede usar:
   → Backspace para borrar
   → Flechas para moverse
   → Click para cambiar de celda
```

---

## ⚠️ **CONSIDERACIONES:**

1. **Compatibilidad Móvil:**
   - En móvil, el teclado del sistema aparecerá
   - KeyboardListener funciona con teclado físico y virtual
   
2. **Validación:**
   - Solo validar cuando se complete la palabra
   - O cuando usuario presione Enter
   
3. **Feedback Visual:**
   - Celda activa: Borde grueso + fondo claro
   - Palabra activa: Fondo muy claro
   - Letras correctas: Negro
   - Letras incorrectas: (opcional) Rojo temporal

---

## 📝 **ARCHIVOS A MODIFICAR:**

1. `lib/widgets/themed_crossword_screen.dart` - Implementación completa
2. `lib/themed_providers.dart` - Agregar `setAnswerDirect`

---

## ✅ **VENTAJAS:**

- ✅ Más interactivo
- ✅ Más visual
- ✅ Más intuitivo
- ✅ Como crucigrama real
- ✅ Mejor UX
- ✅ Funciona en móvil y desktop

---

**¿Procedo con la implementación completa?**
