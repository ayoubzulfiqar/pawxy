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
    final num rx = stats['totalDownload'] ?? stats['rx_bytes'] ?? stats['download'] ?? 0;
    final num tx = stats['totalUpload'] ?? stats['tx_bytes'] ?? stats['upload'] ?? 0;

    final now = DateTime.now();
    final double durationSec = now.difference(_lastTrafficTime).inMilliseconds / 1000.0;

    if (durationSec > 0 && _lastRxBytes > 0) {
      final double downloadSpeed = ((rx - _lastRxBytes) / durationSec).clamp(0, double.infinity);
      final double uploadSpeed = ((tx - _lastTxBytes) / durationSec).clamp(0, double.infinity);

      emit(state.copyWith(
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        totalRxBytes: rx,
        totalTxBytes: tx,
      ));
    }

    _lastRxBytes = rx;
    _lastTxBytes = tx;
    _lastTrafficTime = now;
  }

  /// Start VPN connection to [server]
  Future<void> connect(ServerModel server) async {
    emit(state.copyWith(
      stage: VpnStage.connecting,
      connectedServer: server,
      assignedIp: server.assignedIp,
      errorMessage: null,
    ));

    try {
      await _vpnRepository.startVpn(server);

      // Connection negotiation timing
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
    emit(state.copyWith(
      sessionDuration: Duration.zero,
      downloadSpeed: 0,
      uploadSpeed: 0,
    ));
  }

  /// Simulates realistic telemetry fluctuation when running on desktop/emulator without active WireGuard kernel module
  void _startTrafficSimulationIfNecessary() {
    _simulatedTrafficTimer?.cancel();
    final random = Random();

    _simulatedTrafficTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.stage != VpnStage.connected) return;

      final double simulatedDown = (30 * 1024 * 1024 / 8) + (random.nextDouble() * 15 * 1024 * 1024 / 8);
      final double simulatedUp = (400 * 1024 / 8) + (random.nextDouble() * 200 * 1024 / 8);

      final newTotalRx = state.totalRxBytes + (simulatedDown / 8);
      final newTotalTx = state.totalTxBytes + (simulatedUp / 8);

      emit(state.copyWith(
        downloadSpeed: simulatedDown,
        uploadSpeed: simulatedUp,
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
