// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';

// class MarkAttendanceScreen extends StatefulWidget {
//   final bool isMarkIn;

//   const MarkAttendanceScreen({super.key, required this.isMarkIn});

//   @override
//   State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
// }

// class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     // Reset selfie on screen open
//     controller.clearSelfie();
//     controller.currentLat.value = 0.0;
//     controller.currentLng.value = 0.0;
//     controller.currentAddress.value = '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIn = widget.isMarkIn;
//     final color = isIn ? AppTheme.success : AppTheme.error;
//     final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
//     final title = isIn ? 'Check In' : 'Check Out';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =================== HEADER CARD ===================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       isIn ? Icons.login : Icons.logout,
//                       color: color,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       Text(
//                         isIn
//                             ? 'Mark your arrival time'
//                             : 'Mark your departure time',
//                         style: AppTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // =================== SELFIE SECTION ===================
//             const Text('Selfie Verification', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Take a selfie for identity verification',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Obx(() => controller.selfieFile.value == null
//                 ? _SelfiePickerCard(controller: controller)
//                 : _SelfiePreviewCard(controller: controller)),

//             const SizedBox(height: 24),

//             // =================== LOCATION SECTION ===================
//             const Text('Location', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Your current location will be recorded',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() => Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: controller.currentLat.value != 0.0
//                             ? AppTheme.success
//                             : AppTheme.textHint,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: controller.currentAddress.value.isEmpty
//                             ? const Text(
//                                 'Location not fetched yet',
//                                 style: AppTheme.bodySmall,
//                               )
//                             : Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     controller.currentAddress.value,
//                                     style: AppTheme.bodyMedium,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Lat: ${controller.currentLat.value.toStringAsFixed(6)}, '
//                                     'Lng: ${controller.currentLng.value.toStringAsFixed(6)}',
//                                     style: AppTheme.caption,
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ],
//                   )),
//                   const SizedBox(height: 14),

//                   Obx(() => SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton.icon(
//                       onPressed: controller.isLocationLoading.value
//                           ? null
//                           : controller.fetchLocation,
//                       icon: controller.isLocationLoading.value
//                           ? const SizedBox(
//                               height: 16,
//                               width: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: AppTheme.primary,
//                               ),
//                             )
//                           : const Icon(Icons.my_location),
//                       label: Text(
//                         controller.currentLat.value != 0.0
//                             ? 'Refresh Location'
//                             : 'Fetch My Location',
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppTheme.primary,
//                         side: const BorderSide(color: AppTheme.primary),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // =================== SUBMIT BUTTON ===================
//             Obx(() => ElevatedButton(
//               onPressed: (controller.isMarkingIn.value ||
//                       controller.isMarkingOut.value)
//                   ? null
//                   : (isIn ? controller.markIn : controller.markOut),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: color,
//                 minimumSize: const Size(double.infinity, 52),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: (controller.isMarkingIn.value ||
//                       controller.isMarkingOut.value)
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       isIn ? 'Submit Check In' : 'Submit Check Out',
//                       style: AppTheme.buttonText,
//                     ),
//             )),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SelfiePickerCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePickerCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.camera_alt_outlined,
//               size: 40,
//               color: AppTheme.primary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text('No selfie taken', style: AppTheme.bodyLarge),
//           const SizedBox(height: 6),
//           const Text(
//             'Use front camera for best results',
//             style: AppTheme.bodySmall,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.camera_front, size: 18),
//                   label: const Text('Camera'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(0, 44),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: controller.pickFromGallery,
//                   icon: const Icon(Icons.photo_library_outlined,
//                       size: 18, color: AppTheme.primary),
//                   label: const Text(
//                     'Gallery',
//                     style: TextStyle(color: AppTheme.primary),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(0, 44),
//                     side: const BorderSide(color: AppTheme.primary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SelfiePreviewCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePreviewCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.file(
//               controller.selfieFile.value!,
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.check_circle,
//                     color: AppTheme.success, size: 18),
//                 const SizedBox(width: 8),
//                 const Text('Selfie captured', style: AppTheme.bodyMedium),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.refresh, size: 16),
//                   label: const Text('Retake'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppTheme.primary,
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







// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';

// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';

// class MarkAttendanceScreen extends StatefulWidget {
//   final bool isMarkIn;

//   const MarkAttendanceScreen({super.key, required this.isMarkIn});

//   @override
//   State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
// }

// class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     // Reset selfie on screen open
//     controller.clearSelfie();
//     controller.currentLat.value = 0.0;
//     controller.currentLng.value = 0.0;
//     controller.currentAddress.value = '';
//   }

//   // ✅ Biometric verify before submit
//   Future<bool> _verifyBiometric() async {
//     final auth = LocalAuthentication();

//     try {
//       final canCheck = await auth.canCheckBiometrics;
//       final isSupported = await auth.isDeviceSupported();

//       if (!canCheck || !isSupported) {
//         Get.snackbar("Error", "Biometric not available on this device");
//         return false;
//       }

//       final ok = await auth.authenticate(
//         localizedReason: "Verify fingerprint to continue",
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );

//       return ok;
//     } on PlatformException catch (e) {
//       Get.snackbar("Error", "Biometric error: ${e.code}");
//       return false;
//     } catch (e) {
//       Get.snackbar("Error", "Biometric failed");
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIn = widget.isMarkIn;
//     final color = isIn ? AppTheme.success : AppTheme.error;
//     final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
//     final title = isIn ? 'Check In' : 'Check Out';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =================== HEADER CARD ===================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       isIn ? Icons.login : Icons.logout,
//                       color: color,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       Text(
//                         isIn ? 'Mark your arrival time' : 'Mark your departure time',
//                         style: AppTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // =================== SELFIE SECTION ===================
//             const Text('Selfie Verification', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Take a selfie for identity verification',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Obx(() => controller.selfieFile.value == null
//                 ? _SelfiePickerCard(controller: controller)
//                 : _SelfiePreviewCard(controller: controller)),

//             const SizedBox(height: 24),

//             // =================== LOCATION SECTION ===================
//             const Text('Location', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Your current location will be recorded',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() => Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: controller.currentLat.value != 0.0
//                                 ? AppTheme.success
//                                 : AppTheme.textHint,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: controller.currentAddress.value.isEmpty
//                                 ? const Text(
//                                     'Location not fetched yet',
//                                     style: AppTheme.bodySmall,
//                                   )
//                                 : Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         controller.currentAddress.value,
//                                         style: AppTheme.bodyMedium,
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Lat: ${controller.currentLat.value.toStringAsFixed(6)}, '
//                                         'Lng: ${controller.currentLng.value.toStringAsFixed(6)}',
//                                         style: AppTheme.caption,
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ],
//                       )),
//                   const SizedBox(height: 14),
//                   Obx(() => SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: controller.isLocationLoading.value
//                               ? null
//                               : controller.fetchLocation,
//                           icon: controller.isLocationLoading.value
//                               ? const SizedBox(
//                                   height: 16,
//                                   width: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppTheme.primary,
//                                   ),
//                                 )
//                               : const Icon(Icons.my_location),
//                           label: Text(
//                             controller.currentLat.value != 0.0
//                                 ? 'Refresh Location'
//                                 : 'Fetch My Location',
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: AppTheme.primary,
//                             side: const BorderSide(color: AppTheme.primary),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // =================== SUBMIT BUTTON ===================
//             Obx(() => ElevatedButton(
//                   onPressed: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? null
//                       : () async {
//                           final ok = await _verifyBiometric();
//                           if (!ok) return;

//                           if (isIn) {
//                             await controller.markIn();
//                           } else {
//                             await controller.markOut();
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: color,
//                     minimumSize: const Size(double.infinity, 52),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(
//                           isIn ? 'Submit Check In' : 'Submit Check Out',
//                           style: AppTheme.buttonText,
//                         ),
//                 )),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SelfiePickerCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePickerCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.camera_alt_outlined,
//               size: 40,
//               color: AppTheme.primary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text('No selfie taken', style: AppTheme.bodyLarge),
//           const SizedBox(height: 6),
//           const Text(
//             'Use front camera for best results',
//             style: AppTheme.bodySmall,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.camera_front, size: 18),
//                   label: const Text('Camera'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(0, 44),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: controller.pickFromGallery,
//                   icon: const Icon(Icons.photo_library_outlined,
//                       size: 18, color: AppTheme.primary),
//                   label: const Text(
//                     'Gallery',
//                     style: TextStyle(color: AppTheme.primary),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(0, 44),
//                     side: const BorderSide(color: AppTheme.primary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SelfiePreviewCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePreviewCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.file(
//               controller.selfieFile.value!,
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.check_circle,
//                     color: AppTheme.success, size: 18),
//                 const SizedBox(width: 8),
//                 const Text('Selfie captured', style: AppTheme.bodyMedium),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.refresh, size: 16),
//                   label: const Text('Retake'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppTheme.primary,
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








// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';

// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';

// class MarkAttendanceScreen extends StatefulWidget {
//   final bool isMarkIn;

//   const MarkAttendanceScreen({super.key, required this.isMarkIn});

//   @override
//   State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
// }

// class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     controller.clearSelfie();
//     controller.currentLat.value = 0.0;
//     controller.currentLng.value = 0.0;
//     controller.currentAddress.value = '';
//   }

//   Future<bool> _verifyBiometric() async {
//     final auth = LocalAuthentication();

//     try {
//       final canCheck = await auth.canCheckBiometrics;
//       final isSupported = await auth.isDeviceSupported();

//       if (!canCheck || !isSupported) {
//         Get.snackbar("Error", "Biometric not available on this device");
//         return false;
//       }

//       final ok = await auth.authenticate(
//         localizedReason: "Verify fingerprint to continue",
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );

//       return ok;
//     } on PlatformException catch (e) {
//       Get.snackbar("Error", "Biometric error: ${e.code}");
//       return false;
//     } catch (e) {
//       Get.snackbar("Error", "Biometric failed");
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIn = widget.isMarkIn;
//     final color = isIn ? AppTheme.success : AppTheme.error;
//     final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
//     final title = isIn ? 'Check In' : 'Check Out';
//     final selfieRequired = controller.isSelfieRequired;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =================== HEADER CARD ===================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       isIn ? Icons.login : Icons.logout,
//                       color: color,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       Text(
//                         isIn
//                             ? 'Mark your arrival time'
//                             : 'Mark your departure time',
//                         style: AppTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // =================== SELFIE SECTION ===================
//             Row(
//               children: [
//                 const Text('Selfie Verification', style: AppTheme.headline3),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: selfieRequired
//                         ? AppTheme.error.withOpacity(0.12)
//                         : AppTheme.textHint.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     selfieRequired ? 'Required' : 'Optional',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color:
//                           selfieRequired ? AppTheme.error : AppTheme.textHint,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               selfieRequired
//                   ? 'Selfie is mandatory for your role'
//                   : 'Take a selfie for identity verification (optional)',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Obx(() => controller.selfieFile.value == null
//                 ? _SelfiePickerCard(controller: controller)
//                 : _SelfiePreviewCard(controller: controller)),

//             const SizedBox(height: 24),

//             // =================== LOCATION SECTION ===================
//             const Text('Location', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Your current location will be recorded',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() => Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: controller.currentLat.value != 0.0
//                                 ? AppTheme.success
//                                 : AppTheme.textHint,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: controller.currentAddress.value.isEmpty
//                                 ? const Text(
//                                     'Location not fetched yet',
//                                     style: AppTheme.bodySmall,
//                                   )
//                                 : Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         controller.currentAddress.value,
//                                         style: AppTheme.bodyMedium,
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Lat: ${controller.currentLat.value.toStringAsFixed(6)}, '
//                                         'Lng: ${controller.currentLng.value.toStringAsFixed(6)}',
//                                         style: AppTheme.caption,
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ],
//                       )),
//                   const SizedBox(height: 14),
//                   Obx(() => SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: controller.isLocationLoading.value
//                               ? null
//                               : controller.fetchLocation,
//                           icon: controller.isLocationLoading.value
//                               ? const SizedBox(
//                                   height: 16,
//                                   width: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppTheme.primary,
//                                   ),
//                                 )
//                               : const Icon(Icons.my_location),
//                           label: Text(
//                             controller.currentLat.value != 0.0
//                                 ? 'Refresh Location'
//                                 : 'Fetch My Location',
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: AppTheme.primary,
//                             side: const BorderSide(color: AppTheme.primary),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // =================== SUBMIT BUTTON ===================
//             Obx(() => ElevatedButton(
//                   onPressed: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? null
//                       : () async {
//                           final ok = await _verifyBiometric();
//                           if (!ok) return;

//                           if (isIn) {
//                             await controller.markIn();
//                           } else {
//                             await controller.markOut();
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: color,
//                     minimumSize: const Size(double.infinity, 52),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(
//                           isIn ? 'Submit Check In' : 'Submit Check Out',
//                           style: AppTheme.buttonText,
//                         ),
//                 )),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== SELFIE PICKER (Camera Only) ===================
// class _SelfiePickerCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePickerCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.camera_alt_outlined,
//               size: 40,
//               color: AppTheme.primary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text('No selfie taken', style: AppTheme.bodyLarge),
//           const SizedBox(height: 6),
//           const Text(
//             'Use front camera for best results',
//             style: AppTheme.bodySmall,
//           ),
//           const SizedBox(height: 20),
//           // ✅ Gallery removed — Camera only
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: controller.takeSelfie,
//               icon: const Icon(Icons.camera_front, size: 18),
//               label: const Text('Take Selfie'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(0, 44),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== SELFIE PREVIEW ===================
// class _SelfiePreviewCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePreviewCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.file(
//               controller.selfieFile.value!,
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 const Icon(Icons.check_circle,
//                     color: AppTheme.success, size: 18),
//                 const SizedBox(width: 8),
//                 const Text('Selfie captured', style: AppTheme.bodyMedium),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.refresh, size: 16),
//                   label: const Text('Retake'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppTheme.primary,
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











// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';

// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';

// class MarkAttendanceScreen extends StatefulWidget {
//   final bool isMarkIn;

//   const MarkAttendanceScreen({super.key, required this.isMarkIn});

//   @override
//   State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
// }

// class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
//   // ✅ Use existing controller (don't create new on every screen)
//   final AttendanceController controller = Get.find<AttendanceController>();

//   @override
//   void initState() {
//     super.initState();

//     // reset state
//     controller.resetScreenState();

//     // ✅ Auto fetch location when screen opens
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await controller.fetchLocation();
//     });
//   }

//   Future<bool> _verifyBiometric() async {
//     final auth = LocalAuthentication();

//     try {
//       final canCheck = await auth.canCheckBiometrics;
//       final isSupported = await auth.isDeviceSupported();

//       if (!canCheck || !isSupported) {
//         Get.snackbar("Error", "Biometric not available on this device");
//         return false;
//       }

//       final ok = await auth.authenticate(
//         localizedReason: "Verify fingerprint to continue",
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );

//       return ok;
//     } on PlatformException catch (e) {
//       Get.snackbar("Error", "Biometric error: ${e.code}");
//       return false;
//     } catch (_) {
//       Get.snackbar("Error", "Biometric failed");
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIn = widget.isMarkIn;
//     final color = isIn ? AppTheme.success : AppTheme.error;
//     final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
//     final title = isIn ? 'Check In' : 'Check Out';
//     final selfieRequired = controller.isSelfieRequired;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // =================== HEADER CARD ===================
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       isIn ? Icons.login : Icons.logout,
//                       color: color,
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       Text(
//                         isIn
//                             ? 'Mark your arrival time'
//                             : 'Mark your departure time',
//                         style: AppTheme.bodySmall,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // ✅ Location fetching indicator (auto-fetch)
//             Obx(() => controller.isLocationLoading.value
//                 ? Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryLight,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: const [
//                         SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             'Fetching your current location...',
//                             style: AppTheme.bodySmall,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : const SizedBox.shrink()),

//             const SizedBox(height: 24),

//             // =================== SELFIE SECTION ===================
//             Row(
//               children: [
//                 const Text('Selfie Verification', style: AppTheme.headline3),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: selfieRequired
//                         ? AppTheme.error.withOpacity(0.12)
//                         : AppTheme.textHint.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     selfieRequired ? 'Required' : 'Optional',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color:
//                           selfieRequired ? AppTheme.error : AppTheme.textHint,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               selfieRequired
//                   ? 'Selfie is mandatory for your role'
//                   : 'Take a selfie for identity verification (optional)',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Obx(() => controller.selfieFile.value == null
//                 ? _SelfiePickerCard(controller: controller)
//                 : _SelfiePreviewCard(controller: controller)),

//             const SizedBox(height: 24),

//             // =================== LOCATION SECTION ===================
//             const Text('Location', style: AppTheme.headline3),
//             const SizedBox(height: 6),
//             const Text(
//               'Your current location will be recorded',
//               style: AppTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: AppTheme.cardDecoration(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() => Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: controller.currentLat.value != 0.0
//                                 ? AppTheme.success
//                                 : AppTheme.textHint,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: controller.currentAddress.value.isEmpty
//                                 ? const Text(
//                                     'Location not fetched yet',
//                                     style: AppTheme.bodySmall,
//                                   )
//                                 : Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         controller.currentAddress.value,
//                                         style: AppTheme.bodyMedium,
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Lat: ${controller.currentLat.value.toStringAsFixed(6)}, '
//                                         'Lng: ${controller.currentLng.value.toStringAsFixed(6)}',
//                                         style: AppTheme.caption,
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ],
//                       )),
//                   const SizedBox(height: 14),
//                   Obx(() => SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: controller.isLocationLoading.value
//                               ? null
//                               : controller.fetchLocation,
//                           icon: controller.isLocationLoading.value
//                               ? const SizedBox(
//                                   height: 16,
//                                   width: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppTheme.primary,
//                                   ),
//                                 )
//                               : const Icon(Icons.my_location),
//                           label: Text(
//                             controller.currentLat.value != 0.0
//                                 ? 'Refresh Location'
//                                 : 'Fetch My Location',
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: AppTheme.primary,
//                             side: const BorderSide(color: AppTheme.primary),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // =================== SUBMIT BUTTON ===================
//             Obx(() => ElevatedButton(
//                   onPressed: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? null
//                       : () async {
//                           // ✅ ensure location ready
//                           if (controller.currentLat.value == 0.0 ||
//                               controller.currentAddress.value.isEmpty) {
//                             Get.snackbar(
//                               "Location Required",
//                               "Please wait, fetching your location...",
//                             );
//                             await controller.fetchLocation();
//                             return;
//                           }

//                           final ok = await _verifyBiometric();
//                           if (!ok) return;

//                           if (isIn) {
//                             await controller.markIn();
//                           } else {
//                             await controller.markOut();
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: color,
//                     minimumSize: const Size(double.infinity, 52),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: (controller.isMarkingIn.value ||
//                           controller.isMarkingOut.value)
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(
//                           isIn ? 'Submit Check In' : 'Submit Check Out',
//                           style: AppTheme.buttonText,
//                         ),
//                 )),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== SELFIE PICKER (Camera Only) ===================
// class _SelfiePickerCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePickerCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.camera_alt_outlined,
//               size: 40,
//               color: AppTheme.primary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text('No selfie taken', style: AppTheme.bodyLarge),
//           const SizedBox(height: 6),
//           const Text(
//             'Use front camera for best results',
//             style: AppTheme.bodySmall,
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: controller.takeSelfie,
//               icon: const Icon(Icons.camera_front, size: 18),
//               label: const Text('Take Selfie'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(0, 44),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== SELFIE PREVIEW ===================
// class _SelfiePreviewCard extends StatelessWidget {
//   final AttendanceController controller;

//   const _SelfiePreviewCard({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Image.file(
//               controller.selfieFile.value!,
//               height: 220,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 const Icon(Icons.check_circle,
//                     color: AppTheme.success, size: 18),
//                 const SizedBox(width: 8),
//                 const Text('Selfie captured', style: AppTheme.bodyMedium),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: controller.takeSelfie,
//                   icon: const Icon(Icons.refresh, size: 16),
//                   label: const Text('Retake'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppTheme.primary,
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












import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../controllers/attendance_controller.dart';
import '../../core/theme/app_theme.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final bool isMarkIn;

  const MarkAttendanceScreen({super.key, required this.isMarkIn});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // ✅ Use already registered controller (main.dart)
  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();

    // reset local screen state
    controller.clearSelfie();
    controller.currentLat.value = 0.0;
    controller.currentLng.value = 0.0;
    controller.currentAddress.value = '';

    // ✅ Auto fetch location when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLocation();
    });
  }

  Future<bool> _verifyBiometric() async {
    final auth = LocalAuthentication();

    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        Get.snackbar("Error", "Biometric not available on this device");
        return false;
      }

      final ok = await auth.authenticate(
        localizedReason: "Verify fingerprint to continue",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return ok;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Biometric error: ${e.code}");
      return false;
    } catch (e) {
      Get.snackbar("Error", "Biometric failed");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIn = widget.isMarkIn;
    final color = isIn ? AppTheme.success : AppTheme.error;
    final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
    final title = isIn ? 'Check In' : 'Check Out';
    final selfieRequired = controller.isSelfieRequired;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================== HEADER CARD ===================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isIn ? Icons.login : Icons.logout,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        isIn
                            ? 'Mark your arrival time'
                            : 'Mark your departure time',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // =================== SELFIE SECTION ===================
            Row(
              children: [
                const Text('Selfie Verification', style: AppTheme.headline3),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: selfieRequired
                        ? AppTheme.error.withOpacity(0.12)
                        : AppTheme.textHint.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selfieRequired ? 'Required' : 'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          selfieRequired ? AppTheme.error : AppTheme.textHint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selfieRequired
                  ? 'Selfie is mandatory for your role'
                  : 'Take a selfie for identity verification (optional)',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            Obx(() => controller.selfieFile.value == null
                ? _SelfiePickerCard(controller: controller)
                : _SelfiePreviewCard(controller: controller)),

            const SizedBox(height: 24),

            // =================== LOCATION SECTION ===================
            const Text('Location', style: AppTheme.headline3),
            const SizedBox(height: 6),
            const Text(
              'Your current location will be recorded',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: controller.currentLat.value != 0.0
                                ? AppTheme.success
                                : AppTheme.textHint,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: controller.currentAddress.value.isEmpty
                                ? const Text(
                                    'Location not fetched yet',
                                    style: AppTheme.bodySmall,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.currentAddress.value,
                                        style: AppTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lat: ${controller.currentLat.value.toStringAsFixed(6)}, '
                                        'Lng: ${controller.currentLng.value.toStringAsFixed(6)}',
                                        style: AppTheme.caption,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 14),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.isLocationLoading.value
                              ? null
                              : controller.fetchLocation,
                          icon: controller.isLocationLoading.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            controller.currentLat.value != 0.0
                                ? 'Refresh Location'
                                : 'Fetch My Location',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // =================== SUBMIT BUTTON ===================
            Obx(() => ElevatedButton(
                  onPressed: (controller.isMarkingIn.value ||
                          controller.isMarkingOut.value)
                      ? null
                      : () async {
                          // ✅ ensure location is fetched (auto) before submit
                          if (controller.currentLat.value == 0.0 ||
                              controller.currentLng.value == 0.0 ||
                              controller.currentAddress.value.trim().isEmpty) {
                            await controller.fetchLocation();
                          }

                          final ok = await _verifyBiometric();
                          if (!ok) return;

                          if (isIn) {
                            await controller.markIn();
                          } else {
                            await controller.markOut();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (controller.isMarkingIn.value ||
                          controller.isMarkingOut.value)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isIn ? 'Submit Check In' : 'Submit Check Out',
                          style: AppTheme.buttonText,
                        ),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// =================== SELFIE PICKER (Camera Only) ===================
class _SelfiePickerCard extends StatelessWidget {
  final AttendanceController controller;

  const _SelfiePickerCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text('No selfie taken', style: AppTheme.bodyLarge),
          const SizedBox(height: 6),
          const Text(
            'Use front camera for best results',
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.takeSelfie,
              icon: const Icon(Icons.camera_front, size: 18),
              label: const Text('Take Selfie'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================== SELFIE PREVIEW ===================
class _SelfiePreviewCard extends StatelessWidget {
  final AttendanceController controller;

  const _SelfiePreviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.file(
              controller.selfieFile.value!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppTheme.success, size: 18),
                const SizedBox(width: 8),
                const Text('Selfie captured', style: AppTheme.bodyMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.takeSelfie,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retake'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
