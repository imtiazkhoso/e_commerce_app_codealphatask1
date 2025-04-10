import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final users = await authProvider.getAllUsers();
      
      setState(() {
        _users = users;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(UserModel user, UserRole newRole) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserRole(user.uid, newRole);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated successfully')),
        );
        _loadUsers(); // Reload users list
      } else {
        setState(() {
          _errorMessage = authProvider.error ?? 'Failed to update user role';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating user role: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is admin
    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('Only administrators can access this page.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No users found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.displayName?.substring(0, 1).toUpperCase() ?? user.email.substring(0, 1).toUpperCase()),
              ),
              title: Text(user.displayName ?? 'User'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  Text(
                    'Role: ${user.role.name.toUpperCase()}',
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<UserRole>(
                onSelected: (role) => _updateUserRole(user, role),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: UserRole.customer,
                      child: Text('Set as Customer'),
                    ),
                    const PopupMenuItem(
                      value: UserRole.seller,
                      child: Text('Set as Seller'),
                    ),
                    const PopupMenuItem(
                      value: UserRole.admin,
                      child: Text('Set as Admin'),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatisticsTab() {
    final totalUsers = _users.length;
    final customerCount = _users.where((u) => u.role == UserRole.customer).length;
    final sellerCount = _users.where((u) => u.role == UserRole.seller).length;
    final adminCount = _users.where((u) => u.role == UserRole.admin).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Total Users', totalUsers, Icons.people, Colors.blue),
          _buildStatCard('Customers', customerCount, Icons.person, Colors.green),
          _buildStatCard('Sellers', sellerCount, Icons.store, Colors.orange),
          _buildStatCard('Admins', adminCount, Icons.admin_panel_settings, Colors.red),
          const SizedBox(height: 32),
          if (totalUsers > 0) ...[
            const Text(
              'User Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Customers', customerCount / totalUsers, Colors.green),
            const SizedBox(height: 8),
            _buildProgressBar('Sellers', sellerCount / totalUsers, Colors.orange),
            const SizedBox(height: 8),
            _buildProgressBar('Admins', adminCount / totalUsers, Colors.red),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(percentage * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
  
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.seller:
        return Colors.orange;
      case UserRole.customer:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 