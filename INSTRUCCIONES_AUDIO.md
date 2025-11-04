# 🎵 INSTRUCCIONES: Configurar Audio en el Juego

## ✅ YA ESTÁ CONFIGURADO

- ✅ Carpetas creadas (`assets/audio/music/` y `assets/audio/sfx/`)
- ✅ Servicio de audio creado (`lib/audio_service.dart`)
- ✅ Dependencias instaladas (`audioplayers: ^6.1.0`)
- ✅ Assets registrados en `pubspec.yaml`

---

## 📍 PASO 1: Coloca tu Música de Pixabay

### Tu archivo MP3 de Pixabay:

1. **Renombra** tu archivo a: `background_music.mp3`

2. **Mueve** el archivo a:
   ```
   c:\generate_crossword\assets\audio\music\background_music.mp3
   ```

3. **Borra** el archivo `COLOCA_TU_MUSICA_AQUI.txt`

---

## 🔊 PASO 2: Descarga Efectos de Sonido (5 archivos)

Necesitas descargar estos 5 efectos de sonido en formato MP3:

### 1. button_click.mp3
- **Busca en Pixabay:** "ui click" o "button sound"
- **Características:** Clic suave, < 0.5 segundos
- **Ejemplo:** https://pixabay.com/sound-effects/search/button%20click/

### 2. word_correct.mp3
- **Busca:** "success ding" o "correct sound"
- **Características:** Sonido positivo, < 1 segundo
- **Ejemplo:** https://pixabay.com/sound-effects/search/success/

### 3. word_wrong.mp3
- **Busca:** "error buzz" o "wrong sound"
- **Características:** Sonido negativo suave, < 1 segundo
- **Ejemplo:** https://pixabay.com/sound-effects/search/error/

### 4. puzzle_complete.mp3
- **Busca:** "victory" o "win fanfare"
- **Características:** Celebración, 2-3 segundos
- **Ejemplo:** https://pixabay.com/sound-effects/search/victory/

### 5. letter_type.mp3
- **Busca:** "keyboard click" o "key press"
- **Características:** Tecla suave, < 0.3 segundos
- **Ejemplo:** https://pixabay.com/sound-effects/search/keyboard/

### Coloca todos los archivos en:
```
c:\generate_crossword\assets\audio\sfx\
```

---

## 🎮 PASO 3: Cómo Usar el Audio en el Juego

### Inicializar el servicio (en main.dart):

```dart
import 'audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar audio
  await AudioService().initialize();
  await AudioService().playBackgroundMusic();
  
  runApp(
    ProviderScope(
      child: MaterialApp(
        // ...
      ),
    ),
  );
}
```

### Reproducir efectos de sonido:

```dart
import 'package:generate_crossword/audio_service.dart';

// En cualquier widget:

// Clic en botón
AudioService().playSoundEffect(SoundEffect.buttonClick);

// Palabra correcta
AudioService().playSoundEffect(SoundEffect.wordCorrect);

// Palabra incorrecta
AudioService().playSoundEffect(SoundEffect.wordWrong);

// Puzzle completado
AudioService().playSoundEffect(SoundEffect.puzzleComplete);

// Tecla presionada
AudioService().playSoundEffect(SoundEffect.letterType);
```

### Controlar música:

```dart
// Pausar música
AudioService().pauseBackgroundMusic();

// Reanudar música
AudioService().resumeBackgroundMusic();

// Detener música
AudioService().stopBackgroundMusic();

// Activar/desactivar música
AudioService().toggleMusic(true); // o false

// Cambiar volumen (0.0 a 1.0)
AudioService().setMusicVolume(0.5);
```

### Controlar efectos de sonido:

```dart
// Activar/desactivar efectos
AudioService().toggleSound(true); // o false

// Cambiar volumen de efectos (0.0 a 1.0)
AudioService().setSfxVolume(0.8);
```

---

## 🎨 PASO 4: Integrar con Configuración de Usuario

Más adelante puedes conectar esto con Supabase para guardar preferencias:

```dart
// Cargar configuración del usuario
final settings = await supabase
  .from('user_settings')
  .select()
  .eq('user_id', userId)
  .single();

AudioService().toggleMusic(settings['music_enabled']);
AudioService().toggleSound(settings['sound_enabled']);
AudioService().setMusicVolume(settings['volume']);
```

---

## 📂 Estructura Final de Archivos

```
assets/
└── audio/
    ├── music/
    │   └── background_music.mp3       ← Tu música de Pixabay
    └── sfx/
        ├── button_click.mp3           ← Descargar
        ├── word_correct.mp3           ← Descargar
        ├── word_wrong.mp3             ← Descargar
        ├── puzzle_complete.mp3        ← Descargar
        └── letter_type.mp3            ← Descargar
```

---

## ✅ Checklist

- [ ] Música de fondo renombrada y colocada en `assets/audio/music/`
- [ ] 5 efectos de sonido descargados y colocados en `assets/audio/sfx/`
- [ ] Ejecutar `flutter pub get`
- [ ] Inicializar AudioService en `main.dart`
- [ ] Probar reproducción de música
- [ ] Probar efectos de sonido

---

## 🐛 Solución de Problemas

### "Error: Unable to load asset"
- Verifica que los nombres de archivo sean exactos (minúsculas, guiones bajos)
- Ejecuta `flutter clean` y luego `flutter pub get`
- Reinicia la app

### "No se escucha nada"
- Verifica el volumen del dispositivo
- Verifica que `musicEnabled` y `soundEnabled` sean `true`
- Revisa los logs con `debugPrint`

### "Música se corta o no hace loop"
- Verifica que el archivo MP3 no esté corrupto
- Asegúrate de que `ReleaseMode.loop` esté configurado

---

## 📚 Recursos Adicionales

- **Documentación audioplayers:** https://pub.dev/packages/audioplayers
- **Pixabay Sound Effects:** https://pixabay.com/sound-effects/
- **Freesound:** https://freesound.org/
- **Convertir audio online:** https://cloudconvert.com/

---

## 🎓 Para el Proyecto Escolar

Este sistema de audio demuestra:
- ✅ Integración de assets multimedia
- ✅ Singleton pattern para servicios
- ✅ Gestión de estado de audio
- ✅ Experiencia de usuario mejorada
- ✅ Configuración persistente (con Supabase)
