import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

extension VpnStageExtension on VpnStage {
  bool get isConnected => this == VpnStage.connected;
  bool get isConnecting =>
      this == VpnStage.connecting ||
      this == VpnStage.authenticating ||
      this == VpnStage.preparing ||
      this == VpnStage.reconnect ||
      this == VpnStage.waitingConnection;
  bool get isDisconnected =>
      this == VpnStage.disconnected ||
      this == VpnStage.denied ||
      this == VpnStage.noConnection ||
      this == VpnStage.exiting;

  String get displayText {
    switch (this) {
      case VpnStage.connected:
        return 'You Are Connected';
      case VpnStage.connecting:
      case VpnStage.authenticating:
      case VpnStage.preparing:
      case VpnStage.waitingConnection:
        return 'Connecting...';
      case VpnStage.reconnect:
        return 'Reconnecting...';
      case VpnStage.disconnecting:
        return 'Disconnecting...';
      case VpnStage.denied:
        return 'Permission Denied';
      default:
        return 'Disconnected';
    }
  }

  String get subtitleText {
    switch (this) {
      case VpnStage.connected:
        return 'Your connection is secure';
      case VpnStage.connecting:
      case VpnStage.authenticating:
      case VpnStage.preparing:
      case VpnStage.reconnect:
        return 'Establishing encrypted tunnel';
      case VpnStage.disconnecting:
        return 'Closing tunnel';
      default:
        return 'Unprotected network';
    }
  }
}
