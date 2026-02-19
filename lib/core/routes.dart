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





import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/attendance/home_screen.dart';
import '../screens/attendance/mark_attendance_screen.dart';
import '../screens/attendance/user_summary_screen.dart';
import '../screens/attendance/holiday_screen.dart'; // ← ADD
import '../screens/admin/admin_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String markIn = '/mark-in';
  static const String markOut = '/mark-out';
  static const String userSummary = '/user-summary';
  static const String admin = '/admin';
  static const String holidays = '/holidays'; // ← ADD

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
      name: holidays,                              // ← ADD
      page: () => const HolidayScreen(),           // ← ADD
    ),                                             // ← ADD
    GetPage(
      name: admin,
      page: () => const AdminScreen(),
    ),
  ];
}