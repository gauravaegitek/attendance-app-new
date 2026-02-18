// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         slivers: [
//           // =================== APP BAR ===================
//           SliverAppBar(
//             expandedHeight: 220,
//             floating: false,
//             pinned: true,
//             backgroundColor: AppTheme.primary,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: AppTheme.gradientDecoration,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Top Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Avatar & Name
//                             Obx(() => Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 22,
//                                   backgroundColor:
//                                       Colors.white.withOpacity(0.2),
//                                   child: Text(
//                                     authController.userName.value.isNotEmpty
//                                         ? authController.userName.value[0]
//                                             .toUpperCase()
//                                         : 'U',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Hello, ${authController.userName.value}!',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Poppins',
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white.withOpacity(0.2),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         authController.userRole.value
//                                             .toUpperCase(),
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w600,
//                                           fontFamily: 'Poppins',
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             )),

//                             // Logout Button
//                             IconButton(
//                               icon: const Icon(Icons.logout,
//                                   color: Colors.white),
//                               onPressed: authController.logout,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),

//                         // Date/Time
//                         Text(
//                           DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 14,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           DateFormat('hh:mm a').format(DateTime.now()),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.w700,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             actions: const [],
//           ),

//           // =================== CONTENT ===================
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // =================== QUICK ACTIONS ===================
//                   const Text('Quick Actions', style: AppTheme.headline3),
//                   const SizedBox(height: 16),

//                   Row(
//                     children: [
//                       // Check In
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.login,
//                           label: 'Check In',
//                           color: AppTheme.success,
//                           bgColor: AppTheme.successLight,
//                           onTap: () => Get.toNamed('/mark-in'),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Check Out
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.logout,
//                           label: 'Check Out',
//                           color: AppTheme.error,
//                           bgColor: AppTheme.errorLight,
//                           onTap: () => Get.toNamed('/mark-out'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       // My Summary
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.calendar_month,
//                           label: 'My Summary',
//                           color: AppTheme.primary,
//                           bgColor: AppTheme.primaryLight,
//                           onTap: () => Get.toNamed('/user-summary'),
//                         ),
//                       ),
//                       const SizedBox(width: 16),

//                       // Admin Summary (only for admin)
//                       Expanded(
//                         child: Obx(() => authController.isAdmin
//                             ? _ActionCard(
//                                 icon: Icons.admin_panel_settings,
//                                 label: 'Admin Panel',
//                                 color: AppTheme.accent,
//                                 bgColor: AppTheme.warningLight,
//                                 onTap: () => Get.toNamed('/admin'),
//                               )
//                             : _ActionCard(
//                                 icon: Icons.history,
//                                 label: 'History',
//                                 color: AppTheme.textSecondary,
//                                 bgColor: AppTheme.background,
//                                 onTap: () => Get.toNamed('/user-summary'),
//                               )),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 28),

//                   // =================== INFO CARDS ===================
//                   const Text('Today\'s Info', style: AppTheme.headline3),
//                   const SizedBox(height: 16),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: _InfoCard(
//                           icon: Icons.access_time,
//                           label: 'Office Hours',
//                           value: '9:00 AM - 6:00 PM',
//                           color: AppTheme.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _InfoCard(
//                           icon: Icons.work_outline,
//                           label: 'Work Days',
//                           value: 'Mon - Sat',
//                           color: AppTheme.secondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Instructions Card
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: AppTheme.cardDecoration(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.primaryLight,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Icon(Icons.info_outline,
//                                   color: AppTheme.primary, size: 20),
//                             ),
//                             const SizedBox(width: 12),
//                             const Text('How to Mark Attendance',
//                                 style: AppTheme.headline3),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         _InstructionStep(
//                           number: '1',
//                           text: 'Tap "Check In" or "Check Out"',
//                         ),
//                         _InstructionStep(
//                           number: '2',
//                           text: 'Allow location permission',
//                         ),
//                         _InstructionStep(
//                           number: '3',
//                           text: 'Take a selfie for verification',
//                         ),
//                         _InstructionStep(
//                           number: '4',
//                           text: 'Submit to mark attendance',
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActionCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final Color bgColor;
//   final VoidCallback onTap;

//   const _ActionCard({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.bgColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: AppTheme.cardDecoration(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _InfoCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: AppTheme.caption),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.textPrimary,
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InstructionStep extends StatelessWidget {
//   final String number;
//   final String text;

//   const _InstructionStep({required this.number, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: AppTheme.primary,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(text, style: AppTheme.bodyMedium),
//         ],
//       ),
//     );
//   }
// }







// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import 'package:intl/intl.dart';

// // ─────────────────────────────────────────────
// //  BiometricHelper — Phone Fingerprint Only
// // ─────────────────────────────────────────────
// class _BiometricHelper {
//   static final LocalAuthentication _auth = LocalAuthentication();

//   static Future<String> getDeviceId() async {
//     final info = DeviceInfoPlugin();
//     if (Platform.isAndroid) return (await info.androidInfo).id;
//     if (Platform.isIOS) return (await info.iosInfo).identifierForVendor ?? 'unknown';
//     return 'unknown';
//   }

//   /// ✅ Direct authenticate — error codes se pata chalega kya issue hai
//   /// Return values:
//   ///   true  — success
//   ///   false — user ne cancel kiya ya match nahi hua
//   ///   throws BiometricException — hardware/enrollment issue
//   static Future<bool> authenticate(String reason) async {
//     try {
//       final result = await _auth.authenticate(
//         localizedReason: reason,
//         options: const AuthenticationOptions(
//           biometricOnly: true,   // ✅ Sirf fingerprint/face — NO PIN
//           stickyAuth: true,      // background pe gaye tab bhi dialog rahe
//           useErrorDialogs: true, // OS ka native error dialog
//         ),
//       );
//       debugPrint('Biometric result: $result');
//       return result;
//     } on PlatformException catch (e) {
//       debugPrint('Biometric PlatformException: ${e.code} | ${e.message}');
//       // Error codes handle karo
//       switch (e.code) {
//         case 'NotAvailable':
//         case 'no_fragment_activity':
//           throw BiometricException(BiometricError.hardwareNotFound);
//         case 'NotEnrolled':
//         case 'biometric_error_none_enrolled':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'PasscodeNotSet':
//           throw BiometricException(BiometricError.notEnrolled);
//         case 'LockedOut':
//         case 'PermanentlyLockedOut':
//           throw BiometricException(BiometricError.lockedOut);
//         default:
//           return false; // user cancel ya unknown
//       }
//     } catch (e) {
//       debugPrint('Biometric unknown error: $e');
//       if (e is BiometricException) rethrow;
//       return false;
//     }
//   }
// }

// // ─────────────────────────────────────────────
// //  BiometricException
// // ─────────────────────────────────────────────
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
//   late Timer _timer;
//   String _currentTime = '';
//   String _currentDate = '';

//   @override
//   void initState() {
//     super.initState();
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
//   }

//   void _updateTime() {
//     final now = DateTime.now();
//     setState(() {
//       _currentTime = DateFormat('HH:mm:ss').format(now);
//       _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(now);
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   // ── Location Check ──────────────────────────
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

//   // ── ✅ Fingerprint Flow ─────────────────────
//   Future<bool> _handleBiometric(String type) async {
//     final authController = Get.find<AuthController>();

//     final savedToken = type == 'in'
//         ? authController.inBiometric.value
//         : authController.outBiometric.value;

//     final deviceId = await _BiometricHelper.getDeviceId();

//     // ── Register (first time) ────────────────
//     if (savedToken.isEmpty) {
//       final confirm = await _showBiometricRegisterDialog(type);
//       if (!confirm) return false;

//       try {
//         final success = await _BiometricHelper.authenticate(
//           type == 'in'
//               ? 'Register fingerprint for Check In'
//               : 'Register fingerprint for Check Out',
//         );
//         if (!success) {
//           _showSnack('Fingerprint not recognized. Try again.', isError: true);
//           return false;
//         }
//         await authController.saveBiometric(type: type, token: deviceId);
//         _showSnack('Fingerprint registered successfully!');
//         return true;
//       } on BiometricException catch (e) {
//         _handleBiometricError(e.error);
//         return false;
//       }
//     }

//     // ── Verify (already registered) ─────────
//     if (savedToken != deviceId) {
//       _showSnack('Wrong device! Use your registered device.', isError: true);
//       return false;
//     }

//     try {
//       final success = await _BiometricHelper.authenticate(
//         'Place your finger to verify attendance',
//       );
//       if (!success) {
//         _showSnack('Fingerprint not recognized. Try again.', isError: true);
//         return false;
//       }
//       return true;
//     } on BiometricException catch (e) {
//       _handleBiometricError(e.error);
//       return false;
//     }
//   }

//   // ── Biometric Error Dialog ───────────────
//   void _handleBiometricError(BiometricError error) {
//     String title, message;
//     switch (error) {
//       case BiometricError.hardwareNotFound:
//         title = 'No Biometric Sensor';
//         message = 'No fingerprint sensor found on this device.';
//         break;
//       case BiometricError.notEnrolled:
//         title = 'Fingerprint Not Set Up';
//         message = 'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
//         break;
//       case BiometricError.lockedOut:
//         title = 'Too Many Attempts';
//         message = 'Too many attempts. Biometric is locked. Please wait and try again.';
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
//             color: Colors.red,
//           ),
//           const SizedBox(width: 10),
//           Text(title),
//         ]),
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
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('OK', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//     Future<bool> _showBiometricRegisterDialog(String type) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: Row(children: [
//               Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
//               const SizedBox(width: 10),
//               const Text('Register Fingerprint'),
//             ]),
//             content: Text(
//               'First time setup for ${type == 'in' ? 'Check In' : 'Check Out'}.\n\n'
//               'Place your finger on the sensor. Only this finger on this device will be accepted next time.',
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

//   // ── Combined tap handler ────────────────────
//   Future<void> _onAttendanceTap(String route, String type) async {
//     if (!await _checkLocation()) return;
//     if (!await _handleBiometric(type)) return;
//     Get.toNamed(route);
//   }

//   // ── Logout Dialog ───────────────────────────
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
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
//                 decoration: BoxDecoration(
//                     color: AppTheme.errorLight, shape: BoxShape.circle),
//                 child: const Icon(Icons.logout_rounded,
//                     color: AppTheme.error, size: 36),
//               ),
//               const SizedBox(height: 20),
//               const Text('Logout?',
//                   style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary)),
//               const SizedBox(height: 8),
//               const Text(
//                 'Are you sure you want to logout?\nYou will need to login again.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: AppTheme.textSecondary,
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
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(fontFamily: 'Poppins')),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Get.back();
//                         Get.find<AuthController>().logout();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.error,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       child: const Text('Logout',
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── ✅ Device Clear — userId input required ──
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
//                       color: Color(0xFFF0E6FF), shape: BoxShape.circle),
//                   child: const Icon(Icons.phonelink_erase_rounded,
//                       color: Color(0xFF7B2FBE), size: 36),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Device Clear',
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Enter the User ID whose registered\nfingerprint device you want to reset.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 13,
//                       color: AppTheme.textSecondary,
//                       fontFamily: 'Poppins'),
//                 ),
//                 const SizedBox(height: 20),

//                 // ✅ User ID input
//                 TextFormField(
//                   controller: userIdController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
//                           color: Color(0xFF7B2FBE), width: 2),
//                     ),
//                   ),
//                   validator: (v) {
//                     if (v == null || v.trim().isEmpty) return 'User ID required';
//                     if (int.tryParse(v.trim()) == null) return 'Enter valid numeric ID';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),

//                 // Warning
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF3E0),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: const Color(0xFFFFCC80)),
//                   ),
//                   child: const Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.warning_amber_rounded,
//                           color: Colors.orange, size: 16),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'User will be automatically logged out from their device and must re-register fingerprint on next login.',
//                           style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.orange,
//                               fontFamily: 'Poppins'),
//                         ),
//                       ),
//                     ],
//                   ),
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
//                               borderRadius: BorderRadius.circular(14)),
//                           side: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         child: const Text('Cancel',
//                             style: TextStyle(fontFamily: 'Poppins')),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Obx(() => ElevatedButton(
//                             onPressed: isLoading.value
//                                 ? null
//                                 : () async {
//                                     if (!formKey.currentState!.validate()) return;
//                                     final userId = int.parse(
//                                         userIdController.text.trim());
//                                     isLoading.value = true;
//                                     try {
//                                       await Get.find<AuthController>()
//                                           .clearDeviceForUser(userId);
//                                       Get.back();
//                                       _showSnack(
//                                           'Device cleared for User ID: $userId\nUser will be logged out.');
//                                     } catch (e) {
//                                       _showSnack('Failed: ${e.toString()}',
//                                           isError: true);
//                                     } finally {
//                                       isLoading.value = false;
//                                     }
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF7B2FBE),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14)),
//                               elevation: 0,
//                             ),
//                             child: isLoading.value
//                                 ? const SizedBox(
//                                     width: 18, height: 18,
//                                     child: CircularProgressIndicator(
//                                         color: Colors.white, strokeWidth: 2))
//                                 : const Text('Clear Device',
//                                     style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600)),
//                           )),
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
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 230,
//             floating: false,
//             pinned: true,
//             backgroundColor: AppTheme.primary,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: AppTheme.gradientDecoration,
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Obx(() => Row(children: [
//                                   Container(
//                                     width: 48, height: 48,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                           color: Colors.white.withOpacity(0.4),
//                                           width: 2),
//                                       color: Colors.white.withOpacity(0.2),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         authController.userName.value.isNotEmpty
//                                             ? authController.userName.value[0].toUpperCase()
//                                             : 'U',
//                                         style: const TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 20,
//                                             fontFamily: 'Poppins'),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text('Hello, ${authController.userName.value}!',
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               fontFamily: 'Poppins')),
//                                       const SizedBox(height: 4),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10, vertical: 3),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.25),
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         child: Text(
//                                           authController.userRole.value.toUpperCase(),
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 10,
//                                               fontWeight: FontWeight.w700,
//                                               fontFamily: 'Poppins',
//                                               letterSpacing: 0.8),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ])),
//                             GestureDetector(
//                               onTap: _showLogoutDialog,
//                               child: Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                       color: Colors.white.withOpacity(0.3)),
//                                 ),
//                                 child: const Icon(Icons.logout_rounded,
//                                     color: Colors.white, size: 20),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Text(_currentDate,
//                             style: TextStyle(
//                                 color: Colors.white.withOpacity(0.85),
//                                 fontSize: 13,
//                                 fontFamily: 'Poppins')),
//                         const SizedBox(height: 4),
//                         Text(_currentTime,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 34,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'Poppins',
//                                 letterSpacing: 1)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Quick Actions', style: AppTheme.headline3),
//                   const SizedBox(height: 14),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.login_rounded,
//                           label: 'Check In',
//                           subLabel: 'Mark arrival',
//                           color: AppTheme.success,
//                           bgColor: AppTheme.successLight,
//                           onTap: () => _onAttendanceTap('/mark-in', 'in'),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.logout_rounded,
//                           label: 'Check Out',
//                           subLabel: 'Mark departure',
//                           color: AppTheme.error,
//                           bgColor: AppTheme.errorLight,
//                           onTap: () => _onAttendanceTap('/mark-out', 'out'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _ActionCard(
//                           icon: Icons.calendar_month_rounded,
//                           label: 'My Summary',
//                           subLabel: 'View records',
//                           color: AppTheme.primary,
//                           bgColor: AppTheme.primaryLight,
//                           onTap: () => Get.toNamed('/user-summary'),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Obx(() => authController.isAdmin
//                             ? _ActionCard(
//                                 icon: Icons.admin_panel_settings_rounded,
//                                 label: 'Admin Panel',
//                                 subLabel: 'Manage users',
//                                 color: AppTheme.accent,
//                                 bgColor: AppTheme.warningLight,
//                                 onTap: () => Get.toNamed('/admin'),
//                               )
//                             : _ActionCard(
//                                 icon: Icons.history_rounded,
//                                 label: 'History',
//                                 subLabel: 'Past records',
//                                 color: AppTheme.textSecondary,
//                                 bgColor: const Color(0xFFF0F0F0),
//                                 onTap: () => Get.toNamed('/user-summary'),
//                               )),
//                       ),
//                     ],
//                   ),
//                   Obx(() => authController.isAdmin
//                       ? Column(children: [
//                           const SizedBox(height: 14),
//                           _ActionCard(
//                             icon: Icons.phonelink_erase_rounded,
//                             label: 'Device Clear',
//                             subLabel: 'Reset user fingerprint device',
//                             color: const Color(0xFF7B2FBE),
//                             bgColor: const Color(0xFFF0E6FF),
//                             onTap: _showDeviceClearDialog,
//                             fullWidth: true,
//                           ),
//                         ])
//                       : const SizedBox.shrink()),

//                   const SizedBox(height: 28),
//                   const Text("Today's Info", style: AppTheme.headline3),
//                   const SizedBox(height: 14),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _InfoCard(
//                             icon: Icons.access_time_rounded,
//                             label: 'Office Hours',
//                             value: '10:00 AM - 6:00 PM',
//                             color: AppTheme.primary),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: _InfoCard(
//                             icon: Icons.work_outline_rounded,
//                             label: 'Work Days',
//                             value: 'Mon - Sat',
//                             color: AppTheme.secondary),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 28),
//                   _AttendanceStatusBanner(),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Attendance Status Banner
// // ─────────────────────────────────────────────
// class _AttendanceStatusBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final c = Get.find<AuthController>();
//     return Obx(() {
//       final checkedIn  = c.isCheckedIn.value;
//       final checkedOut = c.isCheckedOut.value;

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: checkedOut
//                 ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
//                 : checkedIn
//                     ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
//                     : [AppTheme.primary.withOpacity(0.08), AppTheme.primary.withOpacity(0.02)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: (checkedIn ? AppTheme.success : AppTheme.primary).withOpacity(0.15),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(14)),
//               child: Icon(
//                 checkedOut ? Icons.check_circle_rounded
//                     : checkedIn ? Icons.access_time_rounded
//                     : Icons.fingerprint_rounded,
//                 color: checkedIn ? Colors.white : AppTheme.primary,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     checkedOut ? "Day Complete! 🎉"
//                         : checkedIn ? "You're Checked In"
//                         : "Not Checked In Yet",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: checkedIn ? Colors.white : AppTheme.textPrimary),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     checkedOut ? "In: ${c.checkInTime.value}  •  Out: ${c.checkOutTime.value}"
//                         : checkedIn ? "Checked in at ${c.checkInTime.value}"
//                         : "Tap Check In to start your day",
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontFamily: 'Poppins',
//                         color: checkedIn ? Colors.white.withOpacity(0.85) : AppTheme.textSecondary),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// // ─────────────────────────────────────────────
// //  _ActionCard
// // ─────────────────────────────────────────────
// class _ActionCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String subLabel;
//   final Color color;
//   final Color bgColor;
//   final VoidCallback onTap;
//   final bool fullWidth;

//   const _ActionCard({
//     required this.icon, required this.label, required this.subLabel,
//     required this.color, required this.bgColor, required this.onTap,
//     this.fullWidth = false,
//   });

//   // ✅ Reusable arrow button — sirf yahi tap hoga
//   Widget _arrowBtn() => GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Container itself is NOT tappable — only arrow is
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: EdgeInsets.symmetric(
//           horizontal: 16, vertical: fullWidth ? 14 : 18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//               color: color.withOpacity(0.12),
//               blurRadius: 16,
//               offset: const Offset(0, 6)),
//         ],
//       ),
//       child: fullWidth
//           // ── Wide card (Device Clear) ──
//           ? Row(children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     color: bgColor, borderRadius: BorderRadius.circular(12)),
//                 child: Icon(icon, color: color, size: 22),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(label,
//                         style: const TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w700,
//                             color: AppTheme.textPrimary, fontFamily: 'Poppins')),
//                     Text(subLabel,
//                         style: const TextStyle(
//                             fontSize: 11, color: AppTheme.textSecondary,
//                             fontFamily: 'Poppins')),
//                   ],
//                 ),
//               ),
//               _arrowBtn(), // ✅ Sirf arrow clickable
//             ])
//           // ── Normal square card ──
//           : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: bgColor,
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Icon(icon, color: color, size: 22),
//                   ),
//                   _arrowBtn(), // ✅ Sirf arrow clickable
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(label,
//                   style: const TextStyle(
//                       fontSize: 14, fontWeight: FontWeight.w700,
//                       color: AppTheme.textPrimary, fontFamily: 'Poppins')),
//               const SizedBox(height: 2),
//               Text(subLabel,
//                   style: const TextStyle(
//                       fontSize: 11, color: AppTheme.textSecondary,
//                       fontFamily: 'Poppins')),
//             ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  _InfoCard
// // ─────────────────────────────────────────────
// class _InfoCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _InfoCard({required this.icon, required this.label,
//       required this.value, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4))],
//       ),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10)),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: AppTheme.caption),
//             const SizedBox(height: 2),
//             Text(value, style: const TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.w700,
//                 color: AppTheme.textPrimary, fontFamily: 'Poppins')),
//           ],
//         )),
//       ]),
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

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
//  BiometricHelper — Phone Biometric (Fingerprint/Face)
// ─────────────────────────────────────────────
class _BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<String> getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await info.androidInfo).id;
    if (Platform.isIOS) return (await info.iosInfo).identifierForVendor ?? 'unknown';
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
      debugPrint('Biometric result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: ${e.code} | ${e.message}');
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
      debugPrint('Biometric unknown error: $e');
      if (e is BiometricException) rethrow;
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  BiometricException
// ─────────────────────────────────────────────
enum BiometricError { hardwareNotFound, notEnrolled, lockedOut }

class BiometricException implements Exception {
  final BiometricError error;
  const BiometricException(this.error);
}

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';

  final _box = GetStorage();

  // Keys for device-binding (per Check-In / Check-Out)
  String _keyFor(String type) => type == 'in' ? 'device_bind_in' : 'device_bind_out';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ── Location Check ──────────────────────────
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
        content: const Text('Please turn on your device location (GPS) to mark attendance.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // ── ✅ Fingerprint Flow (No server save, only local device bind) ─────────────
  Future<bool> _handleBiometric(String type) async {
    // 1) Check support
    final supported = await _BiometricHelper.isSupported();
    if (!supported) {
      _handleBiometricError(BiometricError.hardwareNotFound);
      return false;
    }

    final deviceId = await _BiometricHelper.getDeviceId();
    final savedDeviceId = (_box.read<String>(_keyFor(type)) ?? '').trim();

    // ── Register (first time) ────────────────
    if (savedDeviceId.isEmpty) {
      final confirm = await _showBiometricRegisterDialog(type);
      if (!confirm) return false;

      try {
        final ok = await _BiometricHelper.authenticate(
          type == 'in' ? 'Verify fingerprint for Check In' : 'Verify fingerprint for Check Out',
        );
        if (!ok) {
          _showSnack('Fingerprint not recognized. Try again.', isError: true);
          return false;
        }

        // ✅ Local bind
        await _box.write(_keyFor(type), deviceId);

        // (Optional) If you keep user values in controller
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

    // ── Verify (already registered) ─────────
    if (savedDeviceId != deviceId) {
      _showSnack('Wrong device! Use your registered device.', isError: true);
      return false;
    }

    try {
      final ok = await _BiometricHelper.authenticate('Place your finger to continue');
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

  // ── Biometric Error Dialog ───────────────
  void _handleBiometricError(BiometricError error) {
    String title, message;
    switch (error) {
      case BiometricError.hardwareNotFound:
        title = 'No Biometric Sensor';
        message = 'Biometric sensor not available or not supported on this device.';
        break;
      case BiometricError.notEnrolled:
        title = 'Fingerprint Not Set Up';
        message = 'No fingerprint enrolled. Go to Settings > Security > Fingerprint.';
        break;
      case BiometricError.lockedOut:
        title = 'Too Many Attempts';
        message = 'Too many attempts. Biometric is locked. Please wait and try again.';
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
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Text(title),
        ]),
        content: Text(message),
        actions: [
          if (error == BiometricError.notEnrolled)
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              Icon(Icons.fingerprint, color: AppTheme.primary, size: 28),
              const SizedBox(width: 10),
              const Text('Register Device'),
            ]),
            content: Text(
              'First time setup for ${type == 'in' ? 'Check In' : 'Check Out'}.\n\n'
              'We will bind this login to your phone. Next time attendance will work only on this device.',
            ),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Proceed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Combined tap handler ────────────────────
  Future<void> _onAttendanceTap(String route, String type) async {
    if (!await _checkLocation()) return;
    if (!await _handleBiometric(type)) return;

    // ✅ biometric ok => open page
    Get.toNamed(route);
  }

  // ── Logout Dialog ───────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.errorLight, shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to logout?\nYou will need to login again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ✅ Device Clear — clears local device binding too ─────────────
  void _showDeviceClearDialog() {
    final userIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = false.obs;

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
                  decoration: const BoxDecoration(color: Color(0xFFF0E6FF), shape: BoxShape.circle),
                  child: const Icon(Icons.phonelink_erase_rounded, color: Color(0xFF7B2FBE), size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Device Clear',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter the User ID whose registered\ndevice you want to reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontFamily: 'Poppins'),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7B2FBE), width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'User ID required';
                    if (int.tryParse(v.trim()) == null) return 'Enter valid numeric ID';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will clear local device binding.\nUser must re-register on next attempt.',
                          style: TextStyle(fontSize: 11, color: Colors.orange, fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
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
                                    // Clear local bind
                                    await _box.remove(_keyFor('in'));
                                    await _box.remove(_keyFor('out'));

                                    // If you also want to clear on server, call controller method here.
                                    // await Get.find<AuthController>().clearDeviceForUser(int.parse(userIdController.text.trim()));

                                    Get.back();
                                    _showSnack('Device binding cleared. Re-register next time.');
                                  } catch (e) {
                                    _showSnack('Failed: ${e.toString()}', isError: true);
                                  } finally {
                                    isLoading.value = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B2FBE),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: isLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Clear Device',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
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
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: AppTheme.gradientDecoration,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Obx(
                            () => Row(children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Text(
                                    authController.userName.value.isNotEmpty
                                        ? authController.userName.value[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(
                                  'Hello, ${authController.userName.value}!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    authController.userRole.value.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                          GestureDetector(
                            onTap: _showLogoutDialog,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        Text(
                          _currentDate,
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Quick Actions', style: AppTheme.headline3),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.login_rounded,
                      label: 'Check In',
                      subLabel: 'Mark arrival',
                      color: AppTheme.success,
                      bgColor: AppTheme.successLight,
                      onTap: () => _onAttendanceTap('/mark-in', 'in'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.logout_rounded,
                      label: 'Check Out',
                      subLabel: 'Mark departure',
                      color: AppTheme.error,
                      bgColor: AppTheme.errorLight,
                      onTap: () => _onAttendanceTap('/mark-out', 'out'),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'My Summary',
                      subLabel: 'View records',
                      color: AppTheme.primary,
                      bgColor: AppTheme.primaryLight,
                      onTap: () => Get.toNamed('/user-summary'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Obx(
                      () => authController.isAdmin
                          ? _ActionCard(
                              icon: Icons.admin_panel_settings_rounded,
                              label: 'Admin Panel',
                              subLabel: 'Manage users',
                              color: AppTheme.accent,
                              bgColor: AppTheme.warningLight,
                              onTap: () => Get.toNamed('/admin'),
                            )
                          : _ActionCard(
                              icon: Icons.history_rounded,
                              label: 'History',
                              subLabel: 'Past records',
                              color: AppTheme.textSecondary,
                              bgColor: const Color(0xFFF0F0F0),
                              onTap: () => Get.toNamed('/user-summary'),
                            ),
                    ),
                  ),
                ]),
                Obx(
                  () => authController.isAdmin
                      ? Column(children: [
                          const SizedBox(height: 14),
                          _ActionCard(
                            icon: Icons.phonelink_erase_rounded,
                            label: 'Device Clear',
                            subLabel: 'Reset user device binding',
                            color: const Color(0xFF7B2FBE),
                            bgColor: const Color(0xFFF0E6FF),
                            onTap: _showDeviceClearDialog,
                            fullWidth: true,
                          ),
                        ])
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),
                const Text("Today's Info", style: AppTheme.headline3),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.access_time_rounded,
                      label: 'Office Hours',
                      value: '10:00 AM - 6:00 PM',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.work_outline_rounded,
                      label: 'Work Days',
                      value: 'Mon - Sat',
                      color: AppTheme.secondary,
                    ),
                  ),
                ]),
                const SizedBox(height: 28),
                _AttendanceStatusBanner(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Attendance Status Banner
// ─────────────────────────────────────────────
class _AttendanceStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    return Obx(() {
      final checkedIn = c.isCheckedIn.value;
      final checkedOut = c.isCheckedOut.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: checkedOut
                ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                : checkedIn
                    ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
                    : [AppTheme.primary.withOpacity(0.08), AppTheme.primary.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (checkedIn ? AppTheme.success : AppTheme.primary).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                checkedOut
                    ? Icons.check_circle_rounded
                    : checkedIn
                        ? Icons.access_time_rounded
                        : Icons.fingerprint_rounded,
                color: checkedIn ? Colors.white : AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  checkedOut
                      ? "Day Complete! 🎉"
                      : checkedIn
                          ? "You're Checked In"
                          : "Not Checked In Yet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: checkedIn ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  checkedOut
                      ? "In: ${c.checkInTime.value}  •  Out: ${c.checkOutTime.value}"
                      : checkedIn
                          ? "Checked in at ${c.checkInTime.value}"
                          : "Tap Check In to start your day",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: checkedIn ? Colors.white.withOpacity(0.85) : AppTheme.textSecondary,
                  ),
                ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
//  _ActionCard
// ─────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.fullWidth = false,
  });

  Widget _arrowBtn() => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: fullWidth ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: fullWidth
          ? Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    subLabel,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'Poppins'),
                  ),
                ]),
              ),
              _arrowBtn(),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                _arrowBtn(),
              ]),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'Poppins'),
              ),
            ]),
    );
  }
}

// ─────────────────────────────────────────────
//  _InfoCard
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTheme.caption),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
