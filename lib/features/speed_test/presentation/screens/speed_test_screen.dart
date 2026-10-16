import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawxy/core/constants/app_constants.dart';
import 'package:pawxy/core/theme/app_colors.dart';
import 'package:pawxy/core/utils/formatters.dart';
import 'package:pawxy/features/server_sync/presentation/cubit/server_cubit.dart';
import 'package:pawxy/features/server_sync/presentation/cubit/server_state.dart';
import 'package:pawxy/features/speed_test/data/speed_test_service.dart';
import 'package:pawxy/features/speed_test/presentation/cubit/speed_test_cubit.dart';
import 'package:pawxy/features/speed_test/presentation/cubit/speed_test_state.dart';
import 'package:pawxy/features/speed_test/presentation/widgets/speed_gauge_widget.dart';
import 'package:pawxy/features/vpn/presentation/cubit/vpn_cubit.dart';
import 'package:pawxy/features/vpn/presentation/cubit/vpn_state.dart';

class SpeedTestScreen extends StatelessWidget {
  final VoidCallback onNavigateToServers;

  const SpeedTestScreen({super.key, required this.onNavigateToServers});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                AppConstants.mascotLogoAsset,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Speed Test'),
          ],
        ),
      ),
      body: BlocBuilder<ServerCubit, ServerState>(
        builder: (context, serverState) {
          return BlocBuilder<VpnCubit, VpnState>(
            builder: (context, vpnState) {
              final activeServer = (vpnState.stage.name == 'connected' || vpnState.stage.name == 'connecting')
                  ? vpnState.connectedServer
                  : (serverState is ServerLoaded ? serverState.selectedServer : null);

              return BlocBuilder<SpeedTestCubit, SpeedTestState>(
                builder: (context, speedState) {
                  double currentGaugeSpeed = 0.0;
                  double progress = 0.0;
                  String phaseLabel = 'READY';
                  int pingMs = activeServer?.pingMs ?? 45;
                  double downloadMbps = 0.0;
                  double uploadMbps = 0.0;
                  bool isTesting = false;

                  if (speedState is SpeedTestInProgress) {
                    isTesting = true;
                    currentGaugeSpeed = speedState.currentSpeedMbps;
                    progress = speedState.progress;
                    pingMs = speedState.pingMs > 0 ? speedState.pingMs : pingMs;
                    downloadMbps = speedState.downloadMbps;
                    uploadMbps = speedState.uploadMbps;

                    if (speedState.phase == SpeedTestPhase.pinging) {
                      phaseLabel = 'PINGING';
                    } else if (speedState.phase == SpeedTestPhase.downloading) {
                      phaseLabel = 'TESTING DOWNLOAD';
                    } else if (speedState.phase == SpeedTestPhase.uploading) {
                      phaseLabel = 'TESTING UPLOAD';
                    }
                  } else if (speedState is SpeedTestCompleted) {
                    phaseLabel = 'COMPLETED';
                    pingMs = speedState.pingMs;
                    downloadMbps = speedState.downloadMbps;
                    uploadMbps = speedState.uploadMbps;
                    currentGaugeSpeed = downloadMbps;
                    progress = 1.0;
                  }

                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          if (activeServer != null)
                            GestureDetector(
                              onTap: isTesting ? null : onNavigateToServers,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface(isDark),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.cardBorder(isDark),
                                      width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      activeServer.flagEmoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${activeServer.country} (${activeServer.city})',
                                            style: TextStyle(
                                              color: AppColors.textPrimary(isDark),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            'Tap to change server',
                                            style: TextStyle(
                                              color: AppColors.textSecondary(isDark),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.emeraldGreen
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.bolt_rounded,
                                            color: AppColors.emeraldGreen,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$pingMs ms',
                                            style: const TextStyle(
                                              color: AppColors.emeraldGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const Spacer(),

                          SpeedGaugeWidget(
                            speedMbps: currentGaugeSpeed,
                            progress: progress,
                            phaseLabel: phaseLabel,
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface(isDark),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder(isDark)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn(
                                  context: context,
                                  title: 'Download',
                                  value: Formatters.formatMbps(downloadMbps),
                                  icon: Icons.arrow_downward_rounded,
                                  iconColor: AppColors.emeraldGreen,
                                  isDark: isDark,
                                ),
                                Container(
                                  height: 32,
                                  width: 1,
                                  color: AppColors.cardBorder(isDark),
                                ),
                                _buildStatColumn(
                                  context: context,
                                  title: 'Upload',
                                  value: Formatters.formatMbps(uploadMbps),
                                  icon: Icons.arrow_upward_rounded,
                                  iconColor: AppColors.pawxyOrange,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTesting
                                    ? AppColors.cardSurfaceElevated(isDark)
                                    : AppColors.pawxyOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isTesting
                                  ? null
                                  : () {
                                      final endpoint =
                                          activeServer?.endpoint ??
                                              'us1.vpnbook.com:443';
                                      context
                                          .read<SpeedTestCubit>()
                                          .startTest(endpoint);
                                    },
                              child: Text(
                                isTesting ? 'Testing...' : 'Start Speed Test',
                                style: TextStyle(
                                  color: isTesting
                                      ? AppColors.textMuted(isDark)
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatColumn({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
