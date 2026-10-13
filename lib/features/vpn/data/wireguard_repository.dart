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

    final String wgConfig = server.confContent ?? '';
    final String serverAddress = server.endpoint;

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
