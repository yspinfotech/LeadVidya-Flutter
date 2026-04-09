import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(user),
          const SizedBox(height: 32),
          _buildSectionHeader('APP SETTINGS'),
          _buildSettingsItem(Icons.notifications_active_outlined, 'Notifications', () {}),
          _buildSettingsItem(Icons.security_rounded, 'Permissions', () {}),
          _buildSettingsItem(Icons.update_rounded, 'Check for Updates', () {}, trailing: const Text('v3.7.5', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
          const SizedBox(height: 32),
          _buildSectionHeader('SUPPORT & LEGAL'),
          _buildSettingsItem(Icons.help_outline_rounded, 'Help Center', () {}),
          _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger.withOpacity(0.1),
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger, width: 1),
            ),
            child: const Text('LOGOUT'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic>? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['name'] ?? 'Sales Agent',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user?['phone'] ?? '+91 XXXXX XXXXX',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SALESPERSON',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of LeadVidya?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text('LOGOUT', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}
