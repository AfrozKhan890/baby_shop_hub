import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/admin_service.dart';
import '../models/admin_model.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AdminDashboardHome(),
    AdminProductsScreen(),
    AdminOrdersScreen(),
    AdminUsersScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Orders',
    'Users',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppTheme.customColors['babyBlue'],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.customColors['babyBlue'],
      unselectedItemColor: AppTheme.customColors['textLight'],
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
      ],
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }
}

// ============ DASHBOARD HOME ============

class AdminDashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Admin!',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: AppTheme.customColors['textDark'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your BabyShopHub store efficiently',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.customColors['textLight'],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.date_range, color: AppTheme.customColors['babyBlue']),
                      SizedBox(width: 8),
                      Text(
                        'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          color: AppTheme.customColors['textDark'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Stats Grid
          Text(
            'Store Overview',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: AppTheme.customColors['textDark'],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context: context,
                title: 'Total Products',
                value: '48',
                icon: Icons.shopping_bag,
                color: AppTheme.customColors['babyBlue']!,
              ),
              _buildStatCard(
                context: context,
                title: 'Total Orders',
                value: '156',
                icon: Icons.receipt,
                color: AppTheme.customColors['peach']!,
              ),
              _buildStatCard(
                context: context,
                title: 'Total Users',
                value: '89',
                icon: Icons.people,
                color: Colors.green,
              ),
              _buildStatCard(
                context: context,
                title: 'Total Revenue',
                value: '\$2,456',
                icon: Icons.attach_money,
                color: Colors.amber,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: AppTheme.customColors['textDark'],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildActionCard(
                context: context,
                title: 'Add Product',
                icon: Icons.add_circle_outline,
                onTap: () {
                  // Navigate to add product
                },
              ),
              _buildActionCard(
                context: context,
                title: 'View Orders',
                icon: Icons.list_alt,
                onTap: () {
                  // Navigate to orders
                },
              ),
              _buildActionCard(
                context: context,
                title: 'Manage Users',
                icon: Icons.manage_accounts,
                onTap: () {
                  // Navigate to users
                },
              ),
              _buildActionCard(
                context: context,
                title: 'Settings',
                icon: Icons.settings,
                onTap: () {
                  // Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppTheme.customColors['textDark'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppTheme.customColors['textLight'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.customColors['babyBlue']),
              SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}