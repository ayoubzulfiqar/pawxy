class AppConstants {
  static const String appName = 'Pawxy VPN';
  
  // GitHub Raw Config URLs
  static const String githubRawBaseUrl =
      'https://raw.githubusercontent.com/ayoubzulfiqar/pawxy/main/conf';
  static const String manifestUrl = '$githubRawBaseUrl/manifest.json';

  // Fallback Asset Paths
  static const String mascotLogoAsset = 'assets/pawxy.png';
  static const String fallbackManifestAsset = 'assets/fallback_manifest.json';
  static const String fallbackConfAsset = 'assets/fallback_us.conf';

  // Storage Keys
  static const String prefManifestVersion = 'pref_manifest_version';
  static const String prefCachedManifestJson = 'pref_cached_manifest_json';
  static const String prefSelectedServerId = 'pref_selected_server_id';
  static const String prefLastSyncTimestamp = 'pref_last_sync_timestamp';

  // WireGuard Interface Config
  static const String wgInterfaceName = 'wg0';
  static const String iosAppGroup = 'group.com.ayoubzulfiqar.pawxy';
  static const String macosExtensionBundleId =
      'com.ayoubzulfiqar.pawxy.network-extension';
  static const String iosProviderBundleIdentifier =
      'com.ayoubzulfiqar.pawxy.network-extension';
}
