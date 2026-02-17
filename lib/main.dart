import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TempTrackerApp());
}

class TempTrackerApp extends StatelessWidget {
  const TempTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temp Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFF2E86DE),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
