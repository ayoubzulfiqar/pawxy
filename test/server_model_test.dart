import 'package:flutter_test/flutter_test.dart';
import 'package:pawxy/features/server_sync/domain/server_model.dart';

void main() {
  group('ServerModel Tests', () {
    test('Server is completely free and isPro is false by default', () {
      const confContent = '''
[Interface]
Address = 10.0.0.2/32

[Peer]
Endpoint = 1.2.3.4:443
''';

      final server = ServerModel.fromWgConfigContent(
        fileName: 'us_pro_server.conf',
        confContent: confContent,
      );

      expect(server.isPro, isFalse);
      expect(server.country, equals('United States'));
      expect(server.endpoint, equals('1.2.3.4:443'));
    });

    test('flagEmoji generates correct flag for US', () {
      const server = ServerModel(
        id: 'us1',
        country: 'United States',
        city: 'New York',
        flagCode: 'US',
        fileName: 'us1.conf',
        endpoint: '1.2.3.4:443',
      );

      expect(server.flagEmoji, equals('🇺🇸'));
    });
  });
}
