// import 'dart:async';
// import 'dart:convert';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../core/constants/app_constants.dart';
// import 'storage_service.dart';

// class DeviceSessionService extends GetxService {
//   static DeviceSessionService get to => Get.find();

//   Timer? _pollTimer;
//   static const _pollInterval = Duration(seconds: 30);

//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _authHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken() ?? ''}',
//       };

//   // ─── START POLLING AFTER LOGIN ─────────────────────────────
//   void startSessionPolling() {
//     _pollTimer?.cancel();
//     _pollTimer = Timer.periodic(_pollInterval, (_) => _checkSession());
//   }

//   // ─── STOP POLLING ON LOGOUT ────────────────────────────────
//   void stopSessionPolling() {
//     _pollTimer?.cancel();
//     _pollTimer = null;
//   }

//   // ─── GENERATE STABLE DEVICE ID ─────────────────────────────
//   Future<String> getDeviceId() async {
//     // ✅ getDeviceId() returns String? from StorageService
//     String? stored = StorageService.getDeviceId();
//     if (stored != null && stored.isNotEmpty) return stored;

//     final info = DeviceInfoPlugin();
//     String id;
//     try {
//       if (GetPlatform.isAndroid) {
//         final d = await info.androidInfo;
//         id = d.id;
//       } else if (GetPlatform.isIOS) {
//         final d = await info.iosInfo;
//         id = d.identifierForVendor ?? DateTime.now().toString();
//       } else {
//         id = DateTime.now().millisecondsSinceEpoch.toString();
//       }
//     } catch (_) {
//       id = DateTime.now().millisecondsSinceEpoch.toString();
//     }

//     await StorageService.saveDeviceId(id);
//     return id;
//   }

//   // ─── REGISTER SESSION ON SERVER ────────────────────────────
//   Future<bool> registerSession({
//     required String userId,   // passed as int.toString() from controller
//     required String deviceId,
//   }) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/auth/session/register'),
//             headers: _authHeaders,
//             body: jsonEncode({
//               'userId': userId,
//               'deviceId': deviceId,
//               'loginTime': DateTime.now().toIso8601String(),
//             }),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       final data = jsonDecode(response.body);
//       return data['success'] == true;
//     } catch (_) {
//       return false; // Non-critical — don't block login
//     }
//   }

//   // ─── VALIDATE CURRENT DEVICE SESSION ──────────────────────
//   Future<bool> validateSession() async {
//     try {
//       // ✅ getUserId() returns int — convert to String for API
//       final int userId = StorageService.getUserId();
//       // ✅ getDeviceId() returns String?
//       final String? deviceId = StorageService.getDeviceId();

//       if (userId == 0 || deviceId == null || deviceId.isEmpty) return false;

//       final response = await http
//           .post(
//             Uri.parse('$_base/auth/session/validate'),
//             headers: _authHeaders,
//             body: jsonEncode({
//               'userId': userId.toString(),
//               'deviceId': deviceId,
//             }),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       final data = jsonDecode(response.body);
//       return data['success'] == true && data['data']?['valid'] == true;
//     } catch (_) {
//       return true; // Network error — don't force logout, try next cycle
//     }
//   }

//   // ─── REMOVE SESSION (LOGOUT) ───────────────────────────────
//   Future<void> removeSession(String userId) async {
//     try {
//       await http
//           .post(
//             Uri.parse('$_base/auth/session/remove'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': userId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
//     } catch (_) {}
//   }

//   // ─── INTERNAL POLL ─────────────────────────────────────────
//   Future<void> _checkSession() async {
//     final valid = await validateSession();
//     if (!valid) {
//       stopSessionPolling();
//       _showSessionKickedDialog();
//     }
//   }

//   // ─── DIALOG: ANOTHER DEVICE LOGGED IN ─────────────────────
//   void _showSessionKickedDialog() {
//     if (Get.isDialogOpen ?? false) Get.back();

//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           backgroundColor: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF3E0),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: const Icon(Icons.devices_other_rounded,
//                       size: 38, color: Color(0xFFF57C00)),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Session Terminated',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF0A1628),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Your account has been logged in from another device. Please contact your administrator if this was not you.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[600],
//                     fontFamily: 'Poppins',
//                     height: 1.6,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF8E1),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: const Color(0xFFFFECB3)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: const [
//                       Icon(Icons.info_outline_rounded,
//                           size: 15, color: Color(0xFFF57C00)),
//                       SizedBox(width: 6),
//                       Text(
//                         'Please connect to Admin',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFFF57C00),
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _forceLogout,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF57C00),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text(
//                       'Go to Login',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }

//   Future<void> _forceLogout() async {
//     Get.back();
//     await StorageService.clearAll();
//     Get.offAllNamed('/login');
//   }
// }











import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'storage_service.dart';
import 'activity_service.dart';

class DeviceSessionService extends GetxService {
  static DeviceSessionService get to => Get.find();

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 30);

  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${StorageService.getToken() ?? ''}',
      };

  // ─── START POLLING AFTER LOGIN ─────────────────────────────
  void startSessionPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkSession());
    debugPrint('[Session] Polling started — every ${_pollInterval.inSeconds}s');
  }

  // ─── STOP POLLING ON LOGOUT ────────────────────────────────
  void stopSessionPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('[Session] Polling stopped');
  }

  // ─── GENERATE STABLE DEVICE ID ─────────────────────────────
  Future<String> getDeviceId() async {
    String? stored = StorageService.getDeviceId();
    if (stored != null && stored.isNotEmpty) return stored;

    final info = DeviceInfoPlugin();
    String id;
    try {
      if (GetPlatform.isAndroid) {
        final d = await info.androidInfo;
        id = d.id;
      } else if (GetPlatform.isIOS) {
        final d = await info.iosInfo;
        id = d.identifierForVendor ?? DateTime.now().toString();
      } else {
        id = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (_) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await StorageService.saveDeviceId(id);
    return id;
  }

  // ─── REGISTER SESSION ON SERVER ────────────────────────────
  Future<bool> registerSession({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base/auth/session/register'),
            headers: _authHeaders,
            body: jsonEncode({
              'userId': userId,
              'deviceId': deviceId,
              'loginTime': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false; // Non-critical — login block nahi karo
    }
  }

  // ─── VALIDATE CURRENT DEVICE SESSION ──────────────────────
  Future<bool> validateSession() async {
    try {
      final int userId = StorageService.getUserId();
      final String? deviceId = StorageService.getDeviceId();

      if (userId == 0 || deviceId == null || deviceId.isEmpty) return false;

      final response = await http
          .post(
            Uri.parse('$_base/auth/session/validate'),
            headers: _authHeaders,
            body: jsonEncode({
              'userId': userId.toString(),
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      final data = jsonDecode(response.body);
      return data['success'] == true && data['data']?['valid'] == true;
    } catch (_) {
      // Network error — force logout mat karo, next cycle mein try karo
      return true;
    }
  }

  // ─── REMOVE SESSION (LOGOUT) ───────────────────────────────
  Future<void> removeSession(String userId) async {
    try {
      await http
          .post(
            Uri.parse('$_base/auth/session/remove'),
            headers: _authHeaders,
            body: jsonEncode({'userId': userId}),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
    } catch (_) {}
  }

  // ─── INTERNAL POLL ─────────────────────────────────────────
  Future<void> _checkSession() async {
    final valid = await validateSession();
    debugPrint('[Session] Poll — valid: $valid');

    if (!valid) {
      stopSessionPolling();
      await _forceLogout();
    }
  }

  // ─── FORCE LOGOUT ──────────────────────────────────────────
  // Jab device clear ho ya session invalid ho — auto logout + login screen
  Future<void> _forceLogout() async {
    debugPrint('[Session] Force logout triggered');

    // 1. Activity monitoring band karo
    try {
      ActivityService.to.stop();
    } catch (_) {}

    // 2. Koi bhi open dialog band karo
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (_) {}

    // 3. Storage clear karo
    await StorageService.clearAll();

    // 4. ✅ Login screen pe navigate karo
    Get.offAllNamed('/login');

    // 5. Snackbar — navigate ke baad
    await Future.delayed(const Duration(milliseconds: 300));
    Get.snackbar(
      'Device Removed',
      'Admin ne aapka device clear kar diya. Dobara login karein.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFD32F2F),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.phonelink_erase_rounded, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }
}