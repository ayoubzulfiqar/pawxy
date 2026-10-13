import 'package:flutter_test/flutter_test.dart';
import 'package:pawxy/main.dart';

void main() {
  testWidgets('Pawxy VPN app initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const VpnGuardApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Pawxy'), findsOneWidget);
  });
}
