import 'dart:async';
import 'package:wireguard_flutter_plus/wireguard_flutter_platform_interface.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import 'package:pawxy/core/constants/app_constants.dart';
import 'package:pawxy/features/server_sync/domain/server_model.dart';

class WireGuardRepository {
  final WireGuardFlutterInterface _wireguard;
  bool _isInitialized = false;

  WireGuardRepository({WireGuardFlutterInterface? wireguard})
      : _wireguard = wireguard ?? WireGuardFlutter.instance;

  Stream<VpnStage> get vpnStageSnapshot => _wireguard.vpnStageSnapshot;

  Stream<Map<String, dynamic>> get trafficSnapshot => _wireguard.trafficSnapshot;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _wireguard.initialize(
        interfaceName: AppConstants.wgInterfaceName,
        vpnName: AppConstants.appName,
        iosAppGroup: AppConstants.iosAppGroup,
        extensionBundleId: AppConstants.macosExtensionBundleId,
      );
      _isInitialized = true;
    } catch (_) {
      // Platform specific initialization handling
    }
  }

  Future<bool> checkPermission() async {
    try {
      return await _wireguard.checkVpnPermission();
    } catch (_) {
      return true;
    }
  }

  Future<void> startVpn(ServerModel server) async {
    await initialize();

    String wgConfig = server.confContent ?? '';
    
    // Inject MTU = 1280 for stable cellular/SIM network compatibility if missing
    if (!wgConfig.toLowerCase().contains('mtu')) {
      wgConfig = wgConfig.replaceFirst(
        RegExp(r'\[Interface\]', caseSensitive: false), 
        '[Interface]\nMTU = 1280'
      );
    }

    // Enforce reliable public DNS to prevent ERR_NAME_NOT_RESOLVED issues on connected browsers
    if (wgConfig.toLowerCase().contains('dns')) {
      wgConfig = wgConfig.replaceAll(RegExp(r'DNS\s*=.*', caseSensitive: false), 'DNS = 1.1.1.1, 8.8.8.8');
    } else {
      wgConfig = wgConfig.replaceFirst(
        RegExp(r'\[Interface\]', caseSensitive: false), 
        '[Interface]\nDNS = 1.1.1.1, 8.8.8.8'
      );
    }

    // Remove IPv6 from AllowedIPs to prevent cellular/SIM network routing blackholes
    wgConfig = wgConfig.replaceAll(RegExp(r',\s*::/0', caseSensitive: false), '');

    String serverAddress = server.endpoint;
    if (!serverAddress.contains(':')) {
      serverAddress += ':51820'; // Enforce default WireGuard port if missing
    }

    await _wireguard.startVpn(
      serverAddress: serverAddress,
      wgQuickConfig: wgConfig,
      providerBundleIdentifier: AppConstants.iosProviderBundleIdentifier,
    );
  }

  Future<void> stopVpn() async {
    try {
      await _wireguard.stopVpn();
    } catch (_) {}
  }

  Future<VpnStage> getStage() async {
    try {
      return await _wireguard.stage();
    } catch (_) {
      return VpnStage.disconnected;
    }
  }
}
