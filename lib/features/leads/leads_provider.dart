import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lead_model.dart';
import '../../services/leads_service.dart';
import '../../core/api/api_client.dart';

enum LeadsCategory { all, newLeads, inProgress, unresolved }

final leadsServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeadsService(apiClient);
});

// For pagination and category-based fetching
class LeadsNotifier extends StateNotifier<AsyncValue<List<Lead>>> {
  final LeadsService _service;
  LeadsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> fetchLeads({
    int page = 1,
    LeadsCategory category = LeadsCategory.all,
    String? status,
  }) async {
    try {
      if (page == 1) state = const AsyncValue.loading();
      
      List<Lead> leads;
      switch (category) {
        case LeadsCategory.newLeads:
          leads = await _service.getNewLeads(page: page);
          break;
        case LeadsCategory.inProgress:
          if (status != null && status != 'all') {
            leads = await _service.getLeadsByStatus(status, page: page);
          } else {
            leads = await _service.getInProgressLeads(page: page);
          }
          break;
        default:
          leads = await _service.getAssignedLeads(page: page);
      }
      
      if (page == 1) {
        state = AsyncValue.data(leads);
      } else {
        final currentLeads = state.value ?? [];
        state = AsyncValue.data([...currentLeads, ...leads]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leadsProvider = StateNotifierProvider<LeadsNotifier, AsyncValue<List<Lead>>>((ref) {
  return LeadsNotifier(ref.watch(leadsServiceProvider));
});
