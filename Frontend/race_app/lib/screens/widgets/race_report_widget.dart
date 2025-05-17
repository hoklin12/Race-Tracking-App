
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/utils/format_utils.dart';

class RaceReportWidget extends StatefulWidget {
  const RaceReportWidget({super.key});

  @override
  State<RaceReportWidget> createState() => _RaceReportWidgetState();
}

class _RaceReportWidgetState extends State<RaceReportWidget> {
  Duration raceTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final race = raceProvider.race;

    // Cancel any existing timer to avoid duplicates
    _timer?.cancel();

    // Start the timer only if the race is ongoing
    if (race.status == RaceStatus.ongoing) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentRace = Provider.of<RaceProvider>(context, listen: false).race;
        if (currentRace.status != RaceStatus.ongoing) {
          timer.cancel();
          setState(() {
            raceTime = _calculateRaceTime(currentRace);
          });
          return;
        }
        setState(() {
          raceTime = _calculateRaceTime(currentRace);
        });
      });
    }
  }

  Duration _calculateRaceTime(Race race) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, _) {
        final race = raceProvider.race;
        final participantsProvider = Provider.of<ParticipantsProvider>(context);
        final timeLogsProvider = Provider.of<TimeLogsProvider>(context);

        // Restart the timer if the race status changes to ongoing
        if (race.status == RaceStatus.ongoing && (_timer == null || !_timer!.isActive)) {
          _startTimer();
        } else if (race.status != RaceStatus.ongoing) {
          _timer?.cancel();
          raceTime = _calculateRaceTime(race);
        }

        final totalParticipants = participantsProvider.participants.length;
        final completedParticipants = race.status == RaceStatus.notStarted
            ? 0
            : participantsProvider.participants
                .where((p) => timeLogsProvider.hasCompletedAllSegments(p.bib))
                .length;

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
                const Row(
                  children: [
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
              ],
            ),
          ),
        );
      },
    );
  }
}