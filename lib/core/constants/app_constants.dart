// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   // static const String baseUrl = 'http://10.131.0.2:5430';
//   static const String baseUrl = 'https://attendance.milkmatrix.com';
//   static const String apiVersion = '/api';

//   // Auth
//   static const String registerEndpoint = '/auth/register';
//   static const String loginEndpoint = '/auth/login';
//   static const String logoutEndpoint = '/auth/logout';
//   static const String clearDeviceEndpoint = '/auth/cleardevice';
//   static const String getAllUsersEndpoint = '/auth/users';

//   // Roles
//   static const String getRolesEndpoint = '/Role';

//   // Attendance
//   static const String markInEndpoint = '/attendance/markin';
//   static const String markOutEndpoint = '/attendance/markout';
//   static const String userSummaryEndpoint = '/attendance/usersummary';
//   static const String adminSummaryEndpoint = '/attendance/adminsummary';
//   static const String exportAdminSummaryEndpoint =
//       '/attendance/exportadminsummary';

//   // Holiday ← ADD
//   static const String holidayEndpoint = '/Holiday';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey = 'jwt_token';
//   static const String userIdKey = 'user_id';
//   static const String userNameKey = 'user_name';
//   static const String userEmailKey = 'user_email';
//   static const String userRoleKey = 'user_role';
//   static const String deviceIdKey = 'device_id';

//   // =================== ROLES ===================
//   static const String roleAdmin = 'admin';
//   static const String roleManager = 'manager';
//   static const String roleSupervisor = 'supervisor';
//   static const String roleDeveloper = 'developer';
//   static const String roleTester = 'tester';
//   static const String roleHR = 'hr';
//   static const String roleEmployee = 'employee';

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
//   static const int maxSelfieSizeKB = 500;
// }






// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   // static const String baseUrl = 'http://10.131.0.2:5430';
//   static const String baseUrl = 'https://attendance.milkmatrix.com';
//   static const String apiVersion = '/api';

//   // Auth
//   static const String registerEndpoint = '/auth/register';
//   static const String loginEndpoint = '/auth/login';
//   static const String logoutEndpoint = '/auth/logout';
//   static const String clearDeviceEndpoint = '/auth/cleardevice';
//   static const String getAllUsersEndpoint = '/auth/users';

//   // Roles
//   static const String getRolesEndpoint = '/Role';

//   // Attendance
//   static const String markInEndpoint = '/attendance/markin';
//   static const String markOutEndpoint = '/attendance/markout';
//   static const String userSummaryEndpoint = '/attendance/usersummary';
//   static const String adminSummaryEndpoint = '/attendance/adminsummary';
//   static const String exportAdminSummaryEndpoint =
//       '/attendance/exportadminsummary';

//   // Holiday
//   static const String holidayEndpoint = '/Holiday';

//   // ✅ Profile
//   static const String profileEndpoint = '/Profile';
//   static const String profileByIdEndpoint = '/Profile/{userId}';
//   static const String profileAllEndpoint = '/Profile/all';
//   static const String profilePhotoEndpoint = '/Profile/photo';
//   static const String profileChangePasswordEndpoint = '/Profile/changepassword';

//   // Performance
//   static const String performanceScoreEndpoint = '/Performance/employeescore';
//   static const String performanceReviewEndpoint = '/Performance/review';
//   static const String performanceRankingEndpoint = '/Performance/ranking';
//   static const String performanceReviewsEndpoint = '/Performance/reviews';

//   // WFH
//   static const String wfhRequestEndpoint = '/WFH/request';
//   static const String wfhMyRequestsEndpoint = '/WFH/myrequests';
//   static const String wfhSummaryEndpoint = '/WFH/summary';
//   static const String wfhApproveEndpoint = '/WFH/approve';
//   static const String wfhAllEndpoint = '/WFH/all';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey = 'jwt_token';
//   static const String userIdKey = 'user_id';
//   static const String userNameKey = 'user_name';
//   static const String userEmailKey = 'user_email';
//   static const String userRoleKey = 'user_role';
//   static const String deviceIdKey = 'device_id';

//   // =================== ROLES ===================
//   static const String roleAdmin = 'admin';
//   static const String roleManager = 'manager';
//   static const String roleSupervisor = 'supervisor';
//   static const String roleDeveloper = 'developer';
//   static const String roleTester = 'tester';
//   static const String roleHR = 'hr';
//   static const String roleEmployee = 'employee';

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
//   static const int maxSelfieSizeKB = 500;
// }






// // lib/core/constants/app_constants.dart
// class AppConstants {
//   // =================== API ===================
//   // static const String baseUrl = 'http://10.131.0.2:5430';
//   static const String baseUrl = 'https://attendance.milkmatrix.com';
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

//   // ✅ Help & Support
//   static const String helpFaqsEndpoint        = '/HelpSupport/faqs';
//   static const String helpContactEndpoint     = '/HelpSupport/contact';
//   static const String helpContactMsgsEndpoint = '/HelpSupport/contact/messages';
//   static const String helpContactResolveEndpoint = '/HelpSupport/contact/resolve';

//   // =================== STORAGE KEYS ===================
//   static const String tokenKey    = 'jwt_token';
//   static const String userIdKey   = 'user_id';
//   static const String userNameKey = 'user_name';
//   static const String userEmailKey= 'user_email';
//   static const String userRoleKey = 'user_role';
//   static const String deviceIdKey = 'device_id';

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
//   // static const String baseUrl = 'http://10.131.0.2:5430';
//   static const String baseUrl = 'https://attendance.milkmatrix.com';
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

//   // ✅ Leave
//   static const String leaveApplyEndpoint  = '/Leave/apply';
//   static const String leaveMyEndpoint     = '/Leave/my';
//   static const String leaveAllEndpoint    = '/Leave/all';
//   static const String leaveActionEndpoint = '/Leave/action';
//   static const String leaveCancelEndpoint = '/Leave/cancel';

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






// lib/core/constants/app_constants.dart
class AppConstants {
  // =================== API ===================
  // static const String baseUrl = 'http://10.131.0.2:5430';
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

  // ✅ Daily Task
  static const String dailyTaskAddEndpoint      = '/DailyTask/add';
  static const String dailyTaskUpdateEndpoint   = '/DailyTask/update';
  static const String dailyTaskDeleteEndpoint   = '/DailyTask/delete';
  static const String dailyTaskMyEndpoint       = '/DailyTask/my';
  static const String dailyTaskMyTodayEndpoint  = '/DailyTask/my/today';
  static const String dailyTaskAllEndpoint      = '/DailyTask/all';
  static const String dailyTaskAllTodayEndpoint = '/DailyTask/all/today';

  // Location endpoints
  static const String locationCheckinEndpoint  = '/Location/checkin';
  static const String locationCheckoutEndpoint = '/Location/checkout';
  static const String locationMyTodayEndpoint  = '/Location/my/today';
  static const String locationMyHistoryEndpoint = '/Location/my/history';
  static const String locationAllEndpoint      = '/Location/all';
  static const String locationAllTodayEndpoint = '/Location/all/today';

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
    roleAdmin,
    roleManager,
    roleSupervisor,
    roleDeveloper,
    roleTester,
    roleHR,
    roleEmployee,
  ];

  // =================== TIMEOUTS ===================
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // =================== VALIDATION ===================
  static const int maxDateRangeDays = 31;
  static const int maxSelfieSizeKB  = 500;
}