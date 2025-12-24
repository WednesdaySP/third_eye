import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/target_screen.dart';
import 'screens/analytics_screen.dart';
import 'services/shooting_service.dart';

void main() {
  // Lock orientation to portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ThirdEyeApp());
}

class ThirdEyeApp extends StatelessWidget {
  const ThirdEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Shooting service for managing shot data
        ChangeNotifierProvider(create: (_) => ShootingService()),
      ],
      child: MaterialApp.router(
        title: 'Third Eye',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF0D47A1),
            background: const Color(0xFF121212),
            surface: const Color(0xFF1E1E1E),
            error: const Color(0xFFCF6679),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

// GoRouter configuration for navigation
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/bluetooth',
      builder: (context, state) => const BluetoothScreen(),
    ),
    GoRoute(
      path: '/target',
      builder: (context, state) => const TargetScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
  ],
);