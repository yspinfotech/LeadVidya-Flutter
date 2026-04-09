import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/call_log_service.dart';
import '../history/history_provider.dart';

class AnalyticsState {
  final bool isLoading;
  final dynamic metrics;
  final String dateFilter;
  final DateTime startDate;
  final DateTime endDate;

  AnalyticsState({
    required this.isLoading,
    this.metrics,
    required this.dateFilter,
    required this.startDate,
    required this.endDate,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    dynamic metrics,
    String? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      dateFilter: dateFilter ?? this.dateFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final CallLogService _service;

  AnalyticsNotifier(this._service) : super(AnalyticsState(
    isLoading: true,
    dateFilter: 'today',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  ));

  Future<void> setFilter(String filter, {DateTime? start, DateTime? end}) async {
    DateTime s = DateTime.now();
    DateTime e = DateTime.now();

    if (filter == 'yesterday') {
      s = DateTime.now().subtract(const Duration(days: 1));
      e = s;
    } else if (filter == 'custom' && start != null && end != null) {
      s = start;
      e = end;
    }

    state = state.copyWith(dateFilter: filter, startDate: s, endDate: e, isLoading: true);
    await fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Map boundaries to ISO strings at midnight/end-of-day like React
      final s = DateTime(state.startDate.year, state.startDate.month, state.startDate.day, 0, 0, 0);
      final e = DateTime(state.endDate.year, state.endDate.month, state.endDate.day, 23, 59, 59);

      final response = await _service.getCallReports(
        start: s.toIso8601String(),
        end: e.toIso8601String(),
      );

      state = state.copyWith(metrics: response['metrics'] ?? response['data']?['metrics'], isLoading: false);
    } catch (err) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(callLogServiceProvider));
});
