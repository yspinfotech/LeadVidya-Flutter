import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/leads_service.dart';
import '../../services/call_log_service.dart';
import '../../core/api/api_client.dart';
import 'dispose_form.dart';

class LeadDetailsScreen extends StatefulWidget {
  final String leadId;

  const LeadDetailsScreen({super.key, required this.leadId});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeadsService _leadsService;
  late CallLogService _callLogService;
  
  dynamic _lead;
  List<dynamic> _timeline = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final apiClient = ApiClient();
    _leadsService = LeadsService(apiClient);
    _callLogService = CallLogService(apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final leadData = await _leadsService.getLeadById(widget.leadId);
      final timelineData = await _callLogService.getLeadTimeline(widget.leadId);
      setState(() {
        _lead = leadData;
        _timeline = timelineData ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load lead details')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lead?['name'] ?? 'Lead Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'DISPOSITION'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDispositionTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.success,
        child: const Icon(Icons.call_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          const Text('TIMELINE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_outlined, 'Phone', _lead?['phone'] ?? 'N/A'),
          const Divider(height: 32, color: Colors.white10),
          _buildInfoRow(Icons.email_outlined, 'Email', _lead?['email'] ?? 'N/A'),
          const Divider(height: 32, color: Colors.white10),
          _buildInfoRow(Icons.location_on_outlined, 'City', _lead?['city'] ?? 'N/A'),
          const Divider(height: 32, color: Colors.white10),
          _buildInfoRow(Icons.campaign_outlined, 'Campaign', _lead?['campaign'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    if (_timeline.isEmpty) {
      return const Center(child: Text('No activity logs found', style: TextStyle(color: AppTheme.textSecondary)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _timeline.length,
      itemBuilder: (context, index) {
        final item = _timeline[index];
        return _buildTimelineItem(item);
      },
    );
  }

  Widget _buildTimelineItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const CircleAvatar(radius: 6, backgroundColor: AppTheme.accent),
              Container(width: 2, height: 40, color: Colors.white10),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['status'] ?? 'Called', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['notes'] ?? 'No notes added', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(item['time'] ?? 'Just now', style: const TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispositionTab() {
    return DisposeForm(
      leadId: widget.leadId,
      onSuccess: () {
        _tabController.animateTo(0);
        _loadData();
      },
    );
  }
}
