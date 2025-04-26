import 'package:flutter/material.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/utils/format_utils.dart';

class RaceReportWidget extends StatelessWidget {
  final Race race;

  const RaceReportWidget({
    super.key,
    required this.race
  });

@override
Widget build(BuildContext context) {
  final totalParticipants = race.participants.length;
  final completedParticipants = race.participants.where((p) => p.overallTime != null).length;
  final raceTime = _calculateRaceTime();

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.insert_chart,
                size: 24,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Race Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Total Participants: $totalParticipants',
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              Text(
                'Completed: $completedParticipants',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              const Text(
                'Race Time:',
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              Text(
                FormatUtils.formatDuration(raceTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export functionality not implemented')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement snapshot functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Snapshot functionality not implemented')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Snapshot'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Duration _calculateRaceTime() {
    if (race.startTime == null) {
      return Duration.zero;
    }
    if (race.status == RaceStatus.finished && race.endTime != null) {
      return race.endTime!.difference(race.startTime!);
    }
    if (race.status == RaceStatus.ongoing) {
      return DateTime.now().difference(race.startTime!);
    }
    return Duration.zero;
  }
}