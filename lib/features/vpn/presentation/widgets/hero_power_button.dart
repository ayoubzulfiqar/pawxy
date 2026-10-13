import 'package:flutter/material.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/vpn_connection_state.dart';

class HeroPowerButton extends StatefulWidget {
  final VpnStage stage;
  final VoidCallback onTap;

  const HeroPowerButton({
    super.key,
    required this.stage,
    required this.onTap,
  });

  @override
  State<HeroPowerButton> createState() => _HeroPowerButtonState();
}

class _HeroPowerButtonState extends State<HeroPowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isConnected = widget.stage.isConnected;
    final bool isConnecting = widget.stage.isConnecting;

    Color glowColor;
    Color buttonColor;
    Color iconColor;

    if (isConnected) {
      glowColor = AppColors.powerActiveGlow;
      buttonColor = AppColors.emeraldGreen;
      iconColor = Colors.white;
    } else if (isConnecting) {
      glowColor = AppColors.powerConnectingGlow;
      buttonColor = AppColors.electricBlue;
      iconColor = Colors.white;
    } else {
      glowColor = Colors.transparent;
      buttonColor = AppColors.powerInactiveInner(isDark);
      iconColor = AppColors.textMuted(isDark);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final double scale = (isConnected || isConnecting)
              ? _pulseAnimation.value
              : 1.0;

          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor,
                      boxShadow: [
                        if (isConnected || isConnecting)
                          BoxShadow(
                            color: isConnected
                                ? AppColors.emeraldGreen.withValues(alpha: 0.35)
                                : AppColors.electricBlue.withValues(alpha: 0.35),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.powerInactiveOuter(isDark),
                    border: Border.all(
                      color: isConnected
                          ? AppColors.emeraldGreen.withValues(alpha: 0.5)
                          : isConnecting
                              ? AppColors.electricBlue.withValues(alpha: 0.5)
                              : AppColors.cardBorder(isDark),
                      width: 2,
                    ),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 58,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
