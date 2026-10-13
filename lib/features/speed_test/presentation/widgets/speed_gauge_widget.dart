import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SpeedGaugeWidget extends StatelessWidget {
  final double speedMbps;
  final double progress; // 0.0 to 1.0 overall test progress
  final String phaseLabel;
  final double maxSpeedMbps;

  const SpeedGaugeWidget({
    super.key,
    required this.speedMbps,
    required this.progress,
    required this.phaseLabel,
    this.maxSpeedMbps = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate speed fraction relative to scale (0.0 to 1.0)
    final double speedFraction = (speedMbps / maxSpeedMbps).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(250, 250),
              painter: _GaugePainter(
                speedFraction: speedFraction,
                testProgress: progress,
                isDark: isDark,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pawxyOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    phaseLabel.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.pawxyOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  speedMbps > 0 ? speedMbps.toStringAsFixed(1) : '0.0',
                  style: TextStyle(
                    color: AppColors.textPrimary(isDark),
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'Mbps',
                  style: TextStyle(
                    color: AppColors.pawxyOrange,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double speedFraction;
  final double testProgress;
  final bool isDark;

  _GaugePainter({
    required this.speedFraction,
    required this.testProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 28) / 2;
    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // 1. Background Arc Track
    final backgroundPaint = Paint()
      ..color = AppColors.cardSurfaceElevated(isDark)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // 2. Speed Gauge Arc (Reflects current measured speed)
    if (speedFraction > 0) {
      final activeSweepAngle = sweepAngle * speedFraction.clamp(0.02, 1.0);

      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.pawxyOrange, AppColors.emeraldGreen],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweepAngle,
        false,
        activePaint,
      );
    }

    // 3. Outer Test Progress Track
    final outerRadius = radius + 11;
    final progressTrackPaint = Paint()
      ..color = AppColors.cardBorder(isDark)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
      false,
      progressTrackPaint,
    );

    if (testProgress > 0) {
      final progressSweep = sweepAngle * testProgress.clamp(0.0, 1.0);
      final progressPaint = Paint()
        ..color = AppColors.pawxyOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        progressSweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.speedFraction != speedFraction ||
        oldDelegate.testProgress != testProgress ||
        oldDelegate.isDark != isDark;
  }
}
