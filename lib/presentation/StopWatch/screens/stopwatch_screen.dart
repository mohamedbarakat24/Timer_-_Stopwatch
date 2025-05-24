import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/stopwatch_bloc.dart';
import '../logic/stopwatch_event.dart';
import '../logic/stopwatch_state.dart';
import '../../../core/data/colors.dart';
import '../../../core/data/helper_functions.dart';

class StopwatchScreen extends StatelessWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = threeDigits(duration.inMilliseconds.remainder(1000));

    return '$hours:$minutes:$seconds.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? MyColors.darkGreyClr : MyColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Clock Display
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDark ? MyColors.darkHeaderClr : MyColors.lightContainer,
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.bluishClr.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: BlocBuilder<StopwatchBloc, StopwatchState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDuration(state.elapsed),
                            style: TextStyle(
                              color:
                                  isDark ? Colors.white : MyColors.textPrimary,
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
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.refresh,
                    color: MyColors.pinkClr,
                    onPressed: () {
                      context.read<StopwatchBloc>().add(ResetStopwatch());
                    },
                  ),
                  BlocBuilder<StopwatchBloc, StopwatchState>(
                    builder: (context, state) {
                      return _buildControlButton(
                        icon: state.isRunning ? Icons.pause : Icons.play_arrow,
                        color: MyColors.bluishClr,
                        onPressed: () {
                          final bloc = context.read<StopwatchBloc>();
                          if (bloc.state.isRunning) {
                            bloc.add(PauseStopwatch());
                          } else {
                            bloc.add(StartStopwatch());
                          }
                        },
                      );
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.flag,
                    color: MyColors.orangeClr,
                    onPressed: () {
                      final bloc = context.read<StopwatchBloc>();
                      bloc.add(SaveLap(
                          label: 'Label ${bloc.state.laps.length + 1}'));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Laps List
              Expanded(
                child: BlocBuilder<StopwatchBloc, StopwatchState>(
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: state.laps.length,
                      itemBuilder: (context, index) {
                        final lap = state.laps[index];
                        return Card(
                          color: isDark
                              ? MyColors.darkHeaderClr
                              : MyColors.lightContainer,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              lap.label,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : MyColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              _formatDuration(lap.time),
                              style: TextStyle(
                                color: isDark
                                    ? MyColors.grey
                                    : MyColors.textSecondary,
                              ),
                            ),
                            trailing: lap.difference != null
                                ? Text(
                                    '+${_formatDuration(lap.difference!)}',
                                    style: TextStyle(
                                      color: MyColors.orangeClr,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
}
