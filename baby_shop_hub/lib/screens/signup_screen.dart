import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignupScreen({Key? key, required this.onSwitchToLogin}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@%*])[A-Za-z\d@%*]{8,}$'
  );
  final RegExp _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!_nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address\nExample: user@example.com';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    
    String cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Phone number must be 10-15 digits\nExample: 03001234567';
    }
    
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must have:\n• At least 8 characters\n• 1 uppercase letter (A-Z)\n• 1 lowercase letter (a-z)\n• 1 number (0-9)\n• 1 special character (@, %, *)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

 Future<void> _signup() async {
  // Form validation check
  if (!_formKey.currentState!.validate()) {
    print('❌ Form validation failed');
    
    // Show which field failed
    String errorFields = '';
    if (_validateName(_nameController.text) != null) errorFields += 'Name, ';
    if (_validateEmail(_emailController.text) != null) errorFields += 'Email, ';
    if (_validatePhone(_phoneController.text) != null) errorFields += 'Phone, ';
    if (_validatePassword(_passwordController.text) != null) errorFields += 'Password, ';
    if (_validateConfirmPassword(_confirmPasswordController.text) != null) errorFields += 'Confirm Password, ';
    
    if (errorFields.isNotEmpty) {
      errorFields = errorFields.substring(0, errorFields.length - 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix errors in: $errorFields'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
  }

  setState(() {
    _isLoading = true;
  });

  print('🔄 ===== SIGNUP INITIATED FROM UI =====');
  print('🔄 Name: ${_nameController.text}');
  print('🔄 Email: ${_emailController.text}');
  print('🔄 Phone: ${_phoneController.text}');
  print('🔄 Password: ${_passwordController.text}');
  
  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
    );

    if (success) {
      print('✅ Signup successful in UI');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Check your email for verification.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed. User not created.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isLoading = false;
    });
    
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'This email is already registered. Please use another email.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email format. Example: user@example.com';
        break;
      case 'weak-password':
        errorMessage = 'Password must have:\n• At least 8 characters\n• 1 uppercase letter\n• 1 lowercase letter\n• 1 number (0-9)\n• 1 special character (@, %, *)';
        break;
      case 'invalid-name':
        errorMessage = 'Name can only contain letters and spaces.';
        break;
      case 'invalid-phone':
        errorMessage = 'Phone number must be 10-15 digits. Example: 03001234567';
        break;
      case 'network-request-failed':
        errorMessage = 'No internet connection. Please check your network.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again in 5 minutes.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password signup is disabled. Contact support.';
        break;
      default:
        errorMessage = 'Signup failed: ${e.message ?? "Unknown error"}';
        print('🔄 Firebase Error Code: ${e.code}');
        print('🔄 Firebase Error Message: ${e.message}');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
    
  } catch (e, stackTrace) {
    setState(() {
      _isLoading = false;
    });
    
    print('❌ UI: General error: $e');
    print('❌ Stack Trace: $stackTrace');
    
    String errorMessage = 'An unexpected error occurred. Please try again.';
    if (e.toString().contains('firestore')) {
      errorMessage = 'Failed to save user data. Please try again.';
    } else if (e.toString().contains('network')) {
      errorMessage = 'Network error. Check your internet connection.';
    } else if (e.toString().contains('permission')) {
      errorMessage = 'Permission denied. Contact support.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
  void _testSignup() {
    _nameController.text = 'Test User';
    _emailController.text = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
    _passwordController.text = 'Test@1234';
    _confirmPasswordController.text = 'Test@1234';
    _phoneController.text = '03001234567';
    
    _formKey.currentState?.validate();
    
    print('✅ Test data filled');
    print('📝 Email: ${_emailController.text}');
    print('📝 Password: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back),
                      color: AppTheme.customColors['babyBlue'],
                    ),
                    Spacer(),
                    if (!_isLoading)
                      IconButton(
                        onPressed: _testSignup,
                        icon: Icon(Icons.bug_report),
                        color: Colors.orange,
                        tooltip: 'Fill test data',
                      ),
                  ],
                ),
                SizedBox(height: 20),

                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.customColors['babyBlue'],
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sign up to start shopping for your baby',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 40),

                Text(
                  'Full Name *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateName,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 20),

                Text(
                  'Email *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email (e.g., user@example.com)',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 20),

                Text(
                  'Phone Number *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter 10-15 digits (e.g., 03001234567)',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validatePhone,
                ),
                SizedBox(height: 20),

                Text(
                  'Password *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter strong password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validatePassword,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 10),
                
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      _buildRequirement('At least 8 characters', 
                        _passwordController.text.length >= 8),
                      _buildRequirement('1 uppercase letter (A-Z)', 
                        RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                      _buildRequirement('1 lowercase letter (a-z)', 
                        RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                      _buildRequirement('1 number (0-9)', 
                        RegExp(r'\d').hasMatch(_passwordController.text)),
                      _buildRequirement('1 special character (@, %, *)', 
                        RegExp(r'[@%*]').hasMatch(_passwordController.text)),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  'Confirm Password *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 30),

                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Creating your account...',
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.customColors['peach'],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSwitchToLogin,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.customColors['babyBlue'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool satisfied) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: satisfied ? Colors.green : Colors.grey[400],
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: satisfied ? Colors.green : Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}