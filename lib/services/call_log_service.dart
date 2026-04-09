import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

class CallLogService {
  final ApiClient _apiClient;

  CallLogService(this._apiClient);

  Future<dynamic> getLeadTimeline(String leadId) async {
    // GET /calls/lead-timeline
    final response = await _apiClient.get(AppEndpoints.leadTimeline, queryParameters: {'leadId': leadId});
    return response.data;
  }

  Future<dynamic> logCall(Map<String, dynamic> callLog) async {
    // POST /calls/log
    final response = await _apiClient.post(AppEndpoints.logCall, data: callLog);
    return response.data;
  }

  Future<dynamic> getCallReports({required String start, required String end}) async {
    // GET /calls/reports
    final response = await _apiClient.get(AppEndpoints.callReports, queryParameters: {
      'start': start,
      'end': end,
    });
    return response.data;
  }
}
