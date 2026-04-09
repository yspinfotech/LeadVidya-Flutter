import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leads', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildDashboardSnippet(),
          const Expanded(
            child: Center(
              child: Text('Leads List View', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildDashboardSnippet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildStatCard('New', '12', AppTheme.primary),
          const SizedBox(width: 12),
          _buildStatCard('In Progress', '45', AppTheme.accent),
          const SizedBox(width: 12),
          _buildStatCard('Total', '342', AppTheme.success),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
