import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/call_log_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CallLogItem extends StatelessWidget {
  final CallLogModel item;
  final int simCount;
  final bool isLeadLog;
  final Function(CallLogModel)? onAddLead;
  final Function(CallLogModel)? onAssignSelf;

  const CallLogItem({
    super.key,
    required this.item,
    this.simCount = 1,
    this.isLeadLog = false,
    this.onAddLead,
    this.onAssignSelf,
  });

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0s';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('hh:mm a').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, hh:mm a').format(date);
    }
  }

  IconData _getTypeIcon(CallType type) {
    switch (type) {
      case CallType.incoming: return Icons.call_received_rounded;
      case CallType.outgoing: return Icons.call_made_rounded;
      case CallType.missed: return Icons.call_missed_rounded;
      case CallType.rejected: return Icons.call_missed_outgoing_rounded;
      default: return Icons.call_rounded;
    }
  }

  Color _getTypeColor(CallType type) {
    switch (type) {
      case CallType.incoming: return AppTheme.success;
      case CallType.outgoing: return AppTheme.primary;
      case CallType.missed: return AppTheme.danger;
      case CallType.rejected: return AppTheme.textSecondary;
      default: return AppTheme.textMuted;
    }
  }

  void _handleCopy() {
    if (item.phoneNumber != null) {
      Clipboard.setData(ClipboardData(text: item.phoneNumber!));
    }
  }

  void _handleWhatsApp() async {
    if (item.phoneNumber == null) return;
    final clean = item.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('whatsapp://send?phone=$clean');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(item.type);
    final isMyLead = item.isMyCall || (item.leadId != null && !item.isAssignedToOther);

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      color: Colors.white,
      border: Border.all(color: AppTheme.border, width: 1),
      child: InkWell(
        onTap: () {}, // TODO: Navigate to Lead Details
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar section
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isMyLead ? AppTheme.primary.withOpacity(0.1) : AppTheme.divider,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isMyLead ? Icons.person_rounded : (item.canAssignSelf ? Icons.person_add_alt_1_rounded : Icons.person_outline_rounded),
                            color: isMyLead ? AppTheme.primary : AppTheme.textMuted,
                            size: 24,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(_getTypeIcon(item.type), color: Colors.white, size: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.leadName ?? item.phoneNumber ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (simCount > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(4)),
                                child: Text('SIM ${item.simSlot + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(item.phoneNumber ?? 'No number', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(_formatTime(item.timestamp), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(width: 8),
                            Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppTheme.divider, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(_formatDuration(item.duration), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(width: 8),
                            Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppTheme.divider, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(item.type.name.toUpperCase(), style: TextStyle(fontSize: 11, color: typeColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppTheme.divider),
              ),
              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ownership Tag
                  _buildTag(item),
                  // Quick Actions
                  Row(
                    children: [
                      if (!isLeadLog && !isMyLead && !item.isAssignedToOther && !item.canAssignSelf)
                        _buildActionIcon(Icons.person_add_alt_1_rounded, AppTheme.primary, onAddLead != null ? () => onAddLead!(item) : null),
                      if (item.canAssignSelf)
                        _buildActionIcon(Icons.how_to_reg_rounded, AppTheme.warning, onAssignSelf != null ? () => onAssignSelf!(item) : null),
                      _buildActionIcon(Icons.copy_rounded, AppTheme.textSecondary, _handleCopy),
                      _buildActionIcon(Icons.chat_bubble_outline_rounded, const Color(0xFF25D366), _handleWhatsApp),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(CallLogModel item) {
    String text = 'New Contact';
    Color color = AppTheme.primary;
    
    if (item.isMyCall) {
      text = item.ownerName ?? 'Me';
      color = AppTheme.success;
    } else if (item.isAssignedToOther) {
      text = 'Assigned: ${item.assignedToName ?? "Other"}';
      color = AppTheme.textSecondary;
    } else if (item.canAssignSelf) {
      text = 'UNASSIGNED • CLAIM';
      color = AppTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppTheme.divider, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
