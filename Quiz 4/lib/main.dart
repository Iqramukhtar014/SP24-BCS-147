import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';


const String supabaseUrl = 'https://bafdgvbekgipprsjdjkd.supabase.co';
const String supabaseAnonKey =
    'sb_publishable_kaLSovjQR2mpJcejbLxy9A_eLBYMsCK';

Future<void> main() async {
  // Ensure Flutter bindings are initialised before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Supabase once, at app startup
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Convenience getter used throughout the app
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz 4 – Supabase Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3CE1), // deep violet
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins', // fallback to system if not bundled
      ),
      // ── Auto-login: if a session already exists send user to Home ──
      home: _buildStartScreen(),
    );
  }

  Widget _buildStartScreen() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      // User is already logged in → go straight to Home
      return const HomeScreen();
    }
    // No session → show Login
    return const LoginScreen();
  }
}
