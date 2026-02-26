// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/wfh_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart'; // ✅ ADD

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired'; // ✅ ADD

//   static List<GetPage> pages = [
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//       }),
//     ),
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ──────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────── ✅
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),
//   ];
// }



// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/wfh_controller.dart';
// import '../controllers/notification_controller.dart'; // ✅ ADD
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart';
// import '../screens/notification/notification_screen.dart'; // ✅ ADD

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired';
//   static const String notifications      = '/notifications'; // ✅ ADD

//   static List<GetPage> pages = [
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//         if (!Get.isRegistered<NotificationController>()) { // ✅ ADD
//           Get.put(NotificationController());               // ✅ ADD
//         }                                                  // ✅ ADD
//       }),
//     ),
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ──────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────────
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),

//     // ── Notifications ─────────────────────────────────────────────────── ✅
//     GetPage(
//       name: notifications,
//       page: () => const NotificationScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),
//   ];
// }








// // lib/core/routes.dart

// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/wfh_controller.dart';
// import '../controllers/notification_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart';
// import '../screens/notification/notification_screen.dart';
// import '../screens/help_support/help_support_screen.dart'; // ✅ ADD

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired';
//   static const String notifications      = '/notifications';
//   static const String helpSupport        = '/help-support'; // ✅ ADD

//   static List<GetPage> pages = [
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ──────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────────
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),

//     // ── Notifications ─────────────────────────────────────────────────────
//     GetPage(
//       name: notifications,
//       page: () => const NotificationScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),

//     // ── Help & Support ────────────────────────────────────────────────── ✅
//     GetPage(
//       name: helpSupport,
//       page: () => const HelpSupportScreen(),
//     ),
//   ];
// }











// // lib/core/routes.dart

// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/leave_controller.dart';           // ✅ ADD
// import '../controllers/wfh_controller.dart';
// import '../controllers/notification_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart';
// import '../screens/notification/notification_screen.dart';
// import '../screens/help_support/help_support_screen.dart';
// import '../screens/leave/leave_screen.dart';             // ✅ ADD

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired';
//   static const String notifications      = '/notifications';
//   static const String helpSupport        = '/help-support';
//   static const String leave              = '/leave';     // ✅ ADD

//   static List<GetPage> pages = [
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ──────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────────
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),

//     // ── Notifications ─────────────────────────────────────────────────────
//     GetPage(
//       name: notifications,
//       page: () => const NotificationScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),

//     // ── Help & Support ────────────────────────────────────────────────────
//     GetPage(
//       name: helpSupport,
//       page: () => const HelpSupportScreen(),
//     ),

//     // ── Leave ─────────────────────────────────────────────────────── ✅ ADD
//     GetPage(
//       name: leave,
//       page: () => const LeaveScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<LeaveController>()) {
//           Get.put(LeaveController());
//         }
//       }),
//     ),
//   ];
// }




// // lib/core/routes.dart

// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/daily_task_controller.dart';      // ✅ ADD
// import '../controllers/leave_controller.dart';
// import '../controllers/wfh_controller.dart';
// import '../controllers/notification_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart';
// import '../screens/notification/notification_screen.dart';
// import '../screens/help_support/help_support_screen.dart';
// import '../screens/leave/leave_screen.dart';
// import '../screens/daily_task/daily_task_screen.dart';   // ✅ ADD

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired';
//   static const String notifications      = '/notifications';
//   static const String helpSupport        = '/help-support';
//   static const String leave              = '/leave';
//   static const String dailyTask          = '/daily-task';  // ✅ ADD

//   static List<GetPage> pages = [
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ──────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────────
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),

//     // ── Notifications ─────────────────────────────────────────────────────
//     GetPage(
//       name: notifications,
//       page: () => const NotificationScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),

//     // ── Help & Support ────────────────────────────────────────────────────
//     GetPage(
//       name: helpSupport,
//       page: () => const HelpSupportScreen(),
//     ),

//     // ── Leave ─────────────────────────────────────────────────────────────
//     GetPage(
//       name: leave,
//       page: () => const LeaveScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<LeaveController>()) {
//           Get.put(LeaveController());
//         }
//       }),
//     ),

//     // ── Daily Task ────────────────────────────────────────────────── ✅ ADD
//     GetPage(
//       name: dailyTask,
//       page: () => const DailyTaskScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<DailyTaskController>()) {
//           Get.put(DailyTaskController());
//         }
//       }),
//     ),
//   ];
// }








// // lib/core/routes.dart

// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/daily_task_controller.dart';
// import '../controllers/leave_controller.dart';
// import '../controllers/wfh_controller.dart';
// import '../controllers/notification_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart';
// import '../screens/performance/ranking_screen.dart';
// import '../screens/performance/reviews_screen.dart';
// import '../screens/wfh/my_wfh_screen.dart';
// import '../screens/wfh/wfh_admin_screen.dart';
// import '../screens/auth/session_expired_screen.dart';
// import '../screens/notification/notification_screen.dart';
// import '../screens/help_support/help_support_screen.dart';
// import '../screens/leave/leave_screen.dart';
// import '../screens/daily_task/daily_task_screen.dart';

// class AppRoutes {
//   static const String splash             = '/';
//   static const String login              = '/login';
//   static const String register           = '/register';
//   static const String home               = '/home';
//   static const String markIn             = '/mark-in';
//   static const String markOut            = '/mark-out';
//   static const String userSummary        = '/user-summary';
//   static const String admin              = '/admin';
//   static const String holidays           = '/holidays';
//   static const String profile            = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';
//   static const String wfh                = '/wfh';
//   static const String wfhAdmin           = '/wfh-admin';
//   static const String sessionExpired     = '/session-expired';
//   static const String notifications      = '/notifications';
//   static const String helpSupport        = '/help-support';
//   static const String leave              = '/leave';
//   static const String dailyTask          = '/daily-tasks';

//   static List<GetPage> pages = [

//     // ── Splash ────────────────────────────────────────────────────────────
//     GetPage(
//       name: splash,
//       page: () => const SplashScreen(),
//     ),

//     // ── Auth ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: login,
//       page: () => const LoginScreen(),
//       binding: BindingsBuilder(() => Get.put(AuthController())),
//     ),
//     GetPage(
//       name: register,
//       page: () => const RegisterScreen(),
//     ),

//     // ── Home ──────────────────────────────────────────────────────────────
//     GetPage(
//       name: home,
//       page: () => const HomeScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<AuthController>()) {
//           Get.put(AuthController());
//         }
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//         if (!Get.isRegistered<DailyTaskController>()) {
//           Get.put(DailyTaskController());
//         }
//       }),
//     ),

//     // ── Attendance ────────────────────────────────────────────────────────
//     GetPage(
//       name: markIn,
//       page: () => const MarkAttendanceScreen(isMarkIn: true),
//     ),
//     GetPage(
//       name: markOut,
//       page: () => const MarkAttendanceScreen(isMarkIn: false),
//     ),
//     GetPage(
//       name: userSummary,
//       page: () => const UserSummaryScreen(),
//     ),
//     GetPage(
//       name: holidays,
//       page: () => const HolidayScreen(),
//     ),

//     // ── Admin ─────────────────────────────────────────────────────────────
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),

//     // ── Profile ───────────────────────────────────────────────────────────
//     GetPage(
//       name: profile,
//       page: () => const ProfileScreen(),
//     ),

//     // ── Performance ───────────────────────────────────────────────────────
//     GetPage(
//       name: performance,
//       page: () => const PerformanceDashboardScreen(),
//     ),
//     GetPage(
//       name: performanceRanking,
//       page: () => const RankingScreen(),
//     ),
//     GetPage(
//       name: performanceReviews,
//       page: () => const ReviewsScreen(),
//     ),

//     // ── WFH ───────────────────────────────────────────────────────────────
//     GetPage(
//       name: wfh,
//       page: () => const MyWfhScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//       }),
//     ),
//     GetPage(
//       name: wfhAdmin,
//       page: () => const WfhAdminScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<WfhController>()) {
//           Get.put(WfhController());
//         }
//       }),
//     ),

//     // ── Session Expired ───────────────────────────────────────────────────
//     GetPage(
//       name: sessionExpired,
//       page: () => const SessionExpiredScreen(),
//       transition: Transition.fade,
//     ),

//     // ── Notifications ─────────────────────────────────────────────────────
//     GetPage(
//       name: notifications,
//       page: () => const NotificationScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<NotificationController>()) {
//           Get.put(NotificationController());
//         }
//       }),
//     ),

//     // ── Help & Support ────────────────────────────────────────────────────
//     GetPage(
//       name: helpSupport,
//       page: () => const HelpSupportScreen(),
//     ),

//     // ── Leave ─────────────────────────────────────────────────────────────
//     GetPage(
//       name: leave,
//       page: () => const LeaveScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<LeaveController>()) {
//           Get.put(LeaveController());
//         }
//       }),
//     ),

//     // ── Daily Task ────────────────────────────────────────────────────────
//     GetPage(
//       name: dailyTask,
//       page: () => const DailyTaskScreen(),
//       binding: BindingsBuilder(() {
//         if (!Get.isRegistered<DailyTaskController>()) {
//           Get.put(DailyTaskController());
//         }
//       }),
//     ),
//   ];
// }








// lib/core/routes.dart

import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/daily_task_controller.dart';
import '../controllers/leave_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/wfh_controller.dart';
import '../controllers/notification_controller.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/attendance/home_screen.dart';
import '../screens/attendance/mark_attendance_screen.dart';
import '../screens/attendance/user_summary_screen.dart';
import '../screens/attendance/holiday_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/performance/performance_dashboard_screen.dart';
import '../screens/performance/ranking_screen.dart';
import '../screens/performance/reviews_screen.dart';
import '../screens/wfh/my_wfh_screen.dart';
import '../screens/wfh/wfh_admin_screen.dart';
import '../screens/auth/session_expired_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/help_support/help_support_screen.dart';
import '../screens/leave/leave_screen.dart';
import '../screens/daily_task/daily_task_screen.dart';
import '../screens/location/my_location_screen.dart';
import '../screens/location/location_history_screen.dart';
import '../screens/location/admin_location_screen.dart';

class AppRoutes {
  static const String splash             = '/';
  static const String login              = '/login';
  static const String register           = '/register';
  static const String home               = '/home';
  static const String markIn             = '/mark-in';
  static const String markOut            = '/mark-out';
  static const String userSummary        = '/user-summary';
  static const String admin              = '/admin';
  static const String holidays           = '/holidays';
  static const String profile            = '/profile';
  static const String performance        = '/performance';
  static const String performanceRanking = '/performance/ranking';
  static const String performanceReviews = '/performance/reviews';
  static const String wfh                = '/wfh';
  static const String wfhAdmin           = '/wfh-admin';
  static const String sessionExpired     = '/session-expired';
  static const String notifications      = '/notifications';
  static const String helpSupport        = '/help-support';
  static const String leave              = '/leave';
  static const String dailyTask          = '/daily-tasks';
  static const String myLocation         = '/my-location';
  static const String locationHistory    = '/location-history';
  static const String adminLocation      = '/admin-location';

  static List<GetPage> pages = [

    // ── Splash ────────────────────────────────────────────────────────────
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),

    // ── Auth ──────────────────────────────────────────────────────────────
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.put(AuthController())),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),

    // ── Home ──────────────────────────────────────────────────────────────
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
        if (!Get.isRegistered<WfhController>()) {
          Get.put(WfhController());
        }
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
        if (!Get.isRegistered<DailyTaskController>()) {
          Get.put(DailyTaskController());
        }
        if (!Get.isRegistered<LocationController>()) {
          Get.put(LocationController());
        }
      }),
    ),

    // ── Attendance ────────────────────────────────────────────────────────
    GetPage(
      name: markIn,
      page: () => const MarkAttendanceScreen(isMarkIn: true),
    ),
    GetPage(
      name: markOut,
      page: () => const MarkAttendanceScreen(isMarkIn: false),
    ),
    GetPage(
      name: userSummary,
      page: () => const UserSummaryScreen(),
    ),
    GetPage(
      name: holidays,
      page: () => const HolidayScreen(),
    ),

    // ── Admin ─────────────────────────────────────────────────────────────
    GetPage(
      name: admin,
      page: () => const AdminScreen(),
    ),

    // ── Profile ───────────────────────────────────────────────────────────
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),

    // ── Performance ───────────────────────────────────────────────────────
    GetPage(
      name: performance,
      page: () => const PerformanceDashboardScreen(),
    ),
    GetPage(
      name: performanceRanking,
      page: () => const RankingScreen(),
    ),
    GetPage(
      name: performanceReviews,
      page: () => const ReviewsScreen(),
    ),

    // ── WFH ───────────────────────────────────────────────────────────────
    GetPage(
      name: wfh,
      page: () => const MyWfhScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WfhController>()) {
          Get.put(WfhController());
        }
      }),
    ),
    GetPage(
      name: wfhAdmin,
      page: () => const WfhAdminScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<WfhController>()) {
          Get.put(WfhController());
        }
      }),
    ),

    // ── Session Expired ───────────────────────────────────────────────────
    GetPage(
      name: sessionExpired,
      page: () => const SessionExpiredScreen(),
      transition: Transition.fade,
    ),

    // ── Notifications ─────────────────────────────────────────────────────
    GetPage(
      name: notifications,
      page: () => const NotificationScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
      }),
    ),

    // ── Help & Support ────────────────────────────────────────────────────
    GetPage(
      name: helpSupport,
      page: () => const HelpSupportScreen(),
    ),

    // ── Leave ─────────────────────────────────────────────────────────────
    GetPage(
      name: leave,
      page: () => const LeaveScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LeaveController>()) {
          Get.put(LeaveController());
        }
      }),
    ),

    // ── Daily Task ────────────────────────────────────────────────────────
    GetPage(
      name: dailyTask,
      page: () => const DailyTaskScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DailyTaskController>()) {
          Get.put(DailyTaskController());
        }
      }),
    ),

    // ── Location: User ────────────────────────────────────────────────────
    GetPage(
      name: myLocation,
      page: () => const MyLocationScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LocationController>()) {
          Get.put(LocationController());
        }
      }),
    ),
    GetPage(
      name: locationHistory,
      page: () => const LocationHistoryScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LocationController>()) {
          Get.put(LocationController());
        }
      }),
    ),

    // ── Location: Admin only ──────────────────────────────────────────────
    GetPage(
      name: adminLocation,
      page: () => const AdminLocationScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LocationController>()) {
          Get.put(LocationController());
        }
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController());
        }
      }),
    ),
  ];
}