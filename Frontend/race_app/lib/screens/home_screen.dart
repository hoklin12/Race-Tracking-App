import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/screens/participants_screen.dart';
import 'package:race_app/screens/race_control_screen.dart';
import 'package:race_app/screens/time_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ParticipantsProvider>(
          create: (_) => ParticipantsProvider(raceId: 'race_123'),
        ),
        ChangeNotifierProvider<RaceProvider>(
          create: (_) => RaceProvider(raceId: 'race_123'),
        ),
        ChangeNotifierProvider<TimeLogsProvider>(
          create: (_) => TimeLogsProvider(raceId: 'race_123'),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            RaceControlScreen(),
            ParticipantsScreen(),
            TimeTrackingScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Race Control',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Participants',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Time Tracking',
            ),
          ],
        ),
      ),
    );
  }
}
