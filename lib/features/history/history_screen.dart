import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/call_log_model.dart';
import 'history_provider.dart';
import 'widgets/call_log_item.dart';
import '../leads/leads_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PagingController<int, CallLogModel> _pagingController = PagingController(firstPageKey: 1);
  
  String _searchQuery = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _dateFilterType = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchRemotePage(pageKey);
    });
    
    // Fetch local logs initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localHistoryProvider.notifier).fetchLocalLogs();
    });
  }

  Future<void> _fetchRemotePage(int pageKey) async {
    try {
      final service = ref.read(callLogServiceProvider);
      final logs = await service.getSalespersonCallLogs(
        page: pageKey,
        start: DateFormat('yyyy-MM-dd').format(_startDate),
        end: DateFormat('yyyy-MM-dd').format(_endDate),
      );

      final isLastPage = logs.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(logs);
      } else {
        _pagingController.appendPage(logs, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _refreshRemote() {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Call History', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
          tabs: const [
            Tab(text: 'LEADS'),
            Tab(text: 'PERSONAL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemoteLogsTab(),
          _buildLocalLogsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: Open Dialer
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.dialpad_rounded, color: Colors.black),
      ),
    );
  }

  Widget _buildRemoteLogsTab() {
    return Column(
      children: [
        _buildDateFilterHeader(),
        _buildSearchBar(),
        Expanded(
          child: PagedListView<int, CallLogModel>(
            pagingController: _pagingController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            builderDelegate: PagedChildBuilderDelegate<CallLogModel>(
              itemBuilder: (context, item, index) => CallLogItem(
                item: item,
                isLeadLog: true,
                onAssignSelf: (log) {}, // TODO
              ),
              noItemsFoundIndicatorBuilder: (_) => _buildEmptyState('No call logs found for this period'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalLogsTab() {
    final localLogsState = ref.watch(localHistoryProvider);

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(localHistoryProvider.notifier).fetchLocalLogs(),
            child: localLogsState.when(
              data: (logs) {
                if (logs.isEmpty) return _buildEmptyState('No device call logs found');
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) => CallLogItem(item: logs[index], onAddLead: (log) {}),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading logs: $e')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              _buildDateTypeBtn('today', 'Today'),
              const SizedBox(width: 8),
              _buildDateTypeBtn('custom', 'Custom'),
            ],
          ),
          if (_dateFilterType == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDatePickerBox(_startDate, (d) => setState(() => _startDate = d)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('to', style: TextStyle(color: AppTheme.textMuted)),
                ),
                _buildDatePickerBox(_endDate, (d) => setState(() => _endDate = d)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTypeBtn(String type, String label) {
    bool active = _dateFilterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _dateFilterType = type;
            if (type == 'today') {
              _startDate = DateTime.now();
              _endDate = DateTime.now();
              _refreshRemote();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary.withOpacity(0.1) : AppTheme.divider,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? AppTheme.primary : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerBox(DateTime date, Function(DateTime) onPick) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            onPick(picked);
            _refreshRemote();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or number...',
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            icon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppTheme.divider),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
