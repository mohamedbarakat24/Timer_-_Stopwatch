import 'package:equatable/equatable.dart';

class Lap {
  final String label;
  final Duration time;
  final Duration? difference;

  Lap({required this.label, required this.time, this.difference});
}

class StopwatchState extends Equatable {
  final Duration elapsed;
  final bool isRunning;
  final List<Lap> laps;

  const StopwatchState({
    this.elapsed = Duration.zero,
    this.isRunning = false,
    this.laps = const [],
  });

  StopwatchState copyWith({
    Duration? elapsed,
    bool? isRunning,
    List<Lap>? laps,
  }) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      laps: laps ?? this.laps,
    );
  }

  @override
  List<Object> get props => [elapsed, isRunning, laps];
}
