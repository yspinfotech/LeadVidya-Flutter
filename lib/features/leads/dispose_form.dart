import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/leads_service.dart';
import '../../core/api/api_client.dart';

class DisposeForm extends StatefulWidget {
  final String leadId;
  final VoidCallback onSuccess;

  const DisposeForm({super.key, required this.leadId, required this.onSuccess});

  @override
  State<DisposeForm> createState() => _DisposeFormState();
}

class _DisposeFormState extends State<DisposeForm> {
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedStatus = 'Connected';
  DateTime? _followUpDate;
  bool _isSubmitting = false;

  final List<String> _statuses = [
    'Connected',
    'Callback',
    'Interested',
    'Not Interested',
    'Follow up',
    'Demo Booked',
    'Demo Completed',
    'Enrolled',
    'Wrong Number',
    'No Answer',
    'Busy',
    'Switch Off',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStatus.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ApiClient();
      final leadsService = LeadsService(apiClient);

      final payload = {
        'leadId': widget.leadId,
        'status': _selectedStatus,
        'note_desc': _notesController.text,
        'contacted': true,
        if (_followUpDate != null) 'followupdate': _followUpDate!.toIso8601String(),
        if (_amountController.text.isNotEmpty) 'enrolledAmount': _amountController.text,
      };

      await leadsService.updateSalespersonDisposition(payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disposition logged correctly'), backgroundColor: AppTheme.success),
        );
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log disposition')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lead Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildStatusPicker(),
          const SizedBox(height: 24),
          const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Enter call notes...'),
          ),
          if (_selectedStatus == 'Enrolled') ...[
            const SizedBox(height: 24),
            const Text('Enrollment Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 5000'),
            ),
          ],
          const SizedBox(height: 24),
          _buildDatePicker(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: _isSubmitting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('SUBMIT DISPOSITION'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return FilterChip(
          label: Text(status),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedStatus = status),
          selectedColor: AppTheme.primary.withOpacity(0.2),
          checkmarkColor: AppTheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? AppTheme.primary : Colors.white10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Follow-up Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _followUpDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text(
                  _followUpDate == null 
                    ? 'Select Date' 
                    : '${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}',
                  style: TextStyle(color: _followUpDate == null ? AppTheme.textSecondary : Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
