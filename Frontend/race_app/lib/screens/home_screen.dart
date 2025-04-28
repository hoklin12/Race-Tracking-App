import 'package:flutter/material.dart';
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

  final List<Widget> _screens = [
    const RaceControlScreen(),
    const ParticipantsScreen(),
    const TimeTrackingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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
          // NavigationDestination(
          //   icon: Icon(Icons.dashboard_outlined),
          //   selectedIcon: Icon(Icons.dashboard),
          //   label: 'Dashboard',
          // ),
        ],
      ),
    );
  }
}

