// main.dart
// App entry point. Loads environment variables (Gemini API key/model),
// initializes local notifications, and launches the splash screen.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env is optional at dev time - Gemini calls will surface a clear
    // error if the key is missing rather than crashing app startup.
  }

  await NotificationService.init();
  await _reapplyNotificationPrefs();
  await StorageService.ensureDailyRollover();
  runApp(const VexonApp());
}

/// Re-schedules any reminders the user previously enabled. Cheap and
/// idempotent - safe to call on every cold start.
Future<void> _reapplyNotificationPrefs() async {
  final prefs = await StorageService.getNotificationPrefs();
  if (prefs['workout'] == true) await NotificationService.scheduleWorkoutReminder();
  if (prefs['water'] == true) await NotificationService.scheduleWaterReminder();
  if (prefs['meal'] == true) await NotificationService.scheduleMealReminder();
}

class VexonApp extends StatelessWidget {
  const VexonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vexon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
