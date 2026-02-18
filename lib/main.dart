// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'core/theme/app_theme.dart';
// import 'core/routes.dart';
// import 'services/storage_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // System UI
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   // Portrait only
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // Initialize storage
//   await StorageService.init();

//   runApp(const AttendanceApp());
// }

// class AttendanceApp extends StatelessWidget {
//   const AttendanceApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Attendance App',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: AppRoutes.splash,
//       getPages: AppRoutes.pages,
//       defaultTransition: Transition.cupertino,
//       transitionDuration: const Duration(milliseconds: 300),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'controllers/auth_controller.dart';
// import 'core/theme/app_theme.dart';
// import 'core/routes.dart';
// import 'services/storage_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // System UI
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   // Portrait only
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // Initialize storage
//   await StorageService.init();

//   // Initialize AuthController globally
//   Get.put(AuthController(), permanent: true);

//   runApp(const AttendanceApp());
// }

// class AttendanceApp extends StatelessWidget {
//   const AttendanceApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Attendance App',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: AppRoutes.splash,
//       getPages: AppRoutes.pages,
//       defaultTransition: Transition.cupertino,
//       transitionDuration: const Duration(milliseconds: 300),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'services/storage_service.dart';
import 'services/device_session_service.dart';   // ← NEW
import 'services/activity_service.dart';          // ← NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage
  await StorageService.init();

  // Initialize services — order matters!
  Get.put(DeviceSessionService(), permanent: true);  // ← NEW
  Get.put(ActivityService(), permanent: true);        // ← NEW
  Get.put(AuthController(), permanent: true);

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // ← NEW: wraps entire app — captures all touch events for auto-logout
      builder: (context, child) => ActivityDetector(child: child!),
    );
  }
}