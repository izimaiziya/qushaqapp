import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/app_data.dart';
import 'pages/splash_screen.dart';
import 'pages/login_screen.dart';
import 'pages/main_shell.dart';
import 'pages/settings_screen.dart';
import 'pages/sensory_kit_screen.dart';
import 'pages/support_contacts_screen.dart';
import 'pages/bracelet_screen.dart';
import 'pages/child_wizard_screen.dart';
import 'pages/routine_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }
  await AppData.instance.load();
  runApp(const QushaqApp());
}

const kTeal = Color(0xFF7A1B3D);
const kTeal2 = Color(0xFFB23A5B);
const kTealBg = Color(0xFFFDF1F3);
const kInk = Color(0xFF231018);
const kInk3 = Color(0xFF7A6670);
const kLine = Color(0xFFF0DDE2);
const kBg = Color(0xFFFFF8F9);

class QushaqApp extends StatefulWidget {
  const QushaqApp({super.key});

  static final ValueNotifier<String> localeNotifier = ValueNotifier<String>(AppData.instance.lang);

  @override
  State<QushaqApp> createState() => _QushaqAppState();
}

class _QushaqAppState extends State<QushaqApp> {
  @override
  void initState() {
    super.initState();
    QushaqApp.localeNotifier.addListener(_onLocaleChange);
  }

  void _onLocaleChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    QushaqApp.localeNotifier.removeListener(_onLocaleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qushaq',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kTeal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => SplashScreen(),
        '/login': (c) => LoginScreen(),
        '/onboarding': (c) => ChildWizardScreen(mode: WizardMode.editChild),
        '/main': (c) => MainShell(),
        '/settings': (c) => SettingsScreen(),
        '/sensory-kit': (c) => SensoryKitScreen(),
        '/support-contacts': (c) => SupportContactsScreen(),
        '/bracelet': (c) => BraceletScreen(),
        '/routine': (c) => RoutineScreen(),
      },
    );
  }
}
