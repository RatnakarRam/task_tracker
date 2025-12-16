import 'package:daily_tracker/core/constants/app_routing_constants.dart';
import 'package:daily_tracker/views/auth/login_signup_screen.dart';
import 'package:daily_tracker/views/home/home_screen.dart';
import 'package:daily_tracker/views/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutingConstants.splashRoute,
  routes: [
    GoRoute(
      path: AppRoutingConstants.splashRoute,
      name: AppRoutingConstants.splashRoute,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutingConstants.loginRoute,
      name: AppRoutingConstants.loginRoute,
      builder: (context, state) => const LoginSignupScreen(),
    ),
    GoRoute(
      path: AppRoutingConstants.homeRoute,
      name: AppRoutingConstants.homeRoute,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
