// // lib/screens/attendance/home_screen.dart
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
// //  BiometricHelper
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

// // ─────────────────────────────────────────────
// //  HomeScreen
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) => type == 'in' ? 'device_bind_in' : 'device_bind_out';

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

//   // ── Location ──────────────────────────────
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
//         content: const Text('Please turn on your device location (GPS) to mark attendance.'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.settings),
//             label: const Text('Open Settings'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

//   // ── Biometric ────────────────────────────
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
//       final ok = await _BiometricHelper.authenticate('Place your finger to continue');
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
//         message = 'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Biometric is locked. Please wait and try again.';
//         break;
//     }
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
//             TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

//   // ── Bottom Sheet: Mark In / Mark Out ──────
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
//             const Text('Mark Attendance',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: Colors.black87,
//                 )),
//             const SizedBox(height: 4),
//             const Text('Select action to continue',
//                 style: TextStyle(
//                     fontSize: 13, color: Colors.grey, fontFamily: 'Poppins')),
//             const SizedBox(height: 28),

//             // Mark In
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
//                 label: const Text('Mark In',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
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

//             // Mark Out
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
//                 label: const Text('Mark Out',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
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

//             // Cancel
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
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15, color: Colors.grey, fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Logout ────────────────────────────────
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
//                       fontSize: 14, color: Colors.grey, fontFamily: 'Poppins')),
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
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.back();
//                       Get.find<AuthController>().logout();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.error,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       elevation: 0,
//                     ),
//                     child: const Text('Logout',
//                         style: TextStyle(
//                             fontFamily: 'Poppins',
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Device Clear ──────────────────────────
//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
//                         fontSize: 13, color: Colors.grey, fontFamily: 'Poppins')),
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
//                     if (v == null || v.trim().isEmpty) return 'User ID required';
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
//                                   if (!formKey.currentState!.validate()) return;
//                                   isLoading.value = true;
//                                   try {
//                                     await _box.remove(_keyFor('in'));
//                                     await _box.remove(_keyFor('out'));
//                                     Get.back();
//                                     _showSnack('Device binding cleared.');
//                                   } catch (e) {
//                                     _showSnack('Failed: $e', isError: true);
//                                   } finally {
//                                     isLoading.value = false;
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.error,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14)),
//                             elevation: 0,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                       color: Colors.white, strokeWidth: 2),
//                                 )
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
//     final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ── Top Bar ──────────────────────────────
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     const Text('Dashboard',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w800,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textPrimary,
//                         )),
//                     Text(today,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins',
//                         )),
//                   ]),
//                   GestureDetector(
//                     onTap: _showLogoutDialog,
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: AppTheme.cardBackground,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.08),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4)),
//                         ],
//                       ),
//                       child: const Icon(Icons.power_settings_new_rounded,
//                           color: AppTheme.error, size: 22),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // ── User Card ────────────────────────────
//               Obx(() => _UserCard(
//                     name: auth.userName.value,
//                     email: auth.userEmail.value,
//                     role: auth.userRole.value,
//                   )),

//               const SizedBox(height: 16),

//               // ── Mark Attendance ──────────────────────
//               _MenuCard(
//                 icon: Icons.fingerprint_rounded,
//                 iconBg: AppTheme.primaryLight,
//                 iconColor: AppTheme.primary,
//                 title: 'Mark Attendance',
//                 subtitle: 'Tap to clock in or out',
//                 onTap: _showAttendanceSheet,
//               ),

//               const SizedBox(height: 12),

//               // ── My Attendance ────────────────────────
//               _MenuCard(
//                 icon: Icons.calendar_today_rounded,
//                 iconBg: AppTheme.secondaryLight,
//                 iconColor: AppTheme.secondary,
//                 title: 'My Attendance',
//                 subtitle: 'View your records & summary',
//                 onTap: () => Get.toNamed('/user-summary'),
//               ),

//               const SizedBox(height: 24),

//               // ── Admin Panel ──────────────────────────
//               Obx(() => auth.isAdmin
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           const Icon(Icons.admin_panel_settings_rounded,
//                               color: AppTheme.primary, size: 20),
//                           const SizedBox(width: 8),
//                           const Text('Admin Panel',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: AppTheme.textPrimary,
//                               )),
//                         ]),
//                         const SizedBox(height: 14),
//                         Row(children: [
//                           Expanded(
//                             child: _AdminCard(
//                               icon: Icons.groups_rounded,
//                               iconBg: AppTheme.primaryLight,
//                               iconColor: AppTheme.primary,
//                               label: 'Summary',
//                               onTap: () => Get.toNamed('/admin'),
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           Expanded(
//                             child: _AdminCard(
//                               icon: Icons.phonelink_erase_rounded,
//                               iconBg: AppTheme.errorLight,
//                               iconColor: AppTheme.error,
//                               label: 'Clear Device',
//                               onTap: _showDeviceClearDialog,
//                             ),
//                           ),
//                         ]),
//                         const SizedBox(height: 24),
//                       ],
//                     )
//                   : const SizedBox.shrink()),

//               // ── Morning Banner ───────────────────────
//               _MorningBanner(),

//               const SizedBox(height: 8),

//               // ── Footer ───────────────────────────────
//               Center(
//                 child: Column(children: [
//                   const Text('Attendance Management System',
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins')),
//                   const SizedBox(height: 2),
//                   Text(_appVersion,
//                       style: const TextStyle(
//                           fontSize: 11,
//                           color: AppTheme.textHint,
//                           fontFamily: 'Poppins')),
//                 ]),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  User Card
// // ─────────────────────────────────────────────
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
//       padding: const EdgeInsets.all(18),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(children: [
//         Container(
//           width: 62,
//           height: 62,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [AppTheme.secondary, AppTheme.accent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Center(
//             child: Text(
//               name.isNotEmpty ? name[0].toUpperCase() : 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(name,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: AppTheme.textPrimary,
//                 )),
//             const SizedBox(height: 2),
//             Text(email.isNotEmpty ? email : '—',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     color: AppTheme.textSecondary,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
//               ),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 const Icon(Icons.star_rounded, color: AppTheme.primary, size: 13),
//                 const SizedBox(width: 4),
//                 Text(role.toLowerCase(),
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                     )),
//               ]),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Menu Card
// // ─────────────────────────────────────────────
// class _MenuCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _MenuCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//                 color: iconBg, borderRadius: BorderRadius.circular(16)),
//             child: Icon(icon, color: iconColor, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary,
//                   )),
//               const SizedBox(height: 3),
//               Text(subtitle,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       color: AppTheme.textSecondary,
//                       fontFamily: 'Poppins')),
//             ]),
//           ),
//           const Icon(Icons.chevron_right_rounded,
//               color: AppTheme.textHint, size: 24),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Admin Card
// // ─────────────────────────────────────────────
// class _AdminCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String label;
//   final VoidCallback onTap;

//   const _AdminCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//         decoration: AppTheme.cardDecoration(),
//         child: Column(children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//                 color: iconBg, borderRadius: BorderRadius.circular(14)),
//             child: Icon(icon, color: iconColor, size: 26),
//           ),
//           const SizedBox(height: 10),
//           Text(label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textPrimary,
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Morning Banner
// // ─────────────────────────────────────────────
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
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
//       decoration: AppTheme.softOrangeDecoration,
//       child: Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.wb_sunny_rounded, color: AppTheme.primary, size: 22),
//           const SizedBox(width: 8),
//           Text(greeting,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.primary,
//               )),
//         ]),
//         const SizedBox(height: 4),
//         Text('Today is $dayName',
//             style: const TextStyle(
//                 fontSize: 13,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins')),
//         const SizedBox(height: 20),
//         IntrinsicHeight(
//           child: Row(
//             children: [
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.check_circle_outline_rounded,
//                       label: 'Stay Safe')),
//               VerticalDivider(
//                   color: AppTheme.primary.withOpacity(0.3),
//                   thickness: 1,
//                   width: 1),
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.alarm_rounded, label: 'On Time')),
//               VerticalDivider(
//                   color: AppTheme.primary.withOpacity(0.3),
//                   thickness: 1,
//                   width: 1),
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.trending_up_rounded, label: 'Good Work')),
//             ],
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Banner Chip
// // ─────────────────────────────────────────────
// class _BannerChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _BannerChip({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Icon(icon, color: AppTheme.primary, size: 26),
//       const SizedBox(height: 6),
//       Text(label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Poppins',
//             color: AppTheme.primary,
//           )),
//     ]);
//   }
// }










// // lib/screens/attendance/home_screen.dart
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
// //  BiometricHelper
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

// // ─────────────────────────────────────────────
// //  HomeScreen
// // ─────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _box = GetStorage();
//   String _appVersion = 'v1.0.0';

//   String _keyFor(String type) => type == 'in' ? 'device_bind_in' : 'device_bind_out';

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

//   // ── Location ──────────────────────────────
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
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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

//   // ── Biometric ────────────────────────────
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
//             TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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

//   // ── Bottom Sheet: Mark In / Mark Out ──────
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
//             const Text('Mark Attendance',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: Colors.black87,
//                 )),
//             const SizedBox(height: 4),
//             const Text('Select action to continue',
//                 style: TextStyle(
//                     fontSize: 13, color: Colors.grey, fontFamily: 'Poppins')),
//             const SizedBox(height: 28),

//             // Mark In
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.login_rounded,
//                     color: Colors.white, size: 20),
//                 label: const Text('Mark In',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
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

//             // Mark Out
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.logout_rounded,
//                     color: Colors.white, size: 20),
//                 label: const Text('Mark Out',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
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

//             // Cancel
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
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Logout ────────────────────────────────
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.back();
//                       Get.find<AuthController>().logout();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.error,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       elevation: 0,
//                     ),
//                     child: const Text('Logout',
//                         style: TextStyle(
//                             fontFamily: 'Poppins',
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Device Clear ──────────────────────────
//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
//                     if (v == null || v.trim().isEmpty) return 'User ID required';
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
//                                   if (!formKey.currentState!.validate()) return;
//                                   isLoading.value = true;
//                                   try {
//                                     await _box.remove(_keyFor('in'));
//                                     await _box.remove(_keyFor('out'));
//                                     Get.back();
//                                     _showSnack('Device binding cleared.');
//                                   } catch (e) {
//                                     _showSnack('Failed: $e', isError: true);
//                                   } finally {
//                                     isLoading.value = false;
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.error,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14)),
//                             elevation: 0,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                       color: Colors.white, strokeWidth: 2),
//                                 )
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
//     final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ── Top Bar ──────────────────────────────
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Dashboard',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w800,
//                               fontFamily: 'Poppins',
//                               color: AppTheme.textPrimary,
//                             )),
//                         Text(today,
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: AppTheme.textSecondary,
//                               fontFamily: 'Poppins',
//                             )),
//                       ]),
//                   GestureDetector(
//                     onTap: _showLogoutDialog,
//                     child: Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: AppTheme.cardBackground,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.08),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4)),
//                         ],
//                       ),
//                       child: const Icon(Icons.power_settings_new_rounded,
//                           color: AppTheme.error, size: 22),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // ── User Card ────────────────────────────
//               Obx(() => _UserCard(
//                     name: auth.userName.value,
//                     email: auth.userEmail.value,
//                     role: auth.userRole.value,
//                   )),

//               const SizedBox(height: 16),

//               // ── Mark Attendance ──────────────────────
//               _MenuCard(
//                 icon: Icons.fingerprint_rounded,
//                 iconBg: AppTheme.primaryLight,
//                 iconColor: AppTheme.primary,
//                 title: 'Mark Attendance',
//                 subtitle: 'Tap to clock in or out',
//                 onTap: _showAttendanceSheet,
//               ),

//               const SizedBox(height: 12),

//               // ── My Attendance ────────────────────────
//               _MenuCard(
//                 icon: Icons.calendar_today_rounded,
//                 iconBg: AppTheme.secondaryLight,
//                 iconColor: AppTheme.secondary,
//                 title: 'My Attendance',
//                 subtitle: 'View your records & summary',
//                 onTap: () => Get.toNamed('/user-summary'),
//               ),

//               const SizedBox(height: 12),

//               // ── Holidays (All Users) ─────────────────
//               _MenuCard(
//                 icon: Icons.beach_access_rounded,
//                 iconBg: const Color(0xFFFFF3E0),
//                 iconColor: const Color(0xFFFF9800),
//                 title: 'Holidays',
//                 subtitle: 'View public & company holidays',
//                 onTap: () => Get.toNamed('/holidays'),
//               ),

//               const SizedBox(height: 24),

//               // ── Admin Panel ──────────────────────────
//               Obx(() => auth.isAdmin
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           const Icon(Icons.admin_panel_settings_rounded,
//                               color: AppTheme.primary, size: 20),
//                           const SizedBox(width: 8),
//                           const Text('Admin Panel',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: AppTheme.textPrimary,
//                               )),
//                         ]),
//                         const SizedBox(height: 14),
//                         Row(children: [
//                           Expanded(
//                             child: _AdminCard(
//                               icon: Icons.groups_rounded,
//                               iconBg: AppTheme.primaryLight,
//                               iconColor: AppTheme.primary,
//                               label: 'Summary',
//                               onTap: () => Get.toNamed('/admin'),
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           Expanded(
//                             child: _AdminCard(
//                               icon: Icons.phonelink_erase_rounded,
//                               iconBg: AppTheme.errorLight,
//                               iconColor: AppTheme.error,
//                               label: 'Clear Device',
//                               onTap: _showDeviceClearDialog,
//                             ),
//                           ),
//                         ]),
//                         const SizedBox(height: 24),
//                       ],
//                     )
//                   : const SizedBox.shrink()),

//               // ── Morning Banner ───────────────────────
//               _MorningBanner(),

//               const SizedBox(height: 8),

//               // ── Footer ───────────────────────────────
//               Center(
//                 child: Column(children: [
//                   const Text('Attendance Management System',
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins')),
//                   const SizedBox(height: 2),
//                   Text(_appVersion,
//                       style: const TextStyle(
//                           fontSize: 11,
//                           color: AppTheme.textHint,
//                           fontFamily: 'Poppins')),
//                 ]),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  User Card
// // ─────────────────────────────────────────────
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
//       padding: const EdgeInsets.all(18),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(children: [
//         Container(
//           width: 62,
//           height: 62,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [AppTheme.secondary, AppTheme.accent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Center(
//             child: Text(
//               name.isNotEmpty ? name[0].toUpperCase() : 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(name,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: AppTheme.textPrimary,
//                 )),
//             const SizedBox(height: 2),
//             Text(email.isNotEmpty ? email : '—',
//                 style: const TextStyle(
//                     fontSize: 13,
//                     color: AppTheme.textSecondary,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 6),
//             Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryLight,
//                 borderRadius: BorderRadius.circular(20),
//                 border:
//                     Border.all(color: AppTheme.primary.withOpacity(0.3)),
//               ),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 const Icon(Icons.star_rounded,
//                     color: AppTheme.primary, size: 13),
//                 const SizedBox(width: 4),
//                 Text(role.toLowerCase(),
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                     )),
//               ]),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Menu Card
// // ─────────────────────────────────────────────
// class _MenuCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _MenuCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//                 color: iconBg, borderRadius: BorderRadius.circular(16)),
//             child: Icon(icon, color: iconColor, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.textPrimary,
//                       )),
//                   const SizedBox(height: 3),
//                   Text(subtitle,
//                       style: const TextStyle(
//                           fontSize: 13,
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins')),
//                 ]),
//           ),
//           const Icon(Icons.chevron_right_rounded,
//               color: AppTheme.textHint, size: 24),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Admin Card
// // ─────────────────────────────────────────────
// class _AdminCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String label;
//   final VoidCallback onTap;

//   const _AdminCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//         decoration: AppTheme.cardDecoration(),
//         child: Column(children: [
//           Container(
//             width: 54,
//             height: 54,
//             decoration: BoxDecoration(
//                 color: iconBg, borderRadius: BorderRadius.circular(14)),
//             child: Icon(icon, color: iconColor, size: 26),
//           ),
//           const SizedBox(height: 10),
//           Text(label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textPrimary,
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Morning Banner
// // ─────────────────────────────────────────────
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
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
//       decoration: AppTheme.softOrangeDecoration,
//       child: Column(children: [
//         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.wb_sunny_rounded,
//               color: AppTheme.primary, size: 22),
//           const SizedBox(width: 8),
//           Text(greeting,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.primary,
//               )),
//         ]),
//         const SizedBox(height: 4),
//         Text('Today is $dayName',
//             style: const TextStyle(
//                 fontSize: 13,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins')),
//         const SizedBox(height: 20),
//         IntrinsicHeight(
//           child: Row(
//             children: [
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.check_circle_outline_rounded,
//                       label: 'Stay Safe')),
//               VerticalDivider(
//                   color: AppTheme.primary.withOpacity(0.3),
//                   thickness: 1,
//                   width: 1),
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.alarm_rounded, label: 'On Time')),
//               VerticalDivider(
//                   color: AppTheme.primary.withOpacity(0.3),
//                   thickness: 1,
//                   width: 1),
//               Expanded(
//                   child: _BannerChip(
//                       icon: Icons.trending_up_rounded,
//                       label: 'Good Work')),
//             ],
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Banner Chip
// // ─────────────────────────────────────────────
// class _BannerChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _BannerChip({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Icon(icon, color: AppTheme.primary, size: 26),
//       const SizedBox(height: 6),
//       Text(label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Poppins',
//             color: AppTheme.primary,
//           )),
//     ]);
//   }
// }



// // lib/screens/attendance/home_screen.dart
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
// //  BiometricHelper
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS)
//       return (await info.iosInfo).identifierForVendor ?? 'unknown';
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

// // ─────────────────────────────────────────────
// //  HomeScreen
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

//   // ── Location ──────────────────────────────
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
//             borderRadius: BorderRadius.circular(20)),
//         title: const Row(children: [
//           Icon(Icons.location_off, color: Colors.orange),
//           SizedBox(width: 10),
//           Text('Location Required'),
//         ]),
//         content: const Text(
//             'Please turn on your device location (GPS) to mark attendance.'),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel')),
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

//   // ── Biometric ────────────────────────────
//   Future<bool> _handleBiometric(String type) async {
//     final supported = await _BiometricHelper.isSupported();
//     if (!supported) {
//       _handleBiometricError(BiometricError.hardwareNotFound);
//       return false;
//     }

//     final deviceId = await _BiometricHelper.getDeviceId();
//     final savedDeviceId =
//         (_box.read<String>(_keyFor(type)) ?? '').trim();

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
//           _showSnack('Fingerprint not recognized. Try again.',
//               isError: true);
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
//       _showSnack('Wrong device! Use your registered device.',
//           isError: true);
//       return false;
//     }

//     try {
//       final ok = await _BiometricHelper
//           .authenticate('Place your finger to continue');
//       if (!ok) {
//         _showSnack('Fingerprint not recognized. Try again.',
//             isError: true);
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
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20)),
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
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK',
//                 style: TextStyle(color: Colors.white)),
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
//               Icon(Icons.fingerprint,
//                   color: AppTheme.primary, size: 28),
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

//   // ── Bottom Sheet: Mark In / Mark Out ──────
//   void _showAttendanceSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.vertical(top: Radius.circular(28)),
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
//             const Text('Mark Attendance',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: Colors.black87,
//                 )),
//             const SizedBox(height: 4),
//             const Text('Select action to continue',
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 28),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.login_rounded,
//                     color: Colors.white, size: 20),
//                 label: const Text('Mark In',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.success,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16),
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
//                 label: const Text('Mark Out',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                     )),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.error,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16),
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
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     side:
//                         BorderSide(color: Colors.grey.shade200),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.grey,
//                         fontFamily: 'Poppins')),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Logout ────────────────────────────────
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                     color: AppTheme.errorLight,
//                     shape: BoxShape.circle),
//                 child: const Icon(
//                     Icons.power_settings_new_rounded,
//                     color: AppTheme.error,
//                     size: 36),
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
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(14)),
//                       side: const BorderSide(
//                           color: AppTheme.divider),
//                     ),
//                     child: const Text('Cancel',
//                         style:
//                             TextStyle(fontFamily: 'Poppins')),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.back();
//                       Get.find<AuthController>().logout();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.error,
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(14)),
//                       elevation: 0,
//                     ),
//                     child: const Text('Logout',
//                         style: TextStyle(
//                             fontFamily: 'Poppins',
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Device Clear ──────────────────────────
//   void _showDeviceClearDialog() {
//     final userIdController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final isLoading = false.obs;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(24)),
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
//                       color: AppTheme.errorLight,
//                       shape: BoxShape.circle),
//                   child: const Icon(
//                       Icons.phonelink_erase_rounded,
//                       color: AppTheme.error,
//                       size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear',
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 6),
//                 const Text(
//                     'Enter the User ID to reset device binding.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly
//                   ],
//                   decoration: InputDecoration(
//                     labelText: 'User ID',
//                     hintText: 'e.g. 42',
//                     prefixIcon:
//                         const Icon(Icons.person_search_rounded),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(
//                           color: AppTheme.error, width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty)
//                       return 'User ID required';
//                     if (int.tryParse(v.trim()) == null)
//                       return 'Enter valid numeric ID';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(14)),
//                         side: const BorderSide(
//                             color: AppTheme.divider),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(
//                               fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Obx(() => ElevatedButton(
//                           onPressed: isLoading.value
//                               ? null
//                               : () async {
//                                   if (!formKey.currentState!
//                                       .validate()) return;
//                                   isLoading.value = true;
//                                   try {
//                                     await _box
//                                         .remove(_keyFor('in'));
//                                     await _box
//                                         .remove(_keyFor('out'));
//                                     Get.back();
//                                     _showSnack(
//                                         'Device binding cleared.');
//                                   } catch (e) {
//                                     _showSnack('Failed: $e',
//                                         isError: true);
//                                   } finally {
//                                     isLoading.value = false;
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.error,
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(14)),
//                             elevation: 0,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child:
//                                       CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2),
//                                 )
//                               : const Text('Clear Device',
//                                   style: TextStyle(
//                                       fontFamily: 'Poppins',
//                                       color: Colors.white,
//                                       fontWeight:
//                                           FontWeight.w600)),
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
//       backgroundColor:
//           isError ? AppTheme.error : AppTheme.success,
//       colorText: Colors.white,
//       icon: Icon(
//           isError
//               ? Icons.error_outline
//               : Icons.check_circle_outline,
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
//       // ✅ FIX: Wrapped with SingleChildScrollView to prevent overflow
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 20, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ── Top Bar ──────────────────────────────
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Dashboard',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w800,
//                             fontFamily: 'Poppins',
//                             color: AppTheme.textPrimary,
//                           )),
//                       Text(today,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: AppTheme.textSecondary,
//                             fontFamily: 'Poppins',
//                           )),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: _showLogoutDialog,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: AppTheme.cardBackground,
//                         borderRadius: BorderRadius.circular(14),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.08),
//                               blurRadius: 8,
//                               offset: const Offset(0, 3)),
//                         ],
//                       ),
//                       child: const Icon(
//                           Icons.power_settings_new_rounded,
//                           color: AppTheme.error,
//                           size: 20),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // ── User Card ────────────────────────────
//               Obx(() => _UserCard(
//                     name: auth.userName.value,
//                     email: auth.userEmail.value,
//                     role: auth.userRole.value,
//                   )),

//               const SizedBox(height: 10),

//               // ── Mark Attendance ──────────────────────
//               _ArrowMenuCard(
//                 icon: Icons.fingerprint_rounded,
//                 iconBg: AppTheme.primaryLight,
//                 iconColor: AppTheme.primary,
//                 arrowBg: AppTheme.primaryLight,
//                 arrowColor: AppTheme.primary,
//                 title: 'Mark Attendance',
//                 subtitle: 'Tap arrow to clock in or out',
//                 onArrowTap: _showAttendanceSheet,
//               ),

//               const SizedBox(height: 8),

//               // ── My Attendance ────────────────────────
//               _ArrowMenuCard(
//                 icon: Icons.calendar_today_rounded,
//                 iconBg: AppTheme.secondaryLight,
//                 iconColor: AppTheme.secondary,
//                 arrowBg: AppTheme.secondaryLight,
//                 arrowColor: AppTheme.secondary,
//                 title: 'My Attendance',
//                 subtitle: 'View your records & summary',
//                 onArrowTap: () => Get.toNamed('/user-summary'),
//               ),

//               const SizedBox(height: 8),

//               // ── Holidays ─────────────────────────────
//               _ArrowMenuCard(
//                 icon: Icons.beach_access_rounded,
//                 iconBg: const Color(0xFFFFF3E0),
//                 iconColor: const Color(0xFFFF9800),
//                 arrowBg: const Color(0xFFFFF3E0),
//                 arrowColor: const Color(0xFFFF9800),
//                 title: 'Holidays',
//                 subtitle: 'View public & company holidays',
//                 onArrowTap: () => Get.toNamed('/holidays'),
//               ),

//               const SizedBox(height: 10),

//               // ── Admin Panel ──────────────────────────
//               Obx(() => auth.isAdmin
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           const Icon(
//                               Icons.admin_panel_settings_rounded,
//                               color: AppTheme.primary,
//                               size: 18),
//                           const SizedBox(width: 6),
//                           const Text('Admin Panel',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: AppTheme.textPrimary,
//                               )),
//                         ]),
//                         const SizedBox(height: 8),

//                         _ArrowMenuCard(
//                           icon: Icons.groups_rounded,
//                           iconBg: AppTheme.primaryLight,
//                           iconColor: AppTheme.primary,
//                           arrowBg: AppTheme.primaryLight,
//                           arrowColor: AppTheme.primary,
//                           title: 'Summary',
//                           subtitle: 'View all employee attendance',
//                           onArrowTap: () => Get.toNamed('/admin'),
//                         ),

//                         const SizedBox(height: 8),

//                         _ArrowMenuCard(
//                           icon: Icons.phonelink_erase_rounded,
//                           iconBg: AppTheme.errorLight,
//                           iconColor: AppTheme.error,
//                           arrowBg: AppTheme.errorLight,
//                           arrowColor: AppTheme.error,
//                           title: 'Clear Device',
//                           subtitle: 'Reset user device binding',
//                           onArrowTap: _showDeviceClearDialog,
//                         ),

//                         const SizedBox(height: 10),
//                       ],
//                     )
//                   : const SizedBox.shrink()),

//               // ── Morning Banner ───────────────────────
//               _MorningBanner(),

//               const SizedBox(height: 6),

//               // ── Footer ───────────────────────────────
//               Center(
//                 child: Column(children: [
//                   const Text('Attendance Management System',
//                       style: TextStyle(
//                           fontSize: 11,
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins')),
//                   const SizedBox(height: 1),
//                   Text(_appVersion,
//                       style: const TextStyle(
//                           fontSize: 10,
//                           color: AppTheme.textHint,
//                           fontFamily: 'Poppins')),
//                 ]),
//               ),

//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  User Card  (compact version)
// // ─────────────────────────────────────────────
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
//                 Text(name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary,
//                     )),
//                 const SizedBox(height: 1),
//                 Text(email.isNotEmpty ? email : '—',
//                     style: const TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
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
//                         Text(role.toLowerCase(),
//                             style: const TextStyle(
//                               fontSize: 10,
//                               color: AppTheme.primary,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'Poppins',
//                             )),
//                       ]),
//                 ),
//               ]),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Arrow Menu Card  (compact version)
// // ─────────────────────────────────────────────
// class _ArrowMenuCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final Color arrowBg;
//   final Color arrowColor;
//   final String title;
//   final String subtitle;
//   final VoidCallback onArrowTap;

//   const _ArrowMenuCard({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.arrowBg,
//     required this.arrowColor,
//     required this.title,
//     required this.subtitle,
//     required this.onArrowTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//           horizontal: 16, vertical: 14),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(children: [
//         // ── Left Icon ────────────────────────
//         Container(
//           width: 52,
//           height: 52,
//           decoration: BoxDecoration(
//               color: iconBg,
//               borderRadius: BorderRadius.circular(15)),
//           child: Icon(icon, color: iconColor, size: 26),
//         ),
//         const SizedBox(width: 14),

//         // ── Title + Subtitle ──
//         Expanded(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary,
//                     )),
//                 const SizedBox(height: 2),
//                 Text(subtitle,
//                     style: const TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins')),
//               ]),
//         ),

//         // ── Arrow ──
//         GestureDetector(
//           onTap: onArrowTap,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: arrowBg,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               Icons.chevron_right_rounded,
//               color: arrowColor,
//               size: 22,
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Morning Banner  (compact fixed size)
// // ─────────────────────────────────────────────
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
//       padding: const EdgeInsets.symmetric(
//           vertical: 44, horizontal: 20),
//       decoration: AppTheme.softOrangeDecoration,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.wb_sunny_rounded,
//                     color: AppTheme.primary, size: 20),
//                 const SizedBox(width: 8),
//                 Text(greeting,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.primary,
//                     )),
//               ]),
//           const SizedBox(height: 3),
//           Text('Today is $dayName',
//               style: const TextStyle(
//                   fontSize: 13,
//                   color: AppTheme.textSecondary,
//                   fontFamily: 'Poppins')),
//           const SizedBox(height: 32),
//           IntrinsicHeight(
//             child: Row(
//               children: [
//                 Expanded(
//                     child: _BannerChip(
//                         icon: Icons.check_circle_outline_rounded,
//                         label: 'Stay Safe')),
//                 VerticalDivider(
//                     color: AppTheme.primary.withOpacity(0.3),
//                     thickness: 1,
//                     width: 1),
//                 Expanded(
//                     child: _BannerChip(
//                         icon: Icons.alarm_rounded,
//                         label: 'On Time')),
//                 VerticalDivider(
//                     color: AppTheme.primary.withOpacity(0.3),
//                     thickness: 1,
//                     width: 1),
//                 Expanded(
//                     child: _BannerChip(
//                         icon: Icons.trending_up_rounded,
//                         label: 'Good Work')),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Banner Chip
// // ─────────────────────────────────────────────
// class _BannerChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _BannerChip({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Icon(icon, color: AppTheme.primary, size: 24),
//       const SizedBox(height: 5),
//       Text(label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Poppins',
//             color: AppTheme.primary,
//           )),
//     ]);
//   }
// }





// lib/screens/attendance/home_screen.dart
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
import '../../core/theme/app_theme.dart';

class _BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await info.androidInfo).id;
    if (Platform.isIOS)
      return (await info.iosInfo).identifierForVendor ?? 'unknown';
    return 'unknown';
  }

  static Future<bool> isSupported() async {
    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    return canCheck && supported;
  }

  static Future<bool> authenticate(String reason) async {
    try {
      final result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return result;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.location_off, color: Colors.orange),
          SizedBox(width: 10),
          Text('Location Required'),
        ]),
        content: const Text(
            'Please turn on your device location (GPS) to mark attendance.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
    switch (error) {
      case BiometricError.hardwareNotFound:
        title = 'No Biometric Sensor';
        message = 'Biometric sensor not available on this device.';
        break;
      case BiometricError.notEnrolled:
        title = 'Fingerprint Not Set Up';
        message =
            'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
        break;
      case BiometricError.lockedOut:
        title = 'Too Many Attempts';
        message = 'Biometric is locked. Please wait and try again.';
        break;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(
            error == BiometricError.hardwareNotFound
                ? Icons.no_cell_rounded
                : error == BiometricError.lockedOut
                    ? Icons.lock_clock_rounded
                    : Icons.fingerprint,
            color: AppTheme.error,
          ),
          const SizedBox(width: 10),
          Text(title),
        ]),
        content: Text(message),
        actions: [
          if (error == BiometricError.notEnrolled)
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancel')),
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
              Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
              const SizedBox(width: 10),
              const Text('Register Device'),
            ]),
            content: Text(
              'First time setup for ${type == 'in' ? 'Mark In' : 'Mark Out'}.\n\n'
              'We will bind this login to your phone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.fingerprint_rounded,
                  color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 14),
            const Text('Mark Attendance',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Colors.black87)),
            const SizedBox(height: 4),
            const Text('Select action to continue',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey, fontFamily: 'Poppins')),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded,
                    color: Colors.white, size: 20),
                label: const Text('Mark In',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.back();
                  _onAttendanceTap('/mark-in', 'in');
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 20),
                label: const Text('Mark Out',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.back();
                  _onAttendanceTap('/mark-out', 'out');
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: AppTheme.errorLight, shape: BoxShape.circle),
              child: const Icon(Icons.power_settings_new_rounded,
                  color: AppTheme.error, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Logout?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            const Text('Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey, fontFamily: 'Poppins')),
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
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.find<AuthController>().logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Logout',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ]),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: AppTheme.errorLight, shape: BoxShape.circle),
                child: const Icon(Icons.phonelink_erase_rounded,
                    color: AppTheme.error, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Device Clear',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              const Text('Enter the User ID to reset device binding.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontFamily: 'Poppins')),
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
                  if (v == null || v.trim().isEmpty) return 'User ID required';
                  if (int.tryParse(v.trim()) == null)
                    return 'Enter valid numeric ID';
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
                  child: Obx(() => ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                isLoading.value = true;
                                try {
                                  await _box.remove(_keyFor('in'));
                                  await _box.remove(_keyFor('out'));
                                  Get.back();
                                  _showSnack('Device binding cleared.');
                                } catch (e) {
                                  _showSnack('Failed: $e', isError: true);
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
                      )),
                ),
              ]),
            ]),
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

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final today = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dashboard',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: AppTheme.textPrimary)),
                        Text(today,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontFamily: 'Poppins')),
                      ]),
                  GestureDetector(
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.power_settings_new_rounded,
                          color: AppTheme.error, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── User Card ────────────────────────────
              Obx(() => _UserCard(
                    name: auth.userName.value,
                    email: auth.userEmail.value,
                    role: auth.userRole.value,
                  )),

              const SizedBox(height: 10),

              // ── Content: Admin vs Normal ─────────────
              Expanded(
                child: Obx(() => auth.isAdmin
                    ? _AdminLayout(
                        onMarkAttendance: _showAttendanceSheet,
                        onDeviceClear: _showDeviceClearDialog,
                        appVersion: _appVersion,
                      )
                    : _NormalUserLayout(
                        onMarkAttendance: _showAttendanceSheet,
                        appVersion: _appVersion,
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ADMIN LAYOUT — Fixed size cards + banner
// ─────────────────────────────────────────────
class _AdminLayout extends StatelessWidget {
  final VoidCallback onMarkAttendance;
  final VoidCallback onDeviceClear;
  final String appVersion;

  const _AdminLayout({
    required this.onMarkAttendance,
    required this.onDeviceClear,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        // ── Menu Cards ────────────────────────────
        _ArrowMenuCard(
          icon: Icons.fingerprint_rounded,
          iconBg: AppTheme.primaryLight,
          iconColor: AppTheme.primary,
          arrowBg: AppTheme.primaryLight,
          arrowColor: AppTheme.primary,
          title: 'Mark Attendance',
          subtitle: 'Tap arrow to clock in or out',
          onArrowTap: onMarkAttendance,
          large: true,
        ),
        const SizedBox(height: 8),
        _ArrowMenuCard(
          icon: Icons.calendar_today_rounded,
          iconBg: AppTheme.secondaryLight,
          iconColor: AppTheme.secondary,
          arrowBg: AppTheme.secondaryLight,
          arrowColor: AppTheme.secondary,
          title: 'My Attendance',
          subtitle: 'View your records & summary',
          onArrowTap: () => Get.toNamed('/user-summary'),
          large: true,
        ),
        const SizedBox(height: 8),
        _ArrowMenuCard(
          icon: Icons.beach_access_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFFF9800),
          arrowBg: const Color(0xFFFFF3E0),
          arrowColor: const Color(0xFFFF9800),
          title: 'Holidays',
          subtitle: 'View public & company holidays',
          onArrowTap: () => Get.toNamed('/holidays'),
          large: true,
        ),
        const SizedBox(height: 12),

        // ── Admin Panel Label ─────────────────────
        Row(children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: AppTheme.primary, size: 16),
          const SizedBox(width: 6),
          const Text('Admin Panel',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 6),

        _ArrowMenuCard(
          icon: Icons.groups_rounded,
          iconBg: AppTheme.primaryLight,
          iconColor: AppTheme.primary,
          arrowBg: AppTheme.primaryLight,
          arrowColor: AppTheme.primary,
          title: 'Summary',
          subtitle: 'View all employee attendance',
          onArrowTap: () => Get.toNamed('/admin'),
          large: true,
        ),
        const SizedBox(height: 8),
        _ArrowMenuCard(
          icon: Icons.phonelink_erase_rounded,
          iconBg: AppTheme.errorLight,
          iconColor: AppTheme.error,
          arrowBg: AppTheme.errorLight,
          arrowColor: AppTheme.error,
          title: 'Clear Device',
          subtitle: 'Reset user device binding',
          onArrowTap: onDeviceClear,
          large: true,
        ),
        const SizedBox(height: 12),

        // ── Good Morning Banner ───────────────────
        _MorningBanner(),
        const SizedBox(height: 10),

        // ── Footer ────────────────────────────────
        _FooterText(appVersion: appVersion),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  NORMAL USER LAYOUT — fixed cards + extras
// ─────────────────────────────────────────────
class _NormalUserLayout extends StatelessWidget {
  final VoidCallback onMarkAttendance;
  final String appVersion;

  const _NormalUserLayout({
    required this.onMarkAttendance,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        // ── 3 Fixed-height menu cards ──────────
        _ArrowMenuCard(
          icon: Icons.fingerprint_rounded,
          iconBg: AppTheme.primaryLight,
          iconColor: AppTheme.primary,
          arrowBg: AppTheme.primaryLight,
          arrowColor: AppTheme.primary,
          title: 'Mark Attendance',
          subtitle: 'Tap arrow to clock in or out',
          onArrowTap: onMarkAttendance,
          large: true,
        ),
        const SizedBox(height: 8),
        _ArrowMenuCard(
          icon: Icons.calendar_today_rounded,
          iconBg: AppTheme.secondaryLight,
          iconColor: AppTheme.secondary,
          arrowBg: AppTheme.secondaryLight,
          arrowColor: AppTheme.secondary,
          title: 'My Attendance',
          subtitle: 'View your records & summary',
          onArrowTap: () => Get.toNamed('/user-summary'),
          large: true,
        ),
        const SizedBox(height: 8),
        _ArrowMenuCard(
          icon: Icons.beach_access_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFFF9800),
          arrowBg: const Color(0xFFFFF3E0),
          arrowColor: const Color(0xFFFF9800),
          title: 'Holidays',
          subtitle: 'View public & company holidays',
          onArrowTap: () => Get.toNamed('/holidays'),
          large: true,
        ),

        const SizedBox(height: 12),

        // ── Today's Overview Card ──────────────
        _TodayOverviewCard(),

        const SizedBox(height: 10),

        // ── Morning Banner ─────────────────────
        _MorningBanner(),

        // ── Footer ────────────────────────────
        _FooterText(appVersion: appVersion),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Today's Overview Card  (normal user only)
// ─────────────────────────────────────────────
class _TodayOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    final String shiftStatus;
    final Color statusColor;
    final IconData statusIcon;
    if (hour < 9) {
      shiftStatus = 'Shift Not Started';
      statusColor = const Color(0xFFFF9800);
      statusIcon = Icons.schedule_rounded;
    } else if (hour < 18) {
      shiftStatus = 'Shift In Progress';
      statusColor = AppTheme.success;
      statusIcon = Icons.play_circle_rounded;
    } else {
      shiftStatus = 'Shift Ended';
      statusColor = AppTheme.textSecondary;
      statusIcon = Icons.check_circle_rounded;
    }

    final weekday = DateFormat('EEEE').format(now);
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Today's Overview",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, color: statusColor, size: 12),
              const SizedBox(width: 4),
              Text(shiftStatus,
                  style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins')),
            ]),
          ),
        ]),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
              child: _StatTile(
            icon: Icons.calendar_month_rounded,
            iconColor: AppTheme.primary,
            iconBg: AppTheme.primaryLight,
            label: 'Day',
            value: weekday.substring(0, 3),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _StatTile(
            icon: Icons.date_range_rounded,
            iconColor: const Color(0xFF9C27B0),
            iconBg: const Color(0xFFF3E5F5),
            label: 'Month',
            value: monthName.split(' ')[0].substring(0, 3),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _StatTile(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF2196F3),
            iconBg: const Color(0xFFE3F2FD),
            label: 'Time',
            value: DateFormat('hh:mm a').format(now),
          )),
        ]),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.lightbulb_outline_rounded,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getTip(hour),
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  String _getTip(int hour) {
    if (hour < 9) return 'Start your day on time — punctuality builds trust!';
    if (hour < 12) return 'Great morning! Stay focused and productive.';
    if (hour < 15) return 'Keep up the momentum — you\'re doing great!';
    if (hour < 18) return 'Almost done for the day — finish strong!';
    return 'Don\'t forget to Mark Out before you leave.';
  }
}

// ─────────────────────────────────────────────
//  Stat Tile
// ─────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary)),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins')),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  User Card
// ─────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const _UserCard({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.secondary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins'),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 1),
            Text(email.isNotEmpty ? email : '—',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded,
                    color: AppTheme.primary, size: 11),
                const SizedBox(width: 3),
                Text(role.toLowerCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Arrow Menu Card
// ─────────────────────────────────────────────
class _ArrowMenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color arrowBg;
  final Color arrowColor;
  final String title;
  final String subtitle;
  final VoidCallback onArrowTap;
  final bool large;

  const _ArrowMenuCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.arrowBg,
    required this.arrowColor,
    required this.title,
    required this.subtitle,
    required this.onArrowTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final double vertPad = large ? 20 : 14;
    final double iconSize = large ? 66 : 52;
    final double iconInner = large ? 30 : 26;
    final double radius = large ? 16 : 14;
    final double titleSize = large ? 16.5 : 15;
    final double subtitleSize = large ? 13 : 12;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPad),
      decoration: AppTheme.cardDecoration(),
      child: Row(children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(radius)),
          child: Icon(icon, color: iconColor, size: iconInner),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: subtitleSize,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins')),
              ]),
        ),
        GestureDetector(
          onTap: onArrowTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: arrowBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.chevron_right_rounded,
                color: arrowColor, size: 22),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Morning Banner  — compact
// ─────────────────────────────────────────────
class _MorningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final dayName = DateFormat('EEEE').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: AppTheme.softOrangeDecoration,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wb_sunny_rounded,
              color: AppTheme.primary, size: 16),
          const SizedBox(width: 6),
          Text(greeting,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.primary)),
          const SizedBox(width: 8),
          Text('— $dayName',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Poppins')),
        ]),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(children: [
            Expanded(
                child: _BannerChip(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Stay Safe')),
            VerticalDivider(
                color: AppTheme.primary.withOpacity(0.3),
                thickness: 1,
                width: 1),
            Expanded(
                child:
                    _BannerChip(icon: Icons.alarm_rounded, label: 'On Time')),
            VerticalDivider(
                color: AppTheme.primary.withOpacity(0.3),
                thickness: 1,
                width: 1),
            Expanded(
                child: _BannerChip(
                    icon: Icons.trending_up_rounded, label: 'Good Work')),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  Banner Chip
// ─────────────────────────────────────────────
class _BannerChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BannerChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: AppTheme.primary, size: 20),
      const SizedBox(height: 3),
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppTheme.primary)),
    ]);
  }
}

// ─────────────────────────────────────────────
//  Footer Text
// ─────────────────────────────────────────────
class _FooterText extends StatelessWidget {
  final String appVersion;
  const _FooterText({required this.appVersion});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        const Text('Attendance Management System',
            style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins')),
        const SizedBox(height: 1),
        Text(appVersion,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textHint,
                fontFamily: 'Poppins')),
      ]),
    );
  }
}