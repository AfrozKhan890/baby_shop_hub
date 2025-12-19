import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: AppTheme.customColors['babyBlue']),
            SizedBox(height: 20),
            Text(
              'Welcome to BabyShopHub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.customColors['babyBlue'],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Skip to Login'),
            ),
          ],
        ),
      ),
    );
  }
}