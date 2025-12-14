import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  @override
  _PrivacySecurityScreenState createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactorAuth = false;
  bool _biometricLogin = false;
  bool _marketingEmails = true;
  bool _dataCollection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Security'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Data Privacy',
              content: 'We respect your privacy and are committed to protecting your personal data. All your information is encrypted and stored securely.',
            ),
            SizedBox(height: 20),
            
            _buildSection(
              title: 'Security Measures',
              content: 'We use industry-standard encryption (SSL/TLS) to protect your information during transmission. All sensitive data is encrypted at rest.',
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: Text('Two-Factor Authentication'),
                      subtitle: Text('Add an extra layer of security to your account'),
                      value: _twoFactorAuth,
                      onChanged: (value) {
                        setState(() {
                          _twoFactorAuth = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Biometric Login'),
                      subtitle: Text('Use fingerprint or face ID for faster login'),
                      value: _biometricLogin,
                      onChanged: (value) {
                        setState(() {
                          _biometricLogin = value;
                        });
                      },
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
                      'Privacy Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: Text('Marketing Emails'),
                      subtitle: Text('Receive updates about new products and offers'),
                      value: _marketingEmails,
                      onChanged: (value) {
                        setState(() {
                          _marketingEmails = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Data Collection'),
                      subtitle: Text('Allow anonymous usage data collection to improve app'),
                      value: _dataCollection,
                      onChanged: (value) {
                        setState(() {
                          _dataCollection = value;
                        });
                      },
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
                      'Data Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.customColors['textDark'],
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    ListTile(
                      leading: Icon(Icons.download_outlined, color: AppTheme.customColors['babyBlue']),
                      title: Text('Download Your Data'),
                      subtitle: Text('Get a copy of all your data'),
                      onTap: () {
                        _showComingSoon('Data Download');
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete Account'),
                      subtitle: Text('Permanently delete your account and all data'),
                      onTap: () {
                        _showDeleteConfirmation();
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

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.customColors['textDark'],
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppTheme.customColors['babyBlue'],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
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
                  content: Text('Account deletion requested. We will process it within 7 days.'),
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
}