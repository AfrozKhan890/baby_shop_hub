import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late AppUser? _currentUser;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _loadOrders();
    _authService.addListener(_onAuthUpdate);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthUpdate);
    super.dispose();
  }

  void _onAuthUpdate() {
    setState(() {
      _currentUser = _authService.currentUser;
    });
  }

  void _loadOrders() {
    setState(() {
      _orders = [
        Order(
          id: '1',
          userId: _currentUser?.id ?? '1',
          items: [],
          totalAmount: 45.97,
          orderDate: DateTime.now().subtract(Duration(days: 2)),
          status: OrderStatus.delivered,
          shippingAddress: Address(
            id: '1',
            name: 'Home',
            street: '123 Baby Street',
            city: 'Parent City',
            state: 'Family State',
            zipCode: '12345',
            isDefault: true,
          ),
          paymentMethod: 'Credit Card',
        ),
        Order(
          id: '2',
          userId: _currentUser?.id ?? '1',
          items: [],
          totalAmount: 32.99,
          orderDate: DateTime.now().subtract(Duration(days: 7)),
          status: OrderStatus.shipped,
          shippingAddress: Address(
            id: '1',
            name: 'Home',
            street: '123 Baby Street',
            city: 'Parent City',
            state: 'Family State',
            zipCode: '12345',
            isDefault: true,
          ),
          paymentMethod: 'PayPal',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      body: SafeArea(
        child: _currentUser == null
            ? _buildNotLoggedIn()
            : _buildProfile(),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 90),
            SizedBox(height: 16),
            Text('Please login to view profile'),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Login Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        children: [
          _buildUserCard(),
          SizedBox(height: 20),
          _buildOrderHistoryCard(),
          SizedBox(height: 20),
          _buildSettingsCard(),
        ],
      ),
    );
  }

  // -------------------- USER CARD --------------------

  Widget _buildUserCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.customColors['babyBlue'],
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            SizedBox(height: 12),
            Text(
              _currentUser!.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 4),
            Text(_currentUser!.email),
            Text(_currentUser!.phone),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Edit profile coming soon!')),
                  ),
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- ORDERS CARD --------------------

  Widget _buildOrderHistoryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            _orders.isEmpty
                ? _buildNoOrders()
                : Column(
                    children: _orders
                        .map((order) => _buildOrderItem(order))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrders() {
    return Column(
      children: [
        Icon(Icons.shopping_bag_outlined, size: 60),
        SizedBox(height: 8),
        Text('No orders yet'),
      ],
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.customColors['softCream'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.id}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                Text(
                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: order.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.displayName,
              style: TextStyle(
                color: order.status.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SETTINGS CARD --------------------

  Widget _buildSettingsCard() {
    return Card(
      child: Column(
        children: [
          _buildSettingsOption(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
          ),
          _buildSettingsOption(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
          ),
          _buildSettingsOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
          ),
          _buildSettingsOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title coming soon!')),
      ),
    );
  }
}
