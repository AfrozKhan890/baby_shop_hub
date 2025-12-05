import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2), () {});

    if (_authService.isLoggedIn) {
      // YEH LINE CHECK KAREN - /main par jana chahiye
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['babyBlue'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'BabyShopHub',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'For Loving Parents',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}