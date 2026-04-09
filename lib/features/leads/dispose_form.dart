import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/leads_service.dart';
import '../../core/api/api_client.dart';
import '../../core/widgets/glass_card.dart';
import 'package:intl/intl.dart';

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
  String _selectedStatus = '';
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _demoDateTime;
  bool _isSubmitting = false;
  bool? _isConnected;

  final List<String> _statuses = [
    'Busy', 'Callback', 'Connected', 'Interested', 'Not Interested',
    'Follow up', 'Demo Booked', 'Demo Completed', 'Demo Rescheduled',
    'Enrolled', 'Wrong Number', 'No Answer', 'Switch Off'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _showDemoPicker => ['Demo Booked', 'Demo Completed', 'Demo Rescheduled'].contains(_selectedStatus);
  bool get _showAmountField => _selectedStatus == 'Enrolled';

  Future<void> _submit() async {
    if (_isConnected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select if call was connected')));
      return;
    }
    if (_selectedStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a status')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ApiClient();
      final leadsService = LeadsService(apiClient);

      final payload = {
        'leadId': widget.leadId,
        'status': _selectedStatus,
        'note_desc': _notesController.text,
        'contacted': _isConnected,
        'followupdate': _followUpDate.toIso8601String(),
        if (_showAmountField) 'enrolledAmount': _amountController.text,
        if (_showDemoPicker && _demoDateTime != null) 'demoDateTime': _demoDateTime!.toIso8601String(),
      };

      await leadsService.updateSalespersonDisposition(payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disposition logged successfully'), backgroundColor: AppTheme.success),
        );
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to log disposition')));
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
          _buildConnectionToggle(),
          const SizedBox(height: 24),
          const Text('Select Lead Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _buildStatusPicker(),
          if (_showDemoPicker) ...[
            const SizedBox(height: 24),
            _buildDemoDateTimePicker(),
          ],
          if (_showAmountField) ...[
            const SizedBox(height: 24),
            const Text('Enrollment Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 5000',
                prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divider)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Follow-up Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _buildDatePicker(
            date: _followUpDate,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _followUpDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _followUpDate = date);
            },
          ),
          const SizedBox(height: 24),
          const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add a detailed note about the call...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.divider)),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('SUBMIT DISPOSITION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Was the call connected?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildToggleOption(true, 'Yes, Connected', Icons.phone_callback_rounded, AppTheme.success),
            const SizedBox(width: 12),
            _buildToggleOption(false, 'No', Icons.phone_disabled_rounded, AppTheme.danger),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleOption(bool value, String label, IconData icon, Color color) {
    final isSelected = _isConnected == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _isConnected = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : AppTheme.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppTheme.textMuted),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? color : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
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
            color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDemoDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Demo Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        _buildDatePicker(
          date: _demoDateTime ?? DateTime.now().add(const Duration(hours: 1)),
          label: _demoDateTime == null ? 'Select Demo Date/Time' : DateFormat('MMM dd, hh:mm a').format(_demoDateTime!),
          onTap: () async {
            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
            if (date != null) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (time != null) {
                setState(() => _demoDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker({required DateTime date, String? label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.primary),
            const SizedBox(width: 12),
            Text(label ?? DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
