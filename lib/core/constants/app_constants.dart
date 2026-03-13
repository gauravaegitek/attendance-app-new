// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   // static const String baseUrl = 'http://10.131.0.2:5430';
//   static const String baseUrl    = 'https://attendance.milkmatrix.com';
//   static const String apiVersion = '/api';

//   // Auth
//   static const String registerEndpoint    = '/auth/register';
//   static const String loginEndpoint       = '/auth/login';
//   static const String logoutEndpoint      = '/auth/logout';
//   static const String clearDeviceEndpoint = '/auth/cleardevice';
//   static const String getAllUsersEndpoint  = '/auth/users';

//   // Roles
//   static const String getRolesEndpoint = '/Role';

//   // Attendance
//   static const String markInEndpoint             = '/attendance/markin';
//   static const String markOutEndpoint            = '/attendance/markout';
//   static const String userSummaryEndpoint        = '/attendance/usersummary';
//   static const String adminSummaryEndpoint       = '/attendance/adminsummary';
//   static const String exportAdminSummaryEndpoint = '/attendance/exportadminsummary';

//   // Holiday
//   static const String holidayEndpoint = '/Holiday';

//   // Profile
//   static const String profileEndpoint               = '/Profile';
//   static const String profileByIdEndpoint           = '/Profile/{userId}';
//   static const String profileAllEndpoint            = '/Profile/all';
//   static const String profilePhotoEndpoint          = '/Profile/photo';
//   static const String profileChangePasswordEndpoint = '/Profile/changepassword';

//   // Performance
//   static const String performanceScoreEndpoint   = '/Performance/employeescore';
//   static const String performanceReviewEndpoint  = '/Performance/review';
//   static const String performanceRankingEndpoint = '/Performance/ranking';
//   static const String performanceReviewsEndpoint = '/Performance/reviews';

//   // WFH
//   static const String wfhRequestEndpoint    = '/WFH/request';
//   static const String wfhMyRequestsEndpoint = '/WFH/myrequests';
//   static const String wfhSummaryEndpoint    = '/WFH/summary';
//   static const String wfhApproveEndpoint    = '/WFH/approve';
//   static const String wfhAllEndpoint        = '/WFH/all';

//   // Help & Support
//   static const String helpFaqsEndpoint           = '/HelpSupport/faqs';
//   static const String helpContactEndpoint        = '/HelpSupport/contact';
//   static const String helpContactMsgsEndpoint    = '/HelpSupport/contact/messages';
//   static const String helpContactResolveEndpoint = '/HelpSupport/contact/resolve';

//   // Leave
//   static const String leaveApplyEndpoint  = '/Leave/apply';
//   static const String leaveMyEndpoint     = '/Leave/my';
//   static const String leaveAllEndpoint    = '/Leave/all';
//   static const String leaveActionEndpoint = '/Leave/action';
//   static const String leaveCancelEndpoint = '/Leave/cancel';

//   // ✅ Daily Task
//   static const String dailyTaskAddEndpoint      = '/DailyTask/add';
//   static const String dailyTaskUpdateEndpoint   = '/DailyTask/update';
//   static const String dailyTaskDeleteEndpoint   = '/DailyTask/delete';
//   static const String dailyTaskMyEndpoint       = '/DailyTask/my';
//   static const String dailyTaskMyTodayEndpoint  = '/DailyTask/my/today';
//   static const String dailyTaskAllEndpoint      = '/DailyTask/all';
//   static const String dailyTaskAllTodayEndpoint = '/DailyTask/all/today';


//   // ✅ Login History
//   static const String loginHistoryTodayEndpoint  = '/LoginHistory/today';
//   static const String loginHistoryMeEndpoint     = '/LoginHistory/me';
//   static const String loginHistoryUserEndpoint   = '/LoginHistory/user'; // + /{userId}

//     // ✅ Asset
//   static const String assetAddEndpoint     = '/Asset/add';
//   static const String assetAssignEndpoint  = '/Asset/assign';
//   static const String assetReturnEndpoint  = '/Asset/return';
//   static const String assetListEndpoint    = '/Asset/list';
//   static const String assetHistoryEndpoint = '/Asset/history';
//   static const String assetSummaryEndpoint = '/Asset/summary';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey     = 'jwt_token';
//   static const String userIdKey    = 'user_id';
//   static const String userNameKey  = 'user_name';
//   static const String userEmailKey = 'user_email';
//   static const String userRoleKey  = 'user_role';
//   static const String deviceIdKey  = 'device_id';

//   // =================== ROLES ===================
//   static const String roleAdmin      = 'admin';
//   static const String roleManager    = 'manager';
//   static const String roleSupervisor = 'supervisor';
//   static const String roleDeveloper  = 'developer';
//   static const String roleTester     = 'tester';
//   static const String roleHR         = 'hr';
//   static const String roleEmployee   = 'employee';

//   static const List<String> allRoles = [
//     roleAdmin,
//     roleManager,
//     roleSupervisor,
//     roleDeveloper,
//     roleTester,
//     roleHR,
//     roleEmployee,
//   ];

//   // =================== TIMEOUTS ===================
//   static const int connectTimeout = 30000;
//   static const int receiveTimeout = 30000;

//   // =================== VALIDATION ===================
//   static const int maxDateRangeDays = 31;
//   static const int maxSelfieSizeKB  = 500;
// }






// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   static const String baseUrl    = 'https://attendance.milkmatrix.com';
//   static const String apiVersion = '/api';

//   // Auth
//   static const String registerEndpoint    = '/auth/register';
//   static const String loginEndpoint       = '/auth/login';
//   static const String logoutEndpoint      = '/auth/logout';
//   static const String clearDeviceEndpoint = '/auth/cleardevice';
//   static const String getAllUsersEndpoint  = '/auth/users';

//   // Roles
//   static const String getRolesEndpoint = '/Role';

//   // Attendance
//   static const String markInEndpoint             = '/attendance/markin';
//   static const String markOutEndpoint            = '/attendance/markout';
//   static const String userSummaryEndpoint        = '/attendance/usersummary';
//   static const String adminSummaryEndpoint       = '/attendance/adminsummary';
//   static const String exportAdminSummaryEndpoint = '/attendance/exportadminsummary';

//   // Holiday
//   static const String holidayEndpoint = '/Holiday';

//   // Profile
//   static const String profileEndpoint               = '/Profile';
//   static const String profileByIdEndpoint           = '/Profile/{userId}';
//   static const String profileAllEndpoint            = '/Profile/all';
//   static const String profilePhotoEndpoint          = '/Profile/photo';
//   static const String profileChangePasswordEndpoint = '/Profile/changepassword';

//   // Performance
//   static const String performanceScoreEndpoint   = '/Performance/employeescore';
//   static const String performanceReviewEndpoint  = '/Performance/review';
//   static const String performanceRankingEndpoint = '/Performance/ranking';
//   static const String performanceReviewsEndpoint = '/Performance/reviews';

//   // WFH
//   static const String wfhRequestEndpoint    = '/WFH/request';
//   static const String wfhMyRequestsEndpoint = '/WFH/myrequests';
//   static const String wfhSummaryEndpoint    = '/WFH/summary';
//   static const String wfhApproveEndpoint    = '/WFH/approve';
//   static const String wfhAllEndpoint        = '/WFH/all';

//   // Help & Support
//   static const String helpFaqsEndpoint           = '/HelpSupport/faqs';
//   static const String helpContactEndpoint        = '/HelpSupport/contact';
//   static const String helpContactMsgsEndpoint    = '/HelpSupport/contact/messages';
//   static const String helpContactResolveEndpoint = '/HelpSupport/contact/resolve';

//   // Leave
//   static const String leaveApplyEndpoint  = '/Leave/apply';
//   static const String leaveMyEndpoint     = '/Leave/my';
//   static const String leaveAllEndpoint    = '/Leave/all';
//   static const String leaveActionEndpoint = '/Leave/action';
//   static const String leaveCancelEndpoint = '/Leave/cancel';

//   // Daily Task
//   static const String dailyTaskAddEndpoint      = '/DailyTask/add';
//   static const String dailyTaskUpdateEndpoint   = '/DailyTask/update';
//   static const String dailyTaskDeleteEndpoint   = '/DailyTask/delete';
//   static const String dailyTaskMyEndpoint       = '/DailyTask/my';
//   static const String dailyTaskMyTodayEndpoint  = '/DailyTask/my/today';
//   static const String dailyTaskAllEndpoint      = '/DailyTask/all';
//   static const String dailyTaskAllTodayEndpoint = '/DailyTask/all/today';

//   // Login History
//   static const String loginHistoryTodayEndpoint = '/LoginHistory/today';
//   static const String loginHistoryMeEndpoint    = '/LoginHistory/me';
//   static const String loginHistoryUserEndpoint  = '/LoginHistory/user';

//   // Asset
//   static const String assetAddEndpoint         = '/Asset/add';
//   static const String assetAssignEndpoint      = '/Asset/assign';
//   static const String assetReturnEndpoint      = '/Asset/return';
//   static const String assetListEndpoint        = '/Asset/list';
//   static const String assetHistoryEndpoint     = '/Asset/history';
//   static const String assetSummaryEndpoint     = '/Asset/summary';
//   static const String assetMaintenanceStartEndpoint    = '/Asset/maintenance/start';
//   static const String assetMaintenanceCompleteEndpoint = '/Asset/maintenance/complete';
//   static const String assetMaintenanceListEndpoint     = '/Asset/maintenance/list';
//   static const String assetMaintenanceHistoryEndpoint  = '/Asset/maintenance/history';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey     = 'jwt_token';
//   static const String userIdKey    = 'user_id';
//   static const String userNameKey  = 'user_name';
//   static const String userEmailKey = 'user_email';
//   static const String userRoleKey  = 'user_role';
//   static const String deviceIdKey  = 'device_id';

//   // =================== ROLES ===================
//   static const String roleAdmin      = 'admin';
//   static const String roleManager    = 'manager';
//   static const String roleSupervisor = 'supervisor';
//   static const String roleDeveloper  = 'developer';
//   static const String roleTester     = 'tester';
//   static const String roleHR         = 'hr';
//   static const String roleEmployee   = 'employee';

//   static const List<String> allRoles = [
//     roleAdmin, roleManager, roleSupervisor,
//     roleDeveloper, roleTester, roleHR, roleEmployee,
//   ];

//   // =================== TIMEOUTS ===================
//   static const int connectTimeout = 30000;
//   static const int receiveTimeout = 30000;

//   // =================== VALIDATION ===================
//   static const int maxDateRangeDays = 31;
//   static const int maxSelfieSizeKB  = 500;
// }









// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   static const String baseUrl    = 'https://attendance.milkmatrix.com';
//   static const String apiVersion = '/api';

//   // Auth
//   static const String registerEndpoint    = '/auth/register';
//   static const String loginEndpoint       = '/auth/login';
//   static const String logoutEndpoint      = '/auth/logout';
//   static const String clearDeviceEndpoint = '/auth/cleardevice';
//   static const String getAllUsersEndpoint  = '/auth/users';

//   // Roles
//   static const String getRolesEndpoint = '/Role';

//   // Attendance
//   static const String markInEndpoint             = '/attendance/markin';
//   static const String markOutEndpoint            = '/attendance/markout';
//   static const String userSummaryEndpoint        = '/attendance/usersummary';
//   static const String adminSummaryEndpoint       = '/attendance/adminsummary';
//   static const String exportAdminSummaryEndpoint = '/attendance/exportadminsummary';

//   // Holiday
//   static const String holidayEndpoint = '/Holiday';

//   // Profile
//   static const String profileEndpoint               = '/Profile';
//   static const String profileByIdEndpoint           = '/Profile/{userId}';
//   static const String profileAllEndpoint            = '/Profile/all';
//   static const String profilePhotoEndpoint          = '/Profile/photo';
//   static const String profileChangePasswordEndpoint = '/Profile/changepassword';

//   // Performance
//   static const String performanceScoreEndpoint   = '/Performance/employeescore';
//   static const String performanceReviewEndpoint  = '/Performance/review';
//   static const String performanceRankingEndpoint = '/Performance/ranking';
//   static const String performanceReviewsEndpoint = '/Performance/reviews';

//   // WFH
//   static const String wfhRequestEndpoint    = '/WFH/request';
//   static const String wfhMyRequestsEndpoint = '/WFH/myrequests';
//   static const String wfhSummaryEndpoint    = '/WFH/summary';
//   static const String wfhApproveEndpoint    = '/WFH/approve';
//   static const String wfhAllEndpoint        = '/WFH/all';

//   // Help & Support
//   static const String helpFaqsEndpoint           = '/HelpSupport/faqs';
//   static const String helpContactEndpoint        = '/HelpSupport/contact';
//   static const String helpContactMsgsEndpoint    = '/HelpSupport/contact/messages';
//   static const String helpContactResolveEndpoint = '/HelpSupport/contact/resolve';

//   // Leave
//   static const String leaveApplyEndpoint  = '/Leave/apply';
//   static const String leaveMyEndpoint     = '/Leave/my';
//   static const String leaveAllEndpoint    = '/Leave/all';
//   static const String leaveActionEndpoint = '/Leave/action';
//   static const String leaveCancelEndpoint = '/Leave/cancel';

//   // Daily Task
//   static const String dailyTaskAddEndpoint      = '/DailyTask/add';
//   static const String dailyTaskUpdateEndpoint   = '/DailyTask/update';
//   static const String dailyTaskDeleteEndpoint   = '/DailyTask/delete';
//   static const String dailyTaskMyEndpoint       = '/DailyTask/my';
//   static const String dailyTaskMyTodayEndpoint  = '/DailyTask/my/today';
//   static const String dailyTaskAllEndpoint      = '/DailyTask/all';
//   static const String dailyTaskAllTodayEndpoint = '/DailyTask/all/today';

//   // Login History
//   static const String loginHistoryTodayEndpoint = '/LoginHistory/today';
//   static const String loginHistoryMeEndpoint    = '/LoginHistory/me';
//   static const String loginHistoryUserEndpoint  = '/LoginHistory/user';

//   // Asset
//   static const String assetAddEndpoint                     = '/Asset/add';
//   static const String assetAssignEndpoint                  = '/Asset/assign';
//   static const String assetReturnEndpoint                  = '/Asset/return';
//   static const String assetListEndpoint                    = '/Asset/list';
//   static const String assetHistoryEndpoint                 = '/Asset/history';
//   static const String assetSummaryEndpoint                 = '/Asset/summary';
//   static const String assetMaintenanceStartEndpoint        = '/Asset/maintenance/start';
//   static const String assetMaintenanceCompleteEndpoint     = '/Asset/maintenance/complete';
//   static const String assetMaintenanceListEndpoint         = '/Asset/maintenance/list';
//   static const String assetMaintenanceHistoryEndpoint      = '/Asset/maintenance/history';

//   // Document                                                // ✅ NEW
//   static const String documentUploadEndpoint   = '/Document/upload';
//   static const String documentListEndpoint     = '/Document/list';
//   static const String documentDownloadEndpoint = '/Document/download-pdf';
//   static const String documentRemoveEndpoint   = '/Document/remove';
//   static const String documentVerifyEndpoint   = '/Document/verify';
//   static const String documentSummaryEndpoint  = '/Document/summary';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey     = 'jwt_token';
//   static const String userIdKey    = 'user_id';
//   static const String userNameKey  = 'user_name';
//   static const String userEmailKey = 'user_email';
//   static const String userRoleKey  = 'user_role';
//   static const String deviceIdKey  = 'device_id';

//   // =================== ROLES ===================
//   static const String roleAdmin      = 'admin';
//   static const String roleManager    = 'manager';
//   static const String roleSupervisor = 'supervisor';
//   static const String roleDeveloper  = 'developer';
//   static const String roleTester     = 'tester';
//   static const String roleHR         = 'hr';
//   static const String roleEmployee   = 'employee';

//   static const List<String> allRoles = [
//     roleAdmin, roleManager, roleSupervisor,
//     roleDeveloper, roleTester, roleHR, roleEmployee,
//   ];

//   // =================== TIMEOUTS ===================
//   static const int connectTimeout = 30000;
//   static const int receiveTimeout = 30000;

//   // =================== VALIDATION ===================
//   static const int maxDateRangeDays = 31;
//   static const int maxSelfieSizeKB  = 500;
// }











// lib/core/constants/app_constants.dart
class AppConstants {
  // =================== API ===================
  static const String baseUrl    = 'https://attendance.milkmatrix.com';
  static const String apiVersion = '/api';

  // Auth
  static const String registerEndpoint    = '/auth/register';
  static const String loginEndpoint       = '/auth/login';
  static const String logoutEndpoint      = '/auth/logout';
  static const String clearDeviceEndpoint = '/auth/cleardevice';
  static const String getAllUsersEndpoint  = '/auth/users';

  // Roles
  static const String getRolesEndpoint = '/Role';

  // Attendance
  static const String markInEndpoint             = '/attendance/markin';
  static const String markOutEndpoint            = '/attendance/markout';
  static const String userSummaryEndpoint        = '/attendance/usersummary';
  static const String adminSummaryEndpoint       = '/attendance/adminsummary';
  static const String exportAdminSummaryEndpoint = '/attendance/exportadminsummary';

  // Holiday
  static const String holidayEndpoint = '/Holiday';

  // Profile
  static const String profileEndpoint               = '/Profile';
  static const String profileByIdEndpoint           = '/Profile/{userId}';
  static const String profileAllEndpoint            = '/Profile/all';
  static const String profilePhotoEndpoint          = '/Profile/photo';
  static const String profileChangePasswordEndpoint = '/Profile/changepassword';

  // Performance
  static const String performanceScoreEndpoint   = '/Performance/employeescore';
  static const String performanceReviewEndpoint  = '/Performance/review';
  static const String performanceRankingEndpoint = '/Performance/ranking';
  static const String performanceReviewsEndpoint = '/Performance/reviews';

  // WFH
  static const String wfhRequestEndpoint    = '/WFH/request';
  static const String wfhMyRequestsEndpoint = '/WFH/myrequests';
  static const String wfhSummaryEndpoint    = '/WFH/summary';
  static const String wfhApproveEndpoint    = '/WFH/approve';
  static const String wfhAllEndpoint        = '/WFH/all';

  // Help & Support
  static const String helpFaqsEndpoint           = '/HelpSupport/faqs';
  static const String helpContactEndpoint        = '/HelpSupport/contact';
  static const String helpContactMsgsEndpoint    = '/HelpSupport/contact/messages';
  static const String helpContactResolveEndpoint = '/HelpSupport/contact/resolve';

  // Leave
  static const String leaveApplyEndpoint  = '/Leave/apply';
  static const String leaveMyEndpoint     = '/Leave/my';
  static const String leaveAllEndpoint    = '/Leave/all';
  static const String leaveActionEndpoint = '/Leave/action';
  static const String leaveCancelEndpoint = '/Leave/cancel';

  // Daily Task
  static const String dailyTaskAddEndpoint      = '/DailyTask/add';
  static const String dailyTaskUpdateEndpoint   = '/DailyTask/update';
  static const String dailyTaskDeleteEndpoint   = '/DailyTask/delete';
  static const String dailyTaskMyEndpoint       = '/DailyTask/my';
  static const String dailyTaskMyTodayEndpoint  = '/DailyTask/my/today';
  static const String dailyTaskAllEndpoint      = '/DailyTask/all';
  static const String dailyTaskAllTodayEndpoint = '/DailyTask/all/today';

  // Login History
  static const String loginHistoryTodayEndpoint = '/LoginHistory/today';
  static const String loginHistoryMeEndpoint    = '/LoginHistory/me';
  static const String loginHistoryUserEndpoint  = '/LoginHistory/user';

  // Asset
  static const String assetAddEndpoint                 = '/Asset/add';
  static const String assetAssignEndpoint              = '/Asset/assign';
  static const String assetReturnEndpoint              = '/Asset/return';
  static const String assetListEndpoint                = '/Asset/list';
  static const String assetHistoryEndpoint             = '/Asset/history';
  static const String assetSummaryEndpoint             = '/Asset/summary';
  static const String assetMaintenanceStartEndpoint    = '/Asset/maintenance/start';
  static const String assetMaintenanceCompleteEndpoint = '/Asset/maintenance/complete';
  static const String assetMaintenanceListEndpoint     = '/Asset/maintenance/list';
  static const String assetMaintenanceHistoryEndpoint  = '/Asset/maintenance/history';

  // Document
  static const String documentUploadEndpoint   = '/Document/upload';
  static const String documentListEndpoint     = '/Document/list';
  static const String documentDownloadEndpoint = '/Document/download-pdf';
  static const String documentRemoveEndpoint   = '/Document/remove';
  static const String documentVerifyEndpoint   = '/Document/verify';
  static const String documentSummaryEndpoint  = '/Document/summary';

  // ✅ Payroll
  static const String payrollCalculateEndpoint = '/Payroll/calculate';
  static const String payrollDeductionEndpoint = '/Payroll/deduction';
  static const String payrollApproveEndpoint   = '/Payroll/approve';
  static const String payrollMarkPaidEndpoint  = '/Payroll/markpaid';
  static const String payrollSlipEndpoint      = '/Payroll/slip';
  static const String payrollListEndpoint      = '/Payroll/list';

  // =================== STORAGE KEYS ===================
  static const String tokenKey     = 'jwt_token';
  static const String userIdKey    = 'user_id';
  static const String userNameKey  = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey  = 'user_role';
  static const String deviceIdKey  = 'device_id';

  // =================== ROLES ===================
  static const String roleAdmin      = 'admin';
  static const String roleManager    = 'manager';
  static const String roleSupervisor = 'supervisor';
  static const String roleDeveloper  = 'developer';
  static const String roleTester     = 'tester';
  static const String roleHR         = 'hr';
  static const String roleEmployee   = 'employee';

  static const List<String> allRoles = [
    roleAdmin, roleManager, roleSupervisor,
    roleDeveloper, roleTester, roleHR, roleEmployee,
  ];

  // =================== TIMEOUTS ===================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // =================== VALIDATION ===================
  static const int maxDateRangeDays = 31;
  static const int maxSelfieSizeKB  = 500;
}