import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'All';
  final List<String> _roles = ['All', 'user', 'admin'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser?.role != 'admin') {
        throw Exception('Unauthorized access');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _users = snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterUsers() {
    List<AppUser> filtered = _users;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.phone.contains(_searchQuery);
      }).toList();
    }

    // Filter by role
    if (_filterRole != 'All') {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Future<void> _updateUserRole(AppUser user, String newRole) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser?.role != 'admin') {
        throw Exception('Unauthorized access');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({
            'role': newRole,
            'updatedAt': Timestamp.now(),
          });

      // Update local list
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user.copyWith(role: newRole);
        }
      });

      _filterUsers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
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
          throw Exception('Unauthorized access');
        }

        // Don't allow deleting yourself
        if (user.id == authService.currentUser?.id) {
          throw Exception('Cannot delete your own account');
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .delete();

        // Update local list
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
        });

        _filterUsers();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18,
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
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.role == 'admin' 
                      ? Colors.blue[50] 
                      : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: user.role == 'admin' 
                        ? Colors.blue 
                        : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.role == 'admin' 
                        ? Colors.blue 
                        : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // User Details
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  user.phone,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Joined: ${_formatDate(user.createdAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  user.isEmailVerified ? 'Email Verified' : 'Email Not Verified',
                  style: TextStyle(
                    fontSize: 14,
                    color: user.isEmailVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                // Change Role Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final newRole = user.role == 'admin' ? 'user' : 'admin';
                      _updateUserRole(user, newRole);
                    },
                    child: Text(
                      user.role == 'admin' ? 'Make User' : 'Make Admin',
                      style: TextStyle(
                        color: user.role == 'admin' ? Colors.green : Colors.blue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: user.role == 'admin' ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                
                // Delete Button (disabled for current user)
                Expanded(
                  child: OutlinedButton(
                    onPressed: user.id == Provider.of<AuthService>(context).currentUser?.id
                        ? null
                        : () => _deleteUser(user),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: user.id == Provider.of<AuthService>(context).currentUser?.id
                            ? Colors.grey
                            : Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: user.id == Provider.of<AuthService>(context).currentUser?.id
                            ? Colors.grey
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.customColors['softCream'],
      appBar: AppBar(
        title: Text(
          'Users Management',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.customColors['babyBlue'],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterUsers();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 12),
                
                // Role Filter
                Row(
                  children: [
                    Text(
                      'Filter by Role: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _filterRole,
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterRole = value!;
                        });
                        _filterUsers();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredUsers.length} Users Found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filterRole = 'All';
                    });
                    _filterUsers();
                  },
                  child: Text('Clear Filters'),
                ),
              ],
            ),
          ),
          
          // Users List
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
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty || _filterRole != 'All'
                                  ? 'Try adjusting your filters'
                                  : 'No users registered yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                                fontFamily: 'Poppins',
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