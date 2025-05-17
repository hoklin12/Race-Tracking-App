import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_app/providers/participants_provider.dart';
import 'package:race_app/providers/race_provider.dart';
import 'package:race_app/providers/time_logs_provider.dart';
import 'package:race_app/screens/home_screen.dart';
import 'package:race_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const raceId = 'race_123';
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RaceProvider(raceId: raceId),
        ),
        ChangeNotifierProvider(
          create: (_) => ParticipantsProvider(raceId: raceId),
        ),
        ChangeNotifierProvider(
          create: (_) => TimeLogsProvider(raceId: raceId),
        ),
      ],
      child: MaterialApp(
        title: 'RaceApp',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}

