import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Order Shipped',
      'message': 'Your order #ORD001 has been shipped',
      'time': '2 hours ago',
      'read': false,
      'type': 'order',
    },
    {
      'title': 'New Product Alert',
      'message': 'New diapers from Pampers are now available',
      'time': '1 day ago',
      'read': true,
      'type': 'product',
    },
    {
      'title': 'Special Offer',
      'message': 'Get 20% off on baby clothes this weekend',
      'time': '2 days ago',
      'read': true,
      'type': 'offer',
    },
    {
      'title': 'Price Drop Alert',
      'message': 'Baby carriers are now 15% off',
      'time': '3 days ago',
      'read': true,
      'type': 'price',
    },
    {
      'title': 'Welcome to BabyShopHub!',
      'message': 'Start shopping for your baby needs',
      'time': '1 week ago',
      'read': true,
      'type': 'welcome',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: AppTheme.customColors['babyBlue'],
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              // Clear all notifications
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something arrives',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: notification['read'] ? Colors.white : AppTheme.customColors['softCream'],
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(notification['type']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification['type']),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notification['message']),
                    trailing: Text(
                      notification['time'],
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // Handle notification tap
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order': return Colors.green;
      case 'product': return AppTheme.customColors['babyBlue']!;
      case 'offer': return Colors.orange;
      case 'price': return Colors.purple;
      case 'welcome': return Colors.pink;
      default: return AppTheme.customColors['babyBlue']!;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order': return Icons.local_shipping;
      case 'product': return Icons.shopping_bag;
      case 'offer': return Icons.discount;
      case 'price': return Icons.attach_money;
      case 'welcome': return Icons.emoji_emotions;
      default: return Icons.notifications;
    }
  }
}