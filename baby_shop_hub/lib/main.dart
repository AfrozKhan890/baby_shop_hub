import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/category_products_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/about_screen.dart';

// Models
import 'models/product_model.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';

// Services
import 'services/cart_service.dart';
import 'services/auth_service.dart';

// Utils
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Continue with demo mode even if Firebase fails
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<CartService>(create: (_) => CartService()),
      ],
      child: MaterialApp(
        title: 'BabyShopHub',
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: AppTheme.customColors['softCream'],
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.customColors['babyBlue'],
            titleTextStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/onboarding': (context) => OnboardingScreen(),
          '/login': (context) => LoginScreen(
            onSwitchToSignup: () => Navigator.pushReplacementNamed(context, '/signup'),
          ),
          '/signup': (context) => SignupScreen(
            onSwitchToLogin: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          '/main': (context) => MainScreen(),
          '/admin-login': (context) => AdminLoginScreen(),
          '/admin-dashboard': (context) => AdminDashboard(),
          '/profile': (context) => ProfileScreen(),
          '/product-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Product) {
              return ProductDetailScreen(product: args);
            }
            // Fallback product for safety
            return ProductDetailScreen(
  product: Product(
    id: '0',
    name: 'Product Not Found',
    description: 'This product could not be loaded',
    images: [],
    category: '',
    brand: '',
    variants: [
      ProductVariant(
        id: 'default',
        size: 'One Size',
        color: 'Default',
        price: 0.0,
        stock: 0,
      )
    ],
    basePrice: 0.0,
    createdAt: DateTime.now(),
    rating: 0.0,
    reviewCount: 0,
    isFeatured: false,
  
              ),
            );
          },
          // NEW ROUTES
          '/category-products': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return CategoryProductsScreen(
              category: args is String ? args : 'All',
            );
          },
          '/notifications': (context) => NotificationsScreen(),
          '/privacy-security': (context) => PrivacySecurityScreen(),
          '/help-support': (context) => HelpSupportScreen(),
          '/about': (context) => AboutScreen(),
        },
      ),
    );
  }
}