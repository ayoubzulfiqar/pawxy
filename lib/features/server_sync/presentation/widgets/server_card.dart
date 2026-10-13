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
    if (server.pingMs < 50) {
      latencyColor = AppColors.emeraldGreen;
      barsCount = 3;
    } else if (server.pingMs < 100) {
      latencyColor = AppColors.amberGold;
      barsCount = 2;
    } else {
      latencyColor = AppColors.crimsonRed;
      barsCount = 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.cardSurfaceElevated(isDark)
            : AppColors.cardSurface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.electricBlue : AppColors.cardBorder(isDark),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary(isDark),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder(isDark)),
            ),
            child: Center(
              child: Text(
                server.flagEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      server.country,
                      style: TextStyle(
                        color: AppColors.textPrimary(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (server.isPro) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: AppColors.amberGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${server.city} • 25 locations',
                      style: TextStyle(
                        color: AppColors.textSecondary(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            children: [
              _buildSignalBars(barsCount, latencyColor, isDark),
              const SizedBox(width: 6),
              Text(
                '${server.pingMs}ms',
                style: TextStyle(
                  color: latencyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          _buildActionButton(context),
        ],
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
    if (isSelected && isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.emeraldGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.emeraldGreen),
        ),
        child: const Text(
          'Connected',
          style: TextStyle(
            color: AppColors.emeraldGreen,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (server.isPro) {
      return SizedBox(
        height: 34,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.amberGold,
            side: const BorderSide(color: AppColors.amberGold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pro server. Upgrade to unlock all servers!'),
                backgroundColor: AppColors.amberGold,
              ),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 14),
              SizedBox(width: 4),
              Text('Unlock', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
        ),
        onPressed: onSelect,
        child: Text(
          isSelected ? 'Selected' : 'Connect',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
