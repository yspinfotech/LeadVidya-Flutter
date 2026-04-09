import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'LEADS'),
            Tab(text: 'PERSONAL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeadsTab(),
          _buildPersonalTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.dialpad_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildLeadsTab() {
    return const Center(
      child: Text('Leads Call Log (Server Side)', style: TextStyle(color: AppTheme.textSecondary)),
    );
  }

  Widget _buildPersonalTab() {
    return const Center(
      child: Text('Personal Call Log (Device)', style: TextStyle(color: AppTheme.textSecondary)),
    );
  }
}
