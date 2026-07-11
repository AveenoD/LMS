import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';
import 'utils/role_router.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
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
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
