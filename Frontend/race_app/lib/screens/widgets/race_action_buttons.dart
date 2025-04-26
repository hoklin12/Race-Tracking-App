import 'package:flutter/material.dart';
import 'package:race_app/models/race.dart';

class RaceActionButtons extends StatelessWidget {
  final Race race;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onPause;

  const RaceActionButtons({
    super.key,
    required this.race,
    this.onStart,
    this.onFinish,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            label: const Text('Start Race'),
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
          SizedBox(
            width: 230,
            child: ElevatedButton.icon(
              onPressed: onPause,
              icon: const Icon(Icons.pause),
              label: const Text('Pause Race'),

              style: buttonStyle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 230,
            child: ElevatedButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.stop),
              label: const Text('Finish Race'),
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
            onPressed: null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Race Completed'),

            style: buttonStyle
          ),
        ),
      );
    }
  }
}
