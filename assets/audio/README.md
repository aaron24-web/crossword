# 🎵 Audio Assets

## Estructura de Archivos

```
assets/audio/
├── music/
│   └── background_music.mp3    # Música de fondo principal
└── sfx/
    ├── button_click.mp3        # Clic en botón
    ├── word_correct.mp3        # Palabra correcta
    ├── word_wrong.mp3          # Palabra incorrecta
    ├── puzzle_complete.mp3     # Puzzle completado
    └── letter_type.mp3         # Tecla presionada
```

## Instrucciones

### 1. Música de Fondo
**Archivo:** `background_music.mp3`
**Ubicación:** `assets/audio/music/background_music.mp3`
**Características:**
- Formato: MP3
- Duración: 2-5 minutos (loop)
- Volumen: Normalizado a -18dB
- Estilo: Relajante, casual, puzzle game

**Fuentes recomendadas:**
- Pixabay Music (https://pixabay.com/music/)
- Incompetech (https://incompetech.com/music/)

### 2. Efectos de Sonido
**Ubicación:** `assets/audio/sfx/`

#### button_click.mp3
- Duración: < 0.5s
- Sonido: Clic suave, UI feedback

#### word_correct.mp3
- Duración: < 1s
- Sonido: Ding positivo, éxito

#### word_wrong.mp3
- Duración: < 1s
- Sonido: Buzz suave, error

#### puzzle_complete.mp3
- Duración: 2-3s
- Sonido: Fanfarria, celebración

#### letter_type.mp3
- Duración: < 0.3s
- Sonido: Tecla mecánica suave

**Fuentes recomendadas:**
- Freesound (https://freesound.org/)
- Zapsplat (https://www.zapsplat.com/)
- Mixkit (https://mixkit.co/free-sound-effects/)

## Conversión de Formatos

Si tienes archivos en otros formatos (WAV, OGG), puedes convertirlos a MP3:

### Online:
- https://cloudconvert.com/
- https://online-audio-converter.com/

### Offline (FFmpeg):
```bash
ffmpeg -i input.wav -codec:a libmp3lame -qscale:a 2 output.mp3
```

## Optimización

Para reducir el tamaño de los archivos:

```bash
# Reducir bitrate a 128kbps (buena calidad para juegos)
ffmpeg -i input.mp3 -b:a 128k output.mp3

# Normalizar volumen
ffmpeg -i input.mp3 -af "loudnorm" output.mp3
```

## Licencias

Asegúrate de que todos los archivos de audio sean:
- ✅ Royalty-free
- ✅ Libres para uso comercial (si aplica)
- ✅ Con atribución correcta (si es requerida)

## Atribución

Si usas música con atribución requerida, agrégala aquí:

```
background_music.mp3:
- Título: [Nombre de la canción]
- Autor: [Nombre del artista]
- Fuente: [URL]
- Licencia: [Tipo de licencia]
```
