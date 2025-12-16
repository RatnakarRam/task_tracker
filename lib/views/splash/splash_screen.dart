import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_routing_constants.dart';
import '../../providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for UI effect
    await Future.delayed(const Duration(seconds: 3), () {});

    // Check if user is already authenticated by checking shared preferences
    if (mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // Initialize auth status from shared preferences
      // In the new implementation, authentication status is handled directly in AppProvider

      if (appProvider.isAuthenticated) {
        // If authenticated, navigate to home screen
        context.pushReplacement(AppRoutingConstants.homeRoute);
      } else {
        // Otherwise, navigate to login screen
        context.pushReplacement(AppRoutingConstants.loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 100,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                'Daily Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SpinKitThreeBounce(color: Colors.white, size: 25.0),
            ],
          ),
        ),
      ),
    );
  }
}
