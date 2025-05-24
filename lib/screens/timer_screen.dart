import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/timer/timer_bloc.dart';
import '../bloc/timer/timer_event.dart';
import '../bloc/timer/timer_state.dart';
import '../data/colors.dart';
import '../data/helper_functions.dart';
import '../services/sound_service.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunctions.isDarkMode(context);

    return WillPopScope(
      onWillPop: () async {
        await SoundService().stopSound();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          SoundService().stopSound();
        },
        child: Scaffold(
          backgroundColor: isDark ? MyColors.darkGreyClr : MyColors.light,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Timer Display
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? MyColors.darkHeaderClr
                          : MyColors.lightContainer,
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.bluishClr.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDuration(state.remaining),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : MyColors.textPrimary,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                state.isRunning ? 'Running' : 'Paused',
                                style: TextStyle(
                                  color: state.isRunning
                                      ? MyColors.orangeClr
                                      : MyColors.pinkClr,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Time Selection
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark
                          ? MyColors.darkHeaderClr
                          : MyColors.lightContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildTimeWheel(
                              context,
                              label: 'Hours',
                              maxValue: 23,
                              onChanged: (value) {
                                final bloc = context.read<TimerBloc>();
                                final current = bloc.state.remaining;
                                bloc.add(SetTimer(
                                  hours: value,
                                  minutes: current.inMinutes.remainder(60),
                                  seconds: current.inSeconds.remainder(60),
                                ));
                              },
                            ),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : MyColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: _buildTimeWheel(
                              context,
                              label: 'Minutes',
                              maxValue: 59,
                              onChanged: (value) {
                                final bloc = context.read<TimerBloc>();
                                final current = bloc.state.remaining;
                                bloc.add(SetTimer(
                                  hours: current.inHours,
                                  minutes: value,
                                  seconds: current.inSeconds.remainder(60),
                                ));
                              },
                            ),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : MyColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: _buildTimeWheel(
                              context,
                              label: 'Seconds',
                              maxValue: 59,
                              onChanged: (value) {
                                final bloc = context.read<TimerBloc>();
                                final current = bloc.state.remaining;
                                bloc.add(SetTimer(
                                  hours: current.inHours,
                                  minutes: current.inMinutes.remainder(60),
                                  seconds: value,
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.refresh,
                        color: MyColors.pinkClr,
                        onPressed: () {
                          context.read<TimerBloc>().add(ResetTimer());
                        },
                      ),
                      BlocBuilder<TimerBloc, TimerState>(
                        builder: (context, state) {
                          return _buildControlButton(
                            icon: state.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: MyColors.bluishClr,
                            onPressed: () {
                              final bloc = context.read<TimerBloc>();
                              if (bloc.state.isRunning) {
                                bloc.add(PauseTimer());
                              } else {
                                bloc.add(StartTimer());
                              }
                            },
                          );
                        },
                      ),
                      _buildControlButton(
                        icon: Icons.notifications_active,
                        color: MyColors.orangeClr,
                        onPressed: () {
                          _showSoundPicker(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWheel(
    BuildContext context, {
    required String label,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    final isDark = MyHelperFunctions.isDarkMode(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : MyColors.textPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? MyColors.darkGreyClr : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CupertinoPicker(
            itemExtent: 40,
            diameterRatio: 1.5,
            looping: true,
            onSelectedItemChanged: (index) {
              onChanged(index);
            },
            children: List.generate(
              maxValue + 1,
              (index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: isDark ? Colors.white : MyColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 32,
      ),
    );
  }

  void _showSoundPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Sound'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Select Sound from Device'),
              onTap: () {
                Navigator.pop(context);
                context.read<TimerBloc>().add(TimerSelectCustomSound());
              },
            ),
          ],
        ),
      ),
    );
  }
}
