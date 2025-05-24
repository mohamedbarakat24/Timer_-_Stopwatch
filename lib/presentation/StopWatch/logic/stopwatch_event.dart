import 'package:equatable/equatable.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();

  @override
  List<Object> get props => [];
}

class StartStopwatch extends StopwatchEvent {}

class PauseStopwatch extends StopwatchEvent {}

class ResetStopwatch extends StopwatchEvent {}

class SaveLap extends StopwatchEvent {
  final String label;

  const SaveLap({required this.label});

  @override
  List<Object> get props => [label];
}
