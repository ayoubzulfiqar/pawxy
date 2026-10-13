import 'package:flutter_test/flutter_test.dart';
import 'package:pawxy/features/speed_test/data/speed_test_service.dart';

void main() {
  group('SpeedTestService Tests', () {
    test('runSpeedTest emits progress updates through all phases', () async {
      final service = SpeedTestService();
      final updates = await service.runSpeedTest('127.0.0.1:443').toList();

      expect(updates.isNotEmpty, isTrue);
      expect(updates.first.phase, equals(SpeedTestPhase.pinging));
      expect(updates.last.phase, equals(SpeedTestPhase.completed));
      expect(updates.last.progress, equals(1.0));
      expect(updates.last.downloadMbps, greaterThanOrEqualTo(0.0));
      expect(updates.last.uploadMbps, greaterThanOrEqualTo(0.0));
    });
  });
}
