import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stopwatch_event.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  StopwatchBloc() : super(const StopwatchState()) {
    on<StartStopwatch>(_onStart);
    on<PauseStopwatch>(_onPause);
    on<ResetStopwatch>(_onReset);
    on<SaveLap>(_onSaveLap);
  }

  void _onStart(StartStopwatch event, Emitter<StopwatchState> emit) {
    if (!state.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        add(StartStopwatch());
      });
      emit(state.copyWith(isRunning: true));
    }
    emit(state.copyWith(elapsed: _stopwatch.elapsed));
  }

  void _onPause(PauseStopwatch event, Emitter<StopwatchState> emit) {
    if (state.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      emit(state.copyWith(isRunning: false));
    }
  }

  void _onReset(ResetStopwatch event, Emitter<StopwatchState> emit) {
    _stopwatch.reset();
    _timer?.cancel();
    emit(const StopwatchState());
  }

  void _onSaveLap(SaveLap event, Emitter<StopwatchState> emit) {
    final currentTime = _stopwatch.elapsed;
    final lastLap =
        state.laps.isNotEmpty ? state.laps.last.time : Duration.zero;
    final difference = currentTime - lastLap;

    final newLap = Lap(
      label: event.label,
      time: currentTime,
      difference: state.laps.isNotEmpty ? difference : null,
    );

    emit(state.copyWith(laps: [...state.laps, newLap]));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
