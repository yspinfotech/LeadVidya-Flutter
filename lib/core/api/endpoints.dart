class AppEndpoints {
  static const String baseUrl = 'https://connect.leadvidya.in/api';

  // Auth
  static const String login = '/auth/login';
  static const String profile = '/users/current/profile';
  static const String health = '/health';
 
  // Leads
  static const String assignedLeads = '/leads/assigned';
  static const String newLeads = '/leads/newleads';
  static const String inProgressLeads = '/leads/inprogressleads';
  static const String leadsByStatus = '/leads/leadsbystatus';
  static const String getLeadById = '/leads/getLeadbyid';
  static const String createAndAssignLead = '/leads/create-and-assign';
  static const String assignSelf = '/leads/assign-self';
  static const String checkPhone = '/leads/check-phone';
  static const String checkAndGive = '/leads/checkandgive';
  static const String updateLead = '/leads/update';
  static const String updateLeadBySalesperson = '/leads/update-lead-by-salesperson';
  static const String updateBySalesperson = '/leads/update-by-salesperson';
  static const String updateLeadStatus = '/leads/update-status';
  static const String deleteLead = '/leads/delete';

  // Calls
  static const String calls = '/calls';
  static const String callLogs = '/calls/sales/call-logs';
  static const String leadTimeline = '/calls/lead-timeline';
  static const String logCall = '/calls/log';
  static const String callReports = '/calls/reports';

  // Campaigns
  static const String campaigns = '/campaigns';

  // Notifications
  static const String urgentNotifications = '/notifications/urgent';
  static const String notificationCount = '/notifications/count';
  static const String myFollowUps = '/notifications/my-followups';
  static const String completeNotification = '/notifications/{leadId}/complete';
  static const String readNotification = '/notifications/{leadId}/read';
  static const String snoozeNotification = '/notifications/{leadId}/snooze';
  static const String registerToken = '/notifications/register-token';

  // App
  static const String versionCheck = '/app/version-check';
  static const String syncLogs = '/logs/sync';
}
