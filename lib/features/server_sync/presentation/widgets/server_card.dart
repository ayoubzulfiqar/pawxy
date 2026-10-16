import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/server_model.dart';

class ServerCard extends StatelessWidget {
  final ServerModel server;
  final bool isSelected;
  final bool isConnected;
  final VoidCallback onSelect;

  const ServerCard({
    super.key,
    required this.server,
    required this.isSelected,
    required this.isConnected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color latencyColor;
    int barsCount;
    if (server.pingMs < 60) {
      latencyColor = AppColors.emeraldGreen;
      barsCount = 3;
    } else if (server.pingMs < 130) {
      latencyColor = AppColors.pawxyGold;
      barsCount = 2;
    } else {
      latencyColor = AppColors.crimsonRed;
      barsCount = 1;
    }

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cardSurfaceElevated(isDark)
              : AppColors.cardSurface(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.pawxyOrange : AppColors.cardBorder(isDark),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary(isDark),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder(isDark)),
              ),
              child: Center(
                child: Text(
                  server.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    server.country,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${server.city} • WireGuard',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSignalBars(barsCount, latencyColor, isDark),
                const SizedBox(width: 4),
                Text(
                  '${server.pingMs}ms',
                  style: TextStyle(
                    color: latencyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalBars(int count, Color color, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        final double height = 6.0 + (index * 4.0);
        final bool active = index < count;
        return Container(
          width: 3,
          height: height,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: active ? color : AppColors.cardBorder(isDark),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.emeraldGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.emeraldGreen),
        ),
        child: const Text(
          'Connected',
          style: TextStyle(
            color: AppColors.emeraldGreen,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.pawxyOrange.withValues(alpha: 0.15)
              : AppColors.pawxyOrange,
          foregroundColor: isSelected ? AppColors.pawxyOrange : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? const BorderSide(color: AppColors.pawxyOrange)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
        ),
        onPressed: onSelect,
        child: Text(
          isSelected ? 'Selected' : 'Select',
          style: TextStyle(
            color: isSelected ? AppColors.pawxyOrange : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
