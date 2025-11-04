import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../level_data.dart';
import 'themed_crossword_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B46C1),
              Color(0xFF7C3AED),
              Color(0xFF8B5CF6),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Niveles
              Expanded(
                child: _buildLevelGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'SELECCIONA UN NIVEL',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0),
          SizedBox(height: 10),
          Text(
            'Elige un tema para empezar',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,  // Más altura para evitar overflow
      ),
      itemCount: GameLevels.levels.length,
      itemBuilder: (context, index) {
        final level = GameLevels.levels[index];
        return _buildLevelCard(context, level, index);
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelTheme level, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              level.primaryColor,
              level.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: level.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemedCrosswordScreen(theme: level),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Número de nivel
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${level.levelNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Icono
                  Icon(
                    level.icon,
                    size: 50,
                    color: Colors.white,
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Nombre
                  Text(
                    level.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6),
                  
                  // Descripción
                  Text(
                    level.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
        .slideY(begin: 0.3, end: 0);
  }
}
