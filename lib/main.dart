// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'controllers/auth_controller.dart';
// import 'controllers/attendance_controller.dart';
// import 'controllers/performance_controller.dart'; // ✅ ADD
// import 'core/theme/app_theme.dart';
// import 'core/routes.dart';
// import 'services/storage_service.dart';
// import 'services/device_session_service.dart';
// import 'services/activity_service.dart';
// import 'core/widgets/no_internet_wrapper.dart';

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

//   // Register controllers/services ONE TIME — order matters!
//   Get.put(DeviceSessionService(), permanent: true);
//   Get.put(ActivityService(), permanent: true);
//   Get.put(AuthController(), permanent: true);
//   Get.put(AttendanceController(), permanent: true);
//   Get.put(PerformanceController(), permanent: true); // ✅ ADD

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
//       builder: (context, child) => NoInternetWrapper(
//         child: ActivityDetector(child: child!),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/performance_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'services/storage_service.dart';
import 'services/device_session_service.dart';
import 'services/activity_service.dart';
import 'core/widgets/no_internet_wrapper.dart';

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

  // ✅ Sirf zaroori controllers startup pe load karo
  Get.put(DeviceSessionService(), permanent: true);
  Get.put(ActivityService(), permanent: true);
  Get.put(AuthController(), permanent: true);

  // ✅ LazyPut — jab screen khulegi tab initialize honge
  // Geolocator service startup pe trigger nahi hoga
  Get.lazyPut<AttendanceController>(() => AttendanceController(), fenix: true);
  Get.lazyPut<PerformanceController>(() => PerformanceController(), fenix: true);

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
      builder: (context, child) => NoInternetWrapper(
        child: ActivityDetector(child: child!),
      ),
    );
  }
}