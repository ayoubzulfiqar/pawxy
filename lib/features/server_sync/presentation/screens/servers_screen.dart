import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vpn/presentation/cubit/vpn_cubit.dart';
import '../../../vpn/presentation/cubit/vpn_state.dart';
import '../cubit/server_cubit.dart';
import '../cubit/server_state.dart';
import '../widgets/server_card.dart';

class ServersScreen extends StatefulWidget {
  final VoidCallback onSelectAndNavigateHome;

  const ServersScreen({
    super.key,
    required this.onSelectAndNavigateHome,
  });

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            const Text('VPN Servers'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Servers',
            onPressed: () {
              context.read<ServerCubit>().loadServers();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              TextField(
                controller: _searchController,
                style: TextStyle(color: AppColors.textPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'Search country or city...',
                  hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: AppColors.textMuted(isDark)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: AppColors.textMuted(isDark)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ServerCubit>().searchServers('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardSurface(isDark),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.cardBorder(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.cardBorder(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.pawxyOrange),
                  ),
                ),
                onChanged: (query) {
                  context.read<ServerCubit>().searchServers(query);
                },
              ),

              const SizedBox(height: 14),

              BlocBuilder<ServerCubit, ServerState>(
                builder: (context, state) {
                  final String currentCategory =
                      (state is ServerLoaded) ? state.selectedCategory : 'All';

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', currentCategory, isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Americas', currentCategory, isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Europe', currentCategory, isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Asia-Pacific', currentCategory, isDark),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Expanded(
                child: BlocBuilder<ServerCubit, ServerState>(
                  builder: (context, serverState) {
                    if (serverState is ServerLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.pawxyOrange,
                        ),
                      );
                    }

                    if (serverState is ServerError) {
                      return Center(
                        child: Text(
                          serverState.message,
                          style: const TextStyle(color: AppColors.crimsonRed),
                        ),
                      );
                    }

                    if (serverState is ServerLoaded) {
                      final servers = serverState.filteredServers;

                      if (servers.isEmpty) {
                        return Center(
                          child: Text(
                            'No servers found',
                            style: TextStyle(color: AppColors.textMuted(isDark)),
                          ),
                        );
                      }

                      return BlocBuilder<VpnCubit, VpnState>(
                        builder: (context, vpnState) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: servers.length,
                            itemBuilder: (context, index) {
                              final server = servers[index];
                              final isSelected =
                                  server.id == serverState.selectedServer.id;
                              final isConnected = vpnState.stage.name == 'connected';

                              return ServerCard(
                                server: server,
                                isSelected: isSelected,
                                isConnected: isConnected,
                                onSelect: () {
                                  context
                                      .read<ServerCubit>()
                                      .selectServer(server);
                                  widget.onSelectAndNavigateHome();
                                },
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String currentCategory, bool isDark) {
    final bool isSelected = label == currentCategory;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.pawxyOrange,
      backgroundColor: AppColors.cardSurface(isDark),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : AppColors.textSecondary(isDark),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.pawxyOrange : AppColors.cardBorder(isDark),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          context.read<ServerCubit>().filterByCategory(label);
        }
      },
    );
  }
}
