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
// import '../../controllers/daily_task_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
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
//     final canCheck  = await _auth.canCheckBiometrics;
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
//       Get.put(NotificationController(), permanent: true);
//     }
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController(), permanent: true);
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
//     final deviceId      = await _BiometricHelper.getDeviceId();
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
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title   = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon    = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title   = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
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
//               const Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
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
//     final auth             = Get.find<AuthController>();
//     final userIdController = TextEditingController();
//     final formKey          = GlobalKey<FormState>();
//     final isLoading        = false.obs;

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
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Enter another user\'s ID to reset their device binding.\nYou cannot clear your own device here.',
//                   textAlign: TextAlign.center,
//                   style: AppTheme.bodySmall,
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
//                     final parsed = int.tryParse(v.trim());
//                     if (parsed == null) return 'Enter valid numeric ID';
//                     if (parsed == _getCurrentUserId(auth)) {
//                       return 'You cannot clear your own device ID';
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
//                                   final enteredId =
//                                       int.parse(userIdController.text.trim());
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

//   int _getCurrentUserId(AuthController auth) => auth.currentUserId;

//   void _showSnack(String message, {bool isError = false}) {
//     if (isError) {
//       ResponseHandler.showError(apiMessage: '', fallback: message);
//     } else {
//       ResponseHandler.showSuccess(apiMessage: '', fallback: message);
//     }
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
//     _now   = DateTime.now();
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
//     final hour     = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
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
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),
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
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft:  Radius.circular(30),
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

//       // ── My Section ───────────────────────────────────────────────────
//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — Admin ko bhi apne assets dikhenge
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),
//       const SizedBox(height: 26),

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── Admin Panel ──────────────────────────────────────────────────
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'All Summary',
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
//           onTap: () => Get.toNamed('/leave', arguments: {'adminPanel': true}),
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
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         // ✅ Asset Management — Admin Panel
//         _GroupRow(
//           icon: Icons.inventory_2_rounded,
//           label: 'Asset Management',
//           sub: 'Add, assign & manage company assets',
//           color: const Color(0xFF7C3AED),
//           onTap: () => Get.toNamed('/asset-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.history_rounded,
//           label: 'Login Log',
//           sub: 'View all user login sessions',
//           color: const Color(0xFF6366F1),
//           onTap: () => Get.toNamed('/login-history'),
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
//     final now  = DateTime.now();
//     final hour = now.hour;

//     final Color shiftColor;
//     final String shiftLabel;
//     final IconData shiftIcon;
//     if (hour < 10) {
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

//       // ── Quick Access ─────────────────────────────────────────────────
//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — User ke liye (apne assigned assets)
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),

//       const SizedBox(height: 26),

//       // ── Today's Shift ────────────────────────────────────────────────
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

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── More Options ─────────────────────────────────────────────────
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.reviews_outlined,
//           label: 'My Reviews',
//           sub: 'View your performance reviews',
//           color: const Color(0xFF8B5CF6),
//           onTap: () => Get.toNamed('/performance/my-reviews'),
//           isFirst: true,
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
// //  DAILY TASK CARD
// // ─────────────────────────────────────────────
// class _DailyTaskCard extends StatelessWidget {
//   const _DailyTaskCard();

//   Color _statusColor(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return AppTheme.success;
//       case 'in progress': return const Color(0xFFF59E0B);
//       default:            return AppTheme.textSecondary;
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'in progress': return Icons.timelapse_rounded;
//       default:            return Icons.radio_button_unchecked_rounded;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return 'Completed';
//       case 'in progress': return 'In Progress';
//       default:            return 'Pending';
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
//             Row(children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(Icons.task_alt_rounded,
//                     color: AppTheme.primary, size: 22),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Today's Tasks",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textPrimary,
//                         )),
//                     Text('Tap to manage all tasks', style: AppTheme.caption),
//                   ],
//                 ),
//               ),
//               Obx(() {
//                 final tasks     = ctrl.todayMyTasks;
//                 final completed = tasks
//                     .where((t) => t.status.toLowerCase() == 'completed')
//                     .length;
//                 final total = tasks.length;
//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text('$completed / $total Done',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.primary,
//                       )),
//                 );
//               }),
//               const SizedBox(width: 8),
//               const Icon(Icons.chevron_right_rounded,
//                   color: AppTheme.textHint, size: 20),
//             ]),
//             Obx(() {
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

//               if (tasks.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Row(children: [
//                     Icon(Icons.inbox_rounded,
//                         color: AppTheme.textHint, size: 20),
//                     const SizedBox(width: 8),
//                     const Text('No tasks logged today',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textSecondary,
//                         )),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => Get.toNamed('/daily-tasks'),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primary,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text('+ Add',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                               fontFamily: 'Poppins',
//                             )),
//                       ),
//                     ),
//                   ]),
//                 );
//               }

//               final visible = tasks.take(3).toList();
//               final extra   = tasks.length - visible.length;

//               return Column(children: [
//                 const SizedBox(height: 12),
//                 const Divider(height: 1, color: AppTheme.divider),
//                 const SizedBox(height: 10),
//                 ...visible.map((task) {
//                   final color = _statusColor(task.status);
//                   final icon  = _statusIcon(task.status);
//                   final label = _statusLabel(task.status);
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 2),
//                           child: Icon(icon, color: color, size: 18),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(task.taskTitle,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textPrimary,
//                                   )),
//                               Text(task.projectName, style: AppTheme.caption),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (task.hoursSpent > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 6, top: 2),
//                             child: Text('${task.hoursSpent}h',
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.textSecondary,
//                                   fontWeight: FontWeight.w500,
//                                 )),
//                           ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(label,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: color,
//                               )),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 if (extra > 0)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text('+$extra more task${extra > 1 ? 's' : ''}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.primary,
//                           fontWeight: FontWeight.w600,
//                         )),
//                   ),
//                 Builder(builder: (_) {
//                   final total = tasks.length;
//                   final done  = tasks
//                       .where((t) => t.status.toLowerCase() == 'completed')
//                       .length;
//                   final progress = total == 0 ? 0.0 : done / total;
//                   return Column(children: [
//                     const SizedBox(height: 10),
//                     const Divider(height: 1, color: AppTheme.divider),
//                     const SizedBox(height: 10),
//                     Row(children: [
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             minHeight: 6,
//                             backgroundColor:
//                                 AppTheme.primary.withOpacity(0.1),
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppTheme.success),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Text('${(progress * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w700,
//                             color: AppTheme.success,
//                           )),
//                     ]),
//                   ]);
//                 }),
//               ]);
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GRID CHIPS
// // ─────────────────────────────────────────────
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

// class _GridChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _GridChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final rows = <List<_ChipData>>[];
//     for (var i = 0; i < items.length; i += 4) {
//       rows.add(items.sublist(i, i + 4 > items.length ? items.length : i + 4));
//     }

//     return Column(
//       children: rows.asMap().entries.map((entry) {
//         final isLast = entry.key == rows.length - 1;
//         return Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//           child: Row(
//             children: List.generate(4, (col) {
//               if (col < entry.value.length) {
//                 final item = entry.value[col];
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: GestureDetector(
//                       onTap: item.onTap,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 4),
//                         decoration: AppTheme.cardDecoration(),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   color: item.color.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(14)),
//                               child: Icon(item.icon,
//                                   color: item.color, size: 22),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(item.label,
//                                 textAlign: TextAlign.center,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: AppTheme.chipLabel),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: const SizedBox(),
//                   ),
//                 );
//               }
//             }),
//           ),
//         );
//       }).toList(),
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
//                     _MiniTag(label: 'Mark In',  color: AppTheme.success),
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

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) => Container(
//       decoration: AppTheme.cardDecoration(radius: 22),
//       child: Column(children: children));
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
//     this.isDanger    = false,
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
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color, size: 20),
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
//     final tip  = hour < 10
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
//           Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
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
// import '../../controllers/daily_task_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
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
//     final canCheck  = await _auth.canCheckBiometrics;
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
//       Get.put(NotificationController(), permanent: true);
//     }
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController(), permanent: true);
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
//     final deviceId      = await _BiometricHelper.getDeviceId();
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
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title   = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon    = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title   = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
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
//             title: const Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               SizedBox(width: 10),
//               Text('Register Device',
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
//     final auth             = Get.find<AuthController>();
//     final userIdController = TextEditingController();
//     final formKey          = GlobalKey<FormState>();
//     final isLoading        = false.obs;

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
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Enter another user\'s ID to reset their device binding.\nYou cannot clear your own device here.',
//                   textAlign: TextAlign.center,
//                   style: AppTheme.bodySmall,
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
//                     final parsed = int.tryParse(v.trim());
//                     if (parsed == null) return 'Enter valid numeric ID';
//                     if (parsed == _getCurrentUserId(auth)) {
//                       return 'You cannot clear your own device ID';
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
//                                   final enteredId =
//                                       int.parse(userIdController.text.trim());
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

//   int _getCurrentUserId(AuthController auth) => auth.currentUserId;

//   void _showSnack(String message, {bool isError = false}) {
//     if (isError) {
//       ResponseHandler.showError(apiMessage: '', fallback: message);
//     } else {
//       ResponseHandler.showSuccess(apiMessage: '', fallback: message);
//     }
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
//     _now   = DateTime.now();
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
//     final hour     = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
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
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),
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
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft:  Radius.circular(30),
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

//       // ── My Section ───────────────────────────────────────────────────
//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — Admin ko bhi apne assets dikhenge
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),
//       const SizedBox(height: 26),

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── Admin Panel ──────────────────────────────────────────────────
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'All Summary',
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
//           onTap: () => Get.toNamed('/leave', arguments: {'adminPanel': true}),
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
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         // ✅ Asset Management — Admin Panel
//         _GroupRow(
//           icon: Icons.inventory_2_rounded,
//           label: 'Asset Management',
//           sub: 'Add, assign & manage company assets',
//           color: const Color(0xFF7C3AED),
//           onTap: () => Get.toNamed('/asset-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.history_rounded,
//           label: 'Login Log',
//           sub: 'View all user login sessions',
//           color: const Color(0xFF6366F1),
//           onTap: () => Get.toNamed('/login-history'),
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
// //  USER CONTENT  ✅ UPDATED
// //  Changes:
// //    1. StatefulWidget with Timer — live 24-hour clock
// //    2. Sunday → "Sunday Off" (indigo color, weekend icon, badge "Off")
// //    3. Time format → HH:mm:ss (24-hour)
// // ─────────────────────────────────────────────
// class _UserContent extends StatefulWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   State<_UserContent> createState() => _UserContentState();
// }

// class _UserContentState extends State<_UserContent> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now   = DateTime.now();
//     // ✅ Auto-update every second
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
//     final hour     = _now.hour;
//     // ✅ Sunday check — DateTime.sunday = 7
//     final isSunday = _now.weekday == DateTime.sunday;

//     // ── Shift state ──────────────────────────────────────────────────
//     final Color    shiftColor;
//     final String   shiftLabel;
//     final IconData shiftIcon;
//     final String   badgeLabel;

//     if (isSunday) {
//       // ✅ Sunday Off — no on-time requirement
//       shiftLabel = 'Sunday Off';
//       shiftColor = const Color(0xFF6366F1); // indigo
//       shiftIcon  = Icons.weekend_rounded;
//       badgeLabel = 'Off';
//     } else if (hour < 10) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon  = Icons.schedule_rounded;
//       badgeLabel = 'Today';
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon  = Icons.play_circle_outline_rounded;
//       badgeLabel = 'Today';
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon  = Icons.check_circle_outline_rounded;
//       badgeLabel = 'Today';
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: widget.onMarkAttendance),
//       const SizedBox(height: 26),

//       // ── Quick Access ─────────────────────────────────────────────────
//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — User ke liye (apne assigned assets)
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),

//       const SizedBox(height: 26),

//       // ── Today's Shift ────────────────────────────────────────────────
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
//                   // ✅ 24-hour format + live update
//                   Text(
//                     DateFormat('HH:mm:ss  |  dd MMM yyyy').format(_now),
//                     style: AppTheme.caption,
//                   ),
//                 ]),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(badgeLabel,
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── More Options ─────────────────────────────────────────────────
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.reviews_outlined,
//           label: 'My Reviews',
//           sub: 'View your performance reviews',
//           color: const Color(0xFF8B5CF6),
//           onTap: () => Get.toNamed('/performance/my-reviews'),
//           isFirst: true,
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
// //  DAILY TASK CARD
// // ─────────────────────────────────────────────
// class _DailyTaskCard extends StatelessWidget {
//   const _DailyTaskCard();

//   Color _statusColor(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return AppTheme.success;
//       case 'in progress': return const Color(0xFFF59E0B);
//       default:            return AppTheme.textSecondary;
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'in progress': return Icons.timelapse_rounded;
//       default:            return Icons.radio_button_unchecked_rounded;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return 'Completed';
//       case 'in progress': return 'In Progress';
//       default:            return 'Pending';
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
//             Row(children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(Icons.task_alt_rounded,
//                     color: AppTheme.primary, size: 22),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Today's Tasks",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textPrimary,
//                         )),
//                     Text('Tap to manage all tasks', style: AppTheme.caption),
//                   ],
//                 ),
//               ),
//               Obx(() {
//                 final tasks     = ctrl.todayMyTasks;
//                 final completed = tasks
//                     .where((t) => t.status.toLowerCase() == 'completed')
//                     .length;
//                 final total = tasks.length;
//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text('$completed / $total Done',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.primary,
//                       )),
//                 );
//               }),
//               const SizedBox(width: 8),
//               const Icon(Icons.chevron_right_rounded,
//                   color: AppTheme.textHint, size: 20),
//             ]),
//             Obx(() {
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

//               if (tasks.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Row(children: [
//                     Icon(Icons.inbox_rounded,
//                         color: AppTheme.textHint, size: 20),
//                     const SizedBox(width: 8),
//                     const Text('No tasks logged today',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textSecondary,
//                         )),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => Get.toNamed('/daily-tasks'),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primary,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text('+ Add',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                               fontFamily: 'Poppins',
//                             )),
//                       ),
//                     ),
//                   ]),
//                 );
//               }

//               final visible = tasks.take(3).toList();
//               final extra   = tasks.length - visible.length;

//               return Column(children: [
//                 const SizedBox(height: 12),
//                 const Divider(height: 1, color: AppTheme.divider),
//                 const SizedBox(height: 10),
//                 ...visible.map((task) {
//                   final color = _statusColor(task.status);
//                   final icon  = _statusIcon(task.status);
//                   final label = _statusLabel(task.status);
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 2),
//                           child: Icon(icon, color: color, size: 18),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(task.taskTitle,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textPrimary,
//                                   )),
//                               Text(task.projectName, style: AppTheme.caption),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (task.hoursSpent > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 6, top: 2),
//                             child: Text('${task.hoursSpent}h',
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.textSecondary,
//                                   fontWeight: FontWeight.w500,
//                                 )),
//                           ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(label,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: color,
//                               )),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 if (extra > 0)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text('+$extra more task${extra > 1 ? 's' : ''}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.primary,
//                           fontWeight: FontWeight.w600,
//                         )),
//                   ),
//                 Builder(builder: (_) {
//                   final total = tasks.length;
//                   final done  = tasks
//                       .where((t) => t.status.toLowerCase() == 'completed')
//                       .length;
//                   final progress = total == 0 ? 0.0 : done / total;
//                   return Column(children: [
//                     const SizedBox(height: 10),
//                     const Divider(height: 1, color: AppTheme.divider),
//                     const SizedBox(height: 10),
//                     Row(children: [
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             minHeight: 6,
//                             backgroundColor:
//                                 AppTheme.primary.withOpacity(0.1),
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppTheme.success),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Text('${(progress * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w700,
//                             color: AppTheme.success,
//                           )),
//                     ]),
//                   ]);
//                 }),
//               ]);
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GRID CHIPS
// // ─────────────────────────────────────────────
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

// class _GridChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _GridChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final rows = <List<_ChipData>>[];
//     for (var i = 0; i < items.length; i += 4) {
//       rows.add(items.sublist(i, i + 4 > items.length ? items.length : i + 4));
//     }

//     return Column(
//       children: rows.asMap().entries.map((entry) {
//         final isLast = entry.key == rows.length - 1;
//         return Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//           child: Row(
//             children: List.generate(4, (col) {
//               if (col < entry.value.length) {
//                 final item = entry.value[col];
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: GestureDetector(
//                       onTap: item.onTap,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 4),
//                         decoration: AppTheme.cardDecoration(),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   color: item.color.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(14)),
//                               child: Icon(item.icon,
//                                   color: item.color, size: 22),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(item.label,
//                                 textAlign: TextAlign.center,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: AppTheme.chipLabel),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: const SizedBox(),
//                   ),
//                 );
//               }
//             }),
//           ),
//         );
//       }).toList(),
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
//                     _MiniTag(label: 'Mark In',  color: AppTheme.success),
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

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) => Container(
//       decoration: AppTheme.cardDecoration(radius: 22),
//       child: Column(children: children));
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
//     this.isDanger    = false,
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
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color, size: 20),
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
//     final tip  = hour < 10
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
//           Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
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
// import '../../controllers/daily_task_controller.dart';
// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
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
//     final canCheck  = await _auth.canCheckBiometrics;
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
//       Get.put(NotificationController(), permanent: true);
//     }
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController(), permanent: true);
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
//     final deviceId      = await _BiometricHelper.getDeviceId();
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
//     IconData icon;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title   = 'No Biometric Sensor';
//         message = 'Biometric sensor not available on this device.';
//         icon    = Icons.no_cell_rounded;
//         break;
//       case BiometricError.notEnrolled:
//         title   = 'Fingerprint Not Set Up';
//         message =
//             'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         icon = Icons.fingerprint;
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
//             title: const Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               SizedBox(width: 10),
//               Text('Register Device',
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
//     final auth             = Get.find<AuthController>();
//     final userIdController = TextEditingController();
//     final formKey          = GlobalKey<FormState>();
//     final isLoading        = false.obs;

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
//                 const Text('Device Clear', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Enter another user\'s ID to reset their device binding.\nYou cannot clear your own device here.',
//                   textAlign: TextAlign.center,
//                   style: AppTheme.bodySmall,
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
//                     final parsed = int.tryParse(v.trim());
//                     if (parsed == null) return 'Enter valid numeric ID';
//                     if (parsed == _getCurrentUserId(auth)) {
//                       return 'You cannot clear your own device ID';
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
//                                   final enteredId =
//                                       int.parse(userIdController.text.trim());
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

//   int _getCurrentUserId(AuthController auth) => auth.currentUserId;

//   void _showSnack(String message, {bool isError = false}) {
//     if (isError) {
//       ResponseHandler.showError(apiMessage: '', fallback: message);
//     } else {
//       ResponseHandler.showSuccess(apiMessage: '', fallback: message);
//     }
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
//     _now   = DateTime.now();
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
//     final hour     = _now.hour;
//     final greeting = hour < 12
//         ? 'Good Morning'
//         : hour < 17
//             ? 'Good Afternoon'
//             : 'Good Evening';

//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         child: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//             child: Row(children: [
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
//               NotificationBadge(iconColor: AppTheme.textPrimary),
//               const SizedBox(width: 8),
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
//       Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: const BoxDecoration(
//           color: AppTheme.primary,
//           borderRadius: BorderRadius.only(
//             bottomLeft:  Radius.circular(30),
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

//       // ── My Section ───────────────────────────────────────────────────
//       const _Label('My Section'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — Admin ko bhi apne assets dikhenge
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),
//       const SizedBox(height: 26),

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── Admin Panel ──────────────────────────────────────────────────
//       const _Label('Admin Panel'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.groups_rounded,
//           label: 'All Summary',
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
//           onTap: () => Get.toNamed('/leave', arguments: {'adminPanel': true}),
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
//           icon: Icons.help_outline_rounded,
//           label: 'Help & Support',
//           sub: 'Manage FAQs & contact messages',
//           color: AppTheme.info,
//           onTap: () => Get.toNamed('/help-support'),
//           isFirst: false,
//           isLast: false,
//         ),
//         // ✅ Asset Management — Admin Panel
//         _GroupRow(
//           icon: Icons.inventory_2_rounded,
//           label: 'Asset Management',
//           sub: 'Add, assign & manage company assets',
//           color: const Color(0xFF7C3AED),
//           onTap: () => Get.toNamed('/asset-admin'),
//           isFirst: false,
//           isLast: false,
//         ),
//         _GroupRow(
//           icon: Icons.history_rounded,
//           label: 'Login Log',
//           sub: 'View all user login sessions',
//           color: const Color(0xFF6366F1),
//           onTap: () => Get.toNamed('/login-history'),
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
// //  USER CONTENT  ✅ UPDATED
// //  Changes:
// //    1. StatefulWidget with Timer — live 24-hour clock
// //    2. Sunday → "Sunday Off" (indigo color, weekend icon, badge "Off")
// //    3. Time format → HH:mm:ss (24-hour)
// // ─────────────────────────────────────────────
// class _UserContent extends StatefulWidget {
//   final VoidCallback onMarkAttendance;
//   const _UserContent({required this.onMarkAttendance});

//   @override
//   State<_UserContent> createState() => _UserContentState();
// }

// class _UserContentState extends State<_UserContent> {
//   late DateTime _now;
//   late final Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _now   = DateTime.now();
//     // ✅ Auto-update every second
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
//     final hour     = _now.hour;
//     // ✅ Sunday check — DateTime.sunday = 7
//     final isSunday = _now.weekday == DateTime.sunday;

//     // ── Shift state ──────────────────────────────────────────────────
//     final Color    shiftColor;
//     final String   shiftLabel;
//     final IconData shiftIcon;
//     final String   badgeLabel;

//     if (isSunday) {
//       // ✅ Sunday Off — no on-time requirement
//       shiftLabel = 'Sunday Off';
//       shiftColor = const Color(0xFF6366F1); // indigo
//       shiftIcon  = Icons.weekend_rounded;
//       badgeLabel = 'Off';
//     } else if (hour < 10) {
//       shiftLabel = 'Shift Not Started';
//       shiftColor = AppTheme.warning;
//       shiftIcon  = Icons.schedule_rounded;
//       badgeLabel = 'Today';
//     } else if (hour < 18) {
//       shiftLabel = 'Shift In Progress';
//       shiftColor = AppTheme.success;
//       shiftIcon  = Icons.play_circle_outline_rounded;
//       badgeLabel = 'Today';
//     } else {
//       shiftLabel = 'Shift Ended';
//       shiftColor = AppTheme.textSecondary;
//       shiftIcon  = Icons.check_circle_outline_rounded;
//       badgeLabel = 'Today';
//     }

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const SizedBox(height: 24),
//       _BigCTA(onTap: widget.onMarkAttendance),
//       const SizedBox(height: 26),

//       // ── Quick Access ─────────────────────────────────────────────────
//       const _Label('Quick Access'),
//       const SizedBox(height: 12),
//       _GridChips(items: [
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
//         // ✅ My Assets — User ke liye (apne assigned assets)
//         _ChipData(
//             icon: Icons.devices_rounded,
//             label: 'My Assets',
//             color: const Color(0xFF6366F1),
//             onTap: () => Get.toNamed('/my-assets')),
//       ]),

//       const SizedBox(height: 26),

//       // ── Today's Shift ────────────────────────────────────────────────
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
//                   // ✅ 24-hour format + live update
//                   Text(
//                     DateFormat('HH:mm:ss  |  dd MMM yyyy').format(_now),
//                     style: AppTheme.caption,
//                   ),
//                 ]),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: shiftColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(badgeLabel,
//                 style: TextStyle(
//                     fontSize: 11,
//                     color: shiftColor,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins')),
//           ),
//         ]),
//       ),

//       const SizedBox(height: 26),

//       // ── Daily Tasks ──────────────────────────────────────────────────
//       const _Label('Daily Tasks'),
//       const SizedBox(height: 12),
//       const _DailyTaskCard(),
//       const SizedBox(height: 26),

//       // ── More Options ─────────────────────────────────────────────────
//       const _Label('More Options'),
//       const SizedBox(height: 12),
//       _GroupedBox(children: [
//         _GroupRow(
//           icon: Icons.reviews_outlined,
//           label: 'My Reviews',
//           sub: 'View your performance reviews',
//           color: const Color(0xFF8B5CF6),
//           onTap: () => Get.toNamed('/performance/my-reviews'),
//           isFirst: true,
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
// //  DAILY TASK CARD  ✅ Auto-refresh every 30s
// // ─────────────────────────────────────────────
// class _DailyTaskCard extends StatefulWidget {
//   const _DailyTaskCard();

//   @override
//   State<_DailyTaskCard> createState() => _DailyTaskCardState();
// }

// class _DailyTaskCardState extends State<_DailyTaskCard> {
//   late final Timer _refreshTimer;
//   final _ctrl = Get.find<DailyTaskController>();

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Initial load
//     _ctrl.fetchTodayMyTasks();
//     // ✅ Refresh every 30 seconds automatically
//     _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       if (mounted) _ctrl.fetchTodayMyTasks();
//     });
//   }

//   @override
//   void dispose() {
//     _refreshTimer.cancel();
//     super.dispose();
//   }

//   Color _statusColor(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return AppTheme.success;
//       case 'in progress': return const Color(0xFFF59E0B);
//       default:            return AppTheme.textSecondary;
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'in progress': return Icons.timelapse_rounded;
//       default:            return Icons.radio_button_unchecked_rounded;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status.toLowerCase().trim()) {
//       case 'completed':   return 'Completed';
//       case 'in progress': return 'In Progress';
//       default:            return 'Pending';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.toNamed('/daily-tasks'),
//       child: Container(
//         decoration: AppTheme.cardDecoration(),
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(Icons.task_alt_rounded,
//                     color: AppTheme.primary, size: 22),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Today's Tasks",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textPrimary,
//                         )),
//                     Text('Tap to manage all tasks', style: AppTheme.caption),
//                   ],
//                 ),
//               ),
//               Obx(() {
//                 final tasks     = _ctrl.todayMyTasks;
//                 final completed = tasks
//                     .where((t) => t.status.toLowerCase() == 'completed')
//                     .length;
//                 final total = tasks.length;
//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text('$completed / $total Done',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.primary,
//                       )),
//                 );
//               }),
//               const SizedBox(width: 8),
//               // ✅ Manual refresh button
//               Obx(() => _ctrl.isLoadingToday.value
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: AppTheme.primary))
//                   : GestureDetector(
//                       onTap: () => _ctrl.fetchTodayMyTasks(),
//                       child: const Icon(Icons.refresh_rounded,
//                           color: AppTheme.textHint, size: 20),
//                     )),
//               const SizedBox(width: 6),
//               const Icon(Icons.chevron_right_rounded,
//                   color: AppTheme.textHint, size: 20),
//             ]),
//             Obx(() {
//               if (_ctrl.isLoadingToday.value) {
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

//               final tasks = _ctrl.todayMyTasks;

//               if (tasks.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Row(children: [
//                     Icon(Icons.inbox_rounded,
//                         color: AppTheme.textHint, size: 20),
//                     const SizedBox(width: 8),
//                     const Text('No tasks logged today',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.textSecondary,
//                         )),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => Get.toNamed('/daily-tasks'),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primary,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text('+ Add',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                               fontFamily: 'Poppins',
//                             )),
//                       ),
//                     ),
//                   ]),
//                 );
//               }

//               final visible = tasks.take(3).toList();
//               final extra   = tasks.length - visible.length;

//               return Column(children: [
//                 const SizedBox(height: 12),
//                 const Divider(height: 1, color: AppTheme.divider),
//                 const SizedBox(height: 10),
//                 ...visible.map((task) {
//                   final color = _statusColor(task.status);
//                   final icon  = _statusIcon(task.status);
//                   final label = _statusLabel(task.status);
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 2),
//                           child: Icon(icon, color: color, size: 18),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(task.taskTitle,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textPrimary,
//                                   )),
//                               Text(task.projectName, style: AppTheme.caption),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (task.hoursSpent > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 6, top: 2),
//                             child: Text('${task.hoursSpent}h',
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.textSecondary,
//                                   fontWeight: FontWeight.w500,
//                                 )),
//                           ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(label,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 color: color,
//                               )),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 if (extra > 0)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text('+$extra more task${extra > 1 ? 's' : ''}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontFamily: 'Poppins',
//                           color: AppTheme.primary,
//                           fontWeight: FontWeight.w600,
//                         )),
//                   ),
//                 Builder(builder: (_) {
//                   final total = tasks.length;
//                   final done  = tasks
//                       .where((t) => t.status.toLowerCase() == 'completed')
//                       .length;
//                   final progress = total == 0 ? 0.0 : done / total;
//                   return Column(children: [
//                     const SizedBox(height: 10),
//                     const Divider(height: 1, color: AppTheme.divider),
//                     const SizedBox(height: 10),
//                     Row(children: [
//                       Expanded(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: LinearProgressIndicator(
//                             value: progress,
//                             minHeight: 6,
//                             backgroundColor:
//                                 AppTheme.primary.withOpacity(0.1),
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppTheme.success),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Text('${(progress * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w700,
//                             color: AppTheme.success,
//                           )),
//                     ]),
//                   ]);
//                 }),
//               ]);
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  GRID CHIPS
// // ─────────────────────────────────────────────
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

// class _GridChips extends StatelessWidget {
//   final List<_ChipData> items;
//   const _GridChips({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final rows = <List<_ChipData>>[];
//     for (var i = 0; i < items.length; i += 4) {
//       rows.add(items.sublist(i, i + 4 > items.length ? items.length : i + 4));
//     }

//     return Column(
//       children: rows.asMap().entries.map((entry) {
//         final isLast = entry.key == rows.length - 1;
//         return Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
//           child: Row(
//             children: List.generate(4, (col) {
//               if (col < entry.value.length) {
//                 final item = entry.value[col];
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: GestureDetector(
//                       onTap: item.onTap,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14, horizontal: 4),
//                         decoration: AppTheme.cardDecoration(),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   color: item.color.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(14)),
//                               child: Icon(item.icon,
//                                   color: item.color, size: 22),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(item.label,
//                                 textAlign: TextAlign.center,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: AppTheme.chipLabel),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
//                     child: const SizedBox(),
//                   ),
//                 );
//               }
//             }),
//           ),
//         );
//       }).toList(),
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
//                     _MiniTag(label: 'Mark In',  color: AppTheme.success),
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

// class _GroupedBox extends StatelessWidget {
//   final List<Widget> children;
//   const _GroupedBox({required this.children});
//   @override
//   Widget build(BuildContext context) => Container(
//       decoration: AppTheme.cardDecoration(radius: 22),
//       child: Column(children: children));
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
//     this.isDanger    = false,
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
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//                 color: (isComingSoon ? AppTheme.textHint : color)
//                     .withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(13)),
//             child: Icon(icon,
//                 color: isComingSoon ? AppTheme.textHint : color, size: 20),
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
//     final tip  = hour < 10
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
//           Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
//         ]),
//       ),
//     );
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
import '../../controllers/daily_task_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/response_handler.dart';
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
    final canCheck  = await _auth.canCheckBiometrics;
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
      Get.put(NotificationController(), permanent: true);
    }
    if (!Get.isRegistered<DailyTaskController>()) {
      Get.put(DailyTaskController(), permanent: true);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    final deviceId      = await _BiometricHelper.getDeviceId();
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
        title   = 'No Biometric Sensor';
        message = 'Biometric sensor not available on this device.';
        icon    = Icons.no_cell_rounded;
        break;
      case BiometricError.notEnrolled:
        title   = 'Fingerprint Not Set Up';
        message =
            'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
        icon = Icons.fingerprint;
        break;
      case BiometricError.lockedOut:
        title   = 'Too Many Attempts';
        message = 'Biometric is locked. Please wait and try again.';
        icon    = Icons.lock_clock_rounded;
        break;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            title: const Row(children: [
              Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
              SizedBox(width: 10),
              Text('Register Device',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    final auth             = Get.find<AuthController>();
    final userIdController = TextEditingController();
    final formKey          = GlobalKey<FormState>();
    final isLoading        = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                const Text(
                  'Enter another user\'s ID to reset their device binding.\nYou cannot clear your own device here.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall,
                ),
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
                    final parsed = int.tryParse(v.trim());
                    if (parsed == null) return 'Enter valid numeric ID';
                    if (parsed == _getCurrentUserId(auth)) {
                      return 'You cannot clear your own device ID';
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

  int _getCurrentUserId(AuthController auth) => auth.currentUserId;

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      ResponseHandler.showError(apiMessage: '', fallback: message);
    } else {
      ResponseHandler.showSuccess(apiMessage: '', fallback: message);
    }
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
    _now   = DateTime.now();
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
    final hour     = _now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Column(children: [
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
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.only(
            bottomLeft:  Radius.circular(30),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

      // ── My Section ───────────────────────────────────────────────────
      const _Label('My Section'),
      const SizedBox(height: 12),
      _GridChips(items: [
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
        // ✅ My Assets — Admin ko bhi apne assets dikhenge
        _ChipData(
            icon: Icons.devices_rounded,
            label: 'My Assets',
            color: const Color(0xFF6366F1),
            onTap: () => Get.toNamed('/my-assets')),
        // ✅ Documents — Admin can upload & view own docs
        _ChipData(
            icon: Icons.folder_copy_rounded,
            label: 'Documents',
            color: const Color(0xFF0891B2),
            onTap: () => Get.toNamed('/documents')),
      ]),
      const SizedBox(height: 26),

      // ── Daily Tasks ──────────────────────────────────────────────────
      const _Label('Daily Tasks'),
      const SizedBox(height: 12),
      const _DailyTaskCard(),
      const SizedBox(height: 26),

      // ── Admin Panel ──────────────────────────────────────────────────
      const _Label('Admin Panel'),
      const SizedBox(height: 12),
      _GroupedBox(children: [
        _GroupRow(
          icon: Icons.groups_rounded,
          label: 'All Summary',
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
          onTap: () => Get.toNamed('/leave', arguments: {'adminPanel': true}),
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
          icon: Icons.inventory_2_rounded,
          label: 'Asset Management',
          sub: 'Add, assign & manage company assets',
          color: const Color(0xFF7C3AED),
          onTap: () => Get.toNamed('/asset-admin'),
          isFirst: false,
          isLast: false,
        ),
        // ✅ Document Management — Admin verify/reject/delete all docs
        _GroupRow(
          icon: Icons.folder_copy_rounded,
          label: 'Document Management',
          sub: 'Verify, reject & manage employee documents',
          color: const Color(0xFF0891B2),
          onTap: () => Get.toNamed('/documents'),
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
          icon: Icons.history_rounded,
          label: 'Login Log',
          sub: 'View all user login sessions',
          color: const Color(0xFF6366F1),
          onTap: () => Get.toNamed('/login-history'),
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

      const SizedBox(height: 26),
      const _TipBanner(),
      const SizedBox(height: 8),
    ]);
  }
}

// ─────────────────────────────────────────────
//  USER CONTENT
// ─────────────────────────────────────────────
class _UserContent extends StatefulWidget {
  final VoidCallback onMarkAttendance;
  const _UserContent({required this.onMarkAttendance});

  @override
  State<_UserContent> createState() => _UserContentState();
}

class _UserContentState extends State<_UserContent> {
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _now   = DateTime.now();
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
    final hour     = _now.hour;
    final isSunday = _now.weekday == DateTime.sunday;

    final Color    shiftColor;
    final String   shiftLabel;
    final IconData shiftIcon;
    final String   badgeLabel;

    if (isSunday) {
      shiftLabel = 'Sunday Off';
      shiftColor = const Color(0xFF6366F1);
      shiftIcon  = Icons.weekend_rounded;
      badgeLabel = 'Off';
    } else if (hour < 10) {
      shiftLabel = 'Shift Not Started';
      shiftColor = AppTheme.warning;
      shiftIcon  = Icons.schedule_rounded;
      badgeLabel = 'Today';
    } else if (hour < 18) {
      shiftLabel = 'Shift In Progress';
      shiftColor = AppTheme.success;
      shiftIcon  = Icons.play_circle_outline_rounded;
      badgeLabel = 'Today';
    } else {
      shiftLabel = 'Shift Ended';
      shiftColor = AppTheme.textSecondary;
      shiftIcon  = Icons.check_circle_outline_rounded;
      badgeLabel = 'Today';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      _BigCTA(onTap: widget.onMarkAttendance),
      const SizedBox(height: 26),

      // ── Quick Access ─────────────────────────────────────────────────
      const _Label('Quick Access'),
      const SizedBox(height: 12),
      _GridChips(items: [
        _ChipData(
            icon: Icons.calendar_today_rounded,
            label: 'Attendance',
            color: AppTheme.chipAttendance,
            onTap: () => Get.toNamed('/user-summary')),
         // ✅ Documents — User can upload & view own docs
        _ChipData(
            icon: Icons.folder_copy_rounded,
            label: 'Documents',
            color: const Color(0xFF0891B2),
            onTap: () => Get.toNamed('/documents')),
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
        // ✅ My Assets — User ke liye (apne assigned assets)
        _ChipData(
            icon: Icons.devices_rounded,
            label: 'My Assets',
            color: const Color(0xFF6366F1),
            onTap: () => Get.toNamed('/my-assets')),
      ]),

      const SizedBox(height: 26),

      // ── Today's Shift ────────────────────────────────────────────────
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
                  Text(
                    DateFormat('HH:mm:ss  |  dd MMM yyyy').format(_now),
                    style: AppTheme.caption,
                  ),
                ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: shiftColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(badgeLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: shiftColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins')),
          ),
        ]),
      ),

      const SizedBox(height: 26),

      // ── Daily Tasks ──────────────────────────────────────────────────
      const _Label('Daily Tasks'),
      const SizedBox(height: 12),
      const _DailyTaskCard(),
      const SizedBox(height: 26),

      // ── More Options ─────────────────────────────────────────────────
      const _Label('More Options'),
      const SizedBox(height: 12),
      _GroupedBox(children: [
        _GroupRow(
          icon: Icons.reviews_outlined,
          label: 'My Reviews',
          sub: 'View your performance reviews',
          color: const Color(0xFF8B5CF6),
          onTap: () => Get.toNamed('/performance/my-reviews'),
          isFirst: true,
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
class _DailyTaskCard extends StatefulWidget {
  const _DailyTaskCard();

  @override
  State<_DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<_DailyTaskCard> {
  late final Timer _refreshTimer;
  final _ctrl = Get.find<DailyTaskController>();

  @override
  void initState() {
    super.initState();
    _ctrl.fetchTodayMyTasks();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _ctrl.fetchTodayMyTasks();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':   return AppTheme.success;
      case 'in progress': return const Color(0xFFF59E0B);
      default:            return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':   return Icons.check_circle_rounded;
      case 'in progress': return Icons.timelapse_rounded;
      default:            return Icons.radio_button_unchecked_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':   return 'Completed';
      case 'in progress': return 'In Progress';
      default:            return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/daily-tasks'),
      child: Container(
        decoration: AppTheme.cardDecoration(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
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
                    Text("Today's Tasks",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary,
                        )),
                    Text('Tap to manage all tasks', style: AppTheme.caption),
                  ],
                ),
              ),
              Obx(() {
                final tasks     = _ctrl.todayMyTasks;
                final completed = tasks
                    .where((t) => t.status.toLowerCase() == 'completed')
                    .length;
                final total = tasks.length;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$completed / $total Done',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppTheme.primary,
                      )),
                );
              }),
              const SizedBox(width: 8),
              Obx(() => _ctrl.isLoadingToday.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary))
                  : GestureDetector(
                      onTap: () => _ctrl.fetchTodayMyTasks(),
                      child: const Icon(Icons.refresh_rounded,
                          color: AppTheme.textHint, size: 20),
                    )),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textHint, size: 20),
            ]),
            Obx(() {
              if (_ctrl.isLoadingToday.value) {
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

              final tasks = _ctrl.todayMyTasks;

              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(children: [
                    Icon(Icons.inbox_rounded,
                        color: AppTheme.textHint, size: 20),
                    const SizedBox(width: 8),
                    const Text('No tasks logged today',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: AppTheme.textSecondary,
                        )),
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
                        child: const Text('+ Add',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            )),
                      ),
                    ),
                  ]),
                );
              }

              final visible = tasks.take(3).toList();
              final extra   = tasks.length - visible.length;

              return Column(children: [
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.divider),
                const SizedBox(height: 10),
                ...visible.map((task) {
                  final color = _statusColor(task.status);
                  final icon  = _statusIcon(task.status);
                  final label = _statusLabel(task.status);
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
                              Text(task.taskTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textPrimary,
                                  )),
                              Text(task.projectName, style: AppTheme.caption),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (task.hoursSpent > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 6, top: 2),
                            child: Text('${task.hoursSpent}h',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: color,
                              )),
                        ),
                      ],
                    ),
                  );
                }),
                if (extra > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('+$extra more task${extra > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                Builder(builder: (_) {
                  final total = tasks.length;
                  final done  = tasks
                      .where((t) => t.status.toLowerCase() == 'completed')
                      .length;
                  final progress = total == 0 ? 0.0 : done / total;
                  return Column(children: [
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: AppTheme.success,
                          )),
                    ]),
                  ]);
                }),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GRID CHIPS
// ─────────────────────────────────────────────
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

class _GridChips extends StatelessWidget {
  final List<_ChipData> items;
  const _GridChips({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <List<_ChipData>>[];
    for (var i = 0; i < items.length; i += 4) {
      rows.add(items.sublist(i, i + 4 > items.length ? items.length : i + 4));
    }

    return Column(
      children: rows.asMap().entries.map((entry) {
        final isLast = entry.key == rows.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: Row(
            children: List.generate(4, (col) {
              if (col < entry.value.length) {
                final item = entry.value[col];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
                    child: GestureDetector(
                      onTap: item.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                        decoration: AppTheme.cardDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14)),
                              child: Icon(item.icon,
                                  color: item.color, size: 22),
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
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: col < 3 ? 10 : 0),
                    child: const SizedBox(),
                  ),
                );
              }
            }),
          ),
        );
      }).toList(),
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
                    _MiniTag(label: 'Mark In',  color: AppTheme.success),
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
    this.isDanger     = false,
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
            top:    isFirst ? const Radius.circular(22) : Radius.zero,
            bottom: isLast  ? const Radius.circular(22) : Radius.zero,
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
    final tip  = hour < 10
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