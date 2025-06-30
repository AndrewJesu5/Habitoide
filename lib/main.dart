// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import 'habit_provider.dart';
import 'screens/main_tabs_screen.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null); 

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.grey[50],
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
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
    const Color primaryColor = Colors.teal;
    const Color accentColor = Colors.amber;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      secondary: accentColor,
    );

    final ThemeData baseTheme = ThemeData.light();

    return MaterialApp(
      title: 'Habitóide',
      theme: baseTheme.copyWith(
        colorScheme: colorScheme,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: baseTheme.textTheme.copyWith(
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 0.5),
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87, height: 1.4),
          labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 1.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: colorScheme.surface,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.onSurface.withAlpha((0.6 * 255).round());
          }),
          checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          visualDensity: VisualDensity.compact,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: colorScheme.surface,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary),
          contentTextStyle: TextStyle(fontSize: 16, color: colorScheme.onSurface.withAlpha((0.8 * 255).round())),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
          elevation: 2.0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha((0.5 * 255).round()), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
          hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha((0.5 * 255).round())),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: colorScheme.primaryContainer.withAlpha((0.8 * 255).round()),
          labelStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer, size: 18),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainTabsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}