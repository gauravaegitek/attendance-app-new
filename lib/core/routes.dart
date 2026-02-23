// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/admin/admin_screen.dart';


// class AppRoutes {
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String home = '/home';
//   static const String markIn = '/mark-in';
//   static const String markOut = '/mark-out';
//   static const String userSummary = '/user-summary';
//   static const String admin = '/admin';

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
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//   ];
// }





// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart'; // ← ADD
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart'; // ✅ ADD



// class AppRoutes {
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String home = '/home';
//   static const String markIn = '/mark-in';
//   static const String markOut = '/mark-out';
//   static const String userSummary = '/user-summary';
//   static const String admin = '/admin';
//   static const String holidays = '/holidays'; // ← ADD
//     static const profile = '/profile'; // ✅ ADD
//     static const performance        = '/performance';
// static const performanceRanking = '/performance/ranking';
// static const performanceReviews = '/performance/reviews';


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
//       name: holidays,                              // ← ADD
//       page: () => const HolidayScreen(),           // ← ADD
//     ),                                             // ← ADD
//     GetPage(
//       name: admin,
//       page: () => const AdminScreen(),
//     ),
//     GetPage(name: profile, page: () => const ProfileScreen()), // ✅ ADD

// GetPage(name: AppRoutes.performance,        page: () => const PerformanceDashboardScreen()),
// GetPage(name: AppRoutes.performanceRanking, page: () => const RankingScreen()),
// GetPage(name: AppRoutes.performanceReviews, page: () => const ReviewsScreen()),
//   ];
// }







// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';
// import '../screens/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/attendance/home_screen.dart';
// import '../screens/attendance/mark_attendance_screen.dart';
// import '../screens/attendance/user_summary_screen.dart';
// import '../screens/attendance/holiday_screen.dart';
// import '../screens/admin/admin_screen.dart';
// import '../screens/profile/profile_screen.dart';
// import '../screens/performance/performance_dashboard_screen.dart'; // ✅ ADD
// import '../screens/performance/ranking_screen.dart';               // ✅ ADD
// import '../screens/performance/reviews_screen.dart';               // ✅ ADD

// class AppRoutes {
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String home = '/home';
//   static const String markIn = '/mark-in';
//   static const String markOut = '/mark-out';
//   static const String userSummary = '/user-summary';
//   static const String admin = '/admin';
//   static const String holidays = '/holidays';
//   static const String profile = '/profile';
//   static const String performance        = '/performance';
//   static const String performanceRanking = '/performance/ranking';
//   static const String performanceReviews = '/performance/reviews';

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

//     // ── Performance ──────────────────────────────────────────────────────────
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
//   ];
// }










import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/wfh_controller.dart';
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
  ];
}