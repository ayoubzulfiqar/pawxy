import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/config_repository.dart';
import '../../domain/server_model.dart';
import 'server_state.dart';

class ServerCubit extends Cubit<ServerState> {
  final ConfigRepository _configRepository;

  ServerCubit({ConfigRepository? configRepository})
      : _configRepository = configRepository ?? ConfigRepository(),
        super(ServerInitial());

  Future<void> loadServers({bool forceSync = false}) async {
    emit(ServerLoading());
    try {
      final servers = await _configRepository.loadAndSyncServers(forceSync: forceSync);
      if (servers.isEmpty) {
        emit(const ServerError('No VPN servers available'));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedServerId = prefs.getString(AppConstants.prefSelectedServerId);

      ServerModel selected = servers.first;
      if (savedServerId != null) {
        final match = servers.where((s) => s.id == savedServerId).firstOrNull;
        if (match != null) {
          selected = match;
        }
      }

      final filtered = _applyFilters(servers, '', 'All');

      emit(ServerLoaded(
        allServers: servers,
        filteredServers: filtered,
        selectedServer: selected,
      ));

      // Trigger non-blocking background latency refresh
      _refreshPingsInBackground(servers);
    } catch (e) {
      emit(ServerError('Failed to load server list: $e'));
    }
  }

  void _refreshPingsInBackground(List<ServerModel> currentServers) async {
    try {
      final updatedServers = await _configRepository.updateServerPingsAsync(currentServers);
      final currentState = state;
      if (currentState is ServerLoaded) {
        final updatedSelected = updatedServers.firstWhere(
          (s) => s.id == currentState.selectedServer.id,
          orElse: () => currentState.selectedServer,
        );
        final filtered = _applyFilters(
          updatedServers,
          currentState.searchQuery,
          currentState.selectedCategory,
        );
        emit(currentState.copyWith(
          allServers: updatedServers,
          filteredServers: filtered,
          selectedServer: updatedSelected,
        ));
      }
    } catch (_) {}
  }

  void selectServer(ServerModel server) async {
    final currentState = state;
    if (currentState is ServerLoaded) {
      emit(currentState.copyWith(selectedServer: server));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefSelectedServerId, server.id);
    }
  }

  void searchServers(String query) {
    final currentState = state;
    if (currentState is ServerLoaded) {
      final filtered = _applyFilters(
        currentState.allServers,
        query,
        currentState.selectedCategory,
      );
      emit(currentState.copyWith(
        searchQuery: query,
        filteredServers: filtered,
      ));
    }
  }

  void filterByCategory(String category) {
    final currentState = state;
    if (currentState is ServerLoaded) {
      final filtered = _applyFilters(
        currentState.allServers,
        currentState.searchQuery,
        category,
      );
      emit(currentState.copyWith(
        selectedCategory: category,
        filteredServers: filtered,
      ));
    }
  }

  List<ServerModel> _applyFilters(
      List<ServerModel> servers, String query, String category) {
    return servers.where((server) {
      final matchesQuery = query.isEmpty ||
          server.country.toLowerCase().contains(query.toLowerCase()) ||
          server.city.toLowerCase().contains(query.toLowerCase());

      bool matchesCategory = true;
      if (category == 'Americas') {
        final country = server.country.toLowerCase();
        matchesCategory = country.contains('united states') || country.contains('canada');
      } else if (category == 'Europe') {
        final country = server.country.toLowerCase();
        matchesCategory = country.contains('united kingdom') ||
            country.contains('germany') ||
            country.contains('france') ||
            country.contains('netherlands') ||
            country.contains('poland');
      } else if (category == 'Asia-Pacific') {
        final country = server.country.toLowerCase();
        matchesCategory = country.contains('japan') || country.contains('australia');
      }

      return matchesQuery && matchesCategory;
    }).toList();
  }
}
