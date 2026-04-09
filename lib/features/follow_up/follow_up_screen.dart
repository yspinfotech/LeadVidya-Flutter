import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  bool _isLoading = true;
  List<dynamic> _overdue = [];
  List<dynamic> _upcoming = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowUps();
  }

  Future<void> _fetchFollowUps() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(AppEndpoints.urgentNotifications);
      setState(() {
        _overdue = response.data['overdue'] ?? [];
        _upcoming = response.data['upcoming'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Ups', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFollowUps,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_overdue.isNotEmpty) ...[
                  _buildSectionHeader('OVERDUE', AppTheme.danger),
                  ..._overdue.map((item) => _buildFollowUpCard(item, true)),
                  const SizedBox(height: 24),
                ],
                if (_upcoming.isNotEmpty) ...[
                  _buildSectionHeader('UPCOMING (Next 60m)', AppTheme.primary),
                  ..._upcoming.map((item) => _buildFollowUpCard(item, false)),
                ],
                if (_overdue.isEmpty && _upcoming.isEmpty)
                  _buildEmptyState(),
              ],
            ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard(dynamic item, bool isOverdue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? AppTheme.danger.withOpacity(0.2) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: (isOverdue ? AppTheme.danger : AppTheme.primary).withOpacity(0.1),
                child: Icon(Icons.person_rounded, color: isOverdue ? AppTheme.danger : AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] ?? 'Unknown Lead', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(item['followup_time'] ?? 'No time set', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  isOverdue ? 'OVERDUE' : 'UPCOMING',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOverdue ? AppTheme.danger : AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('SNOOZE', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('COMPLETE', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppTheme.success.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('No pending follow-ups for now.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
