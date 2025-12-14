import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About BabyShopHub'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.customColors['babyBlue'],
              child: Icon(
                Icons.child_care,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              'BabyShopHub',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.customColors['textDark'],
              ),
            ),
            SizedBox(height: 8),
            
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Story',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'BabyShopHub was founded in 2023 with a simple mission: to make shopping for baby products easier, safer, and more convenient for parents. We carefully curate high-quality products from trusted brands to ensure the best for your little ones.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Values',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildValueItem(
                      icon: Icons.verified,
                      title: 'Quality Assurance',
                      description: 'All products are thoroughly vetted for safety and quality',
                    ),
                    _buildValueItem(
                      icon: Icons.family_restroom,
                      title: 'Parent-First Approach',
                      description: 'Designed by parents, for parents',
                    ),
                    _buildValueItem(
                      icon: Icons.security,
                      title: 'Safe Shopping',
                      description: 'Secure transactions and data protection',
                    ),
                    _buildValueItem(
                      icon: Icons.local_shipping,
                      title: 'Fast Delivery',
                      description: 'Quick and reliable shipping across the country',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(Icons.location_on, color: AppTheme.customColors['babyBlue']),
                      title: Text('Address'),
                      subtitle: Text('123 Baby Street, Parent City\nFamily State 12345'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: AppTheme.customColors['babyBlue']),
                      title: Text('Email'),
                      subtitle: Text('info@babyshophub.com'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: AppTheme.customColors['babyBlue']),
                      title: Text('Phone'),
                      subtitle: Text('+1 (800) 123-4567'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Media',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.facebook, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.pink),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.message, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.customColors['babyBlue'], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}