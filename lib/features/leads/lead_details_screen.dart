import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/lead_model.dart';
import '../../services/leads_service.dart';
import '../../services/call_log_service.dart';
import '../leads/leads_provider.dart';
import '../history/history_provider.dart';
import 'dispose_form.dart';
import 'widgets/timeline_item.dart';
import 'package:intl/intl.dart';

class LeadDetailsScreen extends ConsumerStatefulWidget {
  final String leadId;
  final Lead? lead;

  const LeadDetailsScreen({super.key, required this.leadId, this.lead});

  @override
  ConsumerState<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends ConsumerState<LeadDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Lead? _lead;
  List<dynamic> _timeline = [];
  bool _isLoading = true;
  bool _isTimelineLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _lead = widget.lead;
    _fetchLead();
    
    _tabController.addListener(() {
      if (_tabController.index == 0 && _timeline.isEmpty) {
        _fetchTimeline();
      }
    });
  }

  Future<void> _fetchLead() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(leadsServiceProvider);
      final fresh = await service.getLeadById(widget.leadId);
      setState(() {
        _lead = fresh;
        _isLoading = false;
      });
      _fetchTimeline();
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle 403 if needed (assigned to another agent)
    }
  }

  Future<void> _fetchTimeline() async {
    setState(() => _isTimelineLoading = true);
    try {
      final service = ref.read(callLogServiceProvider);
      final logs = await service.getLeadTimeline(widget.leadId);
      setState(() {
        _timeline = logs ?? [];
        _isTimelineLoading = false;
      });
    } catch (e) {
      setState(() => _isTimelineLoading = false);
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_lead?.displayName ?? 'Lead Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
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
      bottomNavigationBar: _tabController.index == 0 ? _buildBottomCallBar() : null,
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _fetchLead,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              title: 'Basic Information',
              icon: Icons.person_outline_rounded,
              color: AppTheme.primary,
              children: [
                _buildDetailItem('Full Name', _lead?.displayName ?? '-', Icons.person),
                _buildDetailItem('Phone', _lead?.phone ?? '-', Icons.phone, isInteractive: true),
                if (_lead?.altPhone != null) _buildDetailItem('Alt Phone', _lead!.altPhone!, Icons.phone_android),
                _buildDetailItem('Email', _lead?.email ?? '-', Icons.email_outlined),
                _buildDetailItem('City', _lead?.city ?? '-', Icons.location_on_outlined),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Progress & Status',
              icon: Icons.auto_graph_rounded,
              color: AppTheme.warning,
              children: [
                _buildStatusRow(),
                _buildDetailItem('Campaign', _lead?.campaignName ?? 'General', Icons.campaign_outlined),
                _buildDetailItem('Lead Source', _lead?.leadSource ?? 'Manual', Icons.source_outlined),
                _buildDetailItem('Expected Value', _lead?.expectedValue != null ? '₹${_lead!.expectedValue}' : '-', Icons.payments_outlined),
                _buildDetailItem('Follow-up', _lead?.nextFollowupDate != null ? DateFormat('MMM dd, hh:mm a').format(_lead!.nextFollowupDate!) : 'Not Set', Icons.event_repeat_rounded),
              ],
            ),
            const SizedBox(height: 24),
            const Text('ACTIVITY TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMuted, letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      borderRadius: 20,
      border: Border.all(color: AppTheme.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {bool isInteractive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.textMuted, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isInteractive ? AppTheme.primaryDark : AppTheme.textPrimary,
                    fontWeight: isInteractive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Lead Status', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              _lead?.status?.toUpperCase() ?? 'OPEN',
              style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_isTimelineLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (_timeline.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No activities yet', style: TextStyle(color: AppTheme.textMuted))));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _timeline.length,
      itemBuilder: (context, index) => TimelineItem(
        data: _timeline[index],
        isLast: index == _timeline.length - 1,
      ),
    );
  }

  Widget _buildDispositionTab() {
    return DisposeForm(
      leadId: widget.leadId,
      onSuccess: () {
        _tabController.animateTo(0);
        _fetchLead();
      },
    );
  }

  Widget _buildBottomCallBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {}, // TODO: Initiate Call
          icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.black),
          label: const Text('INITIATE CALL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
