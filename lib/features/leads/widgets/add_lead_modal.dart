import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/campaign_service.dart';
import '../../campaigns/campaigns_provider.dart';
import '../leads_provider.dart';

class AddLeadModal extends ConsumerStatefulWidget {
  final String phoneNumber;
  final VoidCallback onSuccess;

  const AddLeadModal({
    super.key,
    required this.phoneNumber,
    required this.onSuccess,
  });

  @override
  ConsumerState<AddLeadModal> createState() => _AddLeadModalState();
}

class _AddLeadModalState extends ConsumerState<AddLeadModal> {
  final _firstNameController = TextEditingController();
  final _searchController = TextEditingController();
  String? _selectedCampaignId;
  String? _selectedCampaignName;
  
  List<dynamic> _campaigns = [];
  bool _isLoadingCampaigns = false;
  bool _isSaving = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns({bool isNextPage = false}) async {
    if (_isLoadingCampaigns || (!isNextPage && _campaigns.isNotEmpty)) return;
    
    setState(() => _isLoadingCampaigns = true);
    try {
      final service = ref.read(campaignServiceProvider);
      final response = await service.getCampaigns(
        page: isNextPage ? _page + 1 : 1,
        search: _searchController.text,
      );
      
      final List newItems = response['data'] ?? [];
      setState(() {
        if (isNextPage) {
          _campaigns.addAll(newItems);
          _page++;
        } else {
          _campaigns = newItems;
          _page = 1;
        }
        _hasMore = newItems.length == 10;
        _isLoadingCampaigns = false;
      });
    } catch (e) {
      setState(() => _isLoadingCampaigns = false);
    }
  }

  Future<void> _handleSave() async {
    if (_firstNameController.text.isEmpty || _selectedCampaignId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final success = await ref.read(leadsServiceProvider).createLead({
        'firstName': _firstNameController.text,
        'lastName': ' ',
        'campaign': _selectedCampaignId,
        'phone': widget.phoneNumber,
      });

      if (success) {
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create lead. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhoneDisplay(),
                  const SizedBox(height: 24),
                  _buildLabel('FIRST NAME *'),
                  _buildTextField(_firstNameController, 'Enter first name'),
                  const SizedBox(height: 24),
                  _buildLabel('SELECT CAMPAIGN *'),
                  _buildCampaignSelector(),
                  const SizedBox(height: 32),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add New Lead',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_iphone_rounded, color: AppTheme.primaryDark, size: 20),
          const SizedBox(width: 12),
          const Text('Phone:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            widget.phoneNumber,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.border)),
      ),
    );
  }

  Widget _buildCampaignSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _fetchCampaigns(),
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: _campaigns.isEmpty && _isLoadingCampaigns
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _campaigns.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _campaigns.length) {
                        _fetchCampaigns(isNextPage: true);
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final c = _campaigns[index];
                      final isSelected = _selectedCampaignId == c['_id'];
                      return ListTile(
                        onTap: () => setState(() {
                          _selectedCampaignId = c['_id'];
                          _selectedCampaignName = c['name'];
                        }),
                        title: Text(c['name'], style: TextStyle(fontSize: 14, color: isSelected ? AppTheme.primary : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20) : null,
                        dense: true,
                        tileColor: isSelected ? AppTheme.primary.withOpacity(0.05) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.border)),
            ),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.check_circle_outline_rounded, color: Colors.black),
            label: const Text('Save Lead', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
