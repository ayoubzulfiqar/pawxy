import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/formatters.dart';
import '../../../server_sync/presentation/cubit/server_cubit.dart';
import '../../../server_sync/presentation/cubit/server_state.dart';
import '../../domain/vpn_connection_state.dart';
import '../cubit/vpn_cubit.dart';
import '../cubit/vpn_state.dart';
import '../widgets/active_server_bar.dart';
import '../widgets/hero_power_button.dart';
import '../widgets/telemetry_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToServers;

  const HomeScreen({
    super.key,
    required this.onNavigateToServers,
  });

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
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Pawxy',
              style: TextStyle(
                color: AppColors.textPrimary(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.textPrimary(isDark),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Server Location',
            onPressed: onNavigateToServers,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<VpnCubit, VpnState>(
        builder: (context, vpnState) {
          return BlocBuilder<ServerCubit, ServerState>(
            builder: (context, serverState) {
              final activeServer = (serverState is ServerLoaded)
                  ? (vpnState.connectedServer ?? serverState.selectedServer)
                  : null;

              final String formattedTime =
                  Formatters.formatDuration(vpnState.sessionDuration);

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Session Timer (HH:MM:SS)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceElevated(isDark),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder(isDark)),
                        ),
                        child: Text(
                          vpnState.stage == VpnStage.connected
                              ? formattedTime
                              : '00:00:00',
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Connection Status Header & Subtitle
                      Text(
                        vpnState.stage.displayText,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(isDark),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vpnState.stage.subtitleText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: vpnState.stage.isConnected
                                  ? AppColors.emeraldGreen
                                  : AppColors.textMuted(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                      ),

                      const Spacer(),

                      // Hero Power Connection Button
                      HeroPowerButton(
                        stage: vpnState.stage,
                        onTap: () {
                          if (activeServer != null) {
                            context.read<VpnCubit>().toggleVpn(activeServer);
                          }
                        },
                      ),

                      const Spacer(),

                      // Network Telemetry Card
                      TelemetryCard(
                        downloadSpeed: vpnState.downloadSpeed,
                        uploadSpeed: vpnState.uploadSpeed,
                      ),

                      const SizedBox(height: 16),

                      // Active Server Bar
                      if (activeServer != null)
                        ActiveServerBar(
                          server: activeServer,
                          assignedIp: vpnState.assignedIp,
                          onTap: onNavigateToServers,
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
