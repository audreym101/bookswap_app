import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE91E63), // Pink
          secondary: Color(0xFF9C27B0), // Purple
          surface: Color(0xFFFCE4EC), // Light pink
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE91E63),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF9C27B0),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
