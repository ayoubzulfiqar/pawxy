import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class TelemetryCard extends StatelessWidget {
  final double downloadSpeed; // in bytes per second
  final double uploadSpeed; // in bytes per second

  const TelemetryCard({
    super.key,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder(isDark), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSpeedItem(
              context: context,
              title: 'Download',
              speedText: Formatters.formatSpeed(downloadSpeed),
              icon: Icons.arrow_downward_rounded,
              iconColor: AppColors.emeraldGreen,
              isDark: isDark,
            ),
          ),

          Container(
            height: 38,
            width: 1,
            color: AppColors.cardBorder(isDark),
          ),

          Expanded(
            child: _buildSpeedItem(
              context: context,
              title: 'Upload',
              speedText: Formatters.formatSpeed(uploadSpeed),
              icon: Icons.arrow_upward_rounded,
              iconColor: AppColors.pawxyOrange,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedItem({
    required BuildContext context,
    required String title,
    required String speedText,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                speedText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
