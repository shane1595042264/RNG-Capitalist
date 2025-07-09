// lib/components/app_sidebar_dnd.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
    final AuthService authService = AuthService();
    
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
      child: Column(
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
          const Spacer(),
          
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
                      backgroundImage: authService.userPhotoUrl != null
                          ? NetworkImage(authService.userPhotoUrl!)
                          : null,
                      child: authService.userPhotoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.purple[700],
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.userDisplayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF323130),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            authService.userEmail,
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
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          _buildNavItem(Icons.info_outline, 'About', currentPage == 'About'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final AuthService authService = AuthService();
      await authService.signOut();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Successfully signed out'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sign out failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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