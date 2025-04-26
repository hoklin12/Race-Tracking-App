import 'package:flutter/material.dart';
import 'package:race_app/models/dummy_data.dart';
import 'package:race_app/models/race.dart';
import 'package:race_app/screens/widgets/leaderboard_widget.dart';
import 'package:race_app/screens/widgets/race_report_widget.dart';
import 'package:race_app/screens/widgets/race_status_widget.dart';


class RaceControlScreen extends StatefulWidget {
  const RaceControlScreen({super.key});

  @override
  State<RaceControlScreen> createState() => _RaceControlScreenState();
}

class _RaceControlScreenState extends State<RaceControlScreen> {
  late Race race;

  @override
  void initState() {
    super.initState();
    race = dummyRace.copyWith(
      status: RaceStatus.notStarted,
      startTime: null,
      endTime: null,
    );
    print('Initial race status: ${race.status}');
  }

  void _startRace() {
    print('Start Race button pressed');
    print('Before copyWith, status: ${race.status}');
    final newRace = race.copyWith(
      status: RaceStatus.ongoing,
      startTime: DateTime.now(),
    );
    print('After copyWith, new status: ${newRace.status}');
    setState(() {
      race = newRace;
      print('New race status: ${race.status}');
    });
  }

  void _finishRace() {
    print('Finish Race button pressed');
    setState(() {
      race = race.copyWith(
        status: RaceStatus.finished,
        endTime: DateTime.now(),
      );
      print('New race status: ${race.status}');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building with race status: ${race.status}');
    return Scaffold(
      // backgroundColor: const Color(0xFF0A0A1E),
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
                race: race,
                onStart: _startRace,
                onFinish: _finishRace,
              ),
              // _buildControlButton(),
              const SizedBox(height: 16),
              LeaderboardWidget(
                race: race,
                // leaderboard: race.getLeaderboard(),
              ),
              const SizedBox(height: 16),
              RaceReportWidget(
                race: race,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

