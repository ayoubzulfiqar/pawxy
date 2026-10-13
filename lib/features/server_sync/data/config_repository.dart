import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
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
    final docsDir = await getApplicationDocumentsDirectory();
    final configDir = Directory('${docsDir.path}/vpn_configs');
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    return configDir;
  }

  /// Synchronizes and returns the server list using offline cache, remote sync, or fallback assets.
  Future<List<ServerModel>> loadAndSyncServers() async {
    List<ServerModel> cachedServers = [];

    // Step 1: Attempt to load from persistent local disk storage or SharedPreferences
    try {
      cachedServers = await _loadFromLocalDisk();
    } catch (_) {
      // Local load error
    }

    // Step 2: Concurrently fetch remote manifest from GitHub raw URL
    try {
      final remoteManifestStr =
          await _apiClient.fetchRawText(AppConstants.manifestUrl);
      final remoteJson = jsonDecode(remoteManifestStr) as Map<String, dynamic>;
      final int remoteVersion = remoteJson['version'] as int? ?? 0;

      final prefs = await SharedPreferences.getInstance();
      final int localVersion =
          prefs.getInt(AppConstants.prefManifestVersion) ?? -1;

      // Delta Evaluation: If remote version > local version or cached servers empty
      if (remoteVersion > localVersion || cachedServers.isEmpty) {
        final List<dynamic> serverListJson =
            remoteJson['servers'] as List<dynamic>? ?? [];
        final Directory configDir = await _getConfigsDirectory();

        final List<ServerModel> updatedServers = [];

        for (final item in serverListJson) {
          final serverMap = item as Map<String, dynamic>;
          final String fileName =
              serverMap['file_name'] as String? ?? 'us_newyork.conf';
          final String confUrl = '${AppConstants.githubRawBaseUrl}/$fileName';

          String confContent = '';
          try {
            confContent = await _apiClient.fetchRawText(confUrl);
            final File localConfFile = File('${configDir.path}/$fileName');
            await localConfFile.writeAsString(confContent);
          } catch (_) {
            // If fetching individual .conf fails, check if we have a locally saved copy
            final File localConfFile = File('${configDir.path}/$fileName');
            if (await localConfFile.exists()) {
              confContent = await localConfFile.readAsString();
            } else {
              confContent = await _getFallbackConfContent();
            }
          }

          final server = ServerModel.fromJson(serverMap, confContent: confContent);
          updatedServers.add(server);
        }

        // Save new manifest JSON and version to SharedPreferences & disk
        await prefs.setInt(AppConstants.prefManifestVersion, remoteVersion);
        await prefs.setString(
            AppConstants.prefCachedManifestJson, jsonEncode(remoteJson));

        if (updatedServers.isNotEmpty) {
          return await _updateServerPings(updatedServers);
        }
      }
    } catch (e) {
      // Remote sync unreachable or network offline -> Fallback gracefully
    }

    // If cached servers exist, return cached servers with updated pings
    if (cachedServers.isNotEmpty) {
      return await _updateServerPings(cachedServers);
    }

    // Step 3: Fallback to bundled asset manifest and .conf
    return await _loadFromAssetBundle();
  }

  /// Loads cached manifest and config files from local persistent storage
  Future<List<ServerModel>> _loadFromLocalDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedJsonStr =
        prefs.getString(AppConstants.prefCachedManifestJson);
    if (cachedJsonStr == null || cachedJsonStr.isEmpty) {
      return [];
    }

    final Map<String, dynamic> manifestJson = jsonDecode(cachedJsonStr);
    final List<dynamic> serversList = manifestJson['servers'] as List<dynamic>? ?? [];
    final Directory configDir = await _getConfigsDirectory();

    final List<ServerModel> result = [];
    for (final item in serversList) {
      final map = item as Map<String, dynamic>;
      final String fileName = map['file_name'] as String? ?? 'us_newyork.conf';
      final File confFile = File('${configDir.path}/$fileName');

      String confContent = '';
      if (await confFile.exists()) {
        confContent = await confFile.readAsString();
      } else {
        confContent = await _getFallbackConfContent();
      }

      result.add(ServerModel.fromJson(map, confContent: confContent));
    }

    return result;
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
        result.add(ServerModel.fromJson(map, confContent: fallbackConf));
      }
      return await _updateServerPings(result);
    } catch (_) {
      // Fallback emergency inline model
      final fallbackConf = await _getFallbackConfContent();
      return [
        ServerModel(
          id: 'us-01',
          country: 'United States',
          city: 'New York',
          flagCode: 'US',
          fileName: 'us_newyork.conf',
          isPro: false,
          endpoint: 'us1.vpnbook.com:443',
          confContent: fallbackConf,
          pingMs: 28,
        ),
        ServerModel(
          id: 'uk-01',
          country: 'United Kingdom',
          city: 'London',
          flagCode: 'GB',
          fileName: 'uk_london.conf',
          isPro: false,
          endpoint: 'uk1.vpnbook.com:443',
          confContent: fallbackConf,
          pingMs: 42,
        ),
        ServerModel(
          id: 'de-01',
          country: 'Germany',
          city: 'Frankfurt',
          flagCode: 'DE',
          fileName: 'de_frankfurt.conf',
          isPro: true,
          endpoint: 'de1.vpnbook.com:443',
          confContent: fallbackConf,
          pingMs: 38,
        ),
      ];
    }
  }

  Future<String> _getFallbackConfContent() async {
    try {
      return await rootBundle.loadString(AppConstants.fallbackConfAsset);
    } catch (_) {
      return '''[Interface]
PrivateKey = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=
Address = 10.0.0.2/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = us1.vpnbook.com:443
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
