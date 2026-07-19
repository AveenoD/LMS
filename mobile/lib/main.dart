import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';
import 'utils/role_router.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.instance.init();
  runApp(
    // Wrap the entire app in a ProviderScope so Riverpod can manage state
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reflects the logged-in institute's brand color once known; falls back
    // to the default seed before login / for super_admin (no tenant color).
    final primaryColor = Constants.colorFromHex(ref.watch(authProvider).primaryColor);

    return MaterialApp(
      title: 'EdTech OS Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: const Color(0xFF1F2E27),
          secondary: const Color(0xFF2E6656),
          tertiary: const Color(0xFFA87D26),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF1F2E27),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F3),
        // --- AppBar ---
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2E27),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // --- Bottom Navigation Bar ---
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1F2E27),
          unselectedItemColor: Color(0xFF2E6656),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        // --- Elevated Buttons -> Brass-gold ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA87D26),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        // --- Filled Buttons -> Ink-green ---
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1F2E27),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        // --- Text Buttons -> Chalk-teal ---
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E6656),
          ),
        ),
        // --- Floating Action Button -> Brass-gold ---
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFA87D26),
          foregroundColor: Colors.white,
        ),
        // --- Cards -> White with subtle shadow ---
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black12,
        ),
        // --- Input fields ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE2E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE2E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA87D26), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF2E6656)),
          hintStyle: TextStyle(color: const Color(0xFF1F2E27).withValues(alpha: 0.4)),
          prefixIconColor: const Color(0xFF2E6656),
        ),
        // --- Progress Indicator -> Brass-gold ---
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFFA87D26),
        ),
        // --- Divider ---
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEAEEEC),
          thickness: 1,
        ),
        // --- ListTile ---
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF2E6656),
          titleTextStyle: TextStyle(color: Color(0xFF1F2E27), fontWeight: FontWeight.w500, fontSize: 15),
        ),
        // --- Snackbar ---
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1F2E27),
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        // --- Chip ---
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF2E6656).withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: Color(0xFF2E6656)),
          selectedColor: const Color(0xFF2E6656),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Decides the initial screen: if a token is already stored, validate it
/// against `GET /auth/me` and go straight to the dashboard; otherwise (or on
/// failure) show the login screen. This is what lets a returning user skip
/// logging in again on every app restart.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString('auth_token') != null;
    if (!hasToken) {
      _goTo(const LoginScreen());
      return;
    }
    final notifier = ref.read(authProvider.notifier);
    // Show cached branding/role immediately (in case /auth/me is slow),
    // then confirm the session is actually still valid.
    await notifier.hydrateFromCache();
    final ok = await notifier.restoreSession();
    if (!mounted) return;
    _goTo(ok ? homeScreenForRole(ref.read(authProvider).userRole) : const LoginScreen());
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2E27),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_splash.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Column(
                    children: [
                      const Text(
                        'EdTech OS',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Run your institute. Delight every student.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA87D26)),
                ),
                const SizedBox(height: 24),
                Text(
                  'from MILIYAS',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
