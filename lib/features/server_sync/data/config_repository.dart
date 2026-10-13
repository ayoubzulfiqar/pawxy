import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/latency_pinger.dart';
import '../domain/server_model.dart';

class ConfigRepository {
  final ApiClient _apiClient;

  ConfigRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Returns persistent directory for vpn_configs
  Future<Directory> _getConfigsDirectory() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final configDir = Directory(p.join(docsDir.path, 'vpn_configs'));
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      return configDir;
    } catch (_) {
      final tempDir = Directory.systemTemp;
      final configDir = Directory(p.join(tempDir.path, 'vpn_configs'));
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      return configDir;
    }
  }

  /// Synchronizes and returns server list by scanning local configs and GitHub remote repo.
  /// Automatically re-downloads GitHub .conf files weekly (7-day interval), when version increases, or on forceSync.
  Future<List<ServerModel>> loadAndSyncServers({bool forceSync = false}) async {
    Map<String, ServerModel> serversMap = {};

    // Step 1: Scan local configs directory for existing .conf files
    try {
      final localScanned = await _scanLocalConfigsDirectory();
      for (final server in localScanned) {
        serversMap[server.fileName] = server;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final int lastSyncMillis = prefs.getInt(AppConstants.prefLastSyncTimestamp) ?? 0;
    final DateTime lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
    final bool isWeeklySyncDue = DateTime.now().difference(lastSyncTime).inDays >= 7;

    // Step 2: Fetch remote manifest & download .conf files from GitHub
    try {
      final remoteManifestStr =
          await _apiClient.fetchRawText(AppConstants.manifestUrl);
      final remoteJson = jsonDecode(remoteManifestStr) as Map<String, dynamic>;
      final int remoteVersion = remoteJson['version'] as int? ?? 0;
      final int localVersion =
          prefs.getInt(AppConstants.prefManifestVersion) ?? -1;

      final List<dynamic> serverListJson =
          remoteJson['servers'] as List<dynamic>? ?? [];
      final Directory configDir = await _getConfigsDirectory();

      final bool shouldSyncFromGithub = forceSync ||
          remoteVersion > localVersion ||
          serversMap.isEmpty ||
          isWeeklySyncDue;

      if (shouldSyncFromGithub) {
        for (final item in serverListJson) {
          final serverMap = item as Map<String, dynamic>;
          final String fileName =
              serverMap['file_name'] as String? ?? 'us1.conf';
          final String confUrl = '${AppConstants.githubRawBaseUrl}/$fileName';

          String confContent = '';
          try {
            confContent = await _apiClient.fetchRawText(confUrl);
            final File localConfFile = File(p.join(configDir.path, fileName));
            await localConfFile.writeAsString(confContent);
          } catch (_) {
            final File localConfFile = File(p.join(configDir.path, fileName));
            if (await localConfFile.exists()) {
              confContent = await localConfFile.readAsString();
            } else {
              confContent = await _getFallbackConfContent();
            }
          }

          final server = ServerModel.fromWgConfigContent(
            fileName: fileName,
            confContent: confContent,
            manifestOverride: serverMap,
          );
          serversMap[fileName] = server;
        }

        await prefs.setInt(AppConstants.prefManifestVersion, remoteVersion);
        await prefs.setInt(
            AppConstants.prefLastSyncTimestamp, DateTime.now().millisecondsSinceEpoch);
        await prefs.setString(
            AppConstants.prefCachedManifestJson, jsonEncode(remoteJson));
      }
    } catch (_) {
      // Offline / Network error -> continue with local files
    }

    // Rescan local configs directory to ensure all files are loaded
    try {
      final localScanned = await _scanLocalConfigsDirectory();
      for (final server in localScanned) {
        if (!serversMap.containsKey(server.fileName) ||
            serversMap[server.fileName]?.confContent == null) {
          serversMap[server.fileName] = server;
        }
      }
    } catch (_) {}

    final List<ServerModel> finalServers = serversMap.values.toList();

    if (finalServers.isNotEmpty) {
      return await _updateServerPings(finalServers);
    }

    // Fallback to bundled asset manifest & conf if empty
    return await _loadFromAssetBundle();
  }

  /// Automatically scans local vpn_configs directory for all .conf files
  Future<List<ServerModel>> _scanLocalConfigsDirectory() async {
    final Directory configDir = await _getConfigsDirectory();
    final List<FileSystemEntity> entities = await configDir.list().toList();

    final List<ServerModel> scanned = [];

    for (final entity in entities) {
      if (entity is File && entity.path.toLowerCase().endsWith('.conf')) {
        try {
          final String fileName = p.basename(entity.path);
          final String content = await entity.readAsString();
          if (content.isNotEmpty) {
            scanned.add(ServerModel.fromWgConfigContent(
              fileName: fileName,
              confContent: content,
            ));
          }
        } catch (_) {}
      }
    }

    return scanned;
  }

  /// Loads fallback server configuration from flutter asset bundle
  Future<List<ServerModel>> _loadFromAssetBundle() async {
    try {
      final String manifestStr =
          await rootBundle.loadString(AppConstants.fallbackManifestAsset);
      final String fallbackConf = await _getFallbackConfContent();
      final Map<String, dynamic> json = jsonDecode(manifestStr);
      final List<dynamic> serversList = json['servers'] as List<dynamic>? ?? [];

      final List<ServerModel> result = [];
      for (final item in serversList) {
        final map = item as Map<String, dynamic>;
        final String fileName = map['file_name'] as String? ?? 'us1.conf';
        result.add(ServerModel.fromWgConfigContent(
          fileName: fileName,
          confContent: fallbackConf,
          manifestOverride: map,
        ));
      }
      return await _updateServerPings(result);
    } catch (_) {
      final fallbackConf = await _getFallbackConfContent();
      return [
        ServerModel.fromWgConfigContent(
          fileName: 'us1.conf',
          confContent: fallbackConf,
        ),
      ];
    }
  }

  Future<String> _getFallbackConfContent() async {
    try {
      return await rootBundle.loadString(AppConstants.fallbackConfAsset);
    } catch (_) {
      return '''[Interface]
PrivateKey = IF+YRhEIX8jaFRsRFPBj+7/tx2hE7ovRtBc7jFPjbXc=
Address = 10.104.7.160/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = YLaLJahXZ6NuASXQLPl0eUPVAypirpaLuuO7tZa2bmo=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 147.135.15.16:443
PersistentKeepalive = 25''';
    }
  }

  /// Calculates real-time ping latency for each server concurrently
  Future<List<ServerModel>> _updateServerPings(List<ServerModel> servers) async {
    final List<Future<ServerModel>> pingFutures = servers.map((server) async {
      final int ping = await LatencyPinger.pingEndpoint(server.endpoint);
      return server.copyWith(pingMs: ping);
    }).toList();

    return await Future.wait(pingFutures);
  }
}
