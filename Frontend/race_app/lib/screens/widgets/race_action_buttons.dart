import 'package:flutter/material.dart';
import 'package:race_app/models/race.dart';

class RaceActionButtons extends StatelessWidget {
  final Race race;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onPause;
  final VoidCallback? onReset;

  const RaceActionButtons({
    super.key,
    required this.race,
    this.onStart,
    this.onFinish,
    this.onPause,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    if (race.status == RaceStatus.notStarted) {
      return Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Start Race',
              style: TextStyle(fontSize: 18),
            ),
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.green),
            ),
          ),
        ),
      );
    } else if (race.status == RaceStatus.ongoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onPause,
              icon: const Icon(Icons.pause),
              label: const Text(
                'Pause Race',
                style: TextStyle(fontSize: 18),
              ),
              style: buttonStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.stop),
              label: const Text(
                'Finish Race',
                style: TextStyle(fontSize: 18),
              ),
              style: buttonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt),
            label: const Text(
              'Reset Race',
              style: TextStyle(fontSize: 18),
            ),
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
        ),
      );
    }
  }
}
