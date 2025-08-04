import 'package:flutter/material.dart';
import 'package:frontend/apis/auth/auth.dart';
import 'package:frontend/screen/home_screen/home_screen.dart';
import 'package:frontend/screen/login_screen/login_screen.dart';
import 'package:frontend/screen/register_screen/register_screen.dart';
import 'package:frontend/screen/splash_screen/splash_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
  final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final Auth _authService = Auth();
      final String? token = await _authService.getToken();
      final bool isLoggedIn = token != null;
      final String currentLocation = state.matchedLocation;
      final isPublicRoute = currentLocation == '/login' ||
          currentLocation == '/register' ||
          currentLocation == '/splash';
      if (isLoggedIn && isPublicRoute) {
        return '/home';
      } else if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }
      return null;
    }
  );
}

