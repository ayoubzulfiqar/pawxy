import 'package:equatable/equatable.dart';
import '../../data/speed_test_service.dart';

abstract class SpeedTestState extends Equatable {
  const SpeedTestState();

  @override
  List<Object?> get props => [];
}

class SpeedTestInitial extends SpeedTestState {}

class SpeedTestInProgress extends SpeedTestState {
  final SpeedTestPhase phase;
  final double currentSpeedMbps;
  final double progress; // 0.0 - 1.0
  final int pingMs;
  final double downloadMbps;
  final double uploadMbps;

  const SpeedTestInProgress({
    required this.phase,
    required this.currentSpeedMbps,
    required this.progress,
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  @override
  List<Object?> get props => [
        phase,
        currentSpeedMbps,
        progress,
        pingMs,
        downloadMbps,
        uploadMbps,
      ];
}

class SpeedTestCompleted extends SpeedTestState {
  final int pingMs;
  final double downloadMbps;
  final double uploadMbps;

  const SpeedTestCompleted({
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
  });

  @override
  List<Object?> get props => [pingMs, downloadMbps, uploadMbps];
}

class SpeedTestError extends SpeedTestState {
  final String message;

  const SpeedTestError(this.message);

  @override
  List<Object?> get props => [message];
}
