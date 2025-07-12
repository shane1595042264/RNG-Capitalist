// lib/components/app_sidebar_dnd.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_auth_service.dart';

class AppSidebarDnD extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigate;

  const AppSidebarDnD({
    Key? key,
    required this.currentPage,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          right: BorderSide(
            color: Colors.black.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: ListView(
        children: [
            const SizedBox(height: 24),
          // App Logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[600]!, Colors.purple[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RNG Capitalist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'D&D Edition',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavItem(Icons.casino, 'Oracle', currentPage == 'Oracle'),
          _buildNavItem(Icons.history, 'History', currentPage == 'History'),
          _buildNavItem(Icons.account_balance_wallet, 'Fixed Costs', currentPage == 'Fixed Costs'),
          _buildNavItem(Icons.auto_awesome, 'Modifiers', currentPage == 'Modifiers'),
          _buildNavItem(Icons.trending_down, 'Sunk Costs', currentPage == 'Sunk Costs'),
          _buildNavItem(Icons.schedule, 'Schedule', currentPage == 'Schedule'),
          _buildNavItem(Icons.casino, 'Spinner', currentPage == 'Spinner'),
          
          // Divider for new advanced features
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(),
          ),
          
          // Advanced D&D Budget Features
          _buildSectionHeader('🎲 Smart Budget'),
          _buildNavItem(Icons.smart_toy, 'Smart Budget', currentPage == 'Smart Budget'),
          _buildNavItem(Icons.camera_alt, 'Receipt Scanner', currentPage == 'Receipt Scanner'),
          _buildNavItem(Icons.analytics, 'Budget Analytics', currentPage == 'Budget Analytics'),
          
          const SizedBox(height: 40), // Fixed space instead of Spacer
          
          // User Profile Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: Icon(
                        Icons.cloud_queue,
                        size: 20,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cloud Sync Active',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF323130),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Auto-sync enabled',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('☁️ Cloud sync is working automatically!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Sync Active'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Account Settings Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                showAccountSettings(context);
              },
              icon: const Icon(Icons.account_circle, size: 16),
              label: const Text('Account'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          
          // Logout Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                try {
                  final authService = UserAuthService();
                  await authService.logoutUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🚪 Logged out successfully. Restart app to login again.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          
          _buildNavItem(Icons.info_outline, 'About', currentPage == 'About'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.purple[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.purple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.purple[700] : const Color(0xFF605E5C),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.purple[700] : const Color(0xFF323130),
          ),
        ),
        onTap: () => onNavigate(label),
      ),
    );
  }
}

void showAccountSettings(BuildContext context) async {
  final authService = UserAuthService();
  final userProfile = await authService.getUserProfile();
  final currentUserId = await authService.getCurrentUserId();
  
  if (!context.mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AccountSettingsDialog(
      userId: currentUserId ?? 'Unknown',
      userProfile: userProfile,
    ),
  );
}

class AccountSettingsDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? userProfile;

  const AccountSettingsDialog({
    Key? key,
    required this.userId,
    this.userProfile,
  }) : super(key: key);

  @override
  State<AccountSettingsDialog> createState() => _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends State<AccountSettingsDialog> {
  bool _showPassword = false;
  String? _currentPassword;

  @override
  void initState() {
    super.initState();
    _loadCurrentPassword();
  }

  Future<void> _loadCurrentPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final passwordHash = prefs.getString('current_user_password');
      setState(() {
        _currentPassword = passwordHash != null 
            ? '${passwordHash.substring(0, 8)}***' 
            : 'Not available';
      });
    } catch (e) {
      setState(() {
        _currentPassword = 'Error loading password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_circle, color: Colors.blue[600]),
          const SizedBox(width: 8),
          const Text('Account Settings'),
        ],
      ),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Username
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Username: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Text(
                          widget.userId,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            backgroundColor: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Password (Hidden/Shown)
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Password: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Text(
                          _showPassword ? (_currentPassword ?? 'Loading...') : '••••••••••••',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            backgroundColor: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        tooltip: _showPassword ? 'Hide password' : 'Show password',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Account Created Date
                  if (widget.userProfile?['created_at'] != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Created: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Expanded(
                          child: Text(
                            widget.userProfile!['created_at'].toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  
                  // Last Login
                  if (widget.userProfile?['last_login'] != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Last Login: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Expanded(
                          child: Text(
                            widget.userProfile!['last_login'].toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Account Actions
            Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Switch Account'),
              subtitle: const Text('Log out and sign in with different account'),
              onTap: () {
                Navigator.pop(context);
                _showSwitchAccountDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Permanently delete this account and all data'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountDialog(context);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void _showChangePasswordDialog(BuildContext context) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldPasswordController,
            decoration: const InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: newPasswordController,
            decoration: const InputDecoration(labelText: 'New Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm New Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (newPasswordController.text != confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }
            
            try {
              final authService = UserAuthService();
              await authService.changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: const Text('Change Password'),
        ),
      ],
    ),
  );
}

void _showSwitchAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Switch Account'),
      content: const Text('This will log you out so you can login with a different account.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final authService = UserAuthService();
              await authService.logoutUser();
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out. Restart app to login with different account.'),
                  backgroundColor: Colors.orange,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: const Text('Switch Account'),
        ),
      ],
    ),
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  final passwordController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This will permanently delete your account and all data. This cannot be undone.',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Enter your password to confirm'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            if (passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter your password')),
              );
              return;
            }
            
            try {
              final authService = UserAuthService();
              final success = await authService.deleteUser(passwordController.text);
              
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully. Restart the app.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete account')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}