import 'package:equatable/equatable.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import 'package:pawxy/features/server_sync/domain/server_model.dart';

class VpnState extends Equatable {
  final VpnStage stage;
  final ServerModel? connectedServer;
  final Duration sessionDuration;
  final double downloadSpeed; // in bytes/sec
  final double uploadSpeed; // in bytes/sec
  final num totalRxBytes;
  final num totalTxBytes;
  final String assignedIp;
  final String? errorMessage;

  const VpnState({
    this.stage = VpnStage.disconnected,
    this.connectedServer,
    this.sessionDuration = Duration.zero,
    this.downloadSpeed = 0.0,
    this.uploadSpeed = 0.0,
    this.totalRxBytes = 0,
    this.totalTxBytes = 0,
    this.assignedIp = '192.168.1.100',
    this.errorMessage,
  });

  VpnState copyWith({
    VpnStage? stage,
    ServerModel? connectedServer,
    Duration? sessionDuration,
    double? downloadSpeed,
    double? uploadSpeed,
    num? totalRxBytes,
    num? totalTxBytes,
    String? assignedIp,
    String? errorMessage,
  }) {
    return VpnState(
      stage: stage ?? this.stage,
      connectedServer: connectedServer ?? this.connectedServer,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      totalRxBytes: totalRxBytes ?? this.totalRxBytes,
      totalTxBytes: totalTxBytes ?? this.totalTxBytes,
      assignedIp: assignedIp ?? this.assignedIp,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        stage,
        connectedServer,
        sessionDuration,
        downloadSpeed,
        uploadSpeed,
        totalRxBytes,
        totalTxBytes,
        assignedIp,
        errorMessage,
      ];
}
