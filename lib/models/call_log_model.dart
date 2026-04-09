enum CallType { incoming, outgoing, missed, rejected, unknown }

class CallLogModel {
  final String id;
  final String? phoneNumber;
  final String? leadName;
  final String? leadId;
  final int timestamp;
  final int duration;
  final CallType type;
  final bool isMyCall;
  final String? ownerName;
  final bool canAssignSelf;
  final bool isAssignedToOther;
  final String? assignedToName;
  final Map<String, dynamic>? leadData;
  final int simSlot;

  CallLogModel({
    required this.id,
    this.phoneNumber,
    this.leadName,
    this.leadId,
    required this.timestamp,
    required this.duration,
    required this.type,
    this.isMyCall = false,
    this.ownerName,
    this.canAssignSelf = false,
    this.isAssignedToOther = false,
    this.assignedToName,
    this.leadData,
    this.simSlot = 0,
  });

  factory CallLogModel.fromRemoteJson(Map<String, dynamic> json, String? currentUserId) {
    // Porting logic from React HistoryScreen.tsx:206-245
    final typeStr = (json['callType'] ?? 'UNKNOWN').toString().toUpperCase();
    final callType = _parseCallType(typeStr);
    
    // Ownership matching
    final assignedToName = json['leadAssignedPersonName'];
    final isMyCall = json['isMyCall'] ?? false; // Backend might provide this or we calculate

    return CallLogModel(
      id: json['_id'] ?? '${json['leadId']}-${json['callTime']}',
      phoneNumber: json['leadPhone'] ?? json['phoneNumber'],
      leadName: json['leadName'] ?? 'Unknown Lead',
      leadId: json['leadId'],
      timestamp: json['callTime'] != null 
          ? DateTime.parse(json['callTime']).millisecondsSinceEpoch 
          : DateTime.now().millisecondsSinceEpoch,
      duration: json['callDuration'] ?? json['durationSeconds'] ?? 0,
      type: callType,
      isMyCall: isMyCall,
      ownerName: isMyCall ? 'Me' : assignedToName,
      canAssignSelf: json['leadId'] != null && assignedToName == null,
      isAssignedToOther: assignedToName != null && !isMyCall,
      assignedToName: assignedToName,
      leadData: json['leadData'] ?? (json['leadId'] != null ? {
        '_id': json['leadId'],
        'firstName': json['leadName'],
        'phone': json['leadPhone'],
      } : null),
    );
  }

  static CallType _parseCallType(String type) {
    switch (type) {
      case 'INCOMING': return CallType.incoming;
      case 'OUTGOING': return CallType.outgoing;
      case 'MISSED': return CallType.missed;
      case 'REJECTED': return CallType.rejected;
      default: return CallType.unknown;
    }
  }
}
