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



import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/wfh_controller.dart';
import '../controllers/notification_controller.dart'; // ✅ ADD
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
import '../screens/notification/notification_screen.dart'; // ✅ ADD

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
  static const String notifications      = '/notifications'; // ✅ ADD

  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() => Get.put(AuthController())),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
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
        if (!Get.isRegistered<NotificationController>()) { // ✅ ADD
          Get.put(NotificationController());               // ✅ ADD
        }                                                  // ✅ ADD
      }),
    ),
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
    GetPage(
      name: admin,
      page: () => const AdminScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),

    // ── Performance ──────────────────────────────────────────────────────
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

    // ── WFH ──────────────────────────────────────────────────────────────
    GetPage(
      name: wfh,
      page: () => const MyWfhScreen(),
    ),
    GetPage(
      name: wfhAdmin,
      page: () => const WfhAdminScreen(),
    ),

    // ── Session Expired ───────────────────────────────────────────────────
    GetPage(
      name: sessionExpired,
      page: () => const SessionExpiredScreen(),
      transition: Transition.fade,
    ),

    // ── Notifications ─────────────────────────────────────────────────── ✅
    GetPage(
      name: notifications,
      page: () => const NotificationScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationController>()) {
          Get.put(NotificationController());
        }
      }),
    ),
  ];
}