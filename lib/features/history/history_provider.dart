import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:call_log/call_log.dart' as cl;
import '../../core/api/api_client.dart';
import '../../models/call_log_model.dart';
import '../../services/call_log_service.dart';

final callLogServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CallLogService(apiClient);
});

// Remote Logs Notifier (Leads Tab)
class RemoteHistoryNotifier extends StateNotifier<AsyncValue<List<CallLogModel>>> {
  final CallLogService _service;
  RemoteHistoryNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> fetchLogs({int page = 1, String? start, String? end}) async {
    try {
      if (page == 1) state = const AsyncValue.loading();
      final logs = await _service.getSalespersonCallLogs(
        page: page,
        start: start,
        end: end,
      );
      
      if (page == 1) {
        state = AsyncValue.data(logs);
      } else {
        final current = state.value ?? [];
        state = AsyncValue.data([...current, ...logs]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final remoteHistoryProvider = StateNotifierProvider<RemoteHistoryNotifier, AsyncValue<List<CallLogModel>>>((ref) {
  return RemoteHistoryNotifier(ref.watch(callLogServiceProvider));
});

// Local Logs Notifier (Personal Tab)
class LocalHistoryNotifier extends StateNotifier<AsyncValue<List<CallLogModel>>> {
  LocalHistoryNotifier() : super(const AsyncValue.loading());

  Future<void> fetchLocalLogs() async {
    try {
      state = const AsyncValue.loading();
      final Iterable<cl.CallLogEntry> entries = await cl.CallLog.get();
      
      final logs = entries.map((e) => CallLogModel(
        id: e.timestamp?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: e.number,
        leadName: e.name,
        timestamp: e.timestamp ?? 0,
        duration: e.duration ?? 0,
        type: _mapLocalType(e.callType),
        simSlot: 0, // call_log doesn't easily expose SIM slot on all versions
      )).toList();

      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  CallType _mapLocalType(cl.CallType? type) {
    if (type == null) return CallType.unknown;
    switch (type) {
      case cl.CallType.incoming: return CallType.incoming;
      case cl.CallType.outgoing: return CallType.outgoing;
      case cl.CallType.missed: return CallType.missed;
      case cl.CallType.rejected: return CallType.rejected;
      default: return CallType.unknown;
    }
  }
}

final localHistoryProvider = StateNotifierProvider<LocalHistoryNotifier, AsyncValue<List<CallLogModel>>>((ref) {
  return LocalHistoryNotifier();
});
