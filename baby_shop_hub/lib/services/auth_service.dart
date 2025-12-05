import '../models/user_model.dart'; // AppUser use karenge

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AppUser? _currentUser;
  bool _isLoggedIn = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Dummy users for demo
  final List<Map<String, dynamic>> _dummyUsers = [
    {
      'email': 'parent@example.com',
      'password': 'password123',
      'name': 'John Parent',
      'phone': '+1234567890',
    },
    {
      'email': 'caregiver@example.com', 
      'password': 'password123',
      'name': 'Sarah Caregiver',
      'phone': '+0987654321',
    },
  ];

  Future<bool> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    final user = _dummyUsers.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
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
      );
      _isLoggedIn = true;
      _notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    // Check if email already exists
    if (_dummyUsers.any((user) => user['email'] == email)) {
      return false;
    }

    _currentUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      addresses: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

  // Listeners for state management
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