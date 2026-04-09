import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

class CampaignService {
  final ApiClient _apiClient;

  CampaignService(this._apiClient);

  Future<dynamic> getCampaigns({int page = 1, int limit = 10, String? search}) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    final response = await _apiClient.get(AppEndpoints.campaigns, queryParameters: params);
    return response.data;
  }
}
