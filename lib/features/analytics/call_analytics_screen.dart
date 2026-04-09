import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'analytics_provider.dart';
import 'package:intl/intl.dart';

class CallAnalyticsScreen extends ConsumerStatefulWidget {
  const CallAnalyticsScreen({super.key});

  @override
  ConsumerState<CallAnalyticsScreen> createState() => _CallAnalyticsScreenState();
}

class _CallAnalyticsScreenState extends ConsumerState<CallAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Call Insights', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterBar(state),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(analyticsProvider.notifier).fetchReports(),
              child: state.isLoading 
                ? _buildSkeleton()
                : state.metrics == null 
                  ? _buildEmptyState()
                  : _buildAnalyticsContent(state.metrics),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AnalyticsState state) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('today', 'Today', state),
          _buildFilterChip('yesterday', 'Yesterday', state),
          _buildFilterChip('custom', 'Custom', state, icon: Icons.calendar_today_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, AnalyticsState state, {IconData? icon}) {
    final active = state.dateFilter == filter;
    String displayLabel = label;
    if (filter == 'custom' && active) {
      displayLabel = '${DateFormat('MMM dd').format(state.startDate)} - ${DateFormat('MMM dd').format(state.endDate)}';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () async {
          if (filter == 'custom') {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
              initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
            );
            if (picked != null) {
              ref.read(analyticsProvider.notifier).setFilter('custom', start: picked.start, end: picked.end);
            }
          } else {
            ref.read(analyticsProvider.notifier).setFilter(filter);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary.withOpacity(0.1) : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
          ),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 14, color: active ? AppTheme.primaryDark : AppTheme.textMuted), const SizedBox(width: 8)],
              Text(
                displayLabel,
                style: TextStyle(
                  color: active ? AppTheme.primaryDark : AppTheme.textSecondary,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(dynamic metrics) {
    final overview = metrics['callOverview'] ?? {};
    final incoming = metrics['incomingCalls'] ?? {};
    final outgoing = metrics['outgoingCalls'] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Performance Overview', Icons.bolt_rounded, AppTheme.primary),
        const SizedBox(height: 12),
        _buildMetricGrid([
          _MetricData('Total Calls', overview['totalCalls'], Icons.call_rounded, AppTheme.primary),
          _MetricData('Unique Leads', overview['uniqueCalls'], Icons.person_rounded, AppTheme.primary),
          _MetricData('Total Time', overview['totalCallTime'], Icons.access_time_filled_rounded, AppTheme.accent),
          _MetricData('Avg Duration', overview['avgCallDuration'], Icons.speed_rounded, AppTheme.warning),
          _MetricData('Connected', overview['totalConnected'], Icons.check_circle_rounded, AppTheme.success),
        ]),
        const SizedBox(height: 32),
        _buildSectionHeader('Inbound Traffic', Icons.phone_callback_rounded, AppTheme.success),
        const SizedBox(height: 12),
        _buildMetricGrid([
          _MetricData('Total Incoming', incoming['totalIncoming'], Icons.phone_callback_rounded, AppTheme.success),
          _MetricData('Connected', incoming['incomingConnected'], Icons.check_circle_rounded, AppTheme.success),
          _MetricData('Missed', incoming['incomingUnanswered'], Icons.cancel_rounded, AppTheme.danger),
          _MetricData('Avg Duration', incoming['avgIncomingDuration'], Icons.timer_rounded, AppTheme.textSecondary),
        ]),
        const SizedBox(height: 32),
        _buildSectionHeader('Outbound Traffic', Icons.phone_forwarded_rounded, AppTheme.accent),
        const SizedBox(height: 12),
        _buildMetricGrid([
          _MetricData('Total Outgoing', outgoing['totalOutgoing'], Icons.phone_forwarded_rounded, AppTheme.accent),
          _MetricData('Connected', outgoing['outgoingConnected'], Icons.check_circle_rounded, AppTheme.success),
          _MetricData('No Answer', outgoing['outgoingUnanswered'], Icons.cancel_rounded, AppTheme.danger),
          _MetricData('Avg Duration', outgoing['avgOutgoingDuration'], Icons.timer_rounded, AppTheme.textSecondary),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildMetricGrid(List<_MetricData> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final m = metrics[index];
        return GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: m.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(m.icon, color: m.color, size: 16),
                  ),
                  const Icon(Icons.trending_up, color: AppTheme.success, size: 14),
                ],
              ),
              Text(
                m.value?.toString() ?? '0',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textPrimary),
              ),
              Text(
                m.label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 150, height: 20, color: AppTheme.divider, margin: const EdgeInsets.only(bottom: 12)),
          _buildMetricGrid(List.generate(4, (_) => _MetricData('', '...', Icons.circle, AppTheme.divider))),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: AppTheme.divider),
          const SizedBox(height: 16),
          const Text('No Analytics Data', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final dynamic value;
  final IconData icon;
  final Color color;
  _MetricData(this.label, this.value, this.icon, this.color);
}
