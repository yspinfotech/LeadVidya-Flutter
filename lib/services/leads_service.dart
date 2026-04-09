import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

class LeadsService {
  final ApiClient _apiClient;

  LeadsService(this._apiClient);

  Future<dynamic> getAssignedLeads({int page = 1, int limit = 15, String? status}) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      params['status'] = status;
    }
    final response = await _apiClient.get(AppEndpoints.assignedLeads, queryParameters: params);
    return response.data;
  }

  Future<dynamic> getLeadById(String id) async {
    final response = await _apiClient.get(AppEndpoints.getLeadById, queryParameters: {'id': id});
    return response.data;
  }

  Future<dynamic> updateLeadDetails(String id, Map<String, dynamic> data) async {
    // According to docs, PATCH/PUT /leads/update
    final response = await _apiClient.patch(AppEndpoints.updateLead, data: {'id': id, ...data});
    return response.data;
  }

  Future<dynamic> deleteLead(String id) async {
    final response = await _apiClient.delete(AppEndpoints.deleteLead, queryParameters: {'id': id});
    return response.data;
  }

  Future<dynamic> updateSalespersonDisposition(Map<String, dynamic> payload) async {
    // PUT/PATCH /leads/update-salesperson
    final response = await _apiClient.put(AppEndpoints.updateLeadSalesperson, data: payload);
    return response.data;
  }
}
