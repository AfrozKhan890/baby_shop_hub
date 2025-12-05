import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/admin_service.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@babyshophub.com');
  final _passwordController = TextEditingController(text: 'admin123');
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // In production, use Firebase Auth
      // For demo, we'll use a simple check
      if (_emailController.text == 'admin@babyshophub.com' && 
          _passwordController.text == 'admin123') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        setState(() {
          _errorMessage = 'Invalid admin credentials';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: AppTheme.customColors['babyBlue'],
                    ),
                    SizedBox(height: 20),
                    
                    // Title
                    Text(
                      'Admin Portal',
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppTheme.customColors['textDark'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'BabyShopHub Administration',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppTheme.customColors['textLight'],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage.isNotEmpty) SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Admin Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter admin email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),

                    // Demo Credentials
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.customColors['yellow'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Admin Credentials:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.customColors['textDark'],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: admin@babyshophub.com\nPassword: admin123',
                            style: TextStyle(
                              color: AppTheme.customColors['textDark'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
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
                                style: TextStyle(fontSize: 16),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.customColors['babyBlue'],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Back to User App
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Back to User App'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}