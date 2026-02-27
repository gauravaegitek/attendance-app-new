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
  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    controller.clearSelfie();
    controller.currentLat.value = 0.0;
    controller.currentLng.value = 0.0;
    controller.currentAddress.value = '';

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
        Get.snackbar(
          'Error',
          'Biometric not available on this device',
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
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
      Get.snackbar(
        'Error',
        'Biometric error: ${e.code}',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Biometric failed',
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
      return false;
    }
  }

  // ✅ Step-by-step submit — sirf success pe HomeScreen pe jayega
  Future<void> _handleSubmit() async {
    final isIn = widget.isMarkIn;

    // ── Step 1: Location check ─────────────────────────────
    if (controller.currentLat.value == 0.0 ||
        controller.currentLng.value == 0.0 ||
        controller.currentAddress.value.trim().isEmpty) {
      await controller.fetchLocation();

      if (controller.currentLat.value == 0.0) {
        Get.snackbar(
          'Error',
          'Unable to fetch location. Please try again.',
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          icon: const Icon(Icons.location_off, color: Colors.white),
        );
        return; // ❌ stop
      }
    }

    // ── Step 2: Biometric verify ───────────────────────────
    final biometricOk = await _verifyBiometric();
    if (!biometricOk) return; // ❌ stop

    // ── Step 3: API call — bool result milega ──────────────
    final bool success;
    if (isIn) {
      success = await controller.markIn();
    } else {
      success = await controller.markOut();
    }

    // ── Step 4: Sirf success pe HomeScreen navigate karo ──
    if (success) {
      // controller ne resetScreenState() call kar diya
      // ab stack clear karke Home pe wapas jao
      Get.until((route) => route.isFirst); // ✅ HomeScreen
    }
    // failure pe controller already showError/showWarning dikha chuka hai
  }

  @override
  Widget build(BuildContext context) {
    final isIn = widget.isMarkIn;
    final color = isIn ? AppTheme.success : AppTheme.error;
    final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
    final title = isIn ? 'Mark In' : 'Mark Out';
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
                      : _handleSubmit,
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
                          isIn ? 'Submit Mark In' : 'Submit Check Out',
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

// =================== SELFIE PICKER ===================
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











// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart';

// import '../../controllers/attendance_controller.dart';
// import '../../controllers/location_controller.dart';
// import '../../core/theme/app_theme.dart';

// class MarkAttendanceScreen extends StatefulWidget {
//   final bool isMarkIn;

//   const MarkAttendanceScreen({super.key, required this.isMarkIn});

//   @override
//   State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
// }

// class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
//   final AttendanceController controller = Get.find<AttendanceController>();

//   // ✅ LocationController — auto check-in/out ke liye
//   late final LocationController _locationCtrl;

//   // Work type selection for location check-in
//   String _workType = 'Office';
//   final List<String> _workTypes = ['Office', 'WFH', 'Field', 'Client Site'];

//   @override
//   void initState() {
//     super.initState();

//     // Register LocationController agar already nahi hai
//     if (!Get.isRegistered<LocationController>()) {
//       Get.put(LocationController());
//     }
//     _locationCtrl = Get.find<LocationController>();

//     controller.clearSelfie();
//     controller.currentLat.value = 0.0;
//     controller.currentLng.value = 0.0;
//     controller.currentAddress.value = '';

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchLocation();
//     });
//   }

//   Future<bool> _verifyBiometric() async {
//     final auth = LocalAuthentication();
//     try {
//       final canCheck = await auth.canCheckBiometrics;
//       final isSupported = await auth.isDeviceSupported();

//       if (!canCheck || !isSupported) {
//         Get.snackbar(
//           'Error',
//           'Biometric not available on this device',
//           backgroundColor: AppTheme.error,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           borderRadius: 14,
//         );
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
//       Get.snackbar(
//         'Error',
//         'Biometric error: ${e.code}',
//         backgroundColor: AppTheme.error,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(16),
//         borderRadius: 14,
//       );
//       return false;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Biometric failed',
//         backgroundColor: AppTheme.error,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(16),
//         borderRadius: 14,
//       );
//       return false;
//     }
//   }

//   // ✅ Main submit — attendance + auto location
//   Future<void> _handleSubmit() async {
//     final isIn = widget.isMarkIn;

//     // ── Step 1: Location check ─────────────────────────────
//     if (controller.currentLat.value == 0.0 ||
//         controller.currentLng.value == 0.0 ||
//         controller.currentAddress.value.trim().isEmpty) {
//       await controller.fetchLocation();

//       if (controller.currentLat.value == 0.0) {
//         Get.snackbar(
//           'Error',
//           'Unable to fetch location. Please try again.',
//           backgroundColor: AppTheme.error,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           borderRadius: 14,
//           icon: const Icon(Icons.location_off, color: Colors.white),
//         );
//         return;
//       }
//     }

//     // ── Step 2: Biometric verify ───────────────────────────
//     final biometricOk = await _verifyBiometric();
//     if (!biometricOk) return;

//     // ── Step 3: Attendance API call ────────────────────────
//     final bool success;
//     if (isIn) {
//       success = await controller.markIn();
//     } else {
//       success = await controller.markOut();
//     }

//     if (!success) return;

//     // ── Step 4: AUTO Location Check-in / Check-out ─────────
//     if (isIn) {
//       await _autoLocationCheckIn();
//     } else {
//       await _autoLocationCheckOut();
//     }

//     // ── Step 5: HomeScreen pe wapas jao ───────────────────
//     Get.until((route) => route.isFirst);
//   }

//   // ─────────────────────────────────────────────
//   //  AUTO LOCATION CHECK-IN
//   // ─────────────────────────────────────────────
//   Future<void> _autoLocationCheckIn() async {
//     try {
//       if (_locationCtrl.activeTracking.value != null) {
//         debugPrint('Auto check-in skipped — active session already exists');
//         return;
//       }

//       final ok = await _locationCtrl.checkIn(workType: _workType);

//       if (ok) {
//         Get.snackbar(
//           '📍 Location',
//           'Check-in recorded automatically',
//           backgroundColor: AppTheme.success,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           borderRadius: 14,
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } catch (e) {
//       debugPrint('Auto check-in error: $e');
//       // Silent fail — attendance already marked
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  AUTO LOCATION CHECK-OUT
//   // ─────────────────────────────────────────────
//   Future<void> _autoLocationCheckOut() async {
//     try {
//       final active = _locationCtrl.activeTracking.value;
//       if (active == null) {
//         debugPrint('Auto check-out skipped — no active session found');
//         return;
//       }

//       final ok = await _locationCtrl.checkOut(active.trackingId);

//       if (ok) {
//         Get.snackbar(
//           '📍 Location',
//           'Check-out recorded automatically',
//           backgroundColor: const Color(0xFF6366F1),
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(16),
//           borderRadius: 14,
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } catch (e) {
//       debugPrint('Auto check-out error: $e');
//       // Silent fail
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isIn = widget.isMarkIn;
//     final color = isIn ? AppTheme.success : AppTheme.error;
//     final bgColor = isIn ? AppTheme.successLight : AppTheme.errorLight;
//     final title = isIn ? 'Mark In' : 'Mark Out';
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
//             const SizedBox(height: 20),

//             // =================== WORK TYPE (only Mark In) ===================
//             if (isIn) ...[
//               Row(children: [
//                 Container(
//                   width: 4,
//                   height: 18,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Text('Work Type', style: AppTheme.headline3),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6366F1).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Auto Location',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF6366F1),
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ),
//               ]),
//               const SizedBox(height: 6),
//               const Text(
//                 'Select your work mode — location will be recorded automatically',
//                 style: AppTheme.bodySmall,
//               ),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: _workTypes.map((type) {
//                   final selected = _workType == type;
//                   return GestureDetector(
//                     onTap: () => setState(() => _workType = type),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 9),
//                       decoration: BoxDecoration(
//                         color: selected
//                             ? AppTheme.primary
//                             : AppTheme.primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(22),
//                         border: Border.all(
//                           color: selected
//                               ? AppTheme.primary
//                               : AppTheme.primary.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Text(
//                         type,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w600,
//                           color: selected ? Colors.white : AppTheme.primary,
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // =================== MARK OUT — Auto checkout notice ===================
//             if (!isIn) ...[
//               Obx(() {
//                 final active = _locationCtrl.activeTracking.value;
//                 if (active == null) return const SizedBox.shrink();
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6366F1).withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                         color: const Color(0xFF6366F1).withOpacity(0.25)),
//                   ),
//                   child: Row(children: [
//                     const Icon(Icons.location_on_rounded,
//                         color: Color(0xFF6366F1), size: 20),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Location will auto check-out',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: Color(0xFF6366F1),
//                             ),
//                           ),
//                           Text(
//                             'Active session: ${active.workType.isEmpty ? 'Office' : active.workType}',
//                             style: AppTheme.caption,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]),
//                 );
//               }),
//             ],

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
//                       : _handleSubmit,
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
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               isIn
//                                   ? Icons.login_rounded
//                                   : Icons.logout_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               isIn ? 'Submit Mark In' : 'Submit Mark Out',
//                               style: AppTheme.buttonText,
//                             ),
//                             const SizedBox(width: 10),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 7, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Text(
//                                 '+ Location',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                 )),
//             const SizedBox(height: 16),

//             // =================== INFO BANNER ===================
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: AppTheme.info.withOpacity(0.06),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppTheme.info.withOpacity(0.2)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.info_outline_rounded,
//                       color: AppTheme.info, size: 18),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       isIn
//                           ? 'Location check-in will be recorded automatically when you submit Mark In.'
//                           : 'Location check-out will be recorded automatically when you submit Mark Out.',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textSecondary,
//                         fontFamily: 'Poppins',
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== SELFIE PICKER ===================
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
//             decoration: const BoxDecoration(
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


// Mark In Screen
//     ↓ Submit button press
// 1. Location check ✓
// 2. Biometric verify ✓  
// 3. Attendance Mark In API ✓
// 4. ✅ AUTO → Location checkIn(workType) call होगा
// 5. Home screen पर navigate
// Mark Out Screen
//     ↓ Submit button press
// 1. Location check ✓
// 2. Biometric verify ✓
// 3. Attendance Mark Out API ✓
// 4. ✅ AUTO → Location checkOut(trackingId) call होगा
// 5. Home screen पर navigate