import 'dart:math';
import 'package:flutter/material.dart';

/// Widget de confetti animado con Flutter puro
class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;

  const ConfettiWidget({
    super.key,
    this.isPlaying = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Crear partículas de confetti
    _createParticles();

    if (widget.isPlaying) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Opcional: repetir o detener
        // _controller.repeat();
      }
    });
  }

  void _createParticles() {
    // Crear 50 partículas de confetti
    for (int i = 0; i < 50; i++) {
      _particles.add(
        ConfettiParticle(
          color: _getRandomColor(),
          startX: _random.nextDouble(),
          startY: -0.1,
          endY: 1.2,
          rotation: _random.nextDouble() * 4 * pi,
          size: _random.nextDouble() * 10 + 5,
          swingAmount: _random.nextDouble() * 0.3 - 0.15,
          delay: _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Datos de una partícula de confetti
class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double endY;
  final double rotation;
  final double size;
  final double swingAmount;
  final double delay;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.endY,
    required this.rotation,
    required this.size,
    required this.swingAmount,
    required this.delay,
  });
}

/// Painter personalizado para dibujar el confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calcular progreso con delay
      final particleProgress = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);

      if (particleProgress <= 0) continue;

      // Calcular posición Y (caída)
      final y = particle.startY +
          (particle.endY - particle.startY) * particleProgress;

      // Calcular posición X (balanceo)
      final swing = sin(particleProgress * pi * 3) * particle.swingAmount;
      final x = particle.startX + swing;

      // Calcular rotación
      final rotation = particle.rotation * particleProgress;

      // Calcular opacidad (fade out al final)
      final opacity = particleProgress < 0.8
          ? 1.0
          : (1.0 - (particleProgress - 0.8) / 0.2);

      // Dibujar partícula
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Dibujar rectángulo (confetti)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
