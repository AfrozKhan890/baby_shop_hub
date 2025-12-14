import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get softBabyPastelTheme {
    return ThemeData(
      // Enhanced Color Scheme
      colorScheme: ColorScheme.light(
        primary: Color(0xFF89CFF0), // Baby Blue
        primaryContainer: Color(0xFFB6E6FF),
        secondary: Color(0xFFFFB6C1), // Peach
        secondaryContainer: Color(0xFFFFE4E9),
        background: Color(0xFFFFF9F0), // Soft Cream
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF333333),
        onSurface: Color(0xFF333333),
        surfaceVariant: Color(0xFFF8F9FA),
      ),
      
      scaffoldBackgroundColor: Color(0xFFFFF9F0),
      
      // Enhanced Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF444444),
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF555555),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF777777),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // Enhanced App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF89CFF0),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      
      // Enhanced Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFB6C1), // Peach
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
          shadowColor: Color(0xFFFFB6C1).withOpacity(0.3),
        ),
      ),
      
      // Enhanced Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(0xFF89CFF0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Enhanced Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(8),
        shadowColor: Colors.black12,
      ),
      
      // Enhanced Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFF89CFF0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFF89CFF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFFFB6C1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: Color(0xFF999999),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: Color(0xFF666666),
          fontSize: 14,
        ),
      ),
      
      // Enhanced Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF89CFF0),
        unselectedItemColor: Color(0xFF999999),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  // Enhanced Custom Colors
  static Map<String, Color> customColors = {
    'babyBlue': Color(0xFF89CFF0),
    'peach': Color(0xFFFFB6C1),
    'yellow': Color(0xFFFFF9C4),
    'softCream': Color(0xFFFFF9F0),
    'textDark': Color(0xFF333333),
    'textLight': Color(0xFF666666),
    'textLighter': Color(0xFF999999),
    'success': Color(0xFF4CAF50),
    'warning': Color(0xFFFF9800),
    'error': Color(0xFFF44336),
    'backgroundLight': Color(0xFFF8F9FA),
  };
}