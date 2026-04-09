import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../services/campaign_service.dart';

final campaignServiceProvider = Provider<CampaignService>((ref) {
  final apiClient = ApiClient(); // In a real app, this should probably be provided
  return CampaignService(apiClient);
});

// For better state management, we could add a CampaignsNotifier here later if needed
