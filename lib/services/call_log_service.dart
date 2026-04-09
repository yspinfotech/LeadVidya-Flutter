import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../models/call_log_model.dart';

class CallLogService {
  final ApiClient _apiClient;

  CallLogService(this._apiClient);

  Future<List<CallLogModel>> getSalespersonCallLogs({
    String? start,
    String? end,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (start != null) params['start'] = start;
    if (end != null) params['end'] = end;

    final response = await _apiClient.get(AppEndpoints.callLogs, queryParameters: params);
    
    final List data = response.data['data'] ?? response.data ?? [];
    return data.map((e) => CallLogModel.fromRemoteJson(e, null)).toList();
  }

  Future<dynamic> getLeadTimeline(String leadId) async {
    final response = await _apiClient.get(AppEndpoints.leadTimeline, queryParameters: {'leadId': leadId});
    return response.data;
  }

  Future<void> logCall(Map<String, dynamic> payload) async {
    // React uses: POST /calls
    await _apiClient.post(AppEndpoints.calls, data: payload);
  }

  Future<dynamic> getCallReports({required String start, required String end}) async {
    final response = await _apiClient.get(AppEndpoints.callReports, queryParameters: {
      'start': start,
      'end': end,
    });
    return response.data;
  }
}
