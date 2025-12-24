import 'package:flutter/material.dart';
import '../models/shot_data.dart';
import 'dart:math';

/// Custom widget that draws a shooting target board
/// with concentric circles and displays shot markers
class TargetBoard extends StatefulWidget {
  final List<ShotData> shots;
  final bool isAnimating;

  const TargetBoard({
    super.key,
    required this.shots,
    this.isAnimating = false,
  });

  @override
  State<TargetBoard> createState() => _TargetBoardState();
}

class _TargetBoardState extends State<TargetBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(TargetBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when new shot is added
    if (widget.shots.length > oldWidget.shots.length) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomPaint(
            painter: _TargetPainter(
              shots: widget.shots,
              isAnimating: widget.isAnimating,
              animation: _scaleAnimation,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing the target board
class _TargetPainter extends CustomPainter {
  final List<ShotData> shots;
  final bool isAnimating;
  final Animation<double> animation;

  _TargetPainter({
    required this.shots,
    required this.isAnimating,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw target circles (5 zones)
    final colors = [
      Colors.yellow, // Center (10 points)
      Colors.red, // Ring 2 (9 points)
      Colors.blue, // Ring 3 (8 points)
      Colors.black, // Ring 4 (7 points)
      Colors.white, // Outer ring (6 points)
    ];

    for (int i = colors.length - 1; i >= 0; i--) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final ringRadius = radius * (i + 1) / colors.length;
      canvas.drawCircle(center, ringRadius, paint);

      // Draw ring border
      final borderPaint = Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, ringRadius, borderPaint);
    }

    // Draw center crosshair
    final crosshairPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      crosshairPaint,
    );

    // Draw shots
    for (int i = 0; i < shots.length; i++) {
      final shot = shots[i];
      // Convert normalized coordinates (-1 to 1) to canvas coordinates
      final shotX = center.dx + (shot.x * radius * 0.9);
      final shotY = center.dy + (shot.y * radius * 0.9);

      // Determine shot marker color based on accuracy
      Color shotColor;
      if (shot.accuracy >= 80) {
        shotColor = Colors.green;
      } else if (shot.accuracy >= 60) {
        shotColor = Colors.orange;
      } else {
        shotColor = Colors.red;
      }

      // Apply animation to the most recent shot
      final isLatestShot = i == shots.length - 1;
      final scale = isLatestShot ? animation.value : 1.0;

      if (scale > 0) {
        // Draw shot marker
        final shotPaint = Paint()
          ..color = shotColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(shotX, shotY),
          6 * scale,
          shotPaint,
        );

        // Draw shot border
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(
          Offset(shotX, shotY),
          6 * scale,
          borderPaint,
        );

        // Draw shot number
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            shotX - textPainter.width / 2,
            shotY - textPainter.height / 2,
          ),
        );
      }
    }

    // Draw pulsing ring when shooting
    if (isAnimating) {
      final pulsePaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, radius * 0.95, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(_TargetPainter oldDelegate) {
    return oldDelegate.shots.length != shots.length ||
        oldDelegate.isAnimating != isAnimating;
  }
}