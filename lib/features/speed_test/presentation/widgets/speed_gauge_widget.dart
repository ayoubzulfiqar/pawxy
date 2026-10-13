import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SpeedGaugeWidget extends StatelessWidget {
  final double speedMbps;
  final double progress; // 0.0 to 1.0
  final String phaseLabel;

  const SpeedGaugeWidget({
    super.key,
    required this.speedMbps,
    required this.progress,
    required this.phaseLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(240, 240),
            painter: _GaugePainter(progress: progress, isDark: isDark),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                phaseLabel.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textMuted(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                speedMbps > 0 ? speedMbps.toStringAsFixed(1) : '0.0',
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'Mbps',
                style: TextStyle(
                  color: AppColors.electricBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _GaugePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

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

    if (progress > 0) {
      final activeSweepAngle = sweepAngle * progress.clamp(0.0, 1.0);

      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.electricBlue, AppColors.emeraldGreen],
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
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
