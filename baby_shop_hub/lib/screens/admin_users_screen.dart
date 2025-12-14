// screens/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // ✅ Check if user is admin
      if (!authService.isLoggedIn || authService.currentUser?.role != 'admin') {
        _showError('Unauthorized access');
        return;
      }

      // ✅ Get users from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _users = [];
          _isLoading = false;
        });
        return;
      }

      // ✅ Parse user data
      List<AppUser> loadedUsers = [];
      
      for (var doc in snapshot.docs) {
        try {
          final user = AppUser.fromFirestore(doc);
          loadedUsers.add(user);
        } catch (e) {
          print('Error parsing user ${doc.id}: $e');
        }
      }

      setState(() {
        _users = loadedUsers;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error loading users: $e');
      _showError('Failed to load users');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AppUser> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    
    return _users.where((user) {
      final searchLower = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(searchLower) ||
             user.email.toLowerCase().contains(searchLower) ||
             (user.phone?.toLowerCase() ?? '').contains(searchLower);
    }).toList();
  }

  Future<void> _updateUserRole(AppUser user, String newRole) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser?.role != 'admin') {
        _showError('Unauthorized access');
        return;
      }

      // ✅ Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({
            'role': newRole,
            'updatedAt': Timestamp.now(),
          });

      // ✅ Update local list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = _users[index].copyWith(role: newRole);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating role: $e');
      _showError('Failed to update role');
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.currentUser?.role != 'admin') {
          _showError('Unauthorized access');
          return;
        }

        // ✅ Prevent deleting own account
        if (user.id == authService.currentUser?.id) {
          _showError('Cannot delete your own account');
          return;
        }

        // ✅ Delete from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .delete();

        // ✅ Remove from local list
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting user: $e');
        _showError('Failed to delete user');
      }
    }
  }

  void _viewUserDetails(AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // ✅ Draggable handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ✅ Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ User Profile
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.customColors['babyBlue'],
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // ✅ User Information
                    _buildInfoRow('User ID', user.id),
                    _buildInfoRow('Phone', user.phone ?? 'Not provided'),
                    _buildInfoRow('Role', user.role.toUpperCase()),
                    _buildInfoRow('Email Verified', user.isEmailVerified ? 'Verified ✅' : 'Not Verified ❌'),
                    _buildInfoRow('Created', _formatDate(user.createdAt)),
                    _buildInfoRow('Last Login', user.lastLogin != null ? _formatDate(user.lastLogin!) : 'Never'),
                    
                    SizedBox(height: 30),
                    
                    // ✅ Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final newRole = user.role == 'admin' ? 'user' : 'admin';
                              _updateUserRole(user, newRole);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              user.role == 'admin' ? Icons.person : Icons.admin_panel_settings,
                              size: 20,
                            ),
                            label: Text(
                              user.role == 'admin' ? 'Make User' : 'Make Admin',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: user.role == 'admin' ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: user.id == Provider.of<AuthService>(context, listen: false).currentUser?.id
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _deleteUser(user);
                                  },
                            icon: Icon(Icons.delete, size: 20),
                            label: Text(
                              'Delete',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.customColors['babyBlue'],
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // ✅ User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.phone ?? 'No phone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ✅ Role Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user.role == 'admin' ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: user.role == 'admin' ? Colors.blue : Colors.green,
                    width: 1,
                  ),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: user.role == 'admin' ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Changed from softCream to white
      body: Column(
        children: [
          // ✅ SIMPLIFIED Search Bar Only (No filters)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users by name, email or phone...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // ✅ Users Count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Users: ${_users.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey[700],
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Found: ${_filteredUsers.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.customColors['babyBlue'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          
          // ✅ Users List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.customColors['babyBlue'],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Users...',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No users found for "$_searchQuery"'
                                  : 'No users registered yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 8),
                            if (!_searchQuery.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: _loadUsers,
                                icon: Icon(Icons.refresh, size: 18),
                                label: Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.customColors['babyBlue'],
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(_filteredUsers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}