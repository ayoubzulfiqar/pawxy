<div align="center">

  <img src="assets/pawxy.png" alt="Pawxy Logo" width="128" height="128" />

  # Pawxy VPN

  **Next-Generation WireGuard® VPN Client for Seamless Privacy & High-Speed Security**

  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-brightgreen.svg)](#features)
  [![WireGuard](https://img.shields.io/badge/Protocol-WireGuard%C2%AE-orange.svg)](https://www.wireguard.com)

  **Project Showcase**: [https://ayoubzulfiqar.com/projects/pawxy](https://ayoubzulfiqar.com/projects/pawxy)  
  **Created by**: [Ayoub Zulfiqar](https://ayoubzulfiqar.com)

</div>

---

## 🐾 About Pawxy VPN

**Pawxy VPN** is a modern, cross-platform VPN client designed to keep your Internet connection secure, private, and blazingly fast. Powered by state-of-the-art **WireGuard® protocol cryptography**, Pawxy delivers instant encryption with minimal battery drain and maximum throughput across mobile and desktop devices.

Whether you're connected to public Wi-Fi, streaming, or browsing on the go, Pawxy VPN ensures your identity and online traffic remain completely protected.

---

## ✨ Key Features & User Experience

* **⚡ One-Tap Connect**: Experience effortless protection with a single tap. Our reactive concentric power button provides real-time visual status updates.
* **🛡️ WireGuard® Protocol Security**: Utilizes modern state-of-the-art Noise protocol framework and ChaCha20-Poly1305 encryption for top-tier confidentiality.
* **🌍 Automatic Server Network Sync**: Automatically synchronizes global VPN server locations and updates configurations silently in the background with local offline caching.
* **📊 Real-Time Network Telemetry**: Monitor live upload/download speed indicators, assigned IP address, and active session timers directly on your home screen.
* **🚀 Built-In Speed Tester**: Test latency (ping), download rate, and upload rate in seconds using our built-in animated speed gauge.
* **🎨 Adaptive Dark & Light Themes**: Easily switch between sleek Dark Mode and clean Light Mode tailored for comfort during day or night.
* **💻 True Cross-Platform Freedom**: Enjoy identical privacy and speed on **Android, iOS, Windows, macOS, and Linux**.

---

## 📖 User Guide & How to Use Pawxy

### 1. Connecting to the VPN
* Open **Pawxy VPN**.
* Tap the prominent central **Power Button**. Pawxy will automatically establish a secure tunnel to your selected location.
* Once connected, your connection header will display **"You Are Connected"** with live real-time traffic statistics.

### 2. Choosing & Changing Servers
* Tap the **Servers** tab on the bottom navigation bar or click **Change** on the active server pill.
* Browse free and premium global server locations (e.g. United States, United Kingdom, Germany, Japan, Australia).
* Filter locations by **Free** or **Pro** tags, or search by country/city name.
* Tap any available server to instantly set it as your active connection.

### 3. Running Speed Tests
* Navigate to the **Speed Test** tab.
* Tap **Start Speed Test**. Pawxy will measure your server's ping latency, download bandwidth, and upload bandwidth in real-time.

### 4. Customizing Appearance
* Tap the **Sun/Moon Icon** in the top right corner of the main screen to seamlessly toggle between **Light Mode** and **Dark Mode**.

---

## 🗂️ WireGuard Server Configuration Repo Layout

Pawxy VPN dynamically synchronizes server locations hosted in a repository. To host your own WireGuard network configs for Pawxy, set up your repository folder structure as follows:

```text
/conf/
  ├── manifest.json
  ├── us_newyork.conf
  ├── uk_london.conf
  ├── de_frankfurt.conf
  ├── jp_tokyo.conf
  └── au_sydney.conf
```

### `manifest.json` Structure Example
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
