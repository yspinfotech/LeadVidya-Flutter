import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/campaign_service.dart';
import '../../core/api/api_client.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  late CampaignService _campaignService;
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _campaignService = CampaignService(ApiClient());
    _loadCampaigns();
  }

  Future<void> _loadCampaigns({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final data = await _campaignService.getCampaigns(search: search);
      setState(() {
        _campaigns = data['campaigns'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      _loadCampaigns();
                    })
                  : null,
              ),
              onSubmitted: (val) => _loadCampaigns(search: val),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _campaigns.isEmpty 
                  ? const Center(child: Text('No campaigns found', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = _campaigns[index];
                        return _buildCampaignCard(campaign);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(dynamic campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign['name'] ?? 'Unnamed Campaign',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${campaign['assignedCount'] ?? 0} leads assigned',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        ],
      ),
    );
  }
}
