import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/lead_model.dart';
import 'leads_provider.dart';
import 'widgets/lead_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/add_lead_modal.dart';
import 'package:go_router/go_router.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  static const _pageSize = 15;
  final PagingController<int, Lead> _pagingController = PagingController(firstPageKey: 1);
  
  LeadsCategory _selectedCategory = LeadsCategory.all;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  bool _isDashboardView = true;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final service = ref.read(leadsServiceProvider);
      List<Lead> newItems;
      
      switch (_selectedCategory) {
        case LeadsCategory.newLeads:
          newItems = await service.getNewLeads(page: pageKey, limit: _pageSize);
          break;
        case LeadsCategory.inProgress:
          if (_selectedStatus != 'all') {
            newItems = await service.getLeadsByStatus(_selectedStatus, page: pageKey, limit: _pageSize);
          } else {
            newItems = await service.getInProgressLeads(page: pageKey, limit: _pageSize);
          }
          break;
        default:
          newItems = await service.getAssignedLeads(page: pageKey, limit: _pageSize);
      }

      // Local search filtering to match React parity
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        newItems = newItems.where((l) =>
          (l.name?.toLowerCase().contains(query) ?? false) ||
          (l.phone?.contains(query) ?? false) ||
          (l.campaignName?.toLowerCase().contains(query) ?? false)
        ).toList();
      }

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _refresh() {
    _pagingController.refresh();
  }

  void _switchCategory(LeadsCategory category) {
    setState(() {
      _selectedCategory = category;
      _isDashboardView = false;
    });
    _refresh();
  }

  void _showAddLeadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLeadModal(
        phoneNumber: _searchQuery.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(_searchQuery) ? _searchQuery : 'No Number Provided',
        onSuccess: () => _refresh(),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _isDashboardView ? 'My Leads' : 
          (_selectedCategory == LeadsCategory.newLeads ? 'New Leads' : 
           _selectedCategory == LeadsCategory.inProgress ? 'In Progress' : 'All Leads'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: !_isDashboardView ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _isDashboardView = true),
        ) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isDashboardView ? _buildDashboard() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLeadModal,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildCategoryCard(
            title: 'New Leads',
            subtitle: 'Awaiting initial contact',
            icon: Icons.person_add_outlined,
            color: AppTheme.accent,
            onTap: () => _switchCategory(LeadsCategory.newLeads),
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            title: 'In Progress Leads',
            subtitle: 'Scheduled tasks & follow-ups',
            icon: Icons.timer_outlined,
            color: AppTheme.warning,
            onTap: () => _switchCategory(LeadsCategory.inProgress),
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            title: 'Stage: Disposed',
            subtitle: 'Leads with logged dispositions',
            icon: Icons.check_circle_outline_rounded,
            color: AppTheme.success,
            onTap: () => _switchCategory(LeadsCategory.all),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        border: Border.all(color: AppTheme.border, width: 1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        SearchBarWidget(
          value: _searchQuery,
          onChanged: (val) {
            _searchQuery = val;
            _refresh();
          },
        ),
        if (_selectedCategory == LeadsCategory.inProgress) _buildFilterHeader(),
        Expanded(
          child: PagedListView<int, Lead>(
            pagingController: _pagingController,
            padding: const EdgeInsets.all(16),
            builderDelegate: PagedChildBuilderDelegate<Lead>(
              itemBuilder: (context, item, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: LeadCard(
                  lead: item,
                  onTap: () => context.push('/lead-details', extra: item),
                ),
              ),
              firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
              noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          const Text('Status Filter:', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showStatusPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(_selectedStatus.toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker() async {
    final statuses = [
      'all', 'in_progress', 'demo booked', 'demo completed', 'demo rescheduled', 'follow up', 'qualified', 'converted', 'lost', 'closed', 'enrolled'
    ];
    
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: statuses.length,
                  itemBuilder: (context, index) {
                    final s = statuses[index];
                    return ListTile(
                      title: Text(s.toUpperCase(), style: const TextStyle(fontSize: 14)),
                      trailing: _selectedStatus == s ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                      onTap: () => Navigator.pop(context, s),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result != _selectedStatus) {
      setState(() => _selectedStatus = result);
      _refresh();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: AppTheme.divider),
          const SizedBox(height: 16),
          const Text('No leads found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const Text('Try adjusting your filters or search query', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
