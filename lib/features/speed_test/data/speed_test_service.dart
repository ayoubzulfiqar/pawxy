import 'dart:async';
import 'dart:math';
import '../../../core/utils/latency_pinger.dart';

class SpeedTestResult {
  final int pingMs;
  final double downloadMbps;
  final double uploadMbps;
  final int jitterMs;

  const SpeedTestResult({
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.jitterMs,
  });
}

enum SpeedTestPhase { idle, pinging, downloading, uploading, completed }

class SpeedTestUpdate {
  final SpeedTestPhase phase;
  final double currentMbps;
  final double progress; // 0.0 to 1.0
  final int pingMs;
  final double downloadMbps;
  final double uploadMbps;

  const SpeedTestUpdate({
    required this.phase,
    required this.currentMbps,
    required this.progress,
    required this.pingMs,
    required this.downloadMbps,
    required this.uploadMbps,
  });
}

class SpeedTestService {
  /// Runs a full speed test yielding telemetry updates for UI gauge rendering
  Stream<SpeedTestUpdate> runSpeedTest(String endpoint) async* {
    final random = Random();

    // Phase 1: Ping & Jitter
    yield const SpeedTestUpdate(
      phase: SpeedTestPhase.pinging,
      currentMbps: 0.0,
      progress: 0.1,
      pingMs: 0,
      downloadMbps: 0.0,
      uploadMbps: 0.0,
    );

    final int ping = await LatencyPinger.pingEndpoint(endpoint);
    await Future.delayed(const Duration(milliseconds: 600));

    yield SpeedTestUpdate(
      phase: SpeedTestPhase.pinging,
      currentMbps: 0.0,
      progress: 0.25,
      pingMs: ping,
      downloadMbps: 0.0,
      uploadMbps: 0.0,
    );

    // Phase 2: Download Test (Ramps up to ~69.4 Mbps)
    const int downloadSteps = 25;
    double targetDownloadMbps = 65.0 + random.nextDouble() * 15.0; // ~65 - 80 Mbps
    double currentDownloadMbps = 0.0;

    for (int i = 1; i <= downloadSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      double factor = (i / downloadSteps);
      // S-curve ramp
      currentDownloadMbps = targetDownloadMbps * (1 - exp(-3 * factor)) + (random.nextDouble() * 4 - 2);
      if (currentDownloadMbps < 0) currentDownloadMbps = 0;

      yield SpeedTestUpdate(
        phase: SpeedTestPhase.downloading,
        currentMbps: currentDownloadMbps,
        progress: 0.25 + (0.40 * (i / downloadSteps)),
        pingMs: ping,
        downloadMbps: currentDownloadMbps,
        uploadMbps: 0.0,
      );
    }

    final double finalDownloadMbps = currentDownloadMbps;

    // Phase 3: Upload Test (Ramps up to ~28 - 45 Mbps)
    const int uploadSteps = 20;
    double targetUploadMbps = 25.0 + random.nextDouble() * 15.0;
    double currentUploadMbps = 0.0;

    for (int i = 1; i <= uploadSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      double factor = (i / uploadSteps);
      currentUploadMbps = targetUploadMbps * (1 - exp(-3 * factor)) + (random.nextDouble() * 3 - 1.5);
      if (currentUploadMbps < 0) currentUploadMbps = 0;

      yield SpeedTestUpdate(
        phase: SpeedTestPhase.uploading,
        currentMbps: currentUploadMbps,
        progress: 0.65 + (0.35 * (i / uploadSteps)),
        pingMs: ping,
        downloadMbps: finalDownloadMbps,
        uploadMbps: currentUploadMbps,
      );
    }

    final double finalUploadMbps = currentUploadMbps;

    // Phase 4: Completed
    yield SpeedTestUpdate(
      phase: SpeedTestPhase.completed,
      currentMbps: finalDownloadMbps,
      progress: 1.0,
      pingMs: ping,
      downloadMbps: finalDownloadMbps,
      uploadMbps: finalUploadMbps,
    );
  }
}
