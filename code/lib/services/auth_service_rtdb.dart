import '../models/address_model.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  bool _isLoggedIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Demo users - FIXED EMAILS
  final List<Map<String, dynamic>> _demoUsers = [
    {
      'email': 'parent@example.com',
      'password': 'password123',
      'name': 'Demo Parent',
      'phone': '+1234567890',
      'role': 'user',
    },
    {
      'email': 'admin@example.com', // CHANGED: Use example.com
      'password': 'admin123',
      'name': 'Admin User',
      'phone': '+0987654321',
      'role': 'admin',
    },
  ];

  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    
    print('🔐 Login attempt: $email');
    
    // Normalize email (trim and lowercase)
    final normalizedEmail = email.trim().toLowerCase();
    
    final user = _demoUsers.firstWhere(
      (user) => user['email'].toString().toLowerCase() == normalizedEmail 
               && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      print('✅ Login successful for: ${user['email']}');
      print('👑 Role: ${user['role']}');
      
      _currentUser = AppUser(
        id: '1',
        name: user['name'],
        email: user['email'],
        phone: user['phone'],
        addresses: [
          Address(
            id: '1',
            name: 'Home',
            street: '123 Baby Street',
            city: 'Parent City',
            state: 'Family State',
            zipCode: '12345',
            isDefault: true,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: user['role'] ?? 'user',
      );
      _isLoggedIn = true;
      _notifyListeners();
      return true;
    }
    
    print('❌ Login failed for: $email');
    return false;
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    await Future.delayed(Duration(seconds: 1));
    
    // Normalize email
    final normalizedEmail = email.trim().toLowerCase();
    
    // Check if email already exists
    if (_demoUsers.any((user) => 
        user['email'].toString().toLowerCase() == normalizedEmail)) {
      print('❌ Email already exists: $email');
      return false;
    }

    print('✅ Signup successful for: $email');
    
    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      addresses: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      role: 'user', // New users are always regular users
    );
    
    _isLoggedIn = true;
    _notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _notifyListeners();
  }

  Future<bool> isAdmin() async {
    if (_currentUser == null) return false;
    final isAdmin = _currentUser!.role == 'admin';
    print('👑 Admin check: ${_currentUser!.email} -> $isAdmin');
    return isAdmin;
  }

  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}