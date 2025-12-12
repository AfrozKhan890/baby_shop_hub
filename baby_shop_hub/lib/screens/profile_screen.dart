import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart'; 
import '../models/address_model.dart';
import '../models/order_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  List<Order> _orders = [];
  List<Address> _addresses = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _loadingAddresses = false;
  bool _loadingPayments = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData()  {
     _loadOrders();
     _loadAddresses();
     _loadPaymentMethods();
  }

  void _loadOrders() {
    setState(() {
      _orders = [
        Order(
          id: 'ORD001',
          userId: '1',
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
          id: 'ORD002',
          userId: '1',
          items: [],
          totalAmount: 29.99,
          orderDate: DateTime.now().subtract(Duration(days: 5)),
          status: OrderStatus.processing,
          shippingAddress: Address(
            id: '2',
            name: 'Office',
            street: '456 Work Avenue',
            city: 'Business City',
            state: 'Work State',
            zipCode: '67890',
            isDefault: false,
          ),
          paymentMethod: 'PayPal',
        ),
      ];
    });
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loadingAddresses = true;
    });
    
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _addresses = [
        Address(
          id: '1',
          name: 'Home',
          street: '123 Baby Street',
          city: 'Parent City',
          state: 'Family State',
          zipCode: '12345',
          isDefault: true,
        ),
        Address(
          id: '2',
          name: 'Office',
          street: '456 Work Avenue',
          city: 'Business City',
          state: 'Work State',
          zipCode: '67890',
          isDefault: false,
        ),
        Address(
          id: '3',
          name: 'Grandparents',
          street: '789 Family Road',
          city: 'Old Town',
          state: 'Family State',
          zipCode: '11223',
          isDefault: false,
        ),
      ];
      _loadingAddresses = false;
    });
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _loadingPayments = true;
    });
    
    await Future.delayed(Duration(seconds: 1));
    
    setState(() {
      _paymentMethods = [
        {
          'type': 'Credit Card',
          'lastFour': '4242',
          'expiry': '12/25',
          'isDefault': true,
          'icon': Icons.credit_card,
        },
        {
          'type': 'PayPal',
          'email': 'user@example.com',
          'isDefault': false,
          'icon': Icons.payment,
        },
        {
          'type': 'Debit Card',
          'lastFour': '5678',
          'expiry': '09/24',
          'isDefault': false,
          'icon': Icons.credit_card,
        },
      ];
      _loadingPayments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.customColors['babyBlue'],
        elevation: 0,
      ),
      body: currentUser == null ? _buildNotLoggedIn() : _buildProfile(currentUser),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 90, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Please login to view profile',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(
              'Login Now',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.customColors['peach'],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(AppUser currentUser) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserCard(currentUser),
          SizedBox(height: 20),
          _buildAddressesCard(),
          SizedBox(height: 20),
          _buildPaymentMethodsCard(),
          SizedBox(height: 20),
          _buildOrderHistoryCard(),
          SizedBox(height: 20),
          _buildSettingsCard(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.customColors['babyBlue'],
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 4),
            Text(
              user.phone,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _editProfile(),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 6),
                      Text('Edit Profile'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.customColors['babyBlue'],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _changePassword(),
                  child: Row(
                    children: [
                      Icon(Icons.lock, size: 18),
                      SizedBox(width: 6),
                      Text('Change Password'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.customColors['peach'],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Addresses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppTheme.customColors['babyBlue']),
                  onPressed: () => _addNewAddress(),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_loadingAddresses)
              Center(child: CircularProgressIndicator())
            else if (_addresses.isEmpty)
              Column(
                children: [
                  Icon(Icons.location_off, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text(
                    'No addresses saved',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _addNewAddress(),
                    child: Text('Add Your First Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.customColors['peach'],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: _addresses
                    .map((address) => _buildAddressItem(address))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Address address) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.customColors['softCream'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault
              ? AppTheme.customColors['babyBlue']!
              : Colors.grey[300]!,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 8),
                    if (address.isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.customColors['babyBlue'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  address.street,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${address.city}, ${address.state} ${address.zipCode}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (!address.isDefault)
                PopupMenuItem(
                  value: 'set_default',
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 18),
                      SizedBox(width: 8),
                      Text('Set as Default'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editAddress(address);
              } else if (value == 'set_default') {
                _setDefaultAddress(address.id);
              } else if (value == 'delete') {
                _deleteAddress(address.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Methods',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_card, color: AppTheme.customColors['babyBlue']),
                  onPressed: () => _addNewPaymentMethod(),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_loadingPayments)
              Center(child: CircularProgressIndicator())
            else if (_paymentMethods.isEmpty)
              Column(
                children: [
                  Icon(Icons.credit_card_off, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text(
                    'No payment methods saved',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _addNewPaymentMethod(),
                    child: Text('Add Payment Method'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.customColors['peach'],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: _paymentMethods
                    .map((payment) => _buildPaymentMethodItem(payment))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.customColors['softCream'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: payment['isDefault']
              ? AppTheme.customColors['babyBlue']!
              : Colors.grey[300]!,
          width: payment['isDefault'] ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(payment['icon'], size: 30, color: AppTheme.customColors['babyBlue']),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      payment['type'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 8),
                    if (payment['isDefault'])
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.customColors['babyBlue'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                if (payment['lastFour'] != null)
                  Text(
                    '•••• ${payment['lastFour']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                if (payment['expiry'] != null)
                  Text(
                    'Expires ${payment['expiry']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                if (payment['email'] != null)
                  Text(
                    payment['email'],
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              if (!payment['isDefault'])
                PopupMenuItem(
                  value: 'set_default',
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 18),
                      SizedBox(width: 8),
                      Text('Set as Default'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editPaymentMethod(payment);
              } else if (value == 'set_default') {
                _setDefaultPaymentMethod(payment['type']);
              } else if (value == 'delete') {
                _deletePaymentMethod(payment['type']);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllOrders(),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.customColors['babyBlue'],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _orders.isEmpty
                ? _buildNoOrders()
                : Column(
                    children: _orders
                        .take(3) // Show only 3 recent orders
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
        Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
        SizedBox(height: 12),
        Text(
          'No orders yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          },
          child: Text('Start Shopping'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.customColors['peach'],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.customColors['softCream'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.customColors['babyBlue'],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
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
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.shippingAddress.fullAddress,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => _trackOrder(order.id),
                child: Text(
                  'Track Order',
                  style: TextStyle(
                    color: AppTheme.customColors['babyBlue'],
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


Widget _buildSettingsCard() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    child: Column(
      children: [
        _buildSettingsOption(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        Divider(height: 0),
        _buildSettingsOption(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          subtitle: 'Manage your privacy settings',
          onTap: () {
            Navigator.pushNamed(context, '/privacy-security');
          },
        ),
        Divider(height: 0),
        _buildSettingsOption(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs, contact us',
          onTap: () {
            Navigator.pushNamed(context, '/help-support');
          },
        ),
        Divider(height: 0),
        _buildSettingsOption(
          icon: Icons.info_outline,
          title: 'About App',
          subtitle: 'Version 1.0.0',
          onTap: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
        Divider(height: 0),
        _buildSettingsOption(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          isLogout: true,
          onTap: _logout,
        ),
      ],
    ),
  );
}
  Widget _buildSettingsOption({
  required IconData icon,
  required String title,
  String? subtitle,
  bool isLogout = false,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isLogout
            ? Colors.red.withOpacity(0.1)
            : AppTheme.customColors['babyBlue']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: isLogout ? Colors.red : AppTheme.customColors['babyBlue'],
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isLogout ? Colors.red : null,
        fontFamily: 'Poppins',
      ),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          )
        : null,
    trailing: Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: isLogout ? Colors.red : Colors.grey,
    ),
    onTap: onTap,
  );
}
  // Helper Methods for Actions
  void _editProfile() {
    _showComingSoon('Edit Profile');
  }

  void _changePassword() {
    _showComingSoon('Change Password');
  }

  void _addNewAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Address'),
        content: Text('Address form will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editAddress(Address address) {
    _showComingSoon('Edit Address');
  }

  void _setDefaultAddress(String addressId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Address set as default'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _addNewPaymentMethod() {
    _showComingSoon('Add Payment Method');
  }

  void _editPaymentMethod(Map<String, dynamic> payment) {
    _showComingSoon('Edit Payment Method');
  }

  void _setDefaultPaymentMethod(String paymentType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$paymentType set as default'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deletePaymentMethod(String paymentType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment method deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _viewAllOrders() {
    _showComingSoon('All Orders');
  }

  void _trackOrder(String orderId) {
    _showComingSoon('Track Order');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _authService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}