# VPN Guard - Enterprise WireGuard VPN Client in Flutter

A production-grade, modular Flutter application targeting **Android, iOS, Windows, macOS, and Linux** built with Clean Architecture, `flutter_bloc`, and `wireguard_flutter_plus`.

---

## Features
- **WireGuard Protocol Integration**: Secure tunnel establishment via `wireguard_flutter_plus`.
- **Git Config Repo Sync & Persistent Cache**: Dynamic fetching and delta updates from GitHub raw configuration repository (`manifest.json` and `.conf` files) with offline fallback.
- **Neo-Modern Dark UI/UX**: Custom dark fintech/security theme featuring concentric glowing power button animations, signal strength indicators, and real-time telemetry split cards.
- **Speed Test Suite**: Interactive speed test gauge measuring real-time latency, download, and upload rates with smooth visual telemetry.
- **Multi-Platform Support**: Comprehensive support for mobile and desktop targets.

---

## Architecture Overview (`lib/`)

```text
lib/
├── core/
│   ├── constants/         # App constants, fallback config URLs, keys
│   ├── network/           # Raw HTTP client for manifest sync
│   ├── theme/             # Dark theme palette, colors, typography
│   └── utils/             # Formatters & Latency Socket Pinger
├── features/
│   ├── server_sync/       # Remote config downloader, local disk storage, model, cubit, server UI
│   ├── vpn/               # WireGuard engine bridge, status streams, cubit, power button, telemetry UI
│   ├── speed_test/        # Speed test engine, gauge painter, speed test screen UI
│   └── navigation/        # Main bottom navigation container
└── main.dart
```

---

## Remote Git Repository Layout Requirements

Host your server configurations in a public or private repository matching this structure:

```text
/conf/
  ├── manifest.json
  ├── us_newyork.conf
  ├── uk_london.conf
  ├── de_frankfurt.conf
  ├── jp_tokyo.conf
  └── au_sydney.conf
```

### `manifest.json` Format:
```json
{
  "version": 104,
  "updated_at": "2026-10-12T00:00:00Z",
  "servers": [
    {
      "id": "us-01",
      "country": "United States",
      "city": "New York",
      "flag_code": "US",
      "file_name": "us_newyork.conf",
      "is_pro": false,
      "endpoint": "us1.vpnbook.com:443"
    }
  ]
}
```

---

## Platform-Specific Setup Notes

### 1. iOS Setup (`ios/`)
1. Create a `PacketTunnelProvider` Network Extension target in Xcode.
2. Configure App Groups (`group.com.yourcompany.vpnguard`) on both Runner and PacketTunnel targets.
3. Add `NetworkExtension` framework entitlement to `Runner.entitlements`.

### 2. Windows Setup (`windows/`)
1. `windows/runner/runner.exe.manifest` is configured with `requestedExecutionLevel level="requireAdministrator"`.
2. Bundle `wireguard.dll` or `wireguard-nt.dll` drivers alongside `Runner.exe`.

### 3. Android Setup (`android/`)
1. `AndroidManifest.xml` includes `INTERNET`, `ACCESS_NETWORK_STATE`, and `CHANGE_NETWORK_STATE` permissions.

---

## Build & Run Instructions

```bash
# Resolve dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```
