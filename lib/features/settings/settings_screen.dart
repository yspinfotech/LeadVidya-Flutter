import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('More', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account Settings',
            children: [
              _buildSettingItem(Icons.person_outline_rounded, 'Edit Profile', 'Update your personal information', () {}),
              _buildDivider(),
              _buildSettingItem(Icons.notifications_none_rounded, 'Notifications', 'Manage your alerts and preferences', () {}),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'App Preferences',
            children: [
              _buildSettingItem(Icons.download_rounded, 'Check for Updates', 'Current version: 1.0.0', () {}),
              _buildDivider(),
              _buildSettingItem(Icons.security_rounded, 'Permissions', 'Manage app access & security', () {}),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support & Legal',
            children: [
              _buildSettingItem(Icons.help_outline_rounded, 'Help Center', 'FAQs and contact support', () {}),
              _buildDivider(),
              _buildSettingItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'How we handle your data', () {}),
              _buildDivider(),
              _buildSettingItem(Icons.info_outline_rounded, 'About LeadVidya', 'Version, licenses and terms', () {}),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutSection(context, ref),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    final String name = user?['name'] ?? 'User Name';
    final String phone = user?['number'] ?? user?['phone'] ?? 'No Phone';
    final String role = user?['role'] ?? 'Sales Representative';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: Colors.white,
      border: Border.all(color: AppTheme.border),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(role, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(6)),
                  child: Text(phone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_pin_rounded, color: AppTheme.primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: danger ? AppTheme.danger.withOpacity(0.1) : AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: danger ? AppTheme.danger : AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: danger ? AppTheme.danger : AppTheme.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppTheme.divider.withOpacity(0.5)),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          child: _buildSettingItem(Icons.logout_rounded, 'Sign Out', 'Log out of your account', () => _showLogoutDialog(context, ref), danger: true),
        ),
        const SizedBox(height: 24),
        const Text('LeadVidya CRM v1.0.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const Text('© 2026 LeadVidya. All rights reserved.', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text('LOGOUT', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
