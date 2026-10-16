import 'dart:async';
import 'dart:io';

class LatencyPinger {
  /// Measures ping in milliseconds to the given [endpoint] string (e.g., "us1.vpnbook.com:443").
  static Future<int> pingEndpoint(String endpoint) async {
    try {
      final parts = endpoint.split(':');
      if (parts.isEmpty) return 999;
      final host = parts[0].trim();
      final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 443 : 443;

      // 1. Try TCP connect on the specified port
      try {
        final stopwatch = Stopwatch()..start();
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 1),
        );
        stopwatch.stop();
        await socket.close();
        socket.destroy();
        return stopwatch.elapsedMilliseconds;
      } catch (_) {
        // 2. If TCP fails (common for UDP-only WireGuard servers), try real ICMP ping
        if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS) {
          try {
            final result = await Process.run('ping', ['-c', '1', '-W', '1', host]);
            if (result.exitCode == 0) {
              final output = result.stdout.toString();
              final match = RegExp(r'time=([\d.]+)\s*ms').firstMatch(output);
              if (match != null) {
                return double.parse(match.group(1)!).toInt();
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    return 999; // Return high ping if unreachable instead of fake simulation
  }
}
