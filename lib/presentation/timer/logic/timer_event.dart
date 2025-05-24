import 'package:equatable/equatable.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class StartTimer extends TimerEvent {}

class PauseTimer extends TimerEvent {}

class ResetTimer extends TimerEvent {}

class TimerTick extends TimerEvent {}

class SetTimer extends TimerEvent {
  final int hours;
  final int minutes;
  final int seconds;

  const SetTimer({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  List<Object> get props => [hours, minutes, seconds];
}

class TimerComplete extends TimerEvent {}

class TimerSelectSound extends TimerEvent {
  final String soundName;

  const TimerSelectSound({required this.soundName});

  @override
  List<Object> get props => [soundName];
}

class TimerSelectCustomSound extends TimerEvent {}

class ChangeNotificationSound extends TimerEvent {
  final String soundName;

  const ChangeNotificationSound({required this.soundName});

  @override
  List<Object> get props => [soundName];
}
