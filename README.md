<div align="center">

  <img src="assets/pawxy.png" alt="Pawxy Logo" width="128" height="128" />

  # Pawxy VPN

  **Next-Generation WireGuard® VPN Client for High-Speed Security & 100% Free Privacy**

  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
  [![Version](https://img.shields.io/badge/Version-v1.6.9-orange.svg)](https://github.com/ayoubzulfiqar/pawxy/releases/tag/v1.6.9)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-brightgreen.svg)](#features)
  [![WireGuard](https://img.shields.io/badge/Protocol-WireGuard%C2%AE-orange.svg)](https://www.wireguard.com)

  **Project Showcase**: [https://ayoubzulfiqar.com/projects/pawxy](https://ayoubzulfiqar.com/projects/pawxy)  
  **Created by**: [Ayoub Zulfiqar](https://ayoubzulfiqar.com)

</div>

---

## 🐾 About Pawxy VPN

**Pawxy VPN** is a modern, high-performance cross-platform WireGuard® VPN client designed to keep your online connection secure, private, and blazingly fast. Powered by state-of-the-art **WireGuard® protocol cryptography** and an intuitive Pawxy Mascot Fox design system, Pawxy delivers instant encryption with minimal battery drain and maximum throughput.

Pawxy is **100% Free** for all users — with no server locks, no subscription paywalls, and unlimited access to all global locations.

---

## ✨ Key Features & User Experience

* **🎁 100% Free & Unlocked**: Enjoy complete, unrestricted access to all global VPN locations with no pro locks, paywalls, or hidden charges.
* **⚡ One-Tap Connect**: Experience effortless protection with a single tap. Our reactive concentric power button provides real-time visual status updates.
* **🛡️ WireGuard® Protocol Security**: Utilizes modern state-of-the-art Noise protocol framework and ChaCha20-Poly1305 encryption for top-tier confidentiality.
* **🔄 Automatic Weekly GitHub Config Sync**: Automatically checks and re-synchronizes global VPN server configurations weekly (7-day interval) or upon manual refresh directly from GitHub.
* **🚀 Real HTTP Speed Tester**: Measures live HTTP bandwidth throughput (download and upload in Mbps) and real HTTP/TCP latency ping with a dynamic gauge painter.
* **⚡ RepaintBoundary Performance Pipeline**: Engineered with Flutter `RepaintBoundary` paint isolation on high-frequency UI elements for ultra-smooth 60fps rendering without UI lag.
* **📊 Real-Time Network Telemetry**: Monitor live upload/download speed indicators, assigned IP address, and active session timers directly on your home screen.
* **🎨 Default Light & Dark Themes**: Features a crisp default Light Mode and sleek Dark Mode inspired by the Pawxy Mascot Fox brand palette (`#FF8C00` Fox Orange, Gold, Coral, Mint Green).
* **💻 Universal & Per-ABI APK Builds**: Distributed as a universal release APK (`app-release.apk`) or lightweight per-architecture APKs (`arm64-v8a`, `armeabi-v7a`, `x86_64`).

---

## 📖 User Guide & How to Use Pawxy

### 1. Connecting to the VPN
* Open **Pawxy VPN**.
* Tap the prominent central **Power Button**. Pawxy will automatically establish a secure tunnel to your selected location.
* Once connected, your status will display **"You Are Connected"** with live real-time traffic telemetry.

### 2. Choosing & Changing Servers
* Tap the **Servers** tab on the bottom navigation bar or click **Change** on the active server bar.
* Browse server locations organized by regional filter categories (**All**, **Americas**, **Europe**, **Asia-Pacific**) or search by country/city name.
* Tap any server to set it as your active connection.

### 3. Running Speed Tests
* Navigate to the **Speed Test** tab.
* Tap **Start Speed Test**. Pawxy will execute live HTTP download/upload bandwidth checks and display instantaneous throughput in Mbps.

### 4. Customizing Appearance
* Tap the **Sun/Moon Icon** in the top right corner of the main screen to toggle between **Light Mode** (default) and **Dark Mode**.

---

## 🛠️ Building & Releasing

### Prerequisites
* Flutter SDK (`^3.13.5` or higher)
* Android SDK & Java 17

### Build Commands
```bash
# Run tests
flutter test

# Build Universal Android Release APK (61MB - all ABIs)
env -u ANDROID_PREFS_ROOT flutter build apk --release

# Build Split Per-ABI Android Release APKs (~20-22MB each)
env -u ANDROID_PREFS_ROOT flutter build apk --release --split-per-abi
```

---

## 🗂️ WireGuard Server Configuration Repo Layout

Pawxy VPN dynamically synchronizes server locations hosted on GitHub. To host your own WireGuard network configs for Pawxy, set up your repository folder structure as follows:

```text
/conf/
  ├── manifest.json
  ├── us_newyork.conf
  ├── uk_london.conf
  ├── de_frankfurt.conf
  ├── jp_tokyo.conf
  └── au_sydney.conf
```

### `manifest.json` Example
```json
{
  "version": 105,
  "updated_at": "2026-10-13T00:00:00Z",
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

## 🔒 Privacy & Security First

Pawxy VPN is built with privacy at its core:
* **Zero Logging Policy**: Pawxy never logs or tracks your browsing history, traffic data, or DNS queries.
* **Modern Cryptography**: WireGuard® utilizes ChaCha20 for symmetric encryption and Curve25519 for key exchange.

To report security concerns, please consult our [SECURITY.md](SECURITY.md).

---

## 📄 License & Community Guidelines

* **License**: Open-source under the [MIT License](LICENSE).
* **Code of Conduct**: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
* **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)
* **Security Policy**: [SECURITY.md](SECURITY.md)

---

<div align="center">

  **Designed & Developed by [Ayoub Zulfiqar](https://ayoubzulfiqar.com)**  
  Visit the official project page: [https://ayoubzulfiqar.com/projects/pawxy](https://ayoubzulfiqar.com/projects/pawxy)

</div>
