import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting BabyShopHub App...');
  
  // Initialize Firebase
  try {
    await FirebaseService().initialize();
    print('✅ Firebase service initialized');
    
    // Test connection
    final connected = await FirebaseService().testConnection();
    if (connected) {
      print('🔥 Firebase connected successfully');
    } else {
      print('⚠️ Firebase connection failed, app will use offline mode');
    }
  } catch (e) {
    print('❌ Firebase setup failed: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      theme: AppTheme.softBabyPastelTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/main': (context) => MainScreen(),
        '/login': (context) => LoginScreen(
              onSwitchToSignup: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen(
                    onSwitchToLogin: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(
                          onSwitchToSignup: () {}
                        )),
                      );
                    },
                  )),
                );
              },
            ),
        '/signup': (context) => SignupScreen(
              onSwitchToLogin: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(
                    onSwitchToSignup: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen(
                          onSwitchToLogin: () {}
                        )),
                      );
                    },
                  )),
                );
              },
            ),
        // Admin Routes
        '/admin_login': (context) => AdminLoginScreen(),
        '/admin_dashboard': (context) => AdminDashboard(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}