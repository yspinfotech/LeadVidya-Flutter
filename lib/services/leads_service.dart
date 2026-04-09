import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../models/lead_model.dart';

class LeadsService {
  final ApiClient _apiClient;

  LeadsService(this._apiClient);

  Future<List<Lead>> getAssignedLeads({int page = 1, int limit = 15, String? status}) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      params['status'] = status;
    }
    final response = await _apiClient.get(AppEndpoints.assignedLeads, queryParameters: params);
    
    final data = response.data['data'] as List?;
    return data?.map((e) => Lead.fromJson(e)).toList() ?? [];
  }

  Future<List<Lead>> getNewLeads({int page = 1, int limit = 15}) async {
    final response = await _apiClient.get(AppEndpoints.newLeads, queryParameters: {'page': page, 'limit': limit});
    final data = response.data['data'] as List?;
    return data?.map((e) => Lead.fromJson(e)).toList() ?? [];
  }

  Future<List<Lead>> getInProgressLeads({int page = 1, int limit = 15}) async {
    final response = await _apiClient.get(AppEndpoints.inProgressLeads, queryParameters: {'page': page, 'limit': limit});
    final data = response.data['data'] as List?;
    return data?.map((e) => Lead.fromJson(e)).toList() ?? [];
  }

  Future<List<Lead>> getLeadsByStatus(String status, {int page = 1, int limit = 15}) async {
    final response = await _apiClient.get(AppEndpoints.leadsByStatus, queryParameters: {
      'status': status,
      'page': page,
      'limit': limit,
    });
    final data = response.data['data'] as List?;
    return data?.map((e) => Lead.fromJson(e)).toList() ?? [];
  }

  Future<Lead> getLeadById(String id) async {
    final response = await _apiClient.get(AppEndpoints.getLeadById, queryParameters: {'id': id});
    final data = response.data['data'] ?? response.data['lead'] ?? response.data;
    return Lead.fromJson(data);
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    await _apiClient.post('/leads', data: data);
  }

  Future<List<Lead>> searchLeads(String query) async {
    final response = await _apiClient.get('/leads/search', queryParameters: {'q': query});
    final data = response.data['data'] as List?;
    return data?.map((e) => Lead.fromJson(e)).toList() ?? [];
  }

  Future<void> updateLeadDetails(String id, Map<String, dynamic> data) async {
    // React uses: PUT /leads/update-lead-by-salesperson/${leadId}
    await _apiClient.put('${AppEndpoints.updateBySalesperson}/$id', data: data);
  }

  Future<void> updateSalespersonDisposition(Map<String, dynamic> payload) async {
    // React uses: PUT /leads/update-by-salesperson
    await _apiClient.put(AppEndpoints.updateBySalesperson, data: payload);
  }

  Future<void> deleteLead(String id) async {
    // React uses: DELETE /leads/${id}
    await _apiClient.delete('${AppEndpoints.updateLead}/$id');
  }
}
