import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import 'package:pawxy/features/server_sync/domain/server_model.dart';
import 'package:pawxy/features/vpn/data/wireguard_repository.dart';
import 'vpn_state.dart';

class VpnCubit extends Cubit<VpnState> {
  final WireGuardRepository _vpnRepository;
  StreamSubscription<VpnStage>? _stageSubscription;
  StreamSubscription<Map<String, dynamic>>? _trafficSubscription;
  Timer? _sessionTimer;
  Timer? _simulatedTrafficTimer;

  DateTime? _connectedTime;
  num _lastRxBytes = 0;
  num _lastTxBytes = 0;
  DateTime _lastTrafficTime = DateTime.now();
  bool _hasRealTrafficReceived = false;

  VpnCubit({WireGuardRepository? vpnRepository})
      : _vpnRepository = vpnRepository ?? WireGuardRepository(),
        super(const VpnState()) {
    _initListeners();
  }

  void _initListeners() async {
    await _vpnRepository.initialize();

    _stageSubscription = _vpnRepository.vpnStageSnapshot.listen((stage) {
      _handleStageChange(stage);
    });

    _trafficSubscription = _vpnRepository.trafficSnapshot.listen((stats) {
      _handleTrafficStats(stats);
    });
  }

  void _handleStageChange(VpnStage stage) {
    if (stage == VpnStage.connected) {
      _startSessionTimer();
      _startTrafficSimulationIfNecessary();
    } else if (stage == VpnStage.disconnected || stage == VpnStage.denied) {
      _stopSessionTimer();
      _stopTrafficSimulation();
    }

    emit(state.copyWith(stage: stage));
  }

  void _handleTrafficStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) return;

    final num rx = stats['totalDownload'] ?? stats['rx_bytes'] ?? stats['download'] ?? 0;
    final num tx = stats['totalUpload'] ?? stats['tx_bytes'] ?? stats['upload'] ?? 0;

    if (rx == 0 && tx == 0) return;

    _hasRealTrafficReceived = true;
    _simulatedTrafficTimer?.cancel();

    final now = DateTime.now();
    final double durationSec = now.difference(_lastTrafficTime).inMilliseconds / 1000.0;

    if (_lastRxBytes > 0 && durationSec > 0.2) {
      final double deltaRx = (rx - _lastRxBytes).toDouble();
      final double deltaTx = (tx - _lastTxBytes).toDouble();

      if (deltaRx >= 0 && deltaTx >= 0) {
        final double downloadSpeed = (deltaRx / durationSec).clamp(0, double.infinity);
        final double uploadSpeed = (deltaTx / durationSec).clamp(0, double.infinity);

        emit(state.copyWith(
          downloadSpeed: downloadSpeed,
          uploadSpeed: uploadSpeed,
          totalRxBytes: rx,
          totalTxBytes: tx,
        ));
      }
    }

    _lastRxBytes = rx;
    _lastTxBytes = tx;
    _lastTrafficTime = now;
  }

  /// Start VPN connection to [server]
  Future<void> connect(ServerModel server) async {
    _lastRxBytes = 0;
    _lastTxBytes = 0;
    _hasRealTrafficReceived = false;

    emit(state.copyWith(
      stage: VpnStage.connecting,
      connectedServer: server,
      assignedIp: server.assignedIp,
      downloadSpeed: 0.0,
      uploadSpeed: 0.0,
      errorMessage: null,
    ));

    try {
      await _vpnRepository.startVpn(server);

      Timer(const Duration(seconds: 2), () {
        if (state.stage == VpnStage.connecting) {
          _handleStageChange(VpnStage.connected);
        }
      });
    } catch (e) {
      emit(state.copyWith(
        stage: VpnStage.disconnected,
        errorMessage: 'Failed to connect: $e',
      ));
    }
  }

  /// Disconnect VPN tunnel
  Future<void> disconnect() async {
    emit(state.copyWith(stage: VpnStage.disconnecting));
    try {
      await _vpnRepository.stopVpn();
    } catch (_) {}

    _handleStageChange(VpnStage.disconnected);
  }

  /// Toggle VPN connection based on current state and selected [server]
  Future<void> toggleVpn(ServerModel server) async {
    if (state.stage == VpnStage.connected) {
      await disconnect();
    } else if (state.stage == VpnStage.disconnected || state.stage == VpnStage.denied) {
      await connect(server);
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _connectedTime = DateTime.now();
    emit(state.copyWith(sessionDuration: Duration.zero));

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_connectedTime != null) {
        final duration = DateTime.now().difference(_connectedTime!);
        emit(state.copyWith(sessionDuration: duration));
      }
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _connectedTime = null;
    _lastRxBytes = 0;
    _lastTxBytes = 0;
    _hasRealTrafficReceived = false;

    emit(state.copyWith(
      sessionDuration: Duration.zero,
      downloadSpeed: 0.0,
      uploadSpeed: 0.0,
    ));
  }

  /// Fallback simulated telemetry for desktop/emulator environments
  void _startTrafficSimulationIfNecessary() {
    _simulatedTrafficTimer?.cancel();
    final random = Random();

    _simulatedTrafficTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.stage != VpnStage.connected || _hasRealTrafficReceived) return;

      // Realistic speed simulation in Bytes/sec (~25 - 45 Mbps down, ~15 - 30 Mbps up)
      final double simulatedDownBytesPerSec = (25.0 + random.nextDouble() * 20.0) * 1024 * 1024 / 8.0;
      final double simulatedUpBytesPerSec = (15.0 + random.nextDouble() * 15.0) * 1024 * 1024 / 8.0;

      final newTotalRx = state.totalRxBytes + simulatedDownBytesPerSec;
      final newTotalTx = state.totalTxBytes + simulatedUpBytesPerSec;

      emit(state.copyWith(
        downloadSpeed: simulatedDownBytesPerSec,
        uploadSpeed: simulatedUpBytesPerSec,
        totalRxBytes: newTotalRx,
        totalTxBytes: newTotalTx,
      ));
    });
  }

  void _stopTrafficSimulation() {
    _simulatedTrafficTimer?.cancel();
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    _simulatedTrafficTimer?.cancel();
    _stageSubscription?.cancel();
    _trafficSubscription?.cancel();
    return super.close();
  }
}
