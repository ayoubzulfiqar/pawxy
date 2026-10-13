import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches raw text from the specified [url].
  Future<String> fetchRawText(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'User-Agent': 'VPN-Guard-Client/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw HttpException('Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching $url: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
