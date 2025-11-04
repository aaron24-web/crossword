import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio_service.dart';
import 'confetti_widget.dart';

class PuzzleCompletedWidget extends StatefulWidget {
  const PuzzleCompletedWidget({super.key});

  @override
  State<PuzzleCompletedWidget> createState() => _PuzzleCompletedWidgetState();
}

class _PuzzleCompletedWidgetState extends State<PuzzleCompletedWidget> {
  @override
  void initState() {
    super.initState();
    // Reproducir sonido de victoria al mostrar la pantalla
    AudioService().playSoundEffect(SoundEffect.puzzleComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti de fondo
        Positioned.fill(
          child: ConfettiWidget(
            isPlaying: true,
            duration: Duration(seconds: 4),
          ),
        ),

        // Contenido principal
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de trofeo
              Icon(
                Icons.emoji_events,
                size: 120,
                color: Colors.amber,
              )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shake(hz: 2, duration: 500.ms),

              SizedBox(height: 30),

              // Texto "¡Felicidades!"
              Text(
                '¡Felicidades!',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C3AED),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: -0.3, end: 0),

              SizedBox(height: 10),

              // Texto "Puzzle Completado"
              Text(
                'Puzzle Completado',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: 50),

              // Botón "Jugar de Nuevo"
              Container(
                width: 250,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Reiniciar el juego
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Center(
                      child: Text(
                        'JUGAR DE NUEVO',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
