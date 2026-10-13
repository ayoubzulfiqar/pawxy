import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/speed_test_service.dart';
import 'speed_test_state.dart';

class SpeedTestCubit extends Cubit<SpeedTestState> {
  final SpeedTestService _speedTestService;
  StreamSubscription<SpeedTestUpdate>? _subscription;

  SpeedTestCubit({SpeedTestService? speedTestService})
      : _speedTestService = speedTestService ?? SpeedTestService(),
        super(SpeedTestInitial());

  void startTest(String endpoint) {
    if (state is SpeedTestInProgress) return;

    _subscription?.cancel();

    _subscription = _speedTestService.runSpeedTest(endpoint).listen(
      (update) {
        if (update.phase == SpeedTestPhase.completed) {
          emit(SpeedTestCompleted(
            pingMs: update.pingMs,
            downloadMbps: update.downloadMbps,
            uploadMbps: update.uploadMbps,
          ));
        } else {
          emit(SpeedTestInProgress(
            phase: update.phase,
            currentSpeedMbps: update.currentMbps,
            progress: update.progress,
            pingMs: update.pingMs,
            downloadMbps: update.downloadMbps,
            uploadMbps: update.uploadMbps,
          ));
        }
      },
      onError: (error) {
        emit(SpeedTestError('Speed test failed: $error'));
      },
    );
  }

  void reset() {
    _subscription?.cancel();
    emit(SpeedTestInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
