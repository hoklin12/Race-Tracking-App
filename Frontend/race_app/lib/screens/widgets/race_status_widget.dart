
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/screens/widgets/race_action_buttons.dart';

class RaceStatusWidget extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onPause;
  final VoidCallback? onReset;

  const RaceStatusWidget({
    super.key,
    this.onStart,
    this.onFinish,
    this.onPause,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);
    final race = raceProvider.race;

    Color statusColor;
    IconData statusIcon;

    switch (race.status) {
      case RaceStatus.notStarted:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        break;
      case RaceStatus.ongoing:
        statusColor = Colors.green;
        statusIcon = Icons.directions_run;
        break;
      case RaceStatus.paused:
        statusColor = Colors.orange;
        statusIcon = Icons.pause;
        break;
      case RaceStatus.finished:
        statusColor = Colors.blue;
        statusIcon = Icons.flag;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, size: 32, color: statusColor),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Race Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getRaceStatusText(race.status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildTimeInfo(context, race),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        RaceActionButtons(
          race: race,
          onStart: onStart,
          onFinish: onFinish,
          onPause: onPause,
          onReset: onReset,
        ),
      ],
    );
  }

  String _getRaceStatusText(RaceStatus status) {
    switch (status) {
      case RaceStatus.notStarted:
        return 'Not Started';
      case RaceStatus.ongoing:
        return 'Ongoing';
      case RaceStatus.paused:
        return 'Paused';
      case RaceStatus.finished:
        return 'Finished';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeInfo(BuildContext context, Race race) {
    if (race.status == RaceStatus.notStarted) {
      return const SizedBox.shrink();
    } else if (race.status == RaceStatus.ongoing && race.startTime != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow, size: 20, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            'Started: ${_formatDateTime(race.startTime!)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else if (race.status == RaceStatus.finished && race.endTime != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stop, size: 20, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            'Finished: ${_formatDateTime(race.endTime!)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}