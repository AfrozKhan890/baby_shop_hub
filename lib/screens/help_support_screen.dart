import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> faqs = [
    {
      'question': 'How do I place an order?',
      'answer': 'Browse products, add to cart, and proceed to checkout. Enter shipping details and payment information to complete your order.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer': 'We accept credit/debit cards, PayPal, and cash on delivery (where available).',
    },
    {
      'question': 'How long does shipping take?',
      'answer': 'Standard shipping takes 3-5 business days. Express shipping is available for 1-2 business days.',
    },
    {
      'question': 'Can I return or exchange products?',
      'answer': 'Yes, we offer 30-day returns for most items. Products must be unused and in original packaging.',
    },
    {
      'question': 'How do I track my order?',
      'answer': 'Once shipped, you\'ll receive a tracking number via email. You can also check order status in your account.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.email, color: AppTheme.customColors['babyBlue']),
                      title: Text('Email Support'),
                      subtitle: Text('support@babyshophub.com'),
                      onTap: () {
                        // Open email
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: AppTheme.customColors['babyBlue']),
                      title: Text('Phone Support'),
                      subtitle: Text('+1 (800) 123-4567'),
                      onTap: () {
                        // Make phone call
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.chat, color: AppTheme.customColors['babyBlue']),
                      title: Text('Live Chat'),
                      subtitle: Text('Available 9 AM - 6 PM'),
                      onTap: () {
                        // Open chat
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.customColors['textDark'],
              ),
            ),
            SizedBox(height: 16),
            
            ...faqs.map((faq) {
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    faq['question'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(faq['answer']),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Resources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.description, color: AppTheme.customColors['babyBlue']),
                      title: Text('Terms of Service'),
                      onTap: () {
                        // Open terms
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.privacy_tip, color: AppTheme.customColors['babyBlue']),
                      title: Text('Privacy Policy'),
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-security');
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.receipt_long, color: AppTheme.customColors['babyBlue']),
                      title: Text('Return Policy'),
                      onTap: () {
                        // Open return policy
                      },
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
}