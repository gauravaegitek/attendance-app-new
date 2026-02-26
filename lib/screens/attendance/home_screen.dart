// import 'dart:async';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/role_guard.dart';

// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       final result = await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//       return result;
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('Location Required'),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.'),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok =
//           await _BiometricHelper.authenticate('Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(
//             error == BiometricError.hardwareNotFound
//                 ? Icons.no_cell_rounded
//                 : error == BiometricError.lockedOut
//                     ? Icons.lock_clock_rounded
//                     : Icons.fingerprint,
//             color: AppTheme.error,
//           ),
//           const SizedBox(width: 10),
//           Text(title),
//         ]),
//         content: Text(message),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device'),
//             ]),
//             content: Text(
//               'First time setup for ${type == 'in' ? 'Mark In' : 'Mark Out'}.\n\n'
//               'We will bind this login to your phone.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Icon(Icons.fingerprint_rounded,
//                   color: AppTheme.primary, size: 32),
//             ),
//             const SizedBox(height: 14),
//             const Text(
//               'Mark Attendance',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'Select action to continue',
//               style: TextStyle(
//                   fontSize: 13, color: Colors.grey, fontFamily: 'Poppins'),
//             ),
//             const SizedBox(height: 28),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.login_rounded,
//                     color: Colors.white, size: 20),
//                 label: const Text(
//                   'Mark In',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.success,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                   elevation: 0,
//                 ),
//                 onPressed: () {
//                   Get.back();
//                   _onAttendanceTap('/mark-in', 'in');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.logout_rounded,
//                     color: Colors.white, size: 20),
//                 label: const Text(
//                   'Mark Out',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.error,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                   elevation: 0,
//                 ),
//                 onPressed: () {
//                   Get.back();
//                   _onAttendanceTap('/mark-out', 'out');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: BorderSide(color: Colors.grey.shade200),
//                   ),
//                 ),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey,
//                       fontFamily: 'Poppins'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Logout?',
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Are you sure you want to logout?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 28),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(() {
//                       final disabled = auth.isLoggingOut.value;
//                       return ElevatedButton(
//                         onPressed: disabled
//                             ? null
//                             : () {
//                                 Get.back();
//                                 auth.logout();
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: disabled
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'Logout',
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.phonelink_erase_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Device Clear',
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 6),
//               const Text(
//                 'Enter the User ID to reset device binding.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                     fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: userIdController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: InputDecoration(
//                   labelText: 'User ID',
//                   hintText: 'e.g. 42',
//                   prefixIcon: const Icon(Icons.person_search_rounded),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide:
//                         const BorderSide(color: AppTheme.error, width: 2),
//                   ),
//                 ),
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) return 'User ID required';
//                   if (int.tryParse(v.trim()) == null)
//                     return 'Enter valid numeric ID';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'Clear Device',
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       )),
//                 ),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─────────────────────────────────────────
//   //  BUILD
//   // ─────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             SliverPadding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   // ── Top Bar ────────────────────────────────────
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Dashboard',
//                               style: TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w800,
//                                 fontFamily: 'Poppins',
//                                 color: AppTheme.textPrimary,
//                               ),
//                             ),
//                             Text(
//                               today,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: AppTheme.textSecondary,
//                                 fontFamily: 'Poppins',
//                               ),
//                             ),
//                           ]),
//                       Obx(() {
//                         final disabled = auth.isLoggingOut.value;
//                         return GestureDetector(
//                           onTap: disabled ? null : _doLogout,
//                           child: Opacity(
//                             opacity: disabled ? 0.6 : 1,
//                             child: Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.cardBackground,
//                                 borderRadius: BorderRadius.circular(14),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.08),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: disabled
//                                   ? const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                           strokeWidth: 2),
//                                     )
//                                   : const Icon(
//                                       Icons.power_settings_new_rounded,
//                                       color: AppTheme.error,
//                                       size: 20,
//                                     ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ],
//                   ),

//                   const SizedBox(height: 10),

//                   // ── User Card ──────────────────────────────────
//                   Obx(() => _UserCard(
//                         name: auth.userName.value,
//                         email: auth.userEmail.value,
//                         role: auth.userRole.value,
//                       )),

//                   const SizedBox(height: 10),

//                   // ── Layouts ────────────────────────────────────
//                   Obx(() => auth.isAdmin
//                       ? _AdminLayout(
//                           onMarkAttendance: _showAttendanceSheet,
//                           onDeviceClear: _showDeviceClearDialog,
//                           appVersion: _appVersion,
//                         )
//                       : _NormalUserLayout(
//                           onMarkAttendance: _showAttendanceSheet,
//                           appVersion: _appVersion,
//                         )),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN LAYOUT
// // ─────────────────────────────────────────────
// class _AdminLayout extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;
//   final String appVersion;

//   const _AdminLayout({
//     required this.onMarkAttendance,
//     required this.onDeviceClear,
//     required this.appVersion,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       _ArrowMenuCard(
//         icon: Icons.fingerprint_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Mark Attendance',
//         subtitle: 'Tap arrow to clock in or out',
//         onArrowTap: onMarkAttendance,
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.calendar_today_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'My Attendance',
//         subtitle: 'View your records & summary',
//         onArrowTap: () => Get.toNamed('/user-summary'),
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.beach_access_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Holidays',
//         subtitle: 'View public & company holidays',
//         onArrowTap: () => Get.toNamed('/holidays'),
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.bar_chart_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Performance',
//         subtitle: 'Scores, rankings & reviews',
//         onArrowTap: () => Get.toNamed('/performance'),
//         large: true,
//       ),

//       const SizedBox(height: 12),

//       // ── Admin Panel Label ──────────────────────
//       Row(children: [
//         const Icon(Icons.admin_panel_settings_rounded,
//             color: AppTheme.primary, size: 16),
//         const SizedBox(width: 6),
//         const Text(
//           'Admin Panel',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             fontFamily: 'Poppins',
//             color: AppTheme.textPrimary,
//           ),
//         ),
//       ]),
//       const SizedBox(height: 6),

//       // ✅ Summary
//       _ArrowMenuCard(
//         icon: Icons.groups_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Summary',
//         subtitle: 'View all employee attendance',
//         onArrowTap: () => Get.toNamed('/admin'),
//         large: true,
//       ),
//       const SizedBox(height: 8),

//       // ✅ WFH Requests — Admin Panel ke andar
//       _ArrowMenuCard(
//         icon: Icons.home_work_outlined,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primary,
//         arrowColor: AppTheme.primary,
//         title: 'WFH Requests',
//         subtitle: 'Manage work from home approvals',
//         onArrowTap: () => Get.toNamed('/wfh-admin'),
//         large: true,
//       ),
//       const SizedBox(height: 8),

//       // ✅ Performance Reviews
//       _ArrowMenuCard(
//         icon: Icons.rate_review_rounded,
//         iconBg: const Color(0xFFFCE4EC),
//         iconColor: const Color(0xFFE91E63),
//         arrowBg: const Color(0xFFFCE4EC),
//         arrowColor: const Color(0xFFE91E63),
//         title: 'Performance Reviews',
//         subtitle: 'Submit & manage employee reviews',
//         onArrowTap: () => Get.toNamed('/performance/reviews'),
//         large: true,
//       ),
//       const SizedBox(height: 8),

//       // ✅ Clear Device
//       _ArrowMenuCard(
//         icon: Icons.phonelink_erase_rounded,
//         iconBg: AppTheme.errorLight,
//         iconColor: AppTheme.error,
//         arrowBg: AppTheme.errorLight,
//         arrowColor: AppTheme.error,
//         title: 'Clear Device',
//         subtitle: 'Reset user device binding',
//         onArrowTap: onDeviceClear,
//         large: true,
//       ),
//       const SizedBox(height: 12),
//       _MorningBanner(),
//       const SizedBox(height: 10),
//       _FooterText(appVersion: appVersion),
//       const SizedBox(height: 16),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  NORMAL USER LAYOUT
// // ─────────────────────────────────────────────
// class _NormalUserLayout extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final String appVersion;

//   const _NormalUserLayout({
//     required this.onMarkAttendance,
//     required this.appVersion,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       _ArrowMenuCard(
//         icon: Icons.fingerprint_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Mark Attendance',
//         subtitle: 'Tap arrow to clock in or out',
//         onArrowTap: onMarkAttendance,
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.calendar_today_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'My Attendance',
//         subtitle: 'View your records & summary',
//         onArrowTap: () => Get.toNamed('/user-summary'),
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.beach_access_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'Holidays',
//         subtitle: 'View public & company holidays',
//         onArrowTap: () => Get.toNamed('/holidays'),
//         large: true,
//       ),
//       const SizedBox(height: 8),
//       _ArrowMenuCard(
//         icon: Icons.bar_chart_rounded,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primaryLight,
//         arrowColor: AppTheme.primary,
//         title: 'My Performance',
//         subtitle: 'View your score & rank',
//         onArrowTap: () => Get.toNamed('/performance'),
//         large: true,
//       ),
//       const SizedBox(height: 8),

//       // ✅ WFH — Employee apne requests dekhe + new request kare
//       _ArrowMenuCard(
//         icon: Icons.home_work_outlined,
//         iconBg: AppTheme.primaryLight,
//         iconColor: AppTheme.primary,
//         arrowBg: AppTheme.primary,
//         arrowColor: AppTheme.primary,
//         title: 'Work From Home',
//         subtitle: 'Request & track your WFH',
//         onArrowTap: () => Get.toNamed('/wfh'),
//         large: true,
//       ),

//       const SizedBox(height: 12),
//       _TodayOverviewCard(),
//       const SizedBox(height: 10),
//       _MorningBanner(),
//       _FooterText(appVersion: appVersion),
//       const SizedBox(height: 16),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  Today's Overview Card
// // ─────────────────────────────────────────────
// class _TodayOverviewCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;

//     final String shiftStatus;
//     final Color statusColor;
//     final IconData statusIcon;
//     if (hour < 9) {
//       shiftStatus = 'Shift Not Started';
//       statusColor = const Color(0xFFFF9800);
//       statusIcon = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftStatus = 'Shift In Progress';
//       statusColor = AppTheme.success;
//       statusIcon = Icons.play_circle_rounded;
//     } else {
//       shiftStatus = 'Shift Ended';
//       statusColor = AppTheme.textSecondary;
//       statusIcon = Icons.check_circle_rounded;
//     }

//     final weekday = DateFormat('EEEE').format(now);
//     final monthName = DateFormat('MMMM yyyy').format(now);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           const Text(
//             "Today's Overview",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//               color: AppTheme.textPrimary,
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(statusIcon, color: statusColor, size: 12),
//               const SizedBox(width: 4),
//               Text(
//                 shiftStatus,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: statusColor,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ]),
//           ),
//         ]),
//         const SizedBox(height: 12),
//         Row(children: [
//           Expanded(
//             child: _StatTile(
//               icon: Icons.calendar_month_rounded,
//               iconColor: AppTheme.primary,
//               iconBg: AppTheme.primaryLight,
//               label: 'Day',
//               value: weekday.substring(0, 3),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _StatTile(
//               icon: Icons.date_range_rounded,
//               iconColor: const Color(0xFF9C27B0),
//               iconBg: const Color(0xFFF3E5F5),
//               label: 'Month',
//               value: monthName.split(' ')[0].substring(0, 3),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _StatTile(
//               icon: Icons.access_time_rounded,
//               iconColor: const Color(0xFF2196F3),
//               iconBg: const Color(0xFFE3F2FD),
//               label: 'Time',
//               value: DateFormat('hh:mm a').format(now),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppTheme.primaryLight,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(children: [
//             const Icon(Icons.lightbulb_outline_rounded,
//                 color: AppTheme.primary, size: 16),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 _getTip(hour),
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: AppTheme.primary,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }

//   String _getTip(int hour) {
//     if (hour < 9) return 'Start your day on time — punctuality builds trust!';
//     if (hour < 12) return 'Great morning! Stay focused and productive.';
//     if (hour < 15) return 'Keep up the momentum — you\'re doing great!';
//     if (hour < 18) return 'Almost done for the day — finish strong!';
//     return 'Don\'t forget to Mark Out before you leave.';
//   }
// }

// class _StatTile extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final Color iconBg;
//   final String label;
//   final String value;

//   const _StatTile({
//     required this.icon,
//     required this.iconColor,
//     required this.iconBg,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//       decoration: BoxDecoration(
//         color: AppTheme.background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.divider),
//       ),
//       child: Column(children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration:
//               BoxDecoration(color: iconBg, shape: BoxShape.circle),
//           child: Icon(icon, color: iconColor, size: 16),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             fontFamily: 'Poppins',
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             color: AppTheme.textSecondary,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _UserCard extends StatelessWidget {
//   final String name;
//   final String email;
//   final String role;

//   const _UserCard({
//     required this.name,
//     required this.email,
//     required this.role,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(children: [
//         Container(
//           width: 52,
//           height: 52,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [AppTheme.secondary, AppTheme.accent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Center(
//             child: Text(
//               name.isNotEmpty ? name[0].toUpperCase() : 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   email.isNotEmpty ? email : '—',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppTheme.textSecondary,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: AppTheme.primary.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.star_rounded,
//                             color: AppTheme.primary, size: 11),
//                         const SizedBox(width: 3),
//                         Text(
//                           role.toLowerCase(),
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: AppTheme.primary,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ]),
//                 ),
//               ]),
//         ),
//         GestureDetector(
//           onTap: () => Get.toNamed('/profile'),
//           child: Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: AppTheme.primary,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: Colors.white, size: 22),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _MorningBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';
//     final dayName = DateFormat('EEEE').format(DateTime.now());

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//       decoration: AppTheme.softOrangeDecoration,
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.wb_sunny_rounded,
//               color: AppTheme.primary, size: 16),
//           const SizedBox(width: 6),
//           Text(
//             greeting,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//               color: AppTheme.primary,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '— $dayName',
//             style: const TextStyle(
//                 fontSize: 12,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins'),
//           ),
//         ]),
//         const SizedBox(height: 10),
//         IntrinsicHeight(
//           child: Row(children: [
//             Expanded(
//                 child: _BannerChip(
//                     icon: Icons.check_circle_outline_rounded,
//                     label: 'Stay Safe')),
//             VerticalDivider(
//                 color: AppTheme.primary.withOpacity(0.3),
//                 thickness: 1,
//                 width: 1),
//             Expanded(
//                 child: _BannerChip(
//                     icon: Icons.alarm_rounded, label: 'On Time')),
//             VerticalDivider(
//                 color: AppTheme.primary.withOpacity(0.3),
//                 thickness: 1,
//                 width: 1),
//             Expanded(
//                 child: _BannerChip(
//                     icon: Icons.trending_up_rounded,
//                     label: 'Good Work')),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// class _BannerChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const _BannerChip({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Icon(icon, color: AppTheme.primary, size: 20),
//       const SizedBox(height: 3),
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Poppins',
//           color: AppTheme.primary,
//         ),
//       ),
//     ]);
//   }
// }

// class _FooterText extends StatelessWidget {
//   final String appVersion;
//   const _FooterText({required this.appVersion});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(children: [
//         const Text(
//           'Attendance Management System',
//           style: TextStyle(
//               fontSize: 11,
//               color: AppTheme.textSecondary,
//               fontFamily: 'Poppins'),
//         ),
//         const SizedBox(height: 1),
//         Text(
//           appVersion,
//           style: const TextStyle(
//               fontSize: 10,
//               color: AppTheme.textHint,
//               fontFamily: 'Poppins'),
//         ),
//       ]),
//     );
//   }
// }

// class _ArrowMenuCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final Color arrowBg;
//   final Color arrowColor;
//   final String title;
//   final String subtitle;
//   final VoidCallback onArrowTap;
//   final bool large;

//   const _ArrowMenuCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.arrowBg,
//     required this.arrowColor,
//     required this.title,
//     required this.subtitle,
//     required this.onArrowTap,
//     this.large = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double vertPad = large ? 20 : 14;
//     final double iconSize = large ? 66 : 52;
//     final double iconInner = large ? 30 : 26;
//     final double radius = large ? 16 : 14;
//     final double titleSize = large ? 16.5 : 15;
//     final double subtitleSize = large ? 13 : 12;

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPad),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(children: [
//         Container(
//           width: iconSize,
//           height: iconSize,
//           decoration: BoxDecoration(
//               color: iconBg,
//               borderRadius: BorderRadius.circular(radius)),
//           child: Icon(icon, color: iconColor, size: iconInner),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: titleSize,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: subtitleSize,
//                     color: AppTheme.textSecondary,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ]),
//         ),
//         GestureDetector(
//           onTap: onArrowTap,
//           child: Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: arrowColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.arrow_forward_ios_rounded,
//                 color: Colors.white, size: 16),
//           ),
//         ),
//       ]),
//     );
//   }
// }













// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('Location Required'),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.'),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper
//           .authenticate('Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(
//             error == BiometricError.hardwareNotFound
//                 ? Icons.no_cell_rounded
//                 : error == BiometricError.lockedOut
//                     ? Icons.lock_clock_rounded
//                     : Icons.fingerprint,
//             color: AppTheme.error,
//           ),
//           const SizedBox(width: 10),
//           Text(title),
//         ]),
//         content: Text(message),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device'),
//             ]),
//             content: Text(
//               'First time setup for ${type == 'in' ? 'Mark In' : 'Mark Out'}.\n\nWe will bind this login to your phone.',
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel')),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppTheme.primary, const Color(0xFFFFB347)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance',
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 4),
//             Text('Choose an action to continue',
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: BorderSide(color: Colors.grey.shade200),
//                   ),
//                 ),
//                 child: Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey.shade500,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?',
//                   style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear',
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(() => ElevatedButton(
//                           onPressed: isLoading.value
//                               ? null
//                               : () async {
//                                   if (!formKey.currentState!.validate()) {
//                                     return;
//                                   }
//                                   isLoading.value = true;
//                                   try {
//                                     final enteredId = int.parse(
//                                         userIdController.text.trim());
//                                     final auth = Get.find<AuthController>();
//                                     final success =
//                                         await auth.clearUserDevice(enteredId);
//                                     if (success) {
//                                       Get.back();
//                                       _showSnack(
//                                           'Device cleared for User #$enteredId');
//                                     } else {
//                                       _showSnack(
//                                           'Invalid User ID or server error',
//                                           isError: true);
//                                     }
//                                   } catch (e) {
//                                     _showSnack('Error: $e', isError: true);
//                                   } finally {
//                                     isLoading.value = false;
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.error,
//                             padding:
//                                 const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14)),
//                             elevation: 0,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                       color: Colors.white, strokeWidth: 2))
//                               : const Text('Clear Device',
//                                   style: TextStyle(
//                                       fontFamily: 'Poppins',
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600)),
//                         )),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   // ─────────────────────────────────────────
//   //  BUILD
//   // ─────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF7F4),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _WarmHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(() => auth.isAdmin
//                   ? _AdminContent(
//                       onMarkAttendance: _showAttendanceSheet,
//                       onDeviceClear: _showDeviceClearDialog,
//                     )
//                   : _UserContent(onMarkAttendance: _showAttendanceSheet)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  WARM HEADER  (curved, soft orange-cream)
// // ─────────────────────────────────────────────
// class _WarmHeader extends StatelessWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;

//   const _WarmHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;
//     final greeting =
//         hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
//     final emoji = hour < 12 ? '🌅' : hour < 17 ? '☀️' : '🌆';

//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFFF8C00),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(40),
//           bottomRight: Radius.circular(40),
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Decorative circles
//           Positioned(
//             top: -30, right: -20,
//             child: Container(width: 140, height: 140,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 20, right: 60,
//             child: Container(width: 70, height: 70,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10, left: -30,
//             child: Container(width: 100, height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           // Content
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Left: greeting + name
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(children: [
//                               Text(emoji, style: const TextStyle(fontSize: 16)),
//                               const SizedBox(width: 6),
//                               Text(greeting,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.white.withOpacity(0.85),
//                                     fontFamily: 'Poppins',
//                                     fontWeight: FontWeight.w500,
//                                   )),
//                             ]),
//                             const SizedBox(height: 4),
//                             Obx(() => Text(
//                                   auth.userName.value,
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.w800,
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                   ),
//                                 )),
//                           ],
//                         ),
//                       ),
//                       // Right: avatar + logout
//                       Row(children: [
//                         GestureDetector(
//                           onTap: onProfile,
//                           child: Obx(() => Container(
//                                 width: 48,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.15),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     auth.userName.value.isNotEmpty
//                                         ? auth.userName.value[0].toUpperCase()
//                                         : 'U',
//                                     style: TextStyle(
//                                       color: AppTheme.primary,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w800,
//                                       fontFamily: 'Poppins',
//                                     ),
//                                   ),
//                                 ),
//                               )),
//                         ),
//                         const SizedBox(width: 10),
//                         Obx(() {
//                           final disabled = auth.isLoggingOut.value;
//                           return GestureDetector(
//                             onTap: disabled ? null : onLogout,
//                             child: Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.25),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: disabled
//                                   ? const Center(
//                                       child: SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2)),
//                                     )
//                                   : const Icon(
//                                       Icons.power_settings_new_rounded,
//                                       color: Colors.white,
//                                       size: 22),
//                             ),
//                           );
//                         }),
//                       ]),
//                     ],
//                   ),

//                   const SizedBox(height: 22),

//                   // Stats row
//                   Row(children: [
//                     _HeaderStat(
//                       icon: Icons.calendar_today_rounded,
//                       value: DateFormat('dd MMM').format(now),
//                       label: 'Today',
//                     ),
//                     _HeaderDivider(),
//                     _HeaderStat(
//                       icon: Icons.access_time_rounded,
//                       value: DateFormat('hh:mm a').format(now),
//                       label: 'Current Time',
//                     ),
//                     _HeaderDivider(),
//                     Obx(() => _HeaderStat(
//                           icon: Icons.badge_rounded,
//                           value: auth.userRole.value,
//                           label: 'Role',
//                         )),
//                   ]),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeaderStat extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;

//   const _HeaderStat({
//     required this.icon,
//     required this.value,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(children: [
//         Icon(icon, color: Colors.white, size: 16),
//         const SizedBox(height: 5),
//         Text(value,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//               color: Colors.white,
//             )),
//         Text(label,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.white.withOpacity(0.7),
//               fontFamily: 'Poppins',
//             )),
//       ]),
//     );
//   }
// }

// class _HeaderDivider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(
//         width: 1,
//         height: 40,
//         color: Colors.white.withOpacity(0.25),
//       );
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;

//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       // Attendance CTA
//       _AttendanceCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 28),

//       // My Section
//       const _SectionTitle(title: 'My Section', emoji: '👤'),
//       const SizedBox(height: 14),
//       GridView.count(
//         crossAxisCount: 2,
//         crossAxisSpacing: 14,
//         mainAxisSpacing: 14,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         childAspectRatio: 1.35,
//         children: [
//           _TileCard(
//             icon: Icons.calendar_today_rounded,
//             title: 'My Attendance',
//             subtitle: 'Records & summary',
//             color: const Color(0xFFE3F0FF),
//             iconColor: const Color(0xFF2979FF),
//             onTap: () => Get.toNamed('/user-summary'),
//           ),
//           _TileCard(
//             icon: Icons.beach_access_rounded,
//             title: 'Holidays',
//             subtitle: 'Public & company',
//             color: const Color(0xFFE8F5E9),
//             iconColor: const Color(0xFF43A047),
//             onTap: () => Get.toNamed('/holidays'),
//           ),
//           _TileCard(
//             icon: Icons.bar_chart_rounded,
//             title: 'Performance',
//             subtitle: 'Scores & ranks',
//             color: const Color(0xFFFCE4EC),
//             iconColor: const Color(0xFFE91E63),
//             onTap: () => Get.toNamed('/performance'),
//           ),
//           _TileCard(
//             icon: Icons.emoji_events_rounded,
//             title: 'Achievements',
//             subtitle: 'Your milestones',
//             color: const Color(0xFFFFF8E1),
//             iconColor: const Color(0xFFFFA000),
//             onTap: () {},
//           ),
//         ],
//       ),

//       const SizedBox(height: 28),

//       // Admin Panel
//       const _SectionTitle(title: 'Admin Panel', emoji: '🔧'),
//       const SizedBox(height: 14),

//       _StripCard(
//         icon: Icons.groups_rounded,
//         title: 'Summary',
//         subtitle: 'View all employee attendance',
//         color: AppTheme.primary,
//         onTap: () => Get.toNamed('/admin'),
//       ),
//       const SizedBox(height: 10),
//       _StripCard(
//         icon: Icons.home_work_outlined,
//         title: 'WFH Requests',
//         subtitle: 'Manage work from home approvals',
//         color: const Color(0xFF7B1FA2),
//         onTap: () => Get.toNamed('/wfh-admin'),
//         badge: 'WFH',
//       ),
//       const SizedBox(height: 10),
//       _StripCard(
//         icon: Icons.rate_review_rounded,
//         title: 'Performance Reviews',
//         subtitle: 'Submit & manage employee reviews',
//         color: const Color(0xFFE91E63),
//         onTap: () => Get.toNamed('/performance/reviews'),
//       ),
//       const SizedBox(height: 10),
//       _StripCard(
//         icon: Icons.phonelink_erase_rounded,
//         title: 'Clear Device',
//         subtitle: 'Reset user device binding',
//         color: AppTheme.error,
//         onTap: onDeviceClear,
//         isDanger: true,
//       ),

//       const SizedBox(height: 28),
//       _TipCard(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;

//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       _AttendanceCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 28),

//       const _SectionTitle(title: 'Quick Access', emoji: '⚡'),
//       const SizedBox(height: 14),

//       GridView.count(
//         crossAxisCount: 2,
//         crossAxisSpacing: 14,
//         mainAxisSpacing: 14,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         childAspectRatio: 1.35,
//         children: [
//           _TileCard(
//             icon: Icons.calendar_today_rounded,
//             title: 'My Attendance',
//             subtitle: 'Records & summary',
//             color: const Color(0xFFE3F0FF),
//             iconColor: const Color(0xFF2979FF),
//             onTap: () => Get.toNamed('/user-summary'),
//           ),
//           _TileCard(
//             icon: Icons.beach_access_rounded,
//             title: 'Holidays',
//             subtitle: 'Public & company',
//             color: const Color(0xFFE8F5E9),
//             iconColor: const Color(0xFF43A047),
//             onTap: () => Get.toNamed('/holidays'),
//           ),
//           _TileCard(
//             icon: Icons.bar_chart_rounded,
//             title: 'My Performance',
//             subtitle: 'Score & rank',
//             color: const Color(0xFFFCE4EC),
//             iconColor: const Color(0xFFE91E63),
//             onTap: () => Get.toNamed('/performance'),
//           ),
//           _TileCard(
//             icon: Icons.home_work_outlined,
//             title: 'Work From Home',
//             subtitle: 'Request & track',
//             color: const Color(0xFFF3E5F5),
//             iconColor: const Color(0xFF7B1FA2),
//             onTap: () => Get.toNamed('/wfh'),
//           ),
//         ],
//       ),

//       const SizedBox(height: 28),
//       _TipCard(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  WIDGETS
// // ─────────────────────────────────────────────

// // Section title with emoji
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   final String emoji;

//   const _SectionTitle({required this.title, required this.emoji});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Text(emoji, style: const TextStyle(fontSize: 18)),
//       const SizedBox(width: 8),
//       Text(title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             fontFamily: 'Poppins',
//             color: Color(0xFF2C2C2C),
//           )),
//     ]);
//   }
// }

// // Big attendance CTA with time shown
// class _AttendanceCTA extends StatelessWidget {
//   final VoidCallback onTap;

//   const _AttendanceCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.primary.withOpacity(0.18),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//           border: Border.all(
//             color: AppTheme.primary.withOpacity(0.12),
//             width: 1.5,
//           ),
//         ),
//         child: Row(children: [
//           // Icon
//           Container(
//             width: 68,
//             height: 68,
//             decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               Icon(Icons.fingerprint_rounded,
//                   color: AppTheme.primary, size: 34),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Mark Attendance',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Color(0xFF2C2C2C),
//                       )),
//                   const SizedBox(height: 4),
//                   Text('Tap to clock in or out',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade500,
//                         fontFamily: 'Poppins',
//                       )),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryLight,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(Icons.touch_app_rounded,
//                           color: AppTheme.primary, size: 13),
//                       const SizedBox(width: 4),
//                       Text('Fingerprint required',
//                           style: TextStyle(
//                               fontSize: 10,
//                               color: AppTheme.primary,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w600)),
//                     ]),
//                   ),
//                 ]),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppTheme.primary,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: Colors.white, size: 24),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // Pastel tile card for grid
// class _TileCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final Color iconColor;
//   final VoidCallback onTap;

//   const _TileCard({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.iconColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: iconColor, size: 20),
//                 ),
//                 Icon(Icons.arrow_forward_ios_rounded,
//                     color: Colors.grey.shade300, size: 13),
//               ],
//             ),
//             const Spacer(),
//             Text(title,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: Color(0xFF2C2C2C),
//                 )),
//             const SizedBox(height: 2),
//             Text(subtitle,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey.shade500,
//                   fontFamily: 'Poppins',
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Horizontal strip card for admin panel
// class _StripCard extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;
//   final String? badge;
//   final bool isDanger;

//   const _StripCard({
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//     this.badge,
//     this.isDanger = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: isDanger
//               ? Border.all(color: color.withOpacity(0.3))
//               : Border.all(color: Colors.grey.shade100),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(children: [
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: color, size: 22),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Text(title,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: Color(0xFF2C2C2C),
//                         )),
//                     if (badge != null) ...[
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(badge!,
//                             style: TextStyle(
//                               fontSize: 9,
//                               fontWeight: FontWeight.w700,
//                               color: color,
//                               fontFamily: 'Poppins',
//                             )),
//                       ),
//                     ],
//                   ]),
//                   const SizedBox(height: 3),
//                   Text(subtitle,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey.shade500,
//                         fontFamily: 'Poppins',
//                       )),
//                 ]),
//           ),
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(Icons.chevron_right_rounded, color: color, size: 20),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // Motivational tip card
// class _TipCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum going — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primary.withOpacity(0.1),
//             const Color(0xFFFFF3E0),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
//       ),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: AppTheme.primary.withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: Text('💡', style: const TextStyle(fontSize: 18)),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade700,
//                 fontFamily: 'Poppins',
//                 height: 1.5,
//                 fontWeight: FontWeight.w500,
//               )),
//         ),
//       ]),
//     );
//   }
// }

// // Bottom sheet button
// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _SheetBtn(
//       {required this.label,
//       required this.icon,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//                 fontFamily: 'Poppins',
//               )),
//         ]),
//       ),
//     );
//   }
// }











// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.location_off, color: Colors.orange),
//             SizedBox(width: 10),
//             Text('Location Required'),
//           ],
//         ),
//         content: const Text(
//           'Please turn on your device location (GPS) to mark attendance.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper.authenticate(
//         'Place your finger to continue',
//       );
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title;
//     String message;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Icon(
//               error == BiometricError.hardwareNotFound
//                   ? Icons.no_cell_rounded
//                   : error == BiometricError.lockedOut
//                       ? Icons.lock_clock_rounded
//                       : Icons.fingerprint,
//               color: AppTheme.error,
//             ),
//             const SizedBox(width: 10),
//             Text(title),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel'),
//             ),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: Row(
//               children: [
//                 Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//                 const SizedBox(width: 10),
//                 const Text('Register Device'),
//               ],
//             ),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppTheme.primary, const Color(0xFFFFB347)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(
//                 Icons.fingerprint_rounded,
//                 color: Colors.white,
//                 size: 36,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Mark Attendance',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Choose an action to continue',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey.shade500,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 28),
//             Row(
//               children: [
//                 Expanded(
//                   child: _SheetBtn(
//                     label: 'Mark In',
//                     icon: Icons.login_rounded,
//                     color: AppTheme.success,
//                     onTap: () {
//                       Get.back();
//                       _onAttendanceTap('/mark-in', 'in');
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _SheetBtn(
//                     label: 'Mark Out',
//                     icon: Icons.logout_rounded,
//                     color: AppTheme.error,
//                     onTap: () {
//                       Get.back();
//                       _onAttendanceTap('/mark-out', 'out');
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: BorderSide(color: Colors.grey.shade200),
//                   ),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                   color: AppTheme.errorLight,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.power_settings_new_rounded,
//                   color: AppTheme.error,
//                   size: 36,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Logout?',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Are you sure you want to logout?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//               const SizedBox(height: 28),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(fontFamily: 'Poppins'),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(() {
//                       final disabled = auth.isLoggingOut.value;
//                       return ElevatedButton(
//                         onPressed: disabled
//                             ? null
//                             : () {
//                                 Get.back();
//                                 auth.logout();
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: disabled
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text(
//                                 'Logout',
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                     color: AppTheme.errorLight,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.phonelink_erase_rounded,
//                     color: AppTheme.error,
//                     size: 36,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Device Clear',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Enter the User ID to reset device binding.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(
//                         color: AppTheme.error,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Get.back(),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           side: const BorderSide(color: AppTheme.divider),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(fontFamily: 'Poppins'),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Obx(
//                         () => ElevatedButton(
//                           onPressed: isLoading.value
//                               ? null
//                               : () async {
//                                   if (!formKey.currentState!.validate()) {
//                                     return;
//                                   }
//                                   isLoading.value = true;
//                                   try {
//                                     final enteredId = int.parse(
//                                       userIdController.text.trim(),
//                                     );
//                                     final auth = Get.find<AuthController>();
//                                     final success =
//                                         await auth.clearUserDevice(enteredId);
//                                     if (success) {
//                                       Get.back();
//                                       _showSnack(
//                                         'Device cleared for User #$enteredId',
//                                       );
//                                     } else {
//                                       _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true,
//                                       );
//                                     }
//                                   } catch (e) {
//                                     _showSnack('Error: $e', isError: true);
//                                   } finally {
//                                     isLoading.value = false;
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.error,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             elevation: 0,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : const Text(
//                                   'Clear Device',
//                                   style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle_outline,
//         color: Colors.white,
//       ),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FC),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER  — white top, accent banner
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatelessWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;

//   const _SplitHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;
//     final greeting =
//         hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

//     return Column(
//       children: [
//         // ── White top bar ──
//         Container(
//           color: Colors.white,
//           child: SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//               child: Row(
//                 children: [
//                   // Avatar
//                   GestureDetector(
//                     onTap: onProfile,
//                     child: Obx(
//                       () => Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [AppTheme.primary, const Color(0xFFFFB347)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Center(
//                           child: Text(
//                             auth.userName.value.isNotEmpty
//                                 ? auth.userName.value[0].toUpperCase()
//                                 : 'U',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w800,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   // Name + greeting
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           greeting,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade500,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                         Obx(
//                           () => Text(
//                             auth.userName.value,
//                             style: const TextStyle(
//                               fontSize: 17,
//                               fontWeight: FontWeight.w800,
//                               fontFamily: 'Poppins',
//                               color: Color(0xFF1E1E2C),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Logout
//                   Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return GestureDetector(
//                       onTap: disabled ? null : onLogout,
//                       child: Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                           color: AppTheme.errorLight,
//                           borderRadius: BorderRadius.circular(13),
//                         ),
//                         child: disabled
//                             ? const Center(
//                                 child: SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                     color: AppTheme.error,
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               )
//                             : const Icon(
//                                 Icons.power_settings_new_rounded,
//                                 color: AppTheme.error,
//                                 size: 20,
//                               ),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // ── Accent banner with date/time ──
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: BoxDecoration(
//             color: AppTheme.primary,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//           child: Row(
//             children: [
//               // Date block
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       DateFormat('EEEE').format(now),
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     Text(
//                       DateFormat('dd MMMM yyyy').format(now),
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Time block
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       DateFormat('hh:mm').format(now),
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('a').format(now),
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;

//   const _AdminContent({
//     required this.onMarkAttendance,
//     required this.onDeviceClear,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),

//         // CTA
//         _BigCTA(onTap: onMarkAttendance),
//         const SizedBox(height: 26),

//         // My Section chips
//         _Label(text: 'My Section'),
//         const SizedBox(height: 12),
//         _HorizChips(
//           items: [
//             _ChipData(
//               icon: Icons.calendar_today_rounded,
//               label: 'Attendance',
//               color: const Color(0xFF4F8EF7),
//               onTap: () => Get.toNamed('/user-summary'),
//             ),
//             _ChipData(
//               icon: Icons.beach_access_rounded,
//               label: 'Holidays',
//               color: const Color(0xFF2ECC71),
//               onTap: () => Get.toNamed('/holidays'),
//             ),
//             _ChipData(
//               icon: Icons.bar_chart_rounded,
//               label: 'Performance',
//               color: const Color(0xFFE74C3C),
//               onTap: () => Get.toNamed('/performance'),
//             ),
//           ],
//         ),

//         const SizedBox(height: 26),

//         // Admin Panel
//         _Label(text: 'Admin Panel'),
//         const SizedBox(height: 12),

//         _AdminBox(
//           children: [
//             _AdminRow(
//               icon: Icons.groups_rounded,
//               label: 'Summary',
//               sub: 'All employee attendance',
//               color: AppTheme.primary,
//               onTap: () => Get.toNamed('/admin'),
//               isFirst: true,
//               isLast: false,
//             ),
//             _AdminRow(
//               icon: Icons.home_work_outlined,
//               label: 'WFH Requests',
//               sub: 'Manage approvals',
//               color: const Color(0xFF9B59B6),
//               onTap: () => Get.toNamed('/wfh-admin'),
//               isFirst: false,
//               isLast: false,
//             ),
//             _AdminRow(
//               icon: Icons.rate_review_rounded,
//               label: 'Performance Reviews',
//               sub: 'Submit & manage reviews',
//               color: const Color(0xFFE91E63),
//               onTap: () => Get.toNamed('/performance/reviews'),
//               isFirst: false,
//               isLast: false,
//             ),
//             _AdminRow(
//               icon: Icons.phonelink_erase_rounded,
//               label: 'Clear Device',
//               sub: 'Reset device binding',
//               color: AppTheme.error,
//               onTap: onDeviceClear,
//               isFirst: false,
//               isLast: true,
//               isDanger: true,
//             ),
//           ],
//         ),

//         const SizedBox(height: 26),
//         _BottomBanner(),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;

//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),
//         _BigCTA(onTap: onMarkAttendance),
//         const SizedBox(height: 26),
//         _Label(text: 'Quick Access'),
//         const SizedBox(height: 12),
//         _HorizChips(
//           items: [
//             _ChipData(
//               icon: Icons.calendar_today_rounded,
//               label: 'Attendance',
//               color: const Color(0xFF4F8EF7),
//               onTap: () => Get.toNamed('/user-summary'),
//             ),
//             _ChipData(
//               icon: Icons.beach_access_rounded,
//               label: 'Holidays',
//               color: const Color(0xFF2ECC71),
//               onTap: () => Get.toNamed('/holidays'),
//             ),
//             _ChipData(
//               icon: Icons.bar_chart_rounded,
//               label: 'Performance',
//               color: const Color(0xFFE74C3C),
//               onTap: () => Get.toNamed('/performance'),
//             ),
//             _ChipData(
//               icon: Icons.home_work_outlined,
//               label: 'WFH',
//               color: const Color(0xFF9B59B6),
//               onTap: () => Get.toNamed('/wfh'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 26),
//         _BottomBanner(),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w800,
//         fontFamily: 'Poppins',
//         color: Color(0xFF1E1E2C),
//         letterSpacing: 0.2,
//       ),
//     );
//   }
// }

// // Large fingerprint CTA
// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(26),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Left: icon with rings
//             SizedBox(
//               width: 72,
//               height: 72,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   Container(
//                     width: 56,
//                     height: 56,
//                     decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: AppTheme.primary,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.fingerprint_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 18),
//             // Right: text
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Mark Attendance',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       fontFamily: 'Poppins',
//                       color: Color(0xFF1E1E2C),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Clock in or out with fingerprint',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade500,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       _MiniTag(
//                         label: 'Mark In',
//                         color: AppTheme.success,
//                       ),
//                       const SizedBox(width: 6),
//                       _MiniTag(
//                         label: 'Mark Out',
//                         color: AppTheme.error,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.chevron_right_rounded,
//                 color: AppTheme.primary,
//                 size: 22,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 10,
//           color: color,
//           fontWeight: FontWeight.w700,
//           fontFamily: 'Poppins',
//         ),
//       ),
//     );
//   }
// }

// // Horizontal scrollable chips
// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.08),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: item.color.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     item.label,
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Admin box — grouped rows inside one card
// class _AdminBox extends StatelessWidget {
//   final List<Widget> children;
//   const _AdminBox({required this.children});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }
// }

// class _AdminRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final String sub;
//   final VoidCallback onTap;
//   final bool isFirst;
//   final bool isLast;
//   final bool isDanger;

//   const _AdminRow({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.sub,
//     required this.onTap,
//     required this.isFirst,
//     required this.isLast,
//     this.isDanger = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isDanger ? AppTheme.errorLight.withOpacity(0.4) : null,
//           borderRadius: BorderRadius.vertical(
//             top: isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? Border(
//                   bottom: BorderSide(color: Colors.grey.shade100, width: 1),
//                 )
//               : null,
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               child: Icon(icon, color: color, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: isDanger
//                           ? AppTheme.error
//                           : const Color(0xFF1E1E2C),
//                     ),
//                   ),
//                   Text(
//                     sub,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade500,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.chevron_right_rounded,
//               color: isDanger ? AppTheme.error : Colors.grey.shade400,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Bottom motivational banner
// class _BottomBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.07),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//         border: Border(
//           left: BorderSide(color: AppTheme.primary, width: 4),
//         ),
//       ),
//       child: Row(
//         children: [
//           Text('💡', style: const TextStyle(fontSize: 20)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               tip,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade700,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w500,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Bottom sheet button
// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _SheetBtn({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.35),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: Colors.white, size: 28),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }












// import 'dart:async';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('Location Required'),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.'),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok =
//           await _BiometricHelper.authenticate('Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title;
//     String message;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(
//             error == BiometricError.hardwareNotFound
//                 ? Icons.no_cell_rounded
//                 : error == BiometricError.lockedOut
//                     ? Icons.lock_clock_rounded
//                     : Icons.fingerprint,
//             color: AppTheme.error,
//           ),
//           const SizedBox(width: 10),
//           Text(title),
//         ]),
//         content: Text(message),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device'),
//             ]),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel')),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppTheme.primary, const Color(0xFFFFB347)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance',
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 4),
//             Text('Choose an action to continue',
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: BorderSide(color: Colors.grey.shade200),
//                   ),
//                 ),
//                 child: Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey.shade500,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?',
//                   style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear',
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(
//                       () => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Clear Device',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FC),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatefulWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;

//   const _SplitHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });

//   @override
//   State<_SplitHeader> createState() => _SplitHeaderState();
// }

// class _SplitHeaderState extends State<_SplitHeader> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now = DateTime.now();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hour = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(
//       children: [
//         // White top bar
//         Container(
//           color: Colors.white,
//           child: SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//               child: Row(children: [
//                 GestureDetector(
//                   onTap: widget.onProfile,
//                   child: Obx(() => Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [AppTheme.primary, const Color(0xFFFFB347)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Center(
//                           child: Text(
//                             widget.auth.userName.value.isNotEmpty
//                                 ? widget.auth.userName.value[0].toUpperCase()
//                                 : 'U',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w800,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                         ),
//                       )),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(greeting,
//                           style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade500,
//                               fontFamily: 'Poppins')),
//                       Obx(() => Text(
//                             widget.auth.userName.value,
//                             style: const TextStyle(
//                               fontSize: 17,
//                               fontWeight: FontWeight.w800,
//                               fontFamily: 'Poppins',
//                               color: Color(0xFF1E1E2C),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),
//                 Obx(() {
//                   final disabled = widget.auth.isLoggingOut.value;
//                   return GestureDetector(
//                     onTap: disabled ? null : widget.onLogout,
//                     child: Container(
//                       width: 42,
//                       height: 42,
//                       decoration: BoxDecoration(
//                         color: AppTheme.errorLight,
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       child: disabled
//                           ? const Center(
//                               child: SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                       color: AppTheme.error, strokeWidth: 2)))
//                           : const Icon(Icons.power_settings_new_rounded,
//                               color: AppTheme.error, size: 20),
//                     ),
//                   );
//                 }),
//               ]),
//             ),
//           ),
//         ),

//         // Orange accent banner with live clock
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: BoxDecoration(
//             color: AppTheme.primary,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//           child: Row(children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     DateFormat('EEEE').format(_now),
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins'),
//                   ),
//                   Text(
//                     DateFormat('dd MMMM yyyy').format(_now),
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Text(
//                 DateFormat('HH:mm:ss').format(_now),
//                 style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1),
//               ),
//             ),
//           ]),
//         ),
//       ],
//     );
//   }
// }


// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;

//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label(text: 'My Section'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: const Color(0xFF4F8EF7),
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: const Color(0xFF2ECC71),
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: const Color(0xFFE74C3C),
//             onTap: () => Get.toNamed('/performance')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label(text: 'Admin Panel'),
//       const SizedBox(height: 12),

//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'Summary',
//           sub: 'All employee attendance',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/admin'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.home_work_outlined,
//           label: 'WFH Requests',
//           sub: 'Manage work from home approvals',
//           color: const Color(0xFF9B59B6),
//           onTap: () => Get.toNamed('/wfh-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.rate_review_rounded,
//           label: 'Performance Reviews',
//           sub: 'Submit & manage employee reviews',
//           color: const Color(0xFFE91E63),
//           onTap: () => Get.toNamed('/performance/reviews'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.phonelink_erase_rounded,
//           label: 'Clear Device',
//           sub: 'Reset user device binding',
//           color: AppTheme.error,
//           onTap: onDeviceClear,
//           isFirst: false,
//           isLast: true,
//           isDanger: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT  (fully filled screen)
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;

//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;

//     // Shift status logic
//     final String shiftLabel;
//     final Color shiftColor;
//     final IconData shiftIcon;
//     if (hour < 9) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = Colors.orange;
//       shiftIcon = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = const Color(0xFF2ECC71);
//       shiftIcon = Icons.play_circle_outline_rounded;
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = Colors.grey;
//       shiftIcon = Icons.check_circle_outline_rounded;
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),

//       // ── Mark Attendance ──
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       // ── Quick Access chips ──
//       const _Label(text: 'Quick Access'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: const Color(0xFF4F8EF7),
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: const Color(0xFF2ECC71),
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: const Color(0xFFE74C3C),
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(
//             icon: Icons.home_work_outlined,
//             label: 'WFH',
//             color: const Color(0xFF9B59B6),
//             onTap: () => Get.toNamed('/wfh')),
//       ]),

//       const SizedBox(height: 26),

//       // ── Today's Shift Status ──
//       const _Label(text: "Today's Shift"),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Row(children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(shiftIcon, color: shiftColor, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(shiftLabel,
//                   style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: shiftColor)),
//               Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
//                   style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade500,
//                       fontFamily: 'Poppins')),
//             ]),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text('Today',
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),

//       // ── More options grouped ──
//       const _Label(text: 'More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.person_rounded,
//           label: 'My Profile',
//           sub: 'View & update your details',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/profile'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'Alerts & reminders',
//           color: const Color(0xFFFF9800),
//           onTap: () {},
//           isFirst: false,
//           isLast: false,
//           isComingSoon: true,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'FAQs and contact us',
//           color: const Color(0xFF4F8EF7),
//           onTap: () {},
//           isFirst: false,
//           isLast: true,
//           isComingSoon: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Text(text,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w800,
//           fontFamily: 'Poppins',
//           color: Color(0xFF1E1E2C),
//           letterSpacing: 0.2,
//         ));
//   }
// }

// // Fingerprint CTA
// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(26),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 6))
//           ],
//         ),
//         child: Row(children: [
//           SizedBox(
//             width: 72,
//             height: 72,
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle)),
//               Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle)),
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                     color: AppTheme.primary, shape: BoxShape.circle),
//                 child: const Icon(Icons.fingerprint_rounded,
//                     color: Colors.white, size: 24),
//               ),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Mark Attendance',
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       fontFamily: 'Poppins',
//                       color: Color(0xFF1E1E2C))),
//               const SizedBox(height: 4),
//               Text('Clock in or out with fingerprint',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade500,
//                       fontFamily: 'Poppins')),
//               const SizedBox(height: 10),
//               Row(children: [
//                 _MiniTag(label: 'Mark In', color: AppTheme.success),
//                 const SizedBox(width: 6),
//                 _MiniTag(label: 'Mark Out', color: AppTheme.error),
//               ]),
//             ]),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12)),
//             child: Icon(Icons.chevron_right_rounded,
//                 color: AppTheme.primary, size: 22),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 10,
//               color: color,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins')),
//     );
//   }
// }

// // Horizontal scrollable chips
// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.grey.withOpacity(0.08),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4))
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(item.label,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: Colors.grey.shade700)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Stat box (4 in a row)
// class _StatBox extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;

//   const _StatBox({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.07),
//               blurRadius: 8,
//               offset: const Offset(0, 3))
//         ],
//       ),
//       child: Column(children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.12), shape: BoxShape.circle),
//           child: Icon(icon, color: color, size: 16),
//         ),
//         const SizedBox(height: 6),
//         Text(value,
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'Poppins',
//                 color: color)),
//         Text(label,
//             style: TextStyle(
//                 fontSize: 9,
//                 color: Colors.grey.shade500,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600)),
//       ]),
//     );
//   }
// }

// // Grouped box (iOS settings style)
// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.08),
//               blurRadius: 16,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }
// }

// class _GroupRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final String sub;
//   final VoidCallback onTap;
//   final bool isFirst;
//   final bool isLast;
//   final bool isDanger;
//   final bool isComingSoon;

//   const _GroupRow({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.sub,
//     required this.onTap,
//     required this.isFirst,
//     required this.isLast,
//     this.isDanger = false,
//     this.isComingSoon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isComingSoon
//               ? Colors.grey.shade50
//               : isDanger
//                   ? AppTheme.errorLight.withOpacity(0.4)
//                   : null,
//           borderRadius: BorderRadius.vertical(
//             top: isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? Border(
//                   bottom: BorderSide(color: Colors.grey.shade100, width: 1))
//               : null,
//         ),
//         child: Row(children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? Colors.grey : color).withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? Colors.grey.shade400 : color, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: isComingSoon
//                             ? Colors.grey.shade400
//                             : isDanger
//                                 ? AppTheme.error
//                                 : const Color(0xFF1E1E2C))),
//                 if (isComingSoon) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text('Soon',
//                         style: TextStyle(
//                             fontSize: 9,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.grey.shade500,
//                             fontFamily: 'Poppins')),
//                   ),
//                 ],
//               ]),
//               Text(sub,
//                   style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade400,
//                       fontFamily: 'Poppins')),
//             ]),
//           ),
//           Icon(Icons.chevron_right_rounded,
//               color: isComingSoon
//                   ? Colors.grey.shade300
//                   : isDanger
//                       ? AppTheme.error
//                       : Colors.grey.shade400,
//               size: 20),
//         ]),
//       ),
//     );
//   }
// }

// // Tip banner with left orange border
// class _TipBanner extends StatelessWidget {
//   const _TipBanner();

//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.07),
//               blurRadius: 10,
//               offset: const Offset(0, 3))
//         ],
//         border: Border(left: BorderSide(color: AppTheme.primary, width: 4)),
//       ),
//       child: Row(children: [
//         const Text('💡', style: TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade700,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w500,
//                   height: 1.4)),
//         ),
//       ]),
//     );
//   }
// }

// // Bottom sheet button
// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _SheetBtn(
//       {required this.label,
//       required this.icon,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label,
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                   fontFamily: 'Poppins')),
//         ]),
//       ),
//     );
//   }
// }








// import 'dart:async';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/widgets/notification_badge.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//     if (!Get.isRegistered<NotificationController>()) {
//       Get.put(NotificationController());
//     }
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: AppTheme.warning),
//           SizedBox(width: 10),
//           Text('Location Required',
//               style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.',
//             style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper.authenticate(
//           'Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title   = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon    = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title   = 'Fingerprint Not Set Up';
//         message = 'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon    = Icons.fingerprint;
//         break;
//       case BiometricError.lockedOut:
//         title   = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         icon    = Icons.lock_clock_rounded;
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: AppTheme.error),
//           const SizedBox(width: 10),
//           Text(title, style: const TextStyle(fontFamily: 'Poppins')),
//         ]),
//         content: Text(message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel',
//                     style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child:
//                 const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               const Icon(Icons.fingerprint,
//                   color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device',
//                   style: TextStyle(fontFamily: 'Poppins')),
//             ]),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//               style: const TextStyle(
//                   fontFamily: 'Poppins', color: AppTheme.textSecondary),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel',
//                       style: TextStyle(color: AppTheme.textSecondary))),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44, height: 5,
//               decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradientDecoration.gradient,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             const Text('Choose an action to continue',
//                 style: AppTheme.bodySmall),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: const BorderSide(color: AppTheme.divider),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?', style: AppTheme.headline2),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center, style: AppTheme.bodySmall),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18, height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center,
//                     style: AppTheme.bodySmall),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(
//                       () => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Clear Device',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(
//                         onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatefulWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;
//   const _SplitHeader({
//     required this.auth, required this.appVersion,
//     required this.onLogout, required this.onProfile,
//   });
//   @override
//   State<_SplitHeader> createState() => _SplitHeaderState();
// }

// class _SplitHeaderState extends State<_SplitHeader> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now = DateTime.now();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() { _timer.cancel(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     final hour = _now.hour;
//     final greeting = hour < 12 ? 'Good Morning'
//         : hour < 17 ? 'Good Afternoon'
//         : 'Good Evening';

//     return Column(children: [
//       // ── White top bar ──────────────────────────────────────────
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
//               // Avatar
//               GestureDetector(
//                 onTap: widget.onProfile,
//                 child: Obx(() => Container(
//                       width: 50, height: 50,
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.primaryGradientDecoration.gradient,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.auth.userName.value.isNotEmpty
//                               ? widget.auth.userName.value[0].toUpperCase()
//                               : 'U',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//               const SizedBox(width: 14),

//               // Greeting + Name
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(greeting, style: AppTheme.bodySmall),
//                     Obx(() => Text(widget.auth.userName.value,
//                         style: AppTheme.headline3)),
//                   ],
//                 ),
//               ),

//               // Notification Bell
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),

//               // Logout
//               Obx(() {
//                 final disabled = widget.auth.isLoggingOut.value;
//                 return GestureDetector(
//                   onTap: disabled ? null : widget.onLogout,
//                   child: Container(
//                     width: 42, height: 42,
//                     decoration: BoxDecoration(
//                       color: AppTheme.errorLight,
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: disabled
//                         ? const Center(
//                             child: SizedBox(
//                                 width: 18, height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: AppTheme.error, strokeWidth: 2)))
//                         : const Icon(Icons.power_settings_new_rounded,
//                             color: AppTheme.error, size: 20),
//                   ),
//                 );
//               }),
//             ]),
//           ),
//         ),
//       ),

//       // ── Orange banner ──────────────────────────────────────────
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//         child: Row(children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(DateFormat('EEEE').format(_now),
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins')),
//                 Text(DateFormat('dd MMMM yyyy').format(_now),
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white)),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(DateFormat('HH:mm:ss').format(_now),
//                 style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1)),
//           ),
//         ]),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;
//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(icon: Icons.calendar_today_rounded, label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(icon: Icons.beach_access_rounded, label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(icon: Icons.bar_chart_rounded, label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),

//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded, label: 'Summary',
//           sub: 'All employee attendance',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/admin'),
//           isFirst: true, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.home_work_outlined, label: 'WFH Requests',
//           sub: 'Manage work from home approvals',
//           color: AppTheme.chipWFH,
//           onTap: () => Get.toNamed('/wfh-admin'),
//           isFirst: false, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.rate_review_rounded, label: 'Performance Reviews',
//           sub: 'Submit & manage employee reviews',
//           color: AppTheme.accent,
//           onTap: () => Get.toNamed('/performance/reviews'),
//           isFirst: false, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded, label: 'Notifications',
//           sub: 'Send & manage notifications',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.phonelink_erase_rounded, label: 'Clear Device',
//           sub: 'Reset user device binding',
//           color: AppTheme.error,
//           onTap: onDeviceClear,
//           isFirst: false, isLast: true,
//           isDanger: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     final now  = DateTime.now();
//     final hour = now.hour;

//     final Color shiftColor;
//     final String shiftLabel;
//     final IconData shiftIcon;
//     if (hour < 9) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon  = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon  = Icons.play_circle_outline_rounded;
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon  = Icons.check_circle_outline_rounded;
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(icon: Icons.calendar_today_rounded, label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(icon: Icons.beach_access_rounded, label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(icon: Icons.bar_chart_rounded, label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(icon: Icons.home_work_outlined, label: 'WFH',
//             color: AppTheme.chipWFH,
//             onTap: () => Get.toNamed('/wfh')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label("Today's Shift"),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 52, height: 52,
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(shiftIcon, color: shiftColor, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(shiftLabel,
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins', color: shiftColor)),
//               Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
//                   style: AppTheme.caption),
//             ]),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text('Today',
//                 style: TextStyle(
//                     fontSize: 11, color: shiftColor,
//                     fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.person_rounded, label: 'My Profile',
//           sub: 'View & update your details',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/profile'),
//           isFirst: true, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded, label: 'Notifications',
//           sub: 'View your alerts & reminders',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false, isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded, label: 'Help & Support',
//           sub: 'FAQs and contact us',
//           color: AppTheme.info,
//           onTap: () {},
//           isFirst: false, isLast: true,
//           isComingSoon: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) =>
//       Text(text, style: AppTheme.labelBold);
// }

// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           SizedBox(
//             width: 72, height: 72,
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                   width: 72, height: 72,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle)),
//               Container(
//                   width: 56, height: 56,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle)),
//               Container(
//                 width: 42, height: 42,
//                 decoration: const BoxDecoration(
//                     color: AppTheme.primary, shape: BoxShape.circle),
//                 child: const Icon(Icons.fingerprint_rounded,
//                     color: Colors.white, size: 24),
//               ),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Mark Attendance', style: AppTheme.headline3),
//               const SizedBox(height: 4),
//               const Text('Clock in or out with fingerprint',
//                   style: AppTheme.bodySmall),
//               const SizedBox(height: 10),
//               const Row(children: [
//                 _MiniTag(label: 'Mark In',  color: AppTheme.success),
//                 SizedBox(width: 6),
//                 _MiniTag(label: 'Mark Out', color: AppTheme.error),
//               ]),
//             ]),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 36, height: 36,
//             decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12)),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: AppTheme.primary, size: 22),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(fontSize: 10, color: color,
//               fontWeight: FontWeight.w700, fontFamily: 'Poppins')));
// }

// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData(
//       {required this.icon, required this.label,
//        required this.color, required this.onTap});
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(item.label,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTheme.chipLabel),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) =>
//       Container(
//           decoration: AppTheme.cardDecoration(radius: 22),
//           child: Column(children: children));
// }

// class _GroupRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label, sub;
//   final VoidCallback onTap;
//   final bool isFirst, isLast, isDanger, isComingSoon;

//   const _GroupRow({
//     required this.icon, required this.color,
//     required this.label, required this.sub,
//     required this.onTap,
//     required this.isFirst, required this.isLast,
//     this.isDanger = false, this.isComingSoon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isComingSoon
//               ? AppTheme.background
//               : isDanger
//                   ? AppTheme.errorLight.withOpacity(0.4)
//                   : null,
//           borderRadius: BorderRadius.vertical(
//             top:    isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast  ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? const Border(
//                   bottom: BorderSide(color: AppTheme.divider, width: 1))
//               : null,
//         ),
//         child: Row(children: [
//           Container(
//             width: 42, height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color,
//                 size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Flexible(
//                   child: Text(label,
//                       style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: isComingSoon
//                               ? AppTheme.textHint
//                               : isDanger
//                                   ? AppTheme.error
//                                   : AppTheme.textPrimary)),
//                 ),
//                 if (isComingSoon) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 7, vertical: 2),
//                     decoration: BoxDecoration(
//                         color: AppTheme.shimmerBase,
//                         borderRadius: BorderRadius.circular(6)),
//                     child: const Text('Soon',
//                         style: TextStyle(
//                             fontSize: 9,
//                             fontWeight: FontWeight.w700,
//                             color: AppTheme.textSecondary,
//                             fontFamily: 'Poppins')),
//                   ),
//                 ],
//               ]),
//               Text(sub, style: AppTheme.caption),
//             ]),
//           ),
//           Icon(Icons.chevron_right_rounded,
//               color: isComingSoon
//                   ? AppTheme.shimmerBase
//                   : isDanger
//                       ? AppTheme.error
//                       : AppTheme.textHint,
//               size: 20),
//         ]),
//       ),
//     );
//   }
// }

// class _TipBanner extends StatelessWidget {
//   const _TipBanner();

//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: AppTheme.tipDecoration,
//       child: Row(children: [
//         const Text('💡', style: TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: AppTheme.bodySmall.copyWith(
//                   fontWeight: FontWeight.w500, height: 1.4)),
//         ),
//       ]),
//     );
//   }
// }

// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   const _SheetBtn(
//       {required this.label, required this.icon,
//        required this.color, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
//   }
// }










// import 'dart:async';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/widgets/notification_badge.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//     if (!Get.isRegistered<NotificationController>()) {
//       Get.put(NotificationController());
//     }
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: AppTheme.warning),
//           SizedBox(width: 10),
//           Text('Location Required',
//               style: TextStyle(
//                   fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper.authenticate(
//           'Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         icon = Icons.lock_clock_rounded;
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: AppTheme.error),
//           const SizedBox(width: 10),
//           Text(title, style: const TextStyle(fontFamily: 'Poppins')),
//         ]),
//         content: Text(message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel',
//                     style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               const Icon(Icons.fingerprint,
//                   color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device',
//                   style: TextStyle(fontFamily: 'Poppins')),
//             ]),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//               style: const TextStyle(
//                   fontFamily: 'Poppins', color: AppTheme.textSecondary),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel',
//                       style: TextStyle(color: AppTheme.textSecondary))),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradientDecoration.gradient,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             const Text('Choose an action to continue', style: AppTheme.bodySmall),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: const BorderSide(color: AppTheme.divider),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?', style: AppTheme.headline2),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center, style: AppTheme.bodySmall),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center, style: AppTheme.bodySmall),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(
//                       () => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Clear Device',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatefulWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;
//   const _SplitHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });
//   @override
//   State<_SplitHeader> createState() => _SplitHeaderState();
// }

// class _SplitHeaderState extends State<_SplitHeader> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now = DateTime.now();
//     _timer = Timer.periodic(
//         const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hour = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       // ── White top bar ──────────────────────────────────────────
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
//               // Avatar
//               GestureDetector(
//                 onTap: widget.onProfile,
//                 child: Obx(() => Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         gradient:
//                             AppTheme.primaryGradientDecoration.gradient,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.auth.userName.value.isNotEmpty
//                               ? widget.auth.userName.value[0].toUpperCase()
//                               : 'U',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//               const SizedBox(width: 14),

//               // Greeting + Name
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(greeting, style: AppTheme.bodySmall),
//                     Obx(() => Text(widget.auth.userName.value,
//                         style: AppTheme.headline3)),
//                   ],
//                 ),
//               ),

//               // Notification Bell
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),

//               // Logout
//               Obx(() {
//                 final disabled = widget.auth.isLoggingOut.value;
//                 return GestureDetector(
//                   onTap: disabled ? null : widget.onLogout,
//                   child: Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: AppTheme.errorLight,
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: disabled
//                         ? const Center(
//                             child: SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: AppTheme.error, strokeWidth: 2)))
//                         : const Icon(Icons.power_settings_new_rounded,
//                             color: AppTheme.error, size: 20),
//                   ),
//                 );
//               }),
//             ]),
//           ),
//         ),
//       ),

//       // ── Orange banner ──────────────────────────────────────────
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//         child: Row(children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(DateFormat('EEEE').format(_now),
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins')),
//                 Text(DateFormat('dd MMMM yyyy').format(_now),
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white)),
//               ],
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(DateFormat('HH:mm:ss').format(_now),
//                 style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1)),
//           ),
//         ]),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;
//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),

//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'Summary',
//           sub: 'All employee attendance',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/admin'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.home_work_outlined,
//           label: 'WFH Requests',
//           sub: 'Manage work from home approvals',
//           color: AppTheme.chipWFH,
//           onTap: () => Get.toNamed('/wfh-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.rate_review_rounded,
//           label: 'Performance Reviews',
//           sub: 'Submit & manage employee reviews',
//           color: AppTheme.accent,
//           onTap: () => Get.toNamed('/performance/reviews'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'Send & manage notifications',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         // ✅ Help & Support — Admin ke liye FAQs + Messages
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.phonelink_erase_rounded,
//           label: 'Clear Device',
//           sub: 'Reset user device binding',
//           color: AppTheme.error,
//           onTap: onDeviceClear,
//           isFirst: false,
//           isLast: true,
//           isDanger: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;

//     final Color shiftColor;
//     final String shiftLabel;
//     final IconData shiftIcon;
//     if (hour < 9) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon = Icons.play_circle_outline_rounded;
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon = Icons.check_circle_outline_rounded;
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(
//             icon: Icons.home_work_outlined,
//             label: 'WFH',
//             color: AppTheme.chipWFH,
//             onTap: () => Get.toNamed('/wfh')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label("Today's Shift"),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(shiftIcon, color: shiftColor, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(shiftLabel,
//                       style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: shiftColor)),
//                   Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
//                       style: AppTheme.caption),
//                 ]),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text('Today',
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.person_rounded,
//           label: 'My Profile',
//           sub: 'View & update your details',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/profile'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'View your alerts & reminders',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'FAQs and contact us',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) =>
//       Text(text, style: AppTheme.labelBold);
// }

// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           SizedBox(
//             width: 72,
//             height: 72,
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle)),
//               Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle)),
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: const BoxDecoration(
//                     color: AppTheme.primary, shape: BoxShape.circle),
//                 child: const Icon(Icons.fingerprint_rounded,
//                     color: Colors.white, size: 24),
//               ),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Mark Attendance', style: AppTheme.headline3),
//                   const SizedBox(height: 4),
//                   const Text('Clock in or out with fingerprint',
//                       style: AppTheme.bodySmall),
//                   const SizedBox(height: 10),
//                   const Row(children: [
//                     _MiniTag(label: 'Mark In', color: AppTheme.success),
//                     SizedBox(width: 6),
//                     _MiniTag(label: 'Mark Out', color: AppTheme.error),
//                   ]),
//                 ]),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12)),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: AppTheme.primary, size: 22),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 10,
//               color: color,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins')));
// }

// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(item.label,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTheme.chipLabel),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) =>
//       Container(
//           decoration: AppTheme.cardDecoration(radius: 22),
//           child: Column(children: children));
// }

// class _GroupRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label, sub;
//   final VoidCallback onTap;
//   final bool isFirst, isLast, isDanger, isComingSoon;

//   const _GroupRow({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.sub,
//     required this.onTap,
//     required this.isFirst,
//     required this.isLast,
//     this.isDanger = false,
//     this.isComingSoon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isComingSoon
//               ? AppTheme.background
//               : isDanger
//                   ? AppTheme.errorLight.withOpacity(0.4)
//                   : null,
//           borderRadius: BorderRadius.vertical(
//             top: isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? const Border(
//                   bottom: BorderSide(color: AppTheme.divider, width: 1))
//               : null,
//         ),
//         child: Row(children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color,
//                 size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Flexible(
//                       child: Text(label,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: isComingSoon
//                                   ? AppTheme.textHint
//                                   : isDanger
//                                       ? AppTheme.error
//                                       : AppTheme.textPrimary)),
//                     ),
//                     if (isComingSoon) ...[
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: AppTheme.shimmerBase,
//                             borderRadius: BorderRadius.circular(6)),
//                         child: const Text('Soon',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppTheme.textSecondary,
//                                 fontFamily: 'Poppins')),
//                       ),
//                     ],
//                   ]),
//                   Text(sub, style: AppTheme.caption),
//                 ]),
//           ),
//           Icon(Icons.chevron_right_rounded,
//               color: isComingSoon
//                   ? AppTheme.shimmerBase
//                   : isDanger
//                       ? AppTheme.error
//                       : AppTheme.textHint,
//               size: 20),
//         ]),
//       ),
//     );
//   }
// }

// class _TipBanner extends StatelessWidget {
//   const _TipBanner();

//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: AppTheme.tipDecoration,
//       child: Row(children: [
//         const Text('💡', style: TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: AppTheme.bodySmall
//                   .copyWith(fontWeight: FontWeight.w500, height: 1.4)),
//         ),
//       ]),
//     );
//   }
// }

// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   const _SheetBtn(
//       {required this.label,
//       required this.icon,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label,
//               style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
//   }
// }









// import 'dart:async';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/widgets/notification_badge.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//     if (!Get.isRegistered<NotificationController>()) {
//       Get.put(NotificationController());
//     }
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: AppTheme.warning),
//           SizedBox(width: 10),
//           Text('Location Required',
//               style: TextStyle(
//                   fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper.authenticate(
//           'Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         icon = Icons.lock_clock_rounded;
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: AppTheme.error),
//           const SizedBox(width: 10),
//           Text(title, style: const TextStyle(fontFamily: 'Poppins')),
//         ]),
//         content: Text(message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel',
//                     style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               const Icon(Icons.fingerprint,
//                   color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device',
//                   style: TextStyle(fontFamily: 'Poppins')),
//             ]),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//               style: const TextStyle(
//                   fontFamily: 'Poppins', color: AppTheme.textSecondary),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel',
//                       style: TextStyle(color: AppTheme.textSecondary))),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradientDecoration.gradient,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             const Text('Choose an action to continue', style: AppTheme.bodySmall),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: const BorderSide(color: AppTheme.divider),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?', style: AppTheme.headline2),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center, style: AppTheme.bodySmall),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center, style: AppTheme.bodySmall),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(
//                       () => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Clear Device',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatefulWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;
//   const _SplitHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });
//   @override
//   State<_SplitHeader> createState() => _SplitHeaderState();
// }

// class _SplitHeaderState extends State<_SplitHeader> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now = DateTime.now();
//     _timer = Timer.periodic(
//         const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hour = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       // ── White top bar ──────────────────────────────────────────
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
//               // Avatar
//               GestureDetector(
//                 onTap: widget.onProfile,
//                 child: Obx(() => Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         gradient:
//                             AppTheme.primaryGradientDecoration.gradient,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.auth.userName.value.isNotEmpty
//                               ? widget.auth.userName.value[0].toUpperCase()
//                               : 'U',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//               const SizedBox(width: 14),

//               // Greeting + Name
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(greeting, style: AppTheme.bodySmall),
//                     Obx(() => Text(widget.auth.userName.value,
//                         style: AppTheme.headline3)),
//                   ],
//                 ),
//               ),

//               // Notification Bell
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),

//               // Logout
//               Obx(() {
//                 final disabled = widget.auth.isLoggingOut.value;
//                 return GestureDetector(
//                   onTap: disabled ? null : widget.onLogout,
//                   child: Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: AppTheme.errorLight,
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: disabled
//                         ? const Center(
//                             child: SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: AppTheme.error, strokeWidth: 2)))
//                         : const Icon(Icons.power_settings_new_rounded,
//                             color: AppTheme.error, size: 20),
//                   ),
//                 );
//               }),
//             ]),
//           ),
//         ),
//       ),

//       // ── Orange banner ──────────────────────────────────────────
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//         child: Row(children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(DateFormat('EEEE').format(_now),
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins')),
//                 Text(DateFormat('dd MMMM yyyy').format(_now),
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white)),
//               ],
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(DateFormat('HH:mm:ss').format(_now),
//                 style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1)),
//           ),
//         ]),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;
//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       // ✅ Admin ke liye bhi Leave chip add kiya — My Section mein
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(                                          // ✅ NEW
//             icon: Icons.event_note_rounded,
//             label: 'Leave',
//             color: const Color(0xFF0D9488), // teal
//             onTap: () => Get.toNamed('/leave')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),

//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'Summary',
//           sub: 'All employee attendance',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/admin'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.home_work_outlined,
//           label: 'WFH Requests',
//           sub: 'Manage work from home approvals',
//           color: AppTheme.chipWFH,
//           onTap: () => Get.toNamed('/wfh-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(                                          // ✅ NEW
//           icon: Icons.event_note_rounded,
//           label: 'Leave Requests',
//           sub: 'Manage employee leave approvals',
//           color: const Color(0xFF0D9488), // teal
//           onTap: () => Get.toNamed('/leave'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.rate_review_rounded,
//           label: 'Performance Reviews',
//           sub: 'Submit & manage employee reviews',
//           color: AppTheme.accent,
//           onTap: () => Get.toNamed('/performance/reviews'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'Send & manage notifications',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.phonelink_erase_rounded,
//           label: 'Clear Device',
//           sub: 'Reset user device binding',
//           color: AppTheme.error,
//           onTap: onDeviceClear,
//           isFirst: false,
//           isLast: true,
//           isDanger: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;

//     final Color shiftColor;
//     final String shiftLabel;
//     final IconData shiftIcon;
//     if (hour < 9) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon = Icons.play_circle_outline_rounded;
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon = Icons.check_circle_outline_rounded;
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(
//             icon: Icons.home_work_outlined,
//             label: 'WFH',
//             color: AppTheme.chipWFH,
//             onTap: () => Get.toNamed('/wfh')),
//         _ChipData(                                          // ✅ NEW
//             icon: Icons.event_note_rounded,
//             label: 'Leave',
//             color: const Color(0xFF0D9488), // teal
//             onTap: () => Get.toNamed('/leave')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label("Today's Shift"),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(shiftIcon, color: shiftColor, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(shiftLabel,
//                       style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: shiftColor)),
//                   Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
//                       style: AppTheme.caption),
//                 ]),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text('Today',
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.person_rounded,
//           label: 'My Profile',
//           sub: 'View & update your details',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/profile'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'View your alerts & reminders',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'FAQs and contact us',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) =>
//       Text(text, style: AppTheme.labelBold);
// }

// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           SizedBox(
//             width: 72,
//             height: 72,
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle)),
//               Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle)),
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: const BoxDecoration(
//                     color: AppTheme.primary, shape: BoxShape.circle),
//                 child: const Icon(Icons.fingerprint_rounded,
//                     color: Colors.white, size: 24),
//               ),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Mark Attendance', style: AppTheme.headline3),
//                   const SizedBox(height: 4),
//                   const Text('Clock in or out with fingerprint',
//                       style: AppTheme.bodySmall),
//                   const SizedBox(height: 10),
//                   const Row(children: [
//                     _MiniTag(label: 'Mark In', color: AppTheme.success),
//                     SizedBox(width: 6),
//                     _MiniTag(label: 'Mark Out', color: AppTheme.error),
//                   ]),
//                 ]),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12)),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: AppTheme.primary, size: 22),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 10,
//               color: color,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins')));
// }

// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(item.label,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTheme.chipLabel),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) =>
//       Container(
//           decoration: AppTheme.cardDecoration(radius: 22),
//           child: Column(children: children));
// }

// class _GroupRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label, sub;
//   final VoidCallback onTap;
//   final bool isFirst, isLast, isDanger, isComingSoon;

//   const _GroupRow({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.sub,
//     required this.onTap,
//     required this.isFirst,
//     required this.isLast,
//     this.isDanger = false,
//     this.isComingSoon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isComingSoon
//               ? AppTheme.background
//               : isDanger
//                   ? AppTheme.errorLight.withOpacity(0.4)
//                   : null,
//           borderRadius: BorderRadius.vertical(
//             top: isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? const Border(
//                   bottom: BorderSide(color: AppTheme.divider, width: 1))
//               : null,
//         ),
//         child: Row(children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color,
//                 size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Flexible(
//                       child: Text(label,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: isComingSoon
//                                   ? AppTheme.textHint
//                                   : isDanger
//                                       ? AppTheme.error
//                                       : AppTheme.textPrimary)),
//                     ),
//                     if (isComingSoon) ...[
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: AppTheme.shimmerBase,
//                             borderRadius: BorderRadius.circular(6)),
//                         child: const Text('Soon',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppTheme.textSecondary,
//                                 fontFamily: 'Poppins')),
//                       ),
//                     ],
//                   ]),
//                   Text(sub, style: AppTheme.caption),
//                 ]),
//           ),
//           Icon(Icons.chevron_right_rounded,
//               color: isComingSoon
//                   ? AppTheme.shimmerBase
//                   : isDanger
//                       ? AppTheme.error
//                       : AppTheme.textHint,
//               size: 20),
//         ]),
//       ),
//     );
//   }
// }

// class _TipBanner extends StatelessWidget {
//   const _TipBanner();

//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: AppTheme.tipDecoration,
//       child: Row(children: [
//         const Text('💡', style: TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: AppTheme.bodySmall
//                   .copyWith(fontWeight: FontWeight.w500, height: 1.4)),
//         ),
//       ]),
//     );
//   }
// }

// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   const _SheetBtn(
//       {required this.label,
//       required this.icon,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label,
//               style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
//   }
// }














// import 'dart:async';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/daily_task_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/widgets/notification_badge.dart';

// // ─────────────────────────────────────────────
// //  BIOMETRIC HELPER
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) {
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     }
//     return 'unknown';
//   }

//   static Future<bool> isSupported() async {
//     final canCheck = await _auth.canCheckBiometrics;
//     final supported = await _auth.isDeviceSupported();
//     return canCheck && supported;
//   }

//   static Future<bool> authenticate(String reason) async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false;
//       }
//     } catch (e) {
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

// class BiometricException implements Exception {
//   final BiometricError error;
//   const BiometricException(this.error);
// }

// // ─────────────────────────────────────────────
// //  HOME SCREEN
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) =>
//       type == 'in' ? 'device_bind_in' : 'device_bind_out';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//     if (!Get.isRegistered<NotificationController>()) {
//       Get.put(NotificationController());
//     }
//     // ✅ DailyTaskController register
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController());
//     }
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _appVersion = 'v${info.version}');
//     } catch (_) {}
//   }

//   Future<bool> _checkLocation() async {
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       await _showLocationDialog();
//       return false;
//     }
//     var perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) {
//         _showSnack('Location permission denied', isError: true);
//         return false;
//       }
//     }
//     if (perm == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       return false;
//     }
//     return true;
//   }

//   Future<void> _showLocationDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: AppTheme.warning),
//           SizedBox(width: 10),
//           Text('Location Required',
//               style: TextStyle(
//                   fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }
//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

//     if (savedDeviceId.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;
//       try {
//         final ok = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Verify fingerprint for Mark In'
//               : 'Verify fingerprint for Mark Out',
//         );
//         if (!ok) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await _box.write(_keyFor(type), deviceId);
//         final auth = Get.find<AuthController>();
//         if (type == 'in') {
//           auth.inBiometric.value = deviceId;
//         } else {
//           auth.outBiometric.value = deviceId;
//         }
//         _showSnack('Device registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     if (savedDeviceId != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper.authenticate(
//           'Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         icon = Icons.lock_clock_rounded;
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: AppTheme.error),
//           const SizedBox(width: 10),
//           Text(title, style: const TextStyle(fontFamily: 'Poppins')),
//         ]),
//         content: Text(message,
//             style: const TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           if (error == BiometricError.notEnrolled)
//             TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel',
//                     style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               const Icon(Icons.fingerprint,
//                   color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Device',
//                   style: TextStyle(fontFamily: 'Poppins')),
//             ]),
//             content: Text(
//               'First time setup for '
//               '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
//               '\n\nWe will bind this login to your phone.',
//               style: const TextStyle(
//                   fontFamily: 'Poppins', color: AppTheme.textSecondary),
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () => Get.back(result: false),
//                   child: const Text('Cancel',
//                       style: TextStyle(color: AppTheme.textSecondary))),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.fingerprint),
//                 label: const Text('Proceed'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 onPressed: () => Get.back(result: true),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.primaryGradientDecoration.gradient,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Icon(Icons.fingerprint_rounded,
//                   color: Colors.white, size: 36),
//             ),
//             const SizedBox(height: 16),
//             const Text('Mark Attendance', style: AppTheme.headline2),
//             const SizedBox(height: 4),
//             const Text('Choose an action to continue', style: AppTheme.bodySmall),
//             const SizedBox(height: 28),
//             Row(children: [
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark In',
//                   icon: Icons.login_rounded,
//                   color: AppTheme.success,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-in', 'in');
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SheetBtn(
//                   label: 'Mark Out',
//                   icon: Icons.logout_rounded,
//                   color: AppTheme.error,
//                   onTap: () {
//                     Get.back();
//                     _onAttendanceTap('/mark-out', 'out');
//                   },
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: () => Get.back(),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side: const BorderSide(color: AppTheme.divider),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _doLogout() {
//     final auth = Get.find<AuthController>();
//     if (auth.isLoggingOut.value) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.power_settings_new_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?', style: AppTheme.headline2),
//               const SizedBox(height: 8),
//               const Text('Are you sure you want to logout?',
//                   textAlign: TextAlign.center, style: AppTheme.bodySmall),
//               const SizedBox(height: 28),
//               Row(children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       side: const BorderSide(color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style: TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Obx(() {
//                     final disabled = auth.isLoggingOut.value;
//                     return ElevatedButton(
//                       onPressed: disabled
//                           ? null
//                           : () {
//                               Get.back();
//                               auth.logout();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: disabled
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('Logout',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600)),
//                     );
//                   }),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: const BoxDecoration(
//                       color: AppTheme.errorLight, shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: AppTheme.error, size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text('Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center, style: AppTheme.bodySmall),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon: const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) {
//                       return 'User ID required';
//                     }
//                     if (int.tryParse(v.trim()) == null) {
//                       return 'Enter valid numeric ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         side: const BorderSide(color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(
//                       () => ElevatedButton(
//                         onPressed: isLoading.value
//                             ? null
//                             : () async {
//                                 if (!formKey.currentState!.validate()) return;
//                                 isLoading.value = true;
//                                 try {
//                                   final enteredId = int.parse(
//                                       userIdController.text.trim());
//                                   final auth = Get.find<AuthController>();
//                                   final success =
//                                       await auth.clearUserDevice(enteredId);
//                                   if (success) {
//                                     Get.back();
//                                     _showSnack(
//                                         'Device cleared for User #$enteredId');
//                                   } else {
//                                     _showSnack(
//                                         'Invalid User ID or server error',
//                                         isError: true);
//                                   }
//                                 } catch (e) {
//                                   _showSnack('Error: $e', isError: true);
//                                 } finally {
//                                   isLoading.value = false;
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.error,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14)),
//                           elevation: 0,
//                         ),
//                         child: isLoading.value
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('Clear Device',
//                                 style: TextStyle(
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String message, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       message,
//       backgroundColor: isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: _SplitHeader(
//               auth: auth,
//               appVersion: _appVersion,
//               onLogout: _doLogout,
//               onProfile: () => Get.toNamed('/profile'),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
//             sliver: SliverToBoxAdapter(
//               child: Obx(
//                 () => auth.isAdmin
//                     ? _AdminContent(
//                         onMarkAttendance: _showAttendanceSheet,
//                         onDeviceClear: _showDeviceClearDialog,
//                       )
//                     : _UserContent(onMarkAttendance: _showAttendanceSheet),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SPLIT HEADER
// // ─────────────────────────────────────────────
// class _SplitHeader extends StatefulWidget {
//   final AuthController auth;
//   final String appVersion;
//   final VoidCallback onLogout;
//   final VoidCallback onProfile;
//   const _SplitHeader({
//     required this.auth,
//     required this.appVersion,
//     required this.onLogout,
//     required this.onProfile,
//   });
//   @override
//   State<_SplitHeader> createState() => _SplitHeaderState();
// }

// class _SplitHeaderState extends State<_SplitHeader> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now = DateTime.now();
//     _timer = Timer.periodic(
//         const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _now = DateTime.now());
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hour = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       // ── White top bar ──────────────────────────────────────────
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
//               // Avatar
//               GestureDetector(
//                 onTap: widget.onProfile,
//                 child: Obx(() => Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         gradient:
//                             AppTheme.primaryGradientDecoration.gradient,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.auth.userName.value.isNotEmpty
//                               ? widget.auth.userName.value[0].toUpperCase()
//                               : 'U',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//               const SizedBox(width: 14),

//               // Greeting + Name
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(greeting, style: AppTheme.bodySmall),
//                     Obx(() => Text(widget.auth.userName.value,
//                         style: AppTheme.headline3)),
//                   ],
//                 ),
//               ),

//               // Notification Bell
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),

//               // Logout
//               Obx(() {
//                 final disabled = widget.auth.isLoggingOut.value;
//                 return GestureDetector(
//                   onTap: disabled ? null : widget.onLogout,
//                   child: Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: AppTheme.errorLight,
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: disabled
//                         ? const Center(
//                             child: SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     color: AppTheme.error, strokeWidth: 2)))
//                         : const Icon(Icons.power_settings_new_rounded,
//                             color: AppTheme.error, size: 20),
//                   ),
//                 );
//               }),
//             ]),
//           ),
//         ),
//       ),

//       // ── Orange banner ──────────────────────────────────────────
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//         child: Row(children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(DateFormat('EEEE').format(_now),
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins')),
//                 Text(DateFormat('dd MMMM yyyy').format(_now),
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white)),
//               ],
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(DateFormat('HH:mm:ss').format(_now),
//                 style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Colors.white,
//                     letterSpacing: 1)),
//           ),
//         ]),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  ADMIN CONTENT
// // ─────────────────────────────────────────────
// class _AdminContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   final VoidCallback onDeviceClear;
//   const _AdminContent(
//       {required this.onMarkAttendance, required this.onDeviceClear});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(
//             icon: Icons.event_note_rounded,
//             label: 'Leave',
//             color: const Color(0xFF0D9488),
//             onTap: () => Get.toNamed('/leave')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),

//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'Summary',
//           sub: 'All employee attendance',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/admin'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.home_work_outlined,
//           label: 'WFH Requests',
//           sub: 'Manage work from home approvals',
//           color: AppTheme.chipWFH,
//           onTap: () => Get.toNamed('/wfh-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.event_note_rounded,
//           label: 'Leave Requests',
//           sub: 'Manage employee leave approvals',
//           color: const Color(0xFF0D9488),
//           onTap: () => Get.toNamed('/leave'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.rate_review_rounded,
//           label: 'Performance Reviews',
//           sub: 'Submit & manage employee reviews',
//           color: AppTheme.accent,
//           onTap: () => Get.toNamed('/performance/reviews'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'Send & manage notifications',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.phonelink_erase_rounded,
//           label: 'Clear Device',
//           sub: 'Reset user device binding',
//           color: AppTheme.error,
//           onTap: onDeviceClear,
//           isFirst: false,
//           isLast: true,
//           isDanger: true,
//         ),
//       ]),

//       // ✅ Daily Task Card — Admin
//       const SizedBox(height: 26),
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  USER CONTENT
// // ─────────────────────────────────────────────
// class _UserContent extends StatelessWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final hour = now.hour;

//     final Color shiftColor;
//     final String shiftLabel;
//     final IconData shiftIcon;
//     if (hour < 9) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon = Icons.schedule_rounded;
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon = Icons.play_circle_outline_rounded;
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon = Icons.check_circle_outline_rounded;
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: onMarkAttendance),
//       const SizedBox(height: 26),

//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _HorizChips(items: [
//         _ChipData(
//             icon: Icons.calendar_today_rounded,
//             label: 'Attendance',
//             color: AppTheme.chipAttendance,
//             onTap: () => Get.toNamed('/user-summary')),
//         _ChipData(
//             icon: Icons.beach_access_rounded,
//             label: 'Holidays',
//             color: AppTheme.chipHoliday,
//             onTap: () => Get.toNamed('/holidays')),
//         _ChipData(
//             icon: Icons.bar_chart_rounded,
//             label: 'Performance',
//             color: AppTheme.chipPerformance,
//             onTap: () => Get.toNamed('/performance')),
//         _ChipData(
//             icon: Icons.home_work_outlined,
//             label: 'WFH',
//             color: AppTheme.chipWFH,
//             onTap: () => Get.toNamed('/wfh')),
//         _ChipData(
//             icon: Icons.event_note_rounded,
//             label: 'Leave',
//             color: const Color(0xFF0D9488),
//             onTap: () => Get.toNamed('/leave')),
//       ]),

//       const SizedBox(height: 26),
//       const _Label("Today's Shift"),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(shiftIcon, color: shiftColor, size: 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(shiftLabel,
//                       style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: shiftColor)),
//                   Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
//                       style: AppTheme.caption),
//                 ]),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text('Today',
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       // ✅ Daily Task Card — User
//       const SizedBox(height: 26),
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),

//       const SizedBox(height: 26),
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.person_rounded,
//           label: 'My Profile',
//           sub: 'View & update your details',
//           color: AppTheme.primary,
//           onTap: () => Get.toNamed('/profile'),
//           isFirst: true,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.notifications_rounded,
//           label: 'Notifications',
//           sub: 'View your alerts & reminders',
//           color: AppTheme.chipNotification,
//           onTap: () => Get.toNamed('/notifications'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'FAQs and contact us',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: true,
//         ),
//       ]),

//       const SizedBox(height: 26),
//       const _TipBanner(),
//       const SizedBox(height: 8),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  DAILY TASK CARD  ✅ NEW
// // ─────────────────────────────────────────────
// class _DailyTaskCard extends StatelessWidget {
//   const _DailyTaskCard();

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'Completed':
//         return AppTheme.success;
//       case 'In Progress':
//         return const Color(0xFFF59E0B);
//       default:
//         return AppTheme.textSecondary;
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status) {
//       case 'Completed':
//         return Icons.check_circle_rounded;
//       case 'In Progress':
//         return Icons.timelapse_rounded;
//       default:
//         return Icons.radio_button_unchecked_rounded;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return GestureDetector(
//       onTap: () => Get.toNamed('/daily-tasks'),
//       child: Container(
//         decoration: AppTheme.cardDecoration(),
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header row ───────────────────────────────────────
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.task_alt_rounded,
//                     color: AppTheme.primary,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Today's Tasks",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textPrimary,
//                         ),
//                       ),
//                       Text('Tap to manage all tasks', style: AppTheme.caption),
//                     ],
//                   ),
//                 ),
//                 // ── X / Y Done badge ─────────────────────────────
//                 Obx(() {
//                   final tasks = ctrl.todayMyTasks;
//                   final completed =
//                       tasks.where((t) => t.status == 'Completed').length;
//                   final total = tasks.length;
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       '$completed / $total Done',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.primary,
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.chevron_right_rounded,
//                     color: AppTheme.textHint, size: 20),
//               ],
//             ),

//             // ── Body: loading / empty / task list ────────────────
//             Obx(() {
//               // Loading state
//               if (ctrl.isLoadingToday.value) {
//                 return const Padding(
//                   padding: EdgeInsets.only(top: 16),
//                   child: Center(
//                     child: SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: AppTheme.primary),
//                     ),
//                   ),
//                 );
//               }

//               final tasks = ctrl.todayMyTasks;

//               // Empty state
//               if (tasks.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Row(
//                     children: [
//                       Icon(Icons.inbox_rounded,
//                           color: AppTheme.textHint, size: 20),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'No tasks logged today',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () => Get.toNamed('/daily-tasks'),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 5),
//                           decoration: BoxDecoration(
//                             color: AppTheme.primary,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             '+ Add',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               // Task list (max 3 visible)
//               final visible = tasks.take(3).toList();
//               final extra = tasks.length - visible.length;

//               return Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   const Divider(height: 1, color: AppTheme.divider),
//                   const SizedBox(height: 10),
//                   ...visible.map((task) {
//                     final color = _statusColor(task.status);
//                     final icon = _statusIcon(task.status);
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 10),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Status icon
//                           Padding(
//                             padding: const EdgeInsets.only(top: 2),
//                             child: Icon(icon, color: color, size: 18),
//                           ),
//                           const SizedBox(width: 10),
//                           // Title + project
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   task.taskTitle,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textPrimary,
//                                   ),
//                                 ),
//                                 Text(task.projectName,
//                                     style: AppTheme.caption),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Hours spent
//                           if (task.hoursSpent > 0)
//                             Padding(
//                               padding: const EdgeInsets.only(right: 6, top: 2),
//                               child: Text(
//                                 '${task.hoursSpent}h',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.textSecondary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           // Status badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: color.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               task.status,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: color,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),

//                   // "+N more" indicator
//                   if (extra > 0)
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         '+$extra more task${extra > 1 ? 's' : ''}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                   // ── Progress bar ─────────────────────────────────
//                   Builder(builder: (_) {
//                     final total = tasks.length;
//                     final done =
//                         tasks.where((t) => t.status == 'Completed').length;
//                     final progress = total == 0 ? 0.0 : done / total;
//                     return Column(
//                       children: [
//                         const SizedBox(height: 10),
//                         const Divider(height: 1, color: AppTheme.divider),
//                         const SizedBox(height: 10),
//                         Row(children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(6),
//                               child: LinearProgressIndicator(
//                                 value: progress,
//                                 minHeight: 6,
//                                 backgroundColor:
//                                     AppTheme.primary.withOpacity(0.1),
//                                 valueColor:
//                                     const AlwaysStoppedAnimation<Color>(
//                                         AppTheme.success),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             '${(progress * 100).toInt()}%',
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                               color: AppTheme.success,
//                             ),
//                           ),
//                         ]),
//                       ],
//                     );
//                   }),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SHARED WIDGETS
// // ─────────────────────────────────────────────

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) =>
//       Text(text, style: AppTheme.labelBold);
// }

// class _BigCTA extends StatelessWidget {
//   final VoidCallback onTap;
//   const _BigCTA({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(22),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           SizedBox(
//             width: 72,
//             height: 72,
//             child: Stack(alignment: Alignment.center, children: [
//               Container(
//                   width: 72,
//                   height: 72,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       shape: BoxShape.circle)),
//               Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.15),
//                       shape: BoxShape.circle)),
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: const BoxDecoration(
//                     color: AppTheme.primary, shape: BoxShape.circle),
//                 child: const Icon(Icons.fingerprint_rounded,
//                     color: Colors.white, size: 24),
//               ),
//             ]),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Mark Attendance', style: AppTheme.headline3),
//                   const SizedBox(height: 4),
//                   const Text('Clock in or out with fingerprint',
//                       style: AppTheme.bodySmall),
//                   const SizedBox(height: 10),
//                   const Row(children: [
//                     _MiniTag(label: 'Mark In', color: AppTheme.success),
//                     SizedBox(width: 6),
//                     _MiniTag(label: 'Mark Out', color: AppTheme.error),
//                   ]),
//                 ]),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(12)),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: AppTheme.primary, size: 22),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _MiniTag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _MiniTag({required this.label, required this.color});
//   @override
//   Widget build(BuildContext context) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 10,
//               color: color,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins')));
// }

// class _ChipData {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _ChipData(
//       {required this.icon,
//       required this.label,
//       required this.color,
//       required this.onTap});
// }

// class _HorizChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _HorizChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, i) {
//           final item = items[i];
//           return GestureDetector(
//             onTap: item.onTap,
//             child: Container(
//               width: 90,
//               padding: const EdgeInsets.all(12),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: item.color.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Icon(item.icon, color: item.color, size: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(item.label,
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTheme.chipLabel),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) =>
//       Container(
//           decoration: AppTheme.cardDecoration(radius: 22),
//           child: Column(children: children));
// }

// class _GroupRow extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label, sub;
//   final VoidCallback onTap;
//   final bool isFirst, isLast, isDanger, isComingSoon;

//   const _GroupRow({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.sub,
//     required this.onTap,
//     required this.isFirst,
//     required this.isLast,
//     this.isDanger = false,
//     this.isComingSoon = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isComingSoon ? null : onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isComingSoon
//               ? AppTheme.background
//               : isDanger
//                   ? AppTheme.errorLight.withOpacity(0.4)
//                   : null,
//           borderRadius: BorderRadius.vertical(
//             top: isFirst ? const Radius.circular(22) : Radius.zero,
//             bottom: isLast ? const Radius.circular(22) : Radius.zero,
//           ),
//           border: !isLast
//               ? const Border(
//                   bottom: BorderSide(color: AppTheme.divider, width: 1))
//               : null,
//         ),
//         child: Row(children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color,
//                 size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Flexible(
//                       child: Text(label,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: isComingSoon
//                                   ? AppTheme.textHint
//                                   : isDanger
//                                       ? AppTheme.error
//                                       : AppTheme.textPrimary)),
//                     ),
//                     if (isComingSoon) ...[
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: AppTheme.shimmerBase,
//                             borderRadius: BorderRadius.circular(6)),
//                         child: const Text('Soon',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppTheme.textSecondary,
//                                 fontFamily: 'Poppins')),
//                       ),
//                     ],
//                   ]),
//                   Text(sub, style: AppTheme.caption),
//                 ]),
//           ),
//           Icon(Icons.chevron_right_rounded,
//               color: isComingSoon
//                   ? AppTheme.shimmerBase
//                   : isDanger
//                       ? AppTheme.error
//                       : AppTheme.textHint,
//               size: 20),
//         ]),
//       ),
//     );
//   }
// }

// class _TipBanner extends StatelessWidget {
//   const _TipBanner();

//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final tip = hour < 9
//         ? 'Start your day strong — punctuality builds trust!'
//         : hour < 12
//             ? 'Great morning! Stay focused and productive.'
//             : hour < 15
//                 ? 'Keep the momentum — you\'re doing great!'
//                 : hour < 18
//                     ? 'Almost done — finish the day strong!'
//                     : 'Don\'t forget to Mark Out before you leave.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: AppTheme.tipDecoration,
//       child: Row(children: [
//         const Text('💡', style: TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(tip,
//               style: AppTheme.bodySmall
//                   .copyWith(fontWeight: FontWeight.w500, height: 1.4)),
//         ),
//       ]),
//     );
//   }
// }

// class _SheetBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   const _SheetBtn(
//       {required this.label,
//       required this.icon,
//       required this.color,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//                 color: color.withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(children: [
//           Icon(icon, color: Colors.white, size: 28),
//           const SizedBox(height: 6),
//           Text(label,
//               style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
//   }
// }












import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/daily_task_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/notification_badge.dart';

// ─────────────────────────────────────────────
//  BIOMETRIC HELPER
// ─────────────────────────────────────────────
class _BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await info.androidInfo).id;
    if (Platform.isIOS) {
      return (await info.iosInfo).identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  static Future<bool> isSupported() async {
    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    return canCheck && supported;
  }

  static Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'NotAvailable':
        case 'no_fragment_activity':
          throw BiometricException(BiometricError.hardwareNotFound);
        case 'NotEnrolled':
        case 'biometric_error_none_enrolled':
        case 'PasscodeNotSet':
          throw BiometricException(BiometricError.notEnrolled);
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          throw BiometricException(BiometricError.lockedOut);
        default:
          return false;
      }
    } catch (e) {
      if (e is BiometricException) rethrow;
      return false;
    }
  }
}

enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

class BiometricException implements Exception {
  final BiometricError error;
  const BiometricException(this.error);
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _box = GetStorage();
  String _appVersion = 'v1.0.0';

  String _keyFor(String type) =>
      type == 'in' ? 'device_bind_in' : 'device_bind_out';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    if (!Get.isRegistered<DailyTaskController>()) {
      Get.put(DailyTaskController());
    }
    // ✅ LocationController register
    if (!Get.isRegistered<LocationController>()) {
      Get.put(LocationController());
    }
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = 'v${info.version}');
    } catch (_) {}
  }

  Future<bool> _checkLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await _showLocationDialog();
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        _showSnack('Location permission denied', isError: true);
        return false;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> _showLocationDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.location_off, color: AppTheme.warning),
          SizedBox(width: 10),
          Text('Location Required',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
            'Please turn on your device location (GPS) to mark attendance.',
            style: TextStyle(
                fontFamily: 'Poppins', color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _handleBiometric(String type) async {
    final supported = await _BiometricHelper.isSupported();
    if (!supported) {
      _handleBiometricError(BiometricError.hardwareNotFound);
      return false;
    }
    final deviceId = await _BiometricHelper.getDeviceId();
    final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

    if (savedDeviceId.isEmpty) {
      final confirm = await _showBiometricRegisterDialog(type);
      if (!confirm) return false;
      try {
        final ok = await _BiometricHelper.authenticate(
          type == 'in'
              ? 'Verify fingerprint for Mark In'
              : 'Verify fingerprint for Mark Out',
        );
        if (!ok) {
          _showSnack('Fingerprint not recognized. Try again.', isError: true);
          return false;
        }
        await _box.write(_keyFor(type), deviceId);
        final auth = Get.find<AuthController>();
        if (type == 'in') {
          auth.inBiometric.value = deviceId;
        } else {
          auth.outBiometric.value = deviceId;
        }
        _showSnack('Device registered successfully!');
        return true;
      } on BiometricException catch (e) {
        _handleBiometricError(e.error);
        return false;
      }
    }

    if (savedDeviceId != deviceId) {
      _showSnack('Wrong device! Use your registered device.', isError: true);
      return false;
    }

    try {
      final ok =
          await _BiometricHelper.authenticate('Place your finger to continue');
      if (!ok) {
        _showSnack('Fingerprint not recognized. Try again.', isError: true);
        return false;
      }
      return true;
    } on BiometricException catch (e) {
      _handleBiometricError(e.error);
      return false;
    }
  }

  void _handleBiometricError(BiometricError error) {
    String title, message;
    IconData icon;
    switch (error) {
      case BiometricError.hardwareNotFound:
        title = 'No Biometric Sensor';
        message = 'Biometric sensor not available on this device.';
        icon = Icons.no_cell_rounded;
        break;
      case BiometricError.notEnrolled:
        title = 'Fingerprint Not Set Up';
        message =
            'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
        icon = Icons.fingerprint;
        break;
      case BiometricError.lockedOut:
        title = 'Too Many Attempts';
        message = 'Biometric is locked. Please wait and try again.';
        icon = Icons.lock_clock_rounded;
        break;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(icon, color: AppTheme.error),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontFamily: 'Poppins')),
        ]),
        content: Text(message,
            style: const TextStyle(
                fontFamily: 'Poppins', color: AppTheme.textSecondary)),
        actions: [
          if (error == BiometricError.notEnrolled)
            TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> _showBiometricRegisterDialog(String type) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              const Icon(Icons.fingerprint,
                  color: AppTheme.primary, size: 28),
              const SizedBox(width: 10),
              const Text('Register Device',
                  style: TextStyle(fontFamily: 'Poppins')),
            ]),
            content: Text(
              'First time setup for '
              '${type == 'in' ? 'Mark In' : 'Mark Out'}.'
              '\n\nWe will bind this login to your phone.',
              style: const TextStyle(
                  fontFamily: 'Poppins', color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppTheme.textSecondary))),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Proceed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onAttendanceTap(String route, String type) async {
    if (!await _checkLocation()) return;
    if (!await _handleBiometric(type)) return;
    Get.toNamed(route);
  }

  void _showAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientDecoration.gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.fingerprint_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Mark Attendance', style: AppTheme.headline2),
            const SizedBox(height: 4),
            const Text('Choose an action to continue',
                style: AppTheme.bodySmall),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: _SheetBtn(
                  label: 'Mark In',
                  icon: Icons.login_rounded,
                  color: AppTheme.success,
                  onTap: () {
                    Get.back();
                    _onAttendanceTap('/mark-in', 'in');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetBtn(
                  label: 'Mark Out',
                  icon: Icons.logout_rounded,
                  color: AppTheme.error,
                  onTap: () {
                    Get.back();
                    _onAttendanceTap('/mark-out', 'out');
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _doLogout() {
    final auth = Get.find<AuthController>();
    if (auth.isLoggingOut.value) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: AppTheme.errorLight, shape: BoxShape.circle),
                child: const Icon(Icons.power_settings_new_rounded,
                    color: AppTheme.error, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Logout?', style: AppTheme.headline2),
              const SizedBox(height: 8),
              const Text('Are you sure you want to logout?',
                  textAlign: TextAlign.center, style: AppTheme.bodySmall),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppTheme.divider),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final disabled = auth.isLoggingOut.value;
                    return ElevatedButton(
                      onPressed: disabled
                          ? null
                          : () {
                              Get.back();
                              auth.logout();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: disabled
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Logout',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                    );
                  }),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviceClearDialog() {
    final userIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: AppTheme.errorLight, shape: BoxShape.circle),
                  child: const Icon(Icons.phonelink_erase_rounded,
                      color: AppTheme.error, size: 36),
                ),
                const SizedBox(height: 20),
                const Text('Device Clear', style: AppTheme.headline2),
                const SizedBox(height: 6),
                const Text('Enter the User ID to reset device binding.',
                    textAlign: TextAlign.center, style: AppTheme.bodySmall),
                const SizedBox(height: 20),
                TextFormField(
                  controller: userIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    hintText: 'e.g. 42',
                    prefixIcon: const Icon(Icons.person_search_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppTheme.error, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'User ID required';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Enter valid numeric ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppTheme.divider),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                isLoading.value = true;
                                try {
                                  final enteredId =
                                      int.parse(userIdController.text.trim());
                                  final auth = Get.find<AuthController>();
                                  final success =
                                      await auth.clearUserDevice(enteredId);
                                  if (success) {
                                    Get.back();
                                    _showSnack(
                                        'Device cleared for User #$enteredId');
                                  } else {
                                    _showSnack(
                                        'Invalid User ID or server error',
                                        isError: true);
                                  }
                                } catch (e) {
                                  _showSnack('Error: $e', isError: true);
                                } finally {
                                  isLoading.value = false;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Clear Device',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      colorText: Colors.white,
      icon: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _SplitHeader(
              auth: auth,
              appVersion: _appVersion,
              onLogout: _doLogout,
              onProfile: () => Get.toNamed('/profile'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            sliver: SliverToBoxAdapter(
              child: Obx(
                () => auth.isAdmin
                    ? _AdminContent(
                        onMarkAttendance: _showAttendanceSheet,
                        onDeviceClear: _showDeviceClearDialog,
                      )
                    : _UserContent(onMarkAttendance: _showAttendanceSheet),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SPLIT HEADER
// ─────────────────────────────────────────────
class _SplitHeader extends StatefulWidget {
  final AuthController auth;
  final String appVersion;
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  const _SplitHeader({
    required this.auth,
    required this.appVersion,
    required this.onLogout,
    required this.onProfile,
  });
  @override
  State<_SplitHeader> createState() => _SplitHeaderState();
}

class _SplitHeaderState extends State<_SplitHeader> {
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Column(children: [
      // ── White top bar ──────────────────────────────────────────
      Container(
        color: AppTheme.cardBackground,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(children: [
              GestureDetector(
                onTap: widget.onProfile,
                child: Obx(() => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient:
                            AppTheme.primaryGradientDecoration.gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          widget.auth.userName.value.isNotEmpty
                              ? widget.auth.userName.value[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    )),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: AppTheme.bodySmall),
                    Obx(() => Text(widget.auth.userName.value,
                        style: AppTheme.headline3)),
                  ],
                ),
              ),
              NotificationBadge(iconColor: AppTheme.textPrimary),
              const SizedBox(width: 8),
              Obx(() {
                final disabled = widget.auth.isLoggingOut.value;
                return GestureDetector(
                  onTap: disabled ? null : widget.onLogout,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: disabled
                        ? const Center(
                            child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: AppTheme.error, strokeWidth: 2)))
                        : const Icon(Icons.power_settings_new_rounded,
                            color: AppTheme.error, size: 20),
                  ),
                );
              }),
            ]),
          ),
        ),
      ),

      // ── Orange banner ──────────────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEEE').format(_now),
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Poppins')),
                Text(DateFormat('dd MMMM yyyy').format(_now),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(DateFormat('HH:mm:ss').format(_now),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    letterSpacing: 1)),
          ),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  ADMIN CONTENT
// ─────────────────────────────────────────────
class _AdminContent extends StatelessWidget {
  final VoidCallback onMarkAttendance;
  final VoidCallback onDeviceClear;
  const _AdminContent(
      {required this.onMarkAttendance, required this.onDeviceClear});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      _BigCTA(onTap: onMarkAttendance),
      const SizedBox(height: 26),

      // ── My Section ────────────────────────────────────────────
      const _Label('My Section'),
      const SizedBox(height: 12),
      _HorizChips(items: [
        _ChipData(
            icon: Icons.calendar_today_rounded,
            label: 'Attendance',
            color: AppTheme.chipAttendance,
            onTap: () => Get.toNamed('/user-summary')),
        _ChipData(
            icon: Icons.beach_access_rounded,
            label: 'Holidays',
            color: AppTheme.chipHoliday,
            onTap: () => Get.toNamed('/holidays')),
        _ChipData(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            color: AppTheme.chipPerformance,
            onTap: () => Get.toNamed('/performance')),
        _ChipData(
            icon: Icons.event_note_rounded,
            label: 'Leave',
            color: const Color(0xFF0D9488),
            onTap: () => Get.toNamed('/leave')),
        // ✅ Admin can also track their own location
        _ChipData(
            icon: Icons.map_rounded,
            label: 'Location',
            color: const Color(0xFF6366F1),
            onTap: () => Get.toNamed('/my-location')),
      ]),
      const SizedBox(height: 26),

      // ── Admin Panel ───────────────────────────────────────────
      const _Label('Admin Panel'),
      const SizedBox(height: 12),
      _GroupedBox(children: [
        _GroupRow(
          icon: Icons.groups_rounded,
          label: 'Summary',
          sub: 'All employee attendance',
          color: AppTheme.primary,
          onTap: () => Get.toNamed('/admin'),
          isFirst: true,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.home_work_outlined,
          label: 'WFH Requests',
          sub: 'Manage work from home approvals',
          color: AppTheme.chipWFH,
          onTap: () => Get.toNamed('/wfh-admin'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.event_note_rounded,
          label: 'Leave Requests',
          sub: 'Manage employee leave approvals',
          color: const Color(0xFF0D9488),
          onTap: () => Get.toNamed('/leave'),
          isFirst: false,
          isLast: false,
        ),
        // ✅ Location Tracking — ADMIN ONLY
        _GroupRow(
          icon: Icons.location_on_rounded,
          label: 'Location Tracking',
          sub: 'Track employee field movements',
          color: const Color(0xFF6366F1),
          onTap: () => Get.toNamed('/admin-location'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.rate_review_rounded,
          label: 'Performance Reviews',
          sub: 'Submit & manage employee reviews',
          color: AppTheme.accent,
          onTap: () => Get.toNamed('/performance/reviews'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.notifications_rounded,
          label: 'Notifications',
          sub: 'Send & manage notifications',
          color: AppTheme.chipNotification,
          onTap: () => Get.toNamed('/notifications'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          sub: 'Manage FAQs & contact messages',
          color: AppTheme.info,
          onTap: () => Get.toNamed('/help-support'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.phonelink_erase_rounded,
          label: 'Clear Device',
          sub: 'Reset user device binding',
          color: AppTheme.error,
          onTap: onDeviceClear,
          isFirst: false,
          isLast: true,
          isDanger: true,
        ),
      ]),

      // ── Daily Task Card ───────────────────────────────────────
      const SizedBox(height: 26),
      const _Label('Daily Tasks'),
      const SizedBox(height: 12),
      const _DailyTaskCard(),

      const SizedBox(height: 26),
      const _TipBanner(),
      const SizedBox(height: 8),
    ]);
  }
}

// ─────────────────────────────────────────────
//  USER CONTENT
// ─────────────────────────────────────────────
class _UserContent extends StatelessWidget {
  final VoidCallback onMarkAttendance;
  const _UserContent({required this.onMarkAttendance});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    final Color shiftColor;
    final String shiftLabel;
    final IconData shiftIcon;
    if (hour < 9) {
      shiftLabel = 'Shift Not Started';
      shiftColor = AppTheme.warning;
      shiftIcon = Icons.schedule_rounded;
    } else if (hour < 18) {
      shiftLabel = 'Shift In Progress';
      shiftColor = AppTheme.success;
      shiftIcon = Icons.play_circle_outline_rounded;
    } else {
      shiftLabel = 'Shift Ended';
      shiftColor = AppTheme.textSecondary;
      shiftIcon = Icons.check_circle_outline_rounded;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      _BigCTA(onTap: onMarkAttendance),
      const SizedBox(height: 26),

      // ── Quick Access ──────────────────────────────────────────
      const _Label('Quick Access'),
      const SizedBox(height: 12),
      _HorizChips(items: [
        _ChipData(
            icon: Icons.calendar_today_rounded,
            label: 'Attendance',
            color: AppTheme.chipAttendance,
            onTap: () => Get.toNamed('/user-summary')),
        _ChipData(
            icon: Icons.beach_access_rounded,
            label: 'Holidays',
            color: AppTheme.chipHoliday,
            onTap: () => Get.toNamed('/holidays')),
        _ChipData(
            icon: Icons.bar_chart_rounded,
            label: 'Performance',
            color: AppTheme.chipPerformance,
            onTap: () => Get.toNamed('/performance')),
        _ChipData(
            icon: Icons.home_work_outlined,
            label: 'WFH',
            color: AppTheme.chipWFH,
            onTap: () => Get.toNamed('/wfh')),
        _ChipData(
            icon: Icons.event_note_rounded,
            label: 'Leave',
            color: const Color(0xFF0D9488),
            onTap: () => Get.toNamed('/leave')),
        // ✅ User can track their own location
        _ChipData(
            icon: Icons.map_rounded,
            label: 'Location',
            color: const Color(0xFF6366F1),
            onTap: () => Get.toNamed('/my-location')),
      ]),

      // ── Today's Shift ─────────────────────────────────────────
      const SizedBox(height: 26),
      const _Label("Today's Shift"),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration(),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: shiftColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(shiftIcon, color: shiftColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shiftLabel,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: shiftColor)),
                  Text(DateFormat('hh:mm a  |  dd MMM yyyy').format(now),
                      style: AppTheme.caption),
                ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: shiftColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Today',
                style: TextStyle(
                    fontSize: 11,
                    color: shiftColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins')),
          ),
        ]),
      ),

      // ── Daily Task Card ───────────────────────────────────────
      const SizedBox(height: 26),
      const _Label('Daily Tasks'),
      const SizedBox(height: 12),
      const _DailyTaskCard(),

      // ── More Options ──────────────────────────────────────────
      const SizedBox(height: 26),
      const _Label('More Options'),
      const SizedBox(height: 12),
      _GroupedBox(children: [
        _GroupRow(
          icon: Icons.person_rounded,
          label: 'My Profile',
          sub: 'View & update your details',
          color: AppTheme.primary,
          onTap: () => Get.toNamed('/profile'),
          isFirst: true,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.notifications_rounded,
          label: 'Notifications',
          sub: 'View your alerts & reminders',
          color: AppTheme.chipNotification,
          onTap: () => Get.toNamed('/notifications'),
          isFirst: false,
          isLast: false,
        ),
        _GroupRow(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          sub: 'FAQs and contact us',
          color: AppTheme.info,
          onTap: () => Get.toNamed('/help-support'),
          isFirst: false,
          isLast: true,
        ),
      ]),

      const SizedBox(height: 26),
      const _TipBanner(),
      const SizedBox(height: 8),
    ]);
  }
}

// ─────────────────────────────────────────────
//  DAILY TASK CARD
// ─────────────────────────────────────────────
class _DailyTaskCard extends StatelessWidget {
  const _DailyTaskCard();

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'In Progress':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.timelapse_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DailyTaskController>();

    return GestureDetector(
      onTap: () => Get.toNamed('/daily-tasks'),
      child: Container(
        decoration: AppTheme.cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.task_alt_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Tasks",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text('Tap to manage all tasks',
                          style: AppTheme.caption),
                    ],
                  ),
                ),
                Obx(() {
                  final tasks = ctrl.todayMyTasks;
                  final completed =
                      tasks.where((t) => t.status == 'Completed').length;
                  final total = tasks.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$completed / $total Done',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textHint, size: 20),
              ],
            ),

            // ── Body ──────────────────────────────────────────
            Obx(() {
              if (ctrl.isLoadingToday.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary),
                    ),
                  ),
                );
              }

              final tasks = ctrl.todayMyTasks;

              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Icon(Icons.inbox_rounded,
                          color: AppTheme.textHint, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'No tasks logged today',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.toNamed('/daily-tasks'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+ Add',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final visible = tasks.take(3).toList();
              final extra = tasks.length - visible.length;

              return Column(
                children: [
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.divider),
                  const SizedBox(height: 10),
                  ...visible.map((task) {
                    final color = _statusColor(task.status);
                    final icon = _statusIcon(task.status);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.taskTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(task.projectName,
                                    style: AppTheme.caption),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (task.hoursSpent > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 6, top: 2),
                              child: Text(
                                '${task.hoursSpent}h',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.status,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (extra > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '+$extra more task${extra > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Builder(builder: (_) {
                    final total = tasks.length;
                    final done =
                        tasks.where((t) => t.status == 'Completed').length;
                    final progress = total == 0 ? 0.0 : done / total;
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.divider),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                    AppTheme.primary.withOpacity(0.1),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppTheme.success),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: AppTheme.success,
                            ),
                          ),
                        ]),
                      ],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.labelBold);
}

class _BigCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _BigCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: AppTheme.cardDecoration(),
        child: Row(children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle)),
              Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle)),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    color: AppTheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.fingerprint_rounded,
                    color: Colors.white, size: 24),
              ),
            ]),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mark Attendance', style: AppTheme.headline3),
                  const SizedBox(height: 4),
                  const Text('Clock in or out with fingerprint',
                      style: AppTheme.bodySmall),
                  const SizedBox(height: 10),
                  const Row(children: [
                    _MiniTag(label: 'Mark In', color: AppTheme.success),
                    SizedBox(width: 6),
                    _MiniTag(label: 'Mark Out', color: AppTheme.error),
                  ]),
                ]),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chevron_right_rounded,
                color: AppTheme.primary, size: 22),
          ),
        ]),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins')));
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ChipData(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _HorizChips extends StatelessWidget {
  final List<_ChipData> items;
  const _HorizChips({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.chipLabel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupedBox extends StatelessWidget {
  final List<Widget> children;
  const _GroupedBox({required this.children});
  @override
  Widget build(BuildContext context) => Container(
      decoration: AppTheme.cardDecoration(radius: 22),
      child: Column(children: children));
}

class _GroupRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, sub;
  final VoidCallback onTap;
  final bool isFirst, isLast, isDanger, isComingSoon;

  const _GroupRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    this.isDanger = false,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isComingSoon
              ? AppTheme.background
              : isDanger
                  ? AppTheme.errorLight.withOpacity(0.4)
                  : null,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(22) : Radius.zero,
            bottom: isLast ? const Radius.circular(22) : Radius.zero,
          ),
          border: !isLast
              ? const Border(
                  bottom: BorderSide(color: AppTheme.divider, width: 1))
              : null,
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: (isComingSoon ? AppTheme.textHint : color)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(icon,
                color: isComingSoon ? AppTheme.textHint : color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: isComingSoon
                                  ? AppTheme.textHint
                                  : isDanger
                                      ? AppTheme.error
                                      : AppTheme.textPrimary)),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppTheme.shimmerBase,
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('Soon',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                                fontFamily: 'Poppins')),
                      ),
                    ],
                  ]),
                  Text(sub, style: AppTheme.caption),
                ]),
          ),
          Icon(Icons.chevron_right_rounded,
              color: isComingSoon
                  ? AppTheme.shimmerBase
                  : isDanger
                      ? AppTheme.error
                      : AppTheme.textHint,
              size: 20),
        ]),
      ),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final tip = hour < 9
        ? 'Start your day strong — punctuality builds trust!'
        : hour < 12
            ? 'Great morning! Stay focused and productive.'
            : hour < 15
                ? 'Keep the momentum — you\'re doing great!'
                : hour < 18
                    ? 'Almost done — finish the day strong!'
                    : 'Don\'t forget to Mark Out before you leave.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: AppTheme.tipDecoration,
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(tip,
              style: AppTheme.bodySmall
                  .copyWith(fontWeight: FontWeight.w500, height: 1.4)),
        ),
      ]),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SheetBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
        ]),
      ),
    );
  }
}