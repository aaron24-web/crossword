import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio_service.dart';
import 'confetti_widget.dart';
import 'home_screen.dart';

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
                  color: Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).colorScheme.secondary,
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
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
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
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
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
