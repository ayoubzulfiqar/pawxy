import 'package:equatable/equatable.dart';

class ServerModel extends Equatable {
  final String id;
  final String country;
  final String city;
  final String flagCode;
  final String fileName;
  final bool isPro;
  final String endpoint;
  final String? confContent;
  final int pingMs;

  const ServerModel({
    required this.id,
    required this.country,
    required this.city,
    required this.flagCode,
    required this.fileName,
    this.isPro = false,
    required this.endpoint,
    this.confContent,
    this.pingMs = 45,
  });

  ServerModel copyWith({
    String? id,
    String? country,
    String? city,
    String? flagCode,
    String? fileName,
    bool? isPro,
    String? endpoint,
    String? confContent,
    int? pingMs,
  }) {
    return ServerModel(
      id: id ?? this.id,
      country: country ?? this.country,
      city: city ?? this.city,
      flagCode: flagCode ?? this.flagCode,
      fileName: fileName ?? this.fileName,
      isPro: isPro ?? this.isPro,
      endpoint: endpoint ?? this.endpoint,
      confContent: confContent ?? this.confContent,
      pingMs: pingMs ?? this.pingMs,
    );
  }

  factory ServerModel.fromJson(Map<String, dynamic> json, {String? confContent}) {
    return ServerModel(
      id: json['id'] as String? ?? 'us-01',
      country: json['country'] as String? ?? 'United States',
      city: json['city'] as String? ?? 'New York',
      flagCode: json['flag_code'] as String? ?? 'US',
      fileName: json['file_name'] as String? ?? 'us_newyork.conf',
      isPro: json['is_pro'] as bool? ?? false,
      endpoint: json['endpoint'] as String? ?? 'us1.vpnbook.com:443',
      confContent: confContent,
      pingMs: json['ping_ms'] as int? ?? 45,
    );
  }

  /// Automatically parses a WireGuard .conf file content and builds a ServerModel
  factory ServerModel.fromWgConfigContent({
    required String fileName,
    required String confContent,
    Map<String, dynamic>? manifestOverride,
  }) {
    String parsedEndpoint = '127.0.0.1:443';

    // Parse Endpoint from .conf file
    final lines = confContent.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.toLowerCase().startsWith('endpoint')) {
        final parts = trimmed.split('=');
        if (parts.length > 1) {
          parsedEndpoint = parts[1].trim();
        }
      }
    }

    final String cleanName = fileName.replaceAll('.conf', '').toLowerCase();

    String country = 'VPN Location';
    String flagCode = 'UN';
    String city = cleanName.toUpperCase();

    if (cleanName.startsWith('uk') || cleanName.startsWith('gb')) {
      country = 'United Kingdom';
      flagCode = 'GB';
      city = 'London ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('us')) {
      country = 'United States';
      flagCode = 'US';
      city = 'US Server ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('can') || cleanName.startsWith('ca')) {
      country = 'Canada';
      flagCode = 'CA';
      city = 'CA Server ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('ger') || cleanName.startsWith('de')) {
      country = 'Germany';
      flagCode = 'DE';
      city = 'Frankfurt ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('fran') || cleanName.startsWith('fr')) {
      country = 'France';
      flagCode = 'FR';
      city = 'Paris ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('neh') || cleanName.startsWith('nl') || cleanName.startsWith('neth')) {
      country = 'Netherlands';
      flagCode = 'NL';
      city = 'Amsterdam ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('po') || cleanName.startsWith('pl') || cleanName.startsWith('pol')) {
      country = 'Poland';
      flagCode = 'PL';
      city = 'Warsaw ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('jp')) {
      country = 'Japan';
      flagCode = 'JP';
      city = 'Tokyo ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    } else if (cleanName.startsWith('au')) {
      country = 'Australia';
      flagCode = 'AU';
      city = 'Sydney ${cleanName.replaceAll(RegExp(r'[^0-9]'), '')}'.trim();
    }

    if (city.isEmpty || city.trim().isEmpty) {
      city = cleanName.toUpperCase();
    }

    if (manifestOverride != null) {
      return ServerModel(
        id: manifestOverride['id'] as String? ?? cleanName,
        country: manifestOverride['country'] as String? ?? country,
        city: manifestOverride['city'] as String? ?? city,
        flagCode: manifestOverride['flag_code'] as String? ?? flagCode,
        fileName: fileName,
        isPro: false,
        endpoint: manifestOverride['endpoint'] as String? ?? parsedEndpoint,
        confContent: confContent,
      );
    }

    return ServerModel(
      id: cleanName,
      country: country,
      city: city,
      flagCode: flagCode,
      fileName: fileName,
      isPro: false,
      endpoint: parsedEndpoint,
      confContent: confContent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'flag_code': flagCode,
      'file_name': fileName,
      'is_pro': isPro,
      'endpoint': endpoint,
      'confContent': confContent,
      'ping_ms': pingMs,
    };
  }

  /// Extracts assigned address (IP) from the WireGuard conf file content if available.
  String get assignedIp {
    if (confContent != null && confContent!.isNotEmpty) {
      final lines = confContent!.split('\n');
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('Address')) {
          final parts = trimmed.split('=');
          if (parts.length > 1) {
            return parts[1].trim().split(',').first.split('/').first.trim();
          }
        }
      }
    }
    return '192.168.1.100';
  }

  /// Country flag emoji generator from ISO 3166-1 alpha-2 code e.g. "US" -> "🇺🇸"
  String get flagEmoji {
    if (flagCode.length != 2) return '🌐';
    final int firstLetter = flagCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = flagCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  List<Object?> get props => [
        id,
        country,
        city,
        flagCode,
        fileName,
        isPro,
        endpoint,
        confContent,
        pingMs,
      ];
}
