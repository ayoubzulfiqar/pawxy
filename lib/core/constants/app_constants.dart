class AppConstants {
  static const String appName = 'VPN Guard';
  
  // GitHub Raw Config URLs
  static const String githubRawBaseUrl =
      'https://raw.githubusercontent.com/pawxy-vpn/vpn-configs/main/conf';
  static const String manifestUrl = '$githubRawBaseUrl/manifest.json';

  // Fallback Asset Paths
  static const String fallbackManifestAsset = 'assets/fallback_manifest.json';
  static const String fallbackConfAsset = 'assets/fallback_us.conf';

  // Storage Keys
  static const String prefManifestVersion = 'pref_manifest_version';
  static const String prefCachedManifestJson = 'pref_cached_manifest_json';
  static const String prefSelectedServerId = 'pref_selected_server_id';

  // WireGuard Interface Config
  static const String wgInterfaceName = 'wg0';
  static const String iosAppGroup = 'group.com.yourcompany.vpnguard';
  static const String macosExtensionBundleId =
      'com.yourcompany.vpnguard.network-extension';
  static const String iosProviderBundleIdentifier =
      'com.yourcompany.vpnguard.network-extension';
}
