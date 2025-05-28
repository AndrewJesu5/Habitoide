// Arquivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'screens/main_tabs_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitóide',
      theme: ThemeData(
        primarySwatch: Colors.teal, 
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(
          secondary: Colors.amber, 
        ),
        scaffoldBackgroundColor: Colors.grey[100], 
        textTheme: const TextTheme( 
          headlineSmall: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.teal),
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16.0),
          labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.teal;
            }
            return null;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainTabsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}