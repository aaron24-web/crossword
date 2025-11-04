# 🎯 Flutter Crossword Generator & Puzzle Game

Proyecto completo del **Flutter Crossword Codelab** - Generador y juego de crucigramas con algoritmo de backtracking, paralelización con isolates y UI interactiva.

---

## 📋 Resumen del Proyecto

Este proyecto implementa:
1. **Generador de crucigramas** usando backtracking con validación de restricciones
2. **Paralelización** con múltiples workers (isolates) para mejor rendimiento
3. **Juego interactivo** donde el usuario resuelve crucigramas con palabras alternativas
4. **Visualización en tiempo real** del proceso de generación
5. **Gestión de estado** con Riverpod y estructuras inmutables con built_value

---

## 🏗️ Arquitectura del Proyecto

### **Estructura de Archivos**

```
lib/
├── main.dart                          # Entry point - lanza CrosswordPuzzleApp
├── model.dart                         # Modelos de datos inmutables
│   ├── Location                       # Posición en la cuadrícula
│   ├── Crossword                      # Crucigrama con palabras y caracteres
│   ├── CrosswordWord                  # Palabra individual con ubicación
│   ├── CrosswordCharacter             # Carácter con referencias a palabras
│   ├── WorkQueue                      # Cola de trabajo para backtracking
│   ├── DisplayInfo                    # Estadísticas formateadas
│   └── CrosswordPuzzleGame            # Modelo del juego con alternativas
├── providers.dart                     # Proveedores de Riverpod
│   ├── wordListProvider               # Carga lista de palabras
│   ├── sizeProvider                   # Tamaño del crucigrama
│   ├── workQueueProvider              # Stream de generación
│   └── puzzleProvider                 # Estado del juego
├── isolates.dart                      # Lógica de generación en isolates
│   ├── exploreCrosswordSolutions()    # Función principal de generación
│   ├── _generate()                    # Coordina múltiples workers
│   └── _generateCandidate()           # Worker individual
├── utils.dart                         # Utilidades (formateo de duración)
└── widgets/
    ├── crossword_puzzle_app.dart      # App principal del juego
    ├── crossword_generator_widget.dart # Visualización de generación
    ├── crossword_puzzle_widget.dart   # Widget del juego interactivo
    └── puzzle_completed_widget.dart   # Pantalla de victoria
```

---

## 🔧 Tecnologías y Dependencias

### **Dependencias Principales**

```yaml
dependencies:
  flutter:
    sdk: flutter
  built_collection: ^5.1.1        # Colecciones inmutables
  built_value: ^8.9.2             # Clases inmutables con serialización
  characters: ^1.3.1              # Manejo de caracteres Unicode
  flutter_riverpod: ^2.6.1        # Gestión de estado reactiva
  riverpod_annotation: ^2.6.1     # Anotaciones para code generation
  two_dimensional_scrollables: ^0.3.0  # TableView para cuadrícula
  intl: ^0.19.0                   # Formateo de números

dev_dependencies:
  build_runner: ^2.4.13           # Code generation
  built_value_generator: ^8.9.2   # Generador de built_value
  riverpod_generator: ^2.6.2      # Generador de Riverpod
```

### **Comandos de Build**

```bash
# Generar código de built_value y Riverpod
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en web
flutter run -d chrome

# Ejecutar en Android
flutter run -d <device_id>
```

---

## 🎮 Funcionalidades Implementadas

### **1. Generador de Crucigramas (Secciones 1-7)**

#### **Modelo de Datos Inmutable**
- `Location`: Posición (x, y) con métodos de offset
- `Crossword`: Cuadrícula con palabras y caracteres
- `CrosswordWord`: Palabra con ubicación y dirección
- `CrosswordCharacter`: Carácter con referencias a palabras across/down
- `WorkQueue`: Estado del backtracking con ubicaciones pendientes

#### **Algoritmo de Backtracking**
```dart
// Lógica principal en isolates.dart
- Selecciona ubicación aleatoria de locationsToTry
- Busca palabra candidata que encaje
- Valida que no entre en conflicto
- Agrega palabra y actualiza WorkQueue
- Repite hasta completar o agotar opciones
```

#### **Validación de Restricciones**
- Las palabras deben superponerse en al menos un carácter
- Los caracteres superpuestos deben coincidir
- No puede haber dos palabras en la misma posición/dirección
- Validación de palabras válidas en la cuadrícula

#### **UI de Generación**
- `TableView` para renderizar cuadrícula eficientemente
- Visualización de caracteres con puntos (•)
- Animaciones de celdas en exploración
- Colores dinámicos según estado

---

### **2. Paralelización con Isolates (Sección 8)**

#### **Arquitectura Multi-Worker**
```dart
// Constante de workers
const backgroundWorkerCount = 4;

// Función principal coordina N workers
Future<WorkQueue> _generate((WorkQueue, int) workMessage) async {
  // 1. Selecciona N ubicaciones aleatorias
  // 2. Lanza N isolates en paralelo con compute()
  // 3. Espera resultados con Future.wait
  // 4. Combina resultados en un solo WorkQueue
}

// Cada worker busca una palabra
(Location, Direction, String?) _generateCandidate(...) {
  // Busca palabra que encaje en la ubicación
  // Timeout de 10 segundos para evitar bloqueos
}
```

#### **Beneficios**
- ✅ Generación 4-8x más rápida
- ✅ UI fluida durante generación
- ✅ Aprovecha múltiples núcleos CPU
- ✅ Exploración paralela de múltiples ramas

#### **Visualización de Exploración**
```dart
// En crossword_generator_widget.dart
- Celdas oscuras = ubicaciones en exploración
- Celdas claras = palabras colocadas
- Animaciones suaves con AnimatedContainer
```

---

### **3. Juego de Crucigramas (Sección 9)**

#### **Modelo del Juego**
```dart
class CrosswordPuzzleGame {
  Crossword crossword;                    // Crucigrama solución
  BuiltMap alternateWords;                // Palabras alternativas por posición
  BuiltList<CrosswordWord> selectedWords; // Palabras seleccionadas por jugador
  
  bool canSelectWord(...);  // Valida si palabra es seleccionable
  selectWord(...);          // Selecciona/deselecciona palabra
  bool get solved;          // Verifica si puzzle está completo
}
```

#### **Generación de Alternativas**
```dart
// Para cada palabra en el crucigrama:
- Filtra palabras del mismo largo
- Selecciona 4 palabras aleatorias
- Las ordena alfabéticamente
- Las asocia a la ubicación/dirección
```

#### **UI Interactiva**
```dart
// CrosswordPuzzleWidget
- MenuAnchor en cada celda
- Menú contextual con palabras across/down
- Radio buttons para indicar selección
- Validación en tiempo real
- Toggle para seleccionar/deseleccionar
```

#### **Flujo del Juego**
1. **Generación**: Muestra puntos mientras genera (CrosswordGeneratorWidget)
2. **Juego**: Cuadrícula vacía con menús contextuales (CrosswordPuzzleWidget)
3. **Victoria**: Mensaje "Puzzle Completed!" (PuzzleCompletedWidget)

---

## 🎨 Gestión de Estado con Riverpod

### **Proveedores Principales**

```dart
// Carga de datos
@riverpod
Future<BuiltSet<String>> wordList(Ref ref)
  // Carga assets/words.txt
  // Filtra palabras válidas (a-z, >2 caracteres)

// Configuración
@Riverpod(keepAlive: true)
class Size extends _$Size
  // Mantiene tamaño seleccionado (small, medium, large, etc.)

// Generación
@riverpod
Stream<WorkQueue> workQueue(Ref ref)
  // Stream de WorkQueue durante generación
  // Llama a exploreCrosswordSolutions()

// Juego
@riverpod
class Puzzle extends _$Puzzle
  // Crea puzzle desde crucigrama generado
  // Maneja selección de palabras en isolates
  // Usa funciones "trampoline" para serialización
```

### **Optimizaciones de UI**

```dart
// Select específico para evitar rebuilds innecesarios
ref.watch(puzzleProvider.select((puzzle) => puzzle.solved))

// Consumer local para límites de reconstrucción
Consumer(builder: (context, ref, _) { ... })

// keepAlive para persistir estado
@Riverpod(keepAlive: true)
```

---

## 📊 Características Técnicas

### **Estructuras de Datos Inmutables**

```dart
// built_value genera código para:
- Constructores con validación
- Métodos rebuild() para modificaciones
- Serialización/deserialización
- Equality y hashCode
- toString() útil para debugging

// Ejemplo de uso:
final newCrossword = crossword.rebuild((b) => b
  ..words.add(newWord)
);
```

### **Isolates y Compute**

```dart
// compute() ejecuta función en isolate separado
final result = await compute(
  _generateCandidate,  // Función de nivel superior
  (crossword, words, location, direction)  // Argumentos serializables
);

// Funciones "trampoline" para evitar capturas de closures
Future<CrosswordPuzzleGame> _puzzleFromCrosswordTrampoline(
  (Crossword, BuiltSet<String>) args
) async => CrosswordPuzzleGame.from(...);
```

### **TableView para Cuadrículas**

```dart
TableView.builder(
  diagonalDragBehavior: DiagonalDragBehavior.free,
  cellBuilder: _buildCell,           // Construye cada celda
  columnCount: size.width,
  columnBuilder: (index) => _buildSpan(...),
  rowCount: size.height,
  rowBuilder: (index) => _buildSpan(...),
)
```

---

## 🚀 Cómo Ejecutar

### **1. Instalar Dependencias**
```bash
flutter pub get
```

### **2. Generar Código**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### **3. Ejecutar App**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d <device_id>

# Windows
flutter run -d windows
```

---

## 🎯 Próximas Mejoras (Pendientes)

### **UI/UX**
- [ ] Mejorar pantalla de victoria con animaciones y confeti
- [ ] Agregar tutorial para nuevos jugadores
- [ ] Mostrar estadísticas del juego (tiempo, intentos, etc.)
- [ ] Tema oscuro/claro
- [ ] Animaciones de transición entre pantallas

### **Funcionalidades**
- [ ] Sistema de pistas (hints)
- [ ] Niveles de dificultad (ajustar cantidad de alternativas)
- [ ] Guardar progreso del jugador
- [ ] Compartir crucigramas con amigos
- [ ] Modo multijugador
- [ ] Generación de crucigramas temáticos

### **Optimizaciones**
- [ ] Caché de crucigramas generados
- [ ] Ajuste dinámico de workers según dispositivo
- [ ] Mejor algoritmo de selección de palabras alternativas
- [ ] Reducir tiempo de generación para tamaños grandes

---

## 📚 Conceptos Aprendidos

### **Flutter & Dart**
- ✅ Gestión de estado con Riverpod
- ✅ Code generation con build_runner
- ✅ Estructuras inmutables con built_value
- ✅ Pattern matching moderno de Dart
- ✅ Records y destructuring
- ✅ Isolates y procesamiento paralelo

### **Algoritmos**
- ✅ Backtracking con validación de restricciones
- ✅ Búsqueda con poda (pruning)
- ✅ Paralelización de algoritmos de búsqueda
- ✅ Generación procedural de contenido

### **UI/UX**
- ✅ TableView para renderizado eficiente
- ✅ MenuAnchor para menús contextuales
- ✅ AnimatedContainer y AnimatedDefaultTextStyle
- ✅ Consumer y select() para optimización
- ✅ GestureDetector para interacciones

---

## 📝 Notas de Desarrollo

### **Problemas Comunes y Soluciones**

1. **Error: Missing generated code**
   ```bash
   # Solución: Ejecutar build_runner
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Generación lenta**
   ```dart
   // Solución: Usar tamaño más pequeño o aumentar workers
   const backgroundWorkerCount = 8;  // Ajustar según CPU
   ```

3. **UI no actualiza**
   ```dart
   // Solución: Usar ref.invalidateSelf() después de cambios
   ref.invalidateSelf();
   ```

### **Decisiones de Diseño**

- **¿Por qué built_value?** → Inmutabilidad garantizada, menos bugs
- **¿Por qué Riverpod?** → Mejor que Provider, type-safe, code generation
- **¿Por qué isolates?** → UI fluida durante operaciones pesadas
- **¿Por qué TableView?** → Renderizado eficiente de cuadrículas grandes
- **¿Por qué requireOverlap opcional?** → Permite juego sin restricción de orden

---

## 👨‍💻 Autor

Proyecto desarrollado siguiendo el **Flutter Crossword Codelab** oficial.

**Fecha de Desarrollo:** Octubre 2025

**Estado:** ✅ Completado (funcional, pendiente de mejoras estéticas)

---

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.
