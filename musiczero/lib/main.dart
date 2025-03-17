import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sound Wave',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.pinkAccent,
        ),
        cardColor: Colors.white, // Light theme card color
        scaffoldBackgroundColor: Colors.grey[100], // Light theme background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87), // Light theme text color
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue[800],
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[800]!,
          secondary: Colors.blue,
        ),
        cardColor: Colors.grey[900], // Dark theme card color
        scaffoldBackgroundColor: Colors.grey[850], // Dark theme background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Dark theme text color
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: MusicPlayerScreen(
        toggleTheme: _toggleTheme,
        currentIndex: 0,
        onTabTapped: (int) {},
      ),
    );
  }
}
