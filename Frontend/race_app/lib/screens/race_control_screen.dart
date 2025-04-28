
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/screens/widgets/leaderboard_widget.dart';
import 'package:race_app/screens/widgets/race_report_widget.dart';
import 'package:race_app/screens/widgets/race_status_widget.dart';

class RaceControlScreen extends StatelessWidget {
  const RaceControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, _) {
        final race = raceProvider.race;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Race Control'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RaceStatusWidget(
                    key: ValueKey(race.status),
                    // race: race,
                    onStart: raceProvider.startRace,
                    onFinish: raceProvider.finishRace,
                    onPause: raceProvider.pauseRace,
                  ),
                  const SizedBox(height: 16),
                  LeaderboardWidget(race: race),
                  const SizedBox(height: 16),
                  RaceReportWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}