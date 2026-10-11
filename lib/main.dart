import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acil_atm/screens/main_screen.dart';
import 'package:acil_atm/screens/disclaimer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatılıyor
  await Firebase.initializeApp();

  // Disclaimer onay durumunu kontrol et
  final prefs = await SharedPreferences.getInstance();
  final disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;

  runApp(AtmFinderApp(disclaimerAccepted: disclaimerAccepted));
}

class AtmFinderApp extends StatelessWidget {
  final bool disclaimerAccepted;

  const AtmFinderApp({super.key, required this.disclaimerAccepted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACİL ATM',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
      ),
      home: disclaimerAccepted ? const MainScreen() : const DisclaimerScreen(),
    );
  }
}

