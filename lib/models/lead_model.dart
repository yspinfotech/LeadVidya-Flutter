import 'dart:convert';

class Lead {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? phone;
  final String? altPhone;
  final String? leadSource;
  final String? status;
  final dynamic assignedTo;
  final String? expectedValue;
  final DateTime? lastContactedDate;
  final DateTime? nextFollowupDate;
  final String? city;
  final String? tag;
  final String? campaignName;
  final Map<String, dynamic>? campaign;
  final DateTime? createdAt;

  Lead({
    required this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.phone,
    this.altPhone,
    this.leadSource,
    this.status,
    this.assignedTo,
    this.expectedValue,
    this.lastContactedDate,
    this.nextFollowupDate,
    this.city,
    this.tag,
    this.campaignName,
    this.campaign,
    this.createdAt,
  });

  String get displayName => name ?? '${firstName ?? ""} ${lastName ?? ""}'.trim();
  String get displayPhone => phone ?? "";
  String get displayStatus => status ?? "New";

  factory Lead.fromJson(Map<String, dynamic> json) {
    // Handle assignedTo which can be string or object
    dynamic assigned = json['assigned_to'] ?? json['assignedUser'];
    
    return Lead(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'] ?? json['number'],
      altPhone: json['alt_phone'] ?? json['alternateNumber'],
      leadSource: json['leadSource'],
      status: json['status'] ?? json['leadStatus'],
      assignedTo: assigned,
      expectedValue: json['expectedValue']?.toString(),
      lastContactedDate: json['last_contacted_date'] != null 
          ? DateTime.tryParse(json['last_contacted_date']) 
          : null,
      nextFollowupDate: json['next_followup_date'] != null 
          ? DateTime.tryParse(json['next_followup_date']) 
          : (json['followUpDate'] != null ? DateTime.tryParse(json['followUpDate']) : null),
      city: json['city'],
      tag: json['tag'],
      campaignName: json['campaignName'] ?? (json['campaign'] != null ? json['campaign']['name'] : null),
      campaign: json['campaign'],
      createdAt: json['createdAt'] != null || json['created'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phone': phone,
      'alt_phone': altPhone,
      'leadStatus': status,
      'city': city,
      // Add other fields as needed
    };
  }
}
