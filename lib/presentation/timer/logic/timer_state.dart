import 'package:equatable/equatable.dart';

class TimerState extends Equatable {
  final Duration remaining;
  final bool isRunning;
  final String selectedSound;
  final bool isComplete;

  const TimerState({
    required this.remaining,
    required this.isRunning,
    this.selectedSound = 'Default',
    this.isComplete = false,
  });

  factory TimerState.initial() => const TimerState(
        remaining: Duration.zero,
        isRunning: false,
      );

  TimerState copyWith({
    Duration? remaining,
    bool? isRunning,
    String? selectedSound,
    bool? isComplete,
  }) {
    return TimerState(
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      selectedSound: selectedSound ?? this.selectedSound,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object> get props => [remaining, isRunning, selectedSound, isComplete];
}
