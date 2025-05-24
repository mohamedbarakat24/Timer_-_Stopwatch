import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timer_event.dart';
import 'timer_state.dart';
import '../../../core/services/sound_service.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _timer;
  final SoundService _soundService = SoundService();

  TimerBloc() : super(TimerState.initial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerTick>(_onTimerTick);
    on<SetTimer>(_onSetTimer);
    on<ChangeNotificationSound>(_onChangeNotificationSound);
    on<TimerSelectSound>((event, emit) {
      _soundService.setSound(event.soundName);
    });
    on<TimerSelectCustomSound>((event, emit) async {
      final soundPath = await _soundService.pickCustomSound();
      if (soundPath != null) {
        emit(state.copyWith(selectedSound: 'Custom Sound'));
      }
    });
  }

  void _onStartTimer(StartTimer event, Emitter<TimerState> emit) {
    if (state.remaining.inSeconds > 0) {
      emit(state.copyWith(isRunning: true));
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(TimerTick());
      });
    }
  }

  void _onPauseTimer(PauseTimer event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void _onResetTimer(ResetTimer event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerState.initial());
  }

  void _onTimerTick(TimerTick event, Emitter<TimerState> emit) {
    if (state.remaining.inSeconds > 0) {
      emit(state.copyWith(
        remaining: state.remaining - const Duration(seconds: 1),
      ));
    } else {
      _timer?.cancel();
      emit(state.copyWith(isRunning: false));
      _soundService.playTimerCompleteSound();
    }
  }

  void _onSetTimer(SetTimer event, Emitter<TimerState> emit) {
    final duration = Duration(
      hours: event.hours,
      minutes: event.minutes,
      seconds: event.seconds,
    );
    emit(state.copyWith(remaining: duration));
  }

  void _onChangeNotificationSound(
      ChangeNotificationSound event, Emitter<TimerState> emit) {
    _soundService.setSound(event.soundName);
    emit(state.copyWith(selectedSound: event.soundName));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _soundService.dispose();
    return super.close();
  }
}
