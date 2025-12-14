import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin@example.com';
    _passwordController.text = 'admin123';
  }

  Future<void> _login() async {
    if (_emailController.text == 'admin@example.com' && 
        _passwordController.text == 'admin123') {
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final auth = FirebaseAuth.instance;
        final email = 'admin@example.com';
        final password = 'admin123';
        
        try {
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (signInError) {
          if (signInError.toString().contains('user-not-found') ||
              signInError.toString().contains('wrong-password')) {
            await auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else {
            throw signInError;
          }
        }
        
        final currentUser = auth.currentUser;
        if (currentUser != null) {
          await _ensureAdminUserInFirestore(currentUser.uid, email);
        }
        
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using local admin mode'),
            backgroundColor: Colors.orange,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid admin credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _ensureAdminUserInFirestore(String uid, String email) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      final userDoc = await firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        final adminUser = AppUser(
          id: uid,
          name: 'Admin User',
          email: email,
          phone: '03001234567',
          addresses: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          role: 'admin',
          isEmailVerified: true,
          lastLogin: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(uid)
            .set(adminUser.toMap());
      } else {
        await firestore
            .collection('users')
            .doc(uid)
            .update({
              'role': 'admin',
              'updatedAt': DateTime.now(),
            });
      }
    } catch (e) {
      // Silently handle Firestore error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                  color: AppTheme.customColors['babyBlue'],
                ),
              ),
              SizedBox(height: 40),
              
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppTheme.customColors['babyBlue'],
              ),
              SizedBox(height: 20),
              
              Text(
                'Admin Portal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.customColors['babyBlue'],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Access the admin dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 40),
              
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Admin Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter admin email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Login as Admin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.customColors['babyBlue'],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Admin Credentials:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: admin@example.com',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                          Text(
                            'Password: admin123',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}