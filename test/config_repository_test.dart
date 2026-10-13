import 'package:flutter_test/flutter_test.dart';
import 'package:pawxy/core/constants/app_constants.dart';
import 'package:pawxy/core/network/api_client.dart';
import 'package:pawxy/features/server_sync/data/config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigRepository Auto-Sync Tests', () {
    test('loadAndSyncServers updates last sync timestamp on remote sync', () async {
      SharedPreferences.setMockInitialValues({});

      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('manifest.json')) {
          return http.Response('{"version": 1, "servers": [{"file_name": "us1.conf", "country": "United States"}]}', 200);
        }
        return http.Response('[Interface]\nAddress = 10.0.0.1/32\n[Peer]\nEndpoint = 1.2.3.4:443', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final repository = ConfigRepository(apiClient: apiClient);

      await repository.loadAndSyncServers();

      final prefs = await SharedPreferences.getInstance();
      final lastSyncMillis = prefs.getInt(AppConstants.prefLastSyncTimestamp);

      expect(lastSyncMillis, isNotNull);
      expect(lastSyncMillis!, greaterThan(0));
    });
  });
}
