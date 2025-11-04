import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'crossword_puzzle_app.dart';
import 'level_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B46C1), // Morado oscuro
              Color(0xFF7C3AED), // Morado medio
              Color(0xFF8B5CF6), // Morado claro
              Color(0xFF3B82F6), // Azul
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espaciador
                Spacer(flex: 2),

                // Logo/Título del juego
                _buildTitle(),

                SizedBox(height: 20),

                // Subtítulo
                _buildSubtitle(),

                Spacer(flex: 3),

                // Botón Jugar (Modo Libre)
                _buildPlayButton(context),

                SizedBox(height: 15),

                // Botón Niveles Temáticos (NUEVO)
                _buildLevelsButton(context),

                SizedBox(height: 20),

                // Botón Configuración (placeholder)
                _buildSettingsButton(context),

                Spacer(flex: 2),

                // Versión
                _buildVersion(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Icono decorativo
        Icon(
          Icons.grid_4x4,
          size: 80,
          color: Colors.white.withOpacity(0.9),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
            .shake(duration: 1000.ms, hz: 0.5, curve: Curves.easeInOut),

        SizedBox(height: 20),

        // Título principal
        Text(
          'CROSSWORD',
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),

        // Subtítulo "PUZZLE"
        Text(
          'PUZZLE',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.yellow.shade300,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Desafía tu mente',
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.8),
        letterSpacing: 2,
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPlayButton(BuildContext context) {
    return Container(
      width: 280,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.yellow.shade400,
            Colors.orange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CrosswordPuzzleApp(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(35),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'JUGAR',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.3),
        );
  }

  Widget _buildLevelsButton(BuildContext context) {
    return Container(
      width: 280,
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LevelSelectionScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.layers,
                  size: 28,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'NIVELES TEMÁTICOS',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 700.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Abrir pantalla de configuración
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Configuración próximamente'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 28,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'CONFIGURACIÓN',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildVersion() {
    return Text(
      'v1.0.0',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.5),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms);
  }
}
