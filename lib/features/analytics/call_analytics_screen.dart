import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/call_log_service.dart';
import '../../core/api/api_client.dart';
import 'package:intl/intl.dart';

class CallAnalyticsScreen extends StatefulWidget {
  const CallAnalyticsScreen({super.key});

  @override
  State<CallAnalyticsScreen> createState() => _CallAnalyticsScreenState();
}

class _CallAnalyticsScreenState extends State<CallAnalyticsScreen> {
  late CallLogService _callLogService;
  dynamic _metrics;
  bool _isLoading = true;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _callLogService = CallLogService(ApiClient());
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() => _isLoading = true);
    try {
      final start = DateFormat('yyyy-MM-dd').format(_dateRange.start);
      final end = DateFormat('yyyy-MM-dd').format(_dateRange.end);
      final data = await _callLogService.getCallReports(start: start, end: end);
      setState(() {
        _metrics = data['metrics'];
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
        title: const Text('Performance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDateLabel(),
              const SizedBox(height: 24),
              _buildMetricGrid(),
              const SizedBox(height: 32),
              _buildTrafficSection('Inbound Traffic', _metrics?['incomingCalls']),
              const SizedBox(height: 24),
              _buildTrafficSection('Outbound Traffic', _metrics?['outgoingCalls']),
            ],
          ),
    );
  }

  Widget _buildDateLabel() {
    final f = DateFormat('MMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_toggle_off_rounded, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '${f.format(_dateRange.start)} - ${f.format(_dateRange.end)}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid() {
    final overview = _metrics?['callOverview'] ?? {};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Total Calls', overview['totalCalls']?.toString() ?? '0', Icons.call_rounded, AppTheme.primary),
        _buildMetricCard('Connected', overview['totalConnected']?.toString() ?? '0', Icons.phone_callback_rounded, AppTheme.success),
        _buildMetricCard('Unique Leads', overview['uniqueCalls']?.toString() ?? '0', Icons.person_search_rounded, AppTheme.accent),
        _buildMetricCard('Avg Duration', overview['avgCallDuration'] ?? '0s', Icons.timer_rounded, AppTheme.warning),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              const Icon(Icons.arrow_upward_rounded, size: 14, color: AppTheme.success),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTrafficSection(String title, dynamic traffic) {
    if (traffic == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildTrafficRow('Total', traffic['totalIncoming']?.toString() ?? traffic['totalOutgoing']?.toString() ?? '0'),
              const Divider(height: 24, color: Colors.white10),
              _buildTrafficRow('Connected', traffic['incomingConnected']?.toString() ?? traffic['outgoingConnected']?.toString() ?? '0', isSuccess: true),
              const Divider(height: 24, color: Colors.white10),
              _buildTrafficRow('Missed / No Ans', traffic['incomingUnanswered']?.toString() ?? traffic['outgoingUnanswered']?.toString() ?? '0', isDanger: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficRow(String label, String value, {bool isSuccess = false, bool isDanger = false}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        const Spacer(),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isSuccess ? AppTheme.success : (isDanger ? AppTheme.danger : Colors.white),
          )
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _fetchMetrics();
    }
  }
}
