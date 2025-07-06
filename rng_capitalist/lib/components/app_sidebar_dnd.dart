// lib/components/app_sidebar_dnd.dart
import 'package:flutter/material.dart';

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
          const Spacer(),
          _buildNavItem(Icons.info_outline, 'About', currentPage == 'About'),
          const SizedBox(height: 24),
        ],
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