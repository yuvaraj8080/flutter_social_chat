import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

/// A customized wave animation background
///
/// Creates a smooth flowing wave animation at the bottom of the screen
/// using CustomPaint for better performance without external packages.
class CustomWaveAnimation extends StatefulWidget {
  const CustomWaveAnimation({super.key});

  @override
  State<CustomWaveAnimation> createState() => _CustomWaveAnimationState();
}

class _CustomWaveAnimationState extends State<CustomWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 0.95,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            return CustomPaint(
              painter: WavePainter(
                animationValue: _animationController.value,
                color: customIndigoColor,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Constants for wave animation
    final double waveHeight = size.height * 0.03;
    final double frequency = 2.5; // Number of waves
    final double waterLevel = size.height * 0.95; // Fill most of the screen
    
    // Create main background
    final Paint backgroundPaint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, waterLevel),
      backgroundPaint,
    );
    
    // Create wave path
    final path = Path();
    path.moveTo(0, waterLevel);
    
    // Use fewer points for better performance
    final pixelSkip = (size.width / 100).ceil();
    
    // Create curve points for the wave
    for (double x = 0; x <= size.width; x += pixelSkip) {
      // Calculate y position with sine function
      double y = waterLevel + 
                 math.sin((x / size.width * frequency * math.pi * 2) + 
                     (animationValue * math.pi * 2)) * 
                 waveHeight;
      
      path.lineTo(x, y);
    }
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    // Create gradient for the wave
    final Paint wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevel, size.width, size.height - waterLevel));
    
    // Draw the wave
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}
