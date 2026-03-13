// // lib/controllers/attendance_controller.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:intl/intl.dart';

// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/utils/response_handler.dart';

// class AttendanceController extends GetxController {
//   // =================== STATE ===================
//   final isMarkingIn       = false.obs;
//   final isMarkingOut      = false.obs;
//   final isFetchingSummary = false.obs;

//   final hasSearched = false.obs;

//   final selfieFile        = Rxn<File>();
//   final currentLat        = 0.0.obs;
//   final currentLng        = 0.0.obs;
//   final currentAddress    = ''.obs;
//   final isLocationLoading = false.obs;

//   final attendanceRecords = <AttendanceRecord>[].obs;
//   final markedInData      = Rxn<MarkInData>();
//   final markedOutData     = Rxn<MarkOutData>();

//   // Summary Filters
//   final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
//   final toDate   = DateTime.now().obs;

//   final _imagePicker = ImagePicker();

//   // =================== USER INFO ===================
//   int    get userId           => StorageService.getUserId();
//   String get userName         => StorageService.getUserName();
//   String get role             => StorageService.getUserRole();
//   bool   get isSelfieRequired => StorageService.getRequiresSelfie();

//   // =================== DEVICE ID ===================
//   Future<String> _getDeviceId() async {
//     try {
//       final info = DeviceInfoPlugin();
//       if (Platform.isAndroid) {
//         return (await info.androidInfo).id;
//       } else if (Platform.isIOS) {
//         return (await info.iosInfo).identifierForVendor ?? 'unknown';
//       }
//       return 'unknown';
//     } catch (e) {
//       debugPrint('getDeviceId error: $e');
//       return 'unknown';
//     }
//   }

//   // =================== LOCATION ===================
//   Future<void> fetchLocation() async {
//     isLocationLoading.value = true;
//     try {
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ResponseHandler.showError(
//           apiMessage: '',
//           fallback: 'Unable to fetch location. Please enable GPS and try again.',
//         );
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ResponseHandler.showError(
//             apiMessage: '',
//             fallback: 'Location permission denied. Please allow location access.',
//           );
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         ResponseHandler.showError(
//           apiMessage: '',
//           fallback: 'Location permission permanently denied. Please enable from Settings.',
//         );
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit:       const Duration(seconds: 15),
//       );

//       currentLat.value = position.latitude;
//       currentLng.value = position.longitude;

//       final addr = await _getAddress(position.latitude, position.longitude);
//       currentAddress.value = addr.trim();
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchLocation',
//         fallback: 'Unable to fetch location. Please enable GPS and try again.',
//       );
//     } finally {
//       isLocationLoading.value = false;
//     }
//   }

//   Future<String> _getAddress(double lat, double lng) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(lat, lng).timeout(
//         const Duration(seconds: 10),
//         onTimeout: () => [],
//       );

//       if (placemarks.isEmpty) return '$lat, $lng';

//       final p     = placemarks.first;
//       final parts = <String>[
//         if (p.subThoroughfare?.isNotEmpty == true) p.subThoroughfare!,
//         if (p.thoroughfare?.isNotEmpty == true)    p.thoroughfare!,
//         if (p.subLocality?.isNotEmpty == true)     p.subLocality!,
//         if (p.locality?.isNotEmpty == true)        p.locality!,
//         if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
//         if (p.postalCode?.isNotEmpty == true)      p.postalCode!,
//         if (p.country?.isNotEmpty == true)         p.country!,
//       ];

//       final address = parts.join(', ');
//       return address.isNotEmpty ? address : '$lat, $lng';
//     } catch (e) {
//       debugPrint('_getAddress error: $e');
//       return '$lat, $lng';
//     }
//   }

//   // =================== CAMERA ===================
//   Future<void> takeSelfie() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source:                ImageSource.camera,
//         imageQuality:          70,
//         maxWidth:              800,
//         maxHeight:             800,
//         preferredCameraDevice: CameraDevice.front,
//       );
//       if (picked != null) selfieFile.value = File(picked.path);
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'takeSelfie',
//         fallback: 'Unable to open camera. Please try again.',
//       );
//     }
//   }

//   void clearSelfie() => selfieFile.value = null;

//   void resetScreenState() {
//     clearSelfie();
//     currentLat.value        = 0.0;
//     currentLng.value        = 0.0;
//     currentAddress.value    = '';
//     isLocationLoading.value = false;
//     isMarkingIn.value       = false;
//     isMarkingOut.value      = false;
//   }

//   // =================== MARK IN ===================
//   Future<bool> markIn() async {
//     debugPrint('=== MARK IN DEBUG ===');
//     debugPrint('userId          : $userId');
//     debugPrint('userName        : $userName');
//     debugPrint('role            : $role');
//     debugPrint('isSelfieRequired: $isSelfieRequired');
//     debugPrint('====================');

//     if (isSelfieRequired && selfieFile.value == null) {
//       ResponseHandler.showWarning('Please take a selfie first.');
//       return false;
//     }
//     if (currentLat.value == 0.0 || currentLng.value == 0.0) {
//       ResponseHandler.showWarning('Please fetch location first.');
//       return false;
//     }
//     if (currentAddress.value.trim().isEmpty) {
//       ResponseHandler.showWarning('Address not available. Please refresh location.');
//       return false;
//     }
//     if (userName.isEmpty) {
//       ResponseHandler.showError(
//         apiMessage: '',
//         fallback: 'Unable to continue. Please login again.',
//       );
//       return false;
//     }

//     isMarkingIn.value = true;
//     try {
//       final today    = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId();

//       final result = await ApiService.markIn(
//         attendanceDate:  today,
//         latitude:        currentLat.value,
//         longitude:       currentLng.value,
//         locationAddress: currentAddress.value.trim(),
//         selfieImage:     selfieFile.value,
//         biometricData:   deviceId,
//         userName:        userName,
//         userId:          userId,
//       );

//       debugPrint('markIn result: $result');

//       if (result['success'] == true) {
//         final msg = (result['message'] ?? '').toString();
//         ResponseHandler.showSuccess(
//           apiMessage: msg,
//           fallback:   'Mark-in successful!',
//         );
//         resetScreenState();
//         return true;
//       } else {
//         final msg = (result['message'] ?? '').toString();
//         ResponseHandler.showError(
//           apiMessage: msg,
//           fallback:   'Unable to mark attendance. Please try again.',
//         );
//         return false;
//       }
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'markIn',
//         fallback: 'Unable to mark attendance. Please try again.',
//       );
//       return false;
//     } finally {
//       isMarkingIn.value = false;
//     }
//   }

//   // =================== MARK OUT ===================
//   Future<bool> markOut() async {
//     debugPrint('=== MARK OUT DEBUG ===');
//     debugPrint('userId          : $userId');
//     debugPrint('userName        : $userName');
//     debugPrint('role            : $role');
//     debugPrint('isSelfieRequired: $isSelfieRequired');
//     debugPrint('=====================');

//     if (isSelfieRequired && selfieFile.value == null) {
//       ResponseHandler.showWarning('Please take a selfie first.');
//       return false;
//     }
//     if (currentLat.value == 0.0 || currentLng.value == 0.0) {
//       ResponseHandler.showWarning('Please fetch location first.');
//       return false;
//     }
//     if (currentAddress.value.trim().isEmpty) {
//       ResponseHandler.showWarning('Address not available. Please refresh location.');
//       return false;
//     }
//     if (userName.isEmpty) {
//       ResponseHandler.showError(
//         apiMessage: '',
//         fallback: 'Unable to continue. Please login again.',
//       );
//       return false;
//     }

//     isMarkingOut.value = true;
//     try {
//       final today    = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId();

//       final result = await ApiService.markOut(
//         attendanceDate:  today,
//         latitude:        currentLat.value,
//         longitude:       currentLng.value,
//         locationAddress: currentAddress.value.trim(),
//         selfieImage:     selfieFile.value,
//         biometricData:   deviceId,
//         userName:        userName,
//         userId:          userId,
//       );

//       debugPrint('markOut result: $result');

//       if (result['success'] == true) {
//         final msg = (result['message'] ?? '').toString();
//         ResponseHandler.showSuccess(
//           apiMessage: msg,
//           fallback:   'Mark-out successful!',
//         );
//         resetScreenState();
//         return true;
//       } else {
//         final msg = (result['message'] ?? '').toString();
//         ResponseHandler.showError(
//           apiMessage: msg,
//           fallback:   'Unable to mark out. Please try again.',
//         );
//         return false;
//       }
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'markOut',
//         fallback: 'Unable to mark out. Please try again.',
//       );
//       return false;
//     } finally {
//       isMarkingOut.value = false;
//     }
//   }

//   // =================== SUMMARY ===================
//   Future<void> fetchUserSummary() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       ResponseHandler.showWarning('Date range cannot exceed 31 days.');
//       return;
//     }

//     isFetchingSummary.value = true;
//     try {
//       final records = await ApiService.getUserSummary(
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate:   AppUtils.formatDateApi(toDate.value),
//       );
//       attendanceRecords.value = records;
//       hasSearched.value       = true;
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchUserSummary',
//         fallback: 'Unable to load summary. Please try again.',
//       );
//     } finally {
//       isFetchingSummary.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context:     context,
//       initialDate: fromDate.value,
//       firstDate:   DateTime(2020),
//       lastDate:    DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       if (toDate.value.isBefore(picked)) toDate.value = picked;
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context:     context,
//       initialDate: toDate.value,
//       firstDate:   fromDate.value,
//       lastDate:    DateTime.now(),
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   // =================== SUMMARY STATS ===================
//   int get totalPresent =>
//       attendanceRecords.where((r) => r.status == 'Complete').length;

//   int get totalIncomplete =>
//       attendanceRecords.where((r) => r.status != 'Complete').length;

//   double get totalWorkHours =>
//       attendanceRecords.fold(0, (sum, r) => sum + (r.totalHours ?? 0));

//   // =================== PERIOD SUMMARY STATS ===================
//   int get totalDaysInRange =>
//       toDate.value.difference(fromDate.value).inDays + 1;

//   int get totalSundays {
//     int count = 0;
//     DateTime d = fromDate.value;
//     while (!d.isAfter(toDate.value)) {
//       if (d.weekday == DateTime.sunday) count++;
//       d = d.add(const Duration(days: 1));
//     }
//     return count;
//   }

//   int get totalAbsent {
//     final workingDays = totalDaysInRange - totalSundays;
//     return (workingDays - totalPresent).clamp(0, workingDays);
//   }
// }















// lib/controllers/attendance_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/utils/app_utils.dart';
import '../core/utils/response_handler.dart';
import '../core/theme/app_theme.dart';
import 'payroll_controller.dart';                        // ✅ for late cutoff + slip fetch

class AttendanceController extends GetxController {
  // =================== STATE ===================
  final isMarkingIn       = false.obs;
  final isMarkingOut      = false.obs;
  final isFetchingSummary = false.obs;
  final hasSearched       = false.obs;

  final selfieFile        = Rxn<File>();
  final currentLat        = 0.0.obs;
  final currentLng        = 0.0.obs;
  final currentAddress    = ''.obs;
  final isLocationLoading = false.obs;

  final attendanceRecords = <AttendanceRecord>[].obs;
  final markedInData      = Rxn<MarkInData>();
  final markedOutData     = Rxn<MarkOutData>();

  final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final toDate   = DateTime.now().obs;

  final _imagePicker = ImagePicker();

  // =================== USER INFO ===================
  int    get userId           => StorageService.getUserId();
  String get userName         => StorageService.getUserName();
  String get role             => StorageService.getUserRole();
  bool   get isSelfieRequired => StorageService.getRequiresSelfie();

  // =================== DEVICE ID ===================
  Future<String> _getDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) return (await info.androidInfo).id;
      if (Platform.isIOS)     return (await info.iosInfo).identifierForVendor ?? 'unknown';
      return 'unknown';
    } catch (e) {
      debugPrint('getDeviceId error: $e');
      return 'unknown';
    }
  }

  // =================== LOCATION ===================
  Future<void> fetchLocation() async {
    isLocationLoading.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ResponseHandler.showError(
          apiMessage: '',
          fallback: 'Unable to fetch location. Please enable GPS and try again.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ResponseHandler.showError(
            apiMessage: '',
            fallback: 'Location permission denied. Please allow location access.',
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ResponseHandler.showError(
          apiMessage: '',
          fallback: 'Location permission permanently denied. Please enable from Settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit:       const Duration(seconds: 15),
      );
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      currentAddress.value = (await _getAddress(position.latitude, position.longitude)).trim();
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchLocation',
        fallback: 'Unable to fetch location. Please enable GPS and try again.',
      );
    } finally {
      isLocationLoading.value = false;
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 10),
        onTimeout: () => [],
      );
      if (placemarks.isEmpty) return '$lat, $lng';
      final p = placemarks.first;
      final parts = <String>[
        if (p.subThoroughfare?.isNotEmpty == true) p.subThoroughfare!,
        if (p.thoroughfare?.isNotEmpty == true)    p.thoroughfare!,
        if (p.subLocality?.isNotEmpty == true)     p.subLocality!,
        if (p.locality?.isNotEmpty == true)        p.locality!,
        if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
        if (p.postalCode?.isNotEmpty == true)      p.postalCode!,
        if (p.country?.isNotEmpty == true)         p.country!,
      ];
      final address = parts.join(', ');
      return address.isNotEmpty ? address : '$lat, $lng';
    } catch (e) {
      debugPrint('_getAddress error: $e');
      return '$lat, $lng';
    }
  }

  // =================== CAMERA ===================
  Future<void> takeSelfie() async {
    try {
      final picked = await _imagePicker.pickImage(
        source:                ImageSource.camera,
        imageQuality:          70,
        maxWidth:              800,
        maxHeight:             800,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked != null) selfieFile.value = File(picked.path);
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'takeSelfie',
        fallback: 'Unable to open camera. Please try again.',
      );
    }
  }

  void clearSelfie() => selfieFile.value = null;

  void resetScreenState() {
    clearSelfie();
    currentLat.value        = 0.0;
    currentLng.value        = 0.0;
    currentAddress.value    = '';
    isLocationLoading.value = false;
    isMarkingIn.value       = false;
    isMarkingOut.value      = false;
  }

  // ══════════════════════════════════════════════════════
  //  ✅ LATE CHECK HELPERS
  // ══════════════════════════════════════════════════════

  /// Cutoff string "HH:mm" — reads from PayrollController if registered,
  /// otherwise falls back to default "10:15".
  String get _lateCutoff {
    if (Get.isRegistered<PayrollController>()) {
      return Get.find<PayrollController>().lateCutoff.value;
    }
    return '10:15';
  }

  /// Returns true if [now] is strictly after the cutoff time today.
  bool _isLate(DateTime now) {
    try {
      final parts  = _lateCutoff.split(':');
      final cutoff = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      return now.isAfter(cutoff);
    } catch (_) {
      return false;
    }
  }

  /// How many whole minutes late (0 if on time).
  int _lateMinutes(DateTime now) {
    if (!_isLate(now)) return 0;
    try {
      final parts  = _lateCutoff.split(':');
      final cutoff = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      return now.difference(cutoff).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  /// "1h 23m" or "45m"
  String _lateLabel(int mins) {
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _ordinal(int n) {
    if (n == 1) return 'st';
    if (n == 2) return 'nd';
    if (n == 3) return 'rd';
    return 'th';
  }

  // ══════════════════════════════════════════════════════
  //  ✅ LATE NOTIFICATION — shown after successful mark-in
  // ══════════════════════════════════════════════════════

  Future<void> _notifyLateIfNeeded(DateTime markInTime) async {
    if (!_isLate(markInTime)) return;          // on time → nothing

    final mins      = _lateMinutes(markInTime);
    final lateLabel = _lateLabel(mins);

    // Try to get updated lateDays count from backend via PayrollController
    int lateDaysThisMonth = 1;
    if (Get.isRegistered<PayrollController>()) {
      try {
        final slip = await Get.find<PayrollController>().getSlip(
          employeeId: userId,
          month:      markInTime.month,
          year:       markInTime.year,
        );
        if (slip != null) lateDaysThisMonth = slip.lateDays;
      } catch (_) {}
    }

    final isDeduction = lateDaysThisMonth >= 3;

    Get.dialog(
      _LateAlertDialog(
        lateDays:    lateDaysThisMonth,
        lateLabel:   lateLabel,
        cutoff:      _lateCutoff,
        isDeduction: isDeduction,
        ordinal:     _ordinal(lateDaysThisMonth),
      ),
      barrierDismissible: false,
    );
  }

  // =================== MARK IN ===================
  Future<bool> markIn() async {
    debugPrint('=== MARK IN ===');
    debugPrint('userId: $userId | userName: $userName | lateCutoff: $_lateCutoff');

    if (isSelfieRequired && selfieFile.value == null) {
      ResponseHandler.showWarning('Please take a selfie first.');
      return false;
    }
    if (currentLat.value == 0.0 || currentLng.value == 0.0) {
      ResponseHandler.showWarning('Please fetch location first.');
      return false;
    }
    if (currentAddress.value.trim().isEmpty) {
      ResponseHandler.showWarning('Address not available. Please refresh location.');
      return false;
    }
    if (userName.isEmpty) {
      ResponseHandler.showError(apiMessage: '', fallback: 'Unable to continue. Please login again.');
      return false;
    }

    // ✅ Capture exact mark-in time BEFORE API call
    final markInTime = DateTime.now();
    isMarkingIn.value = true;

    try {
      final today    = DateFormat('yyyy-MM-dd').format(markInTime);
      final deviceId = await _getDeviceId();

      final result = await ApiService.markIn(
        attendanceDate:  today,
        latitude:        currentLat.value,
        longitude:       currentLng.value,
        locationAddress: currentAddress.value.trim(),
        selfieImage:     selfieFile.value,
        biometricData:   deviceId,
        userName:        userName,
        userId:          userId,
      );

      debugPrint('markIn result: $result');

      if (result['success'] == true) {
        ResponseHandler.showSuccess(
          apiMessage: (result['message'] ?? '').toString(),
          fallback:   'Mark-in successful!',
        );
        resetScreenState();

        // ✅ Slight delay so success snackbar renders first, then show late dialog
        await Future.delayed(const Duration(milliseconds: 600));
        await _notifyLateIfNeeded(markInTime);

        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: (result['message'] ?? '').toString(),
          fallback:   'Unable to mark attendance. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'markIn',
        fallback: 'Unable to mark attendance. Please try again.',
      );
      return false;
    } finally {
      isMarkingIn.value = false;
    }
  }

  // =================== MARK OUT ===================
  Future<bool> markOut() async {
    debugPrint('=== MARK OUT ===');
    debugPrint('userId: $userId | userName: $userName');

    if (isSelfieRequired && selfieFile.value == null) {
      ResponseHandler.showWarning('Please take a selfie first.');
      return false;
    }
    if (currentLat.value == 0.0 || currentLng.value == 0.0) {
      ResponseHandler.showWarning('Please fetch location first.');
      return false;
    }
    if (currentAddress.value.trim().isEmpty) {
      ResponseHandler.showWarning('Address not available. Please refresh location.');
      return false;
    }
    if (userName.isEmpty) {
      ResponseHandler.showError(apiMessage: '', fallback: 'Unable to continue. Please login again.');
      return false;
    }

    isMarkingOut.value = true;
    try {
      final today    = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final deviceId = await _getDeviceId();

      final result = await ApiService.markOut(
        attendanceDate:  today,
        latitude:        currentLat.value,
        longitude:       currentLng.value,
        locationAddress: currentAddress.value.trim(),
        selfieImage:     selfieFile.value,
        biometricData:   deviceId,
        userName:        userName,
        userId:          userId,
      );

      debugPrint('markOut result: $result');

      if (result['success'] == true) {
        ResponseHandler.showSuccess(
          apiMessage: (result['message'] ?? '').toString(),
          fallback:   'Mark-out successful!',
        );
        resetScreenState();
        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: (result['message'] ?? '').toString(),
          fallback:   'Unable to mark out. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'markOut',
        fallback: 'Unable to mark out. Please try again.',
      );
      return false;
    } finally {
      isMarkingOut.value = false;
    }
  }

  // =================== SUMMARY ===================
  Future<void> fetchUserSummary() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      ResponseHandler.showWarning('Date range cannot exceed 31 days.');
      return;
    }
    isFetchingSummary.value = true;
    try {
      final records = await ApiService.getUserSummary(
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate:   AppUtils.formatDateApi(toDate.value),
      );
      attendanceRecords.value = records;
      hasSearched.value       = true;
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchUserSummary',
        fallback: 'Unable to load summary. Please try again.',
      );
    } finally {
      isFetchingSummary.value = false;
    }
  }

  // =================== DATE PICKERS ===================
  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: fromDate.value,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value.isBefore(picked)) toDate.value = picked;
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: toDate.value,
      firstDate:   fromDate.value,
      lastDate:    DateTime.now(),
    );
    if (picked != null) toDate.value = picked;
  }

  // =================== STATS ===================
  int get totalPresent =>
      attendanceRecords.where((r) => r.status == 'Complete').length;
  int get totalIncomplete =>
      attendanceRecords.where((r) => r.status != 'Complete').length;
  double get totalWorkHours =>
      attendanceRecords.fold(0, (sum, r) => sum + (r.totalHours ?? 0));

  int get totalDaysInRange =>
      toDate.value.difference(fromDate.value).inDays + 1;

  int get totalSundays {
    int count = 0;
    DateTime d = fromDate.value;
    while (!d.isAfter(toDate.value)) {
      if (d.weekday == DateTime.sunday) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  int get totalAbsent {
    final workingDays = totalDaysInRange - totalSundays;
    return (workingDays - totalPresent).clamp(0, workingDays);
  }
}

// ══════════════════════════════════════════════════════
//  ✅ LATE ALERT DIALOG WIDGET
//     Shown after successful mark-in when employee is late
// ══════════════════════════════════════════════════════

class _LateAlertDialog extends StatelessWidget {
  final int    lateDays;
  final String lateLabel;
  final String cutoff;
  final bool   isDeduction;
  final String ordinal;

  const _LateAlertDialog({
    required this.lateDays,
    required this.lateLabel,
    required this.cutoff,
    required this.isDeduction,
    required this.ordinal,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDeduction ? AppTheme.error   : AppTheme.warning;
    final bg    = isDeduction ? AppTheme.errorLight : AppTheme.warningLight;
    final icon  = isDeduction ? Icons.money_off_rounded : Icons.warning_amber_rounded;

    final title = isDeduction
        ? '⚠ Late Arrival — Deduction Applied'
        : '⏰ Late Arrival — Warning';

    final message = isDeduction
        ? 'You arrived $lateLabel late (after $cutoff).\n\n'
          'This is your $lateDays$ordinal late arrival this month.\n\n'
          'Per-hour salary deduction will be calculated in your payroll.'
        : 'You arrived $lateLabel late (after $cutoff).\n\n'
          'This is your $lateDays$ordinal late arrival this month.\n\n'
          'Deduction starts from the 3rd late arrival onwards.';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: bg,
      title: Row(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: TextStyle(
                fontFamily:  'Poppins',
                fontSize:    14,
                fontWeight:  FontWeight.w700,
                color:       color,
              )),
        ),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   13,
              color:      color,
              height:     1.55,
            )),
        const SizedBox(height: 16),
        _LateDayBar(lateDays: lateDays, color: color),
      ]),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation:       0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Understood',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color:      Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ LATE DAY PROGRESS BAR (3 blocks)
// ─────────────────────────────────────────────

class _LateDayBar extends StatelessWidget {
  final int   lateDays;
  final Color color;
  const _LateDayBar({required this.lateDays, required this.color});

  @override
  Widget build(BuildContext context) {
    final capped = lateDays.clamp(0, 3);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Late arrivals this month: $lateDays / 3',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   11,
              fontWeight: FontWeight.w700,
              color:      color)),
      const SizedBox(height: 6),
      Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              margin:    EdgeInsets.only(right: i < 2 ? 6 : 0),
              height:    8,
              decoration: BoxDecoration(
                color:         i < capped ? color : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 6),
      Text(
        lateDays >= 3
            ? '🔴 Deduction will be applied to this month\'s salary'
            : '🟡 ${3 - lateDays} more late arrival${(3 - lateDays) == 1 ? '' : 's'} before deduction kicks in',
        style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   10,
            color:      color.withOpacity(0.85)),
      ),
    ]);
  }
}