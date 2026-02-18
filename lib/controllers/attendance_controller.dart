// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/location_service.dart';
// import '../core/utils/app_utils.dart';
// import 'package:intl/intl.dart';

// class AttendanceController extends GetxController {
//   // =================== STATE ===================
//   final isMarkingIn = false.obs;
//   final isMarkingOut = false.obs;
//   final isFetchingSummary = false.obs;

//   final selfieFile = Rxn<File>();
//   final currentLat = 0.0.obs;
//   final currentLng = 0.0.obs;
//   final currentAddress = ''.obs;
//   final isLocationLoading = false.obs;

//   final attendanceRecords = <AttendanceRecord>[].obs;
//   final markedInData = Rxn<MarkInData>();
//   final markedOutData = Rxn<MarkOutData>();

//   // Summary Filters
//   final fromDate = DateTime.now().subtract(const Duration(days: 6)).obs;
//   final toDate = DateTime.now().obs;

//   final _imagePicker = ImagePicker();

//   // =================== LOCATION ===================
//   Future<void> fetchLocation() async {
//     isLocationLoading.value = true;
//     try {
//       final position = await LocationService.getCurrentPosition();
//       if (position != null) {
//         currentLat.value = position.latitude;
//         currentLng.value = position.longitude;
//         currentAddress.value = await LocationService.getAddressFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );
//       } else {
//         AppUtils.showError('Could not get location. Please enable GPS.');
//       }
//     } catch (e) {
//       AppUtils.showError('Location error: ${e.toString()}');
//     } finally {
//       isLocationLoading.value = false;
//     }
//   }

//   // =================== CAMERA ===================
//   Future<void> takeSelfie() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 70,
//         maxWidth: 800,
//         maxHeight: 800,
//         preferredCameraDevice: CameraDevice.front,
//       );
//       if (picked != null) {
//         selfieFile.value = File(picked.path);
//       }
//     } catch (e) {
//       AppUtils.showError('Camera error: ${e.toString()}');
//     }
//   }

//   Future<void> pickFromGallery() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 800,
//         maxHeight: 800,
//       );
//       if (picked != null) {
//         selfieFile.value = File(picked.path);
//       }
//     } catch (e) {
//       AppUtils.showError('Gallery error: ${e.toString()}');
//     }
//   }

//   // =================== MARK IN ===================
//   Future<void> markIn() async {
//     if (selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingIn.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final result = await ApiService.markIn(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-in successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-in failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingIn.value = false;
//     }
//   }

//   // =================== MARK OUT ===================
//   Future<void> markOut() async {
//     if (selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingOut.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final result = await ApiService.markOut(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-out successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-out failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingOut.value = false;
//     }
//   }

//   // =================== SUMMARY ===================
//   Future<void> fetchUserSummary() async {
//     // Validate 31-day limit
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Date range cannot exceed 31 days');
//       return;
//     }

//     isFetchingSummary.value = true;
//     try {
//       final records = await ApiService.getUserSummary(
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//       );
//       attendanceRecords.value = records;
//     } catch (e) {
//       AppUtils.showError('Error fetching summary: ${e.toString()}');
//     } finally {
//       isFetchingSummary.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       // Auto-adjust toDate if needed
//       if (toDate.value.isBefore(picked)) {
//         toDate.value = picked;
//       }
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: toDate.value,
//       firstDate: fromDate.value,
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   void clearSelfie() => selfieFile.value = null;

//   // =================== SUMMARY STATS ===================
//   int get totalPresent =>
//       attendanceRecords.where((r) => r.status == 'Complete').length;
//   int get totalIncomplete =>
//       attendanceRecords.where((r) => r.status != 'Complete').length;
//   double get totalWorkHours => attendanceRecords.fold(
//     0,
//     (sum, r) => sum + (r.totalHours ?? 0),
//   );
// }














// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:device_info_plus/device_info_plus.dart'; // ✅ NEW
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/location_service.dart';
// import '../core/utils/app_utils.dart';
// import 'package:intl/intl.dart';

// class AttendanceController extends GetxController {
//   // =================== STATE ===================
//   final isMarkingIn = false.obs;
//   final isMarkingOut = false.obs;
//   final isFetchingSummary = false.obs;

//   final selfieFile = Rxn<File>();
//   final currentLat = 0.0.obs;
//   final currentLng = 0.0.obs;
//   final currentAddress = ''.obs;
//   final isLocationLoading = false.obs;

//   final attendanceRecords = <AttendanceRecord>[].obs;
//   final markedInData = Rxn<MarkInData>();
//   final markedOutData = Rxn<MarkOutData>();

//   // Summary Filters
//   final fromDate = DateTime.now().subtract(const Duration(days: 6)).obs;
//   final toDate = DateTime.now().obs;

//   final _imagePicker = ImagePicker();

//   // =================== ✅ DEVICE ID HELPER ===================
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
//       final position = await LocationService.getCurrentPosition();
//       if (position != null) {
//         currentLat.value = position.latitude;
//         currentLng.value = position.longitude;
//         currentAddress.value = await LocationService.getAddressFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );
//       } else {
//         AppUtils.showError('Could not get location. Please enable GPS.');
//       }
//     } catch (e) {
//       AppUtils.showError('Location error: ${e.toString()}');
//     } finally {
//       isLocationLoading.value = false;
//     }
//   }

//   // =================== CAMERA ===================
//   Future<void> takeSelfie() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 70,
//         maxWidth: 800,
//         maxHeight: 800,
//         preferredCameraDevice: CameraDevice.front,
//       );
//       if (picked != null) {
//         selfieFile.value = File(picked.path);
//       }
//     } catch (e) {
//       AppUtils.showError('Camera error: ${e.toString()}');
//     }
//   }

//   Future<void> pickFromGallery() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 800,
//         maxHeight: 800,
//       );
//       if (picked != null) {
//         selfieFile.value = File(picked.path);
//       }
//     } catch (e) {
//       AppUtils.showError('Gallery error: ${e.toString()}');
//     }
//   }

//   // =================== MARK IN ===================
//   Future<void> markIn() async {
//     if (selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingIn.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId(); // ✅ NEW

//       final result = await ApiService.markIn(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//         biometricData: deviceId, // ✅ NEW
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-in successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-in failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingIn.value = false;
//     }
//   }

//   // =================== MARK OUT ===================
//   Future<void> markOut() async {
//     if (selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingOut.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId(); // ✅ NEW

//       final result = await ApiService.markOut(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//         biometricData: deviceId, // ✅ NEW
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-out successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-out failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingOut.value = false;
//     }
//   }

//   // =================== SUMMARY ===================
//   Future<void> fetchUserSummary() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Date range cannot exceed 31 days');
//       return;
//     }

//     isFetchingSummary.value = true;
//     try {
//       final records = await ApiService.getUserSummary(
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//       );
//       attendanceRecords.value = records;
//     } catch (e) {
//       AppUtils.showError('Error fetching summary: ${e.toString()}');
//     } finally {
//       isFetchingSummary.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       if (toDate.value.isBefore(picked)) {
//         toDate.value = picked;
//       }
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: toDate.value,
//       firstDate: fromDate.value,
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   void clearSelfie() => selfieFile.value = null;

//   // =================== SUMMARY STATS ===================
//   int get totalPresent =>
//       attendanceRecords.where((r) => r.status == 'Complete').length;
//   int get totalIncomplete =>
//       attendanceRecords.where((r) => r.status != 'Complete').length;
//   double get totalWorkHours => attendanceRecords.fold(
//         0,
//         (sum, r) => sum + (r.totalHours ?? 0),
//       );
// }








// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/location_service.dart';
// import '../core/utils/app_utils.dart';
// import 'package:intl/intl.dart';

// class AttendanceController extends GetxController {
//   // =================== STATE ===================
//   final isMarkingIn = false.obs;
//   final isMarkingOut = false.obs;
//   final isFetchingSummary = false.obs;

//   final selfieFile = Rxn<File>();
//   final currentLat = 0.0.obs;
//   final currentLng = 0.0.obs;
//   final currentAddress = ''.obs;
//   final isLocationLoading = false.obs;

//   final attendanceRecords = <AttendanceRecord>[].obs;
//   final markedInData = Rxn<MarkInData>();
//   final markedOutData = Rxn<MarkOutData>();

//   // Summary Filters
//   final fromDate = DateTime.now().subtract(const Duration(days: 6)).obs;
//   final toDate = DateTime.now().obs;

//   final _imagePicker = ImagePicker();
//   final _storage = GetStorage();

//   // =================== SELFIE REQUIRED CHECK ===================
//   // Jin roles ke liye selfie required ho unhe yahan add karo
//   static const _selfieRequiredRoles = ['Hr', 'Tester'];

//   bool get isSelfieRequired {
//     final role = _storage.read('role') ?? '';
//     return _selfieRequiredRoles.contains(role);
//   }

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
//       final position = await LocationService.getCurrentPosition();
//       if (position != null) {
//         currentLat.value = position.latitude;
//         currentLng.value = position.longitude;
//         currentAddress.value = await LocationService.getAddressFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );
//       } else {
//         AppUtils.showError('Could not get location. Please enable GPS.');
//       }
//     } catch (e) {
//       AppUtils.showError('Location error: ${e.toString()}');
//     } finally {
//       isLocationLoading.value = false;
//     }
//   }

//   // =================== CAMERA ===================
//   Future<void> takeSelfie() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 70,
//         maxWidth: 800,
//         maxHeight: 800,
//         preferredCameraDevice: CameraDevice.front,
//       );
//       if (picked != null) {
//         selfieFile.value = File(picked.path);
//       }
//     } catch (e) {
//       AppUtils.showError('Camera error: ${e.toString()}');
//     }
//   }

//   // =================== MARK IN ===================
//   Future<void> markIn() async {
//     if (isSelfieRequired && selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingIn.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId();

//       final result = await ApiService.markIn(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//         biometricData: deviceId,
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-in successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-in failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingIn.value = false;
//     }
//   }

//   // =================== MARK OUT ===================
//   Future<void> markOut() async {
//     if (isSelfieRequired && selfieFile.value == null) {
//       AppUtils.showWarning('Please take a selfie first');
//       return;
//     }
//     if (currentLat.value == 0.0) {
//       AppUtils.showWarning('Please fetch location first');
//       return;
//     }

//     isMarkingOut.value = true;
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final deviceId = await _getDeviceId();

//       final result = await ApiService.markOut(
//         attendanceDate: today,
//         latitude: currentLat.value,
//         longitude: currentLng.value,
//         locationAddress: currentAddress.value,
//         selfieImage: selfieFile.value!,
//         biometricData: deviceId,
//       );

//       if (result['success'] == true) {
//         AppUtils.showSuccess('Check-out successful!');
//         selfieFile.value = null;
//         Get.back();
//       } else {
//         AppUtils.showError(result['message'] ?? 'Mark-out failed');
//       }
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isMarkingOut.value = false;
//     }
//   }

//   // =================== SUMMARY ===================
//   Future<void> fetchUserSummary() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Date range cannot exceed 31 days');
//       return;
//     }

//     isFetchingSummary.value = true;
//     try {
//       final records = await ApiService.getUserSummary(
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//       );
//       attendanceRecords.value = records;
//     } catch (e) {
//       AppUtils.showError('Error fetching summary: ${e.toString()}');
//     } finally {
//       isFetchingSummary.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       if (toDate.value.isBefore(picked)) {
//         toDate.value = picked;
//       }
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: toDate.value,
//       firstDate: fromDate.value,
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   void clearSelfie() => selfieFile.value = null;

//   // =================== SUMMARY STATS ===================
//   int get totalPresent =>
//       attendanceRecords.where((r) => r.status == 'Complete').length;
//   int get totalIncomplete =>
//       attendanceRecords.where((r) => r.status != 'Complete').length;
//   double get totalWorkHours => attendanceRecords.fold(
//         0,
//         (sum, r) => sum + (r.totalHours ?? 0),
//       );
// }












import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../core/utils/app_utils.dart';

class AttendanceController extends GetxController {
  // =================== STATE ===================
  final isMarkingIn = false.obs;
  final isMarkingOut = false.obs;
  final isFetchingSummary = false.obs;

  final selfieFile = Rxn<File>();
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;
  final currentAddress = ''.obs;
  final isLocationLoading = false.obs;

  final attendanceRecords = <AttendanceRecord>[].obs;
  final markedInData = Rxn<MarkInData>();
  final markedOutData = Rxn<MarkOutData>();

  // Summary Filters
  final fromDate = DateTime.now().subtract(const Duration(days: 6)).obs;
  final toDate = DateTime.now().obs;

  final _imagePicker = ImagePicker();
  final _storage = GetStorage();

  // =================== USER INFO (From Storage) ===================
  int get userId => (_storage.read('userId') ?? 0) as int;

  String get userName {
    final v = _storage.read('userName');
    return (v == null) ? '' : v.toString().trim();
  }

  String get role {
    final v = _storage.read('role');
    return (v == null) ? '' : v.toString().trim();
  }

  // =================== SELFIE REQUIRED CHECK ===================
  static const _selfieRequiredRoles = ['Hr', 'Tester'];

  bool get isSelfieRequired {
    return _selfieRequiredRoles.contains(role);
  }

  // =================== DEVICE ID ===================
  Future<String> _getDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        return (await info.androidInfo).id;
      } else if (Platform.isIOS) {
        return (await info.iosInfo).identifierForVendor ?? 'unknown';
      }
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
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        currentLat.value = position.latitude;
        currentLng.value = position.longitude;

        // ✅ ONLY address text, never lat/lng string
        final addr = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        currentAddress.value = addr.trim();
      } else {
        AppUtils.showError('Could not get location. Please enable GPS.');
      }
    } catch (e) {
      AppUtils.showError('Location error: ${e.toString()}');
    } finally {
      isLocationLoading.value = false;
    }
  }

  // =================== CAMERA ===================
  Future<void> takeSelfie() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked != null) {
        selfieFile.value = File(picked.path);
      }
    } catch (e) {
      AppUtils.showError('Camera error: ${e.toString()}');
    }
  }

  void clearSelfie() => selfieFile.value = null;

  void resetScreenState() {
    clearSelfie();
    currentLat.value = 0.0;
    currentLng.value = 0.0;
    currentAddress.value = '';
    isLocationLoading.value = false;
    isMarkingIn.value = false;
    isMarkingOut.value = false;
  }

  // =================== MARK IN ===================
  Future<void> markIn() async {
    // ✅ basic validations
    if (isSelfieRequired && selfieFile.value == null) {
      AppUtils.showWarning('Please take a selfie first');
      return;
    }

    if (currentLat.value == 0.0 || currentLng.value == 0.0) {
      AppUtils.showWarning('Please fetch location first');
      return;
    }

    if (currentAddress.value.trim().isEmpty) {
      AppUtils.showWarning('Address not available. Please refresh location.');
      return;
    }

    if (userName.isEmpty) {
      AppUtils.showError('User name not found. Please login again.');
      return;
    }

    isMarkingIn.value = true;

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final deviceId = await _getDeviceId();

      final result = await ApiService.markIn(
        attendanceDate: today,
        latitude: currentLat.value,
        longitude: currentLng.value,
        locationAddress: currentAddress.value.trim(), // ✅ ONLY address
        selfieImage: selfieFile.value, // ✅ nullable
        biometricData: deviceId,
        userName: userName, // ✅ send name so DB doesn't store NULL
        userId: userId,     // ✅ if backend accepts it
      );

      if (result['success'] == true) {
        AppUtils.showSuccess('Check-in successful!');
        resetScreenState();
        Get.back();
      } else {
        AppUtils.showError(result['message'] ?? 'Mark-in failed');
      }
    } catch (e) {
      AppUtils.showError('Error: ${e.toString()}');
    } finally {
      isMarkingIn.value = false;
    }
  }

  // =================== MARK OUT ===================
  Future<void> markOut() async {
    if (isSelfieRequired && selfieFile.value == null) {
      AppUtils.showWarning('Please take a selfie first');
      return;
    }

    if (currentLat.value == 0.0 || currentLng.value == 0.0) {
      AppUtils.showWarning('Please fetch location first');
      return;
    }

    if (currentAddress.value.trim().isEmpty) {
      AppUtils.showWarning('Address not available. Please refresh location.');
      return;
    }

    if (userName.isEmpty) {
      AppUtils.showError('User name not found. Please login again.');
      return;
    }

    isMarkingOut.value = true;

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final deviceId = await _getDeviceId();

      final result = await ApiService.markOut(
        attendanceDate: today,
        latitude: currentLat.value,
        longitude: currentLng.value,
        locationAddress: currentAddress.value.trim(), // ✅ ONLY address
        selfieImage: selfieFile.value, // ✅ nullable
        biometricData: deviceId,
        userName: userName, // ✅ send name
        userId: userId,
      );

      if (result['success'] == true) {
        AppUtils.showSuccess('Check-out successful!');
        resetScreenState();
        Get.back();
      } else {
        AppUtils.showError(result['message'] ?? 'Mark-out failed');
      }
    } catch (e) {
      AppUtils.showError('Error: ${e.toString()}');
    } finally {
      isMarkingOut.value = false;
    }
  }

  // =================== SUMMARY ===================
  Future<void> fetchUserSummary() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      AppUtils.showError('Date range cannot exceed 31 days');
      return;
    }

    isFetchingSummary.value = true;
    try {
      final records = await ApiService.getUserSummary(
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate: AppUtils.formatDateApi(toDate.value),
      );
      attendanceRecords.value = records;
    } catch (e) {
      AppUtils.showError('Error fetching summary: ${e.toString()}');
    } finally {
      isFetchingSummary.value = false;
    }
  }

  // =================== DATE PICKERS ===================
  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value.isBefore(picked)) {
        toDate.value = picked;
      }
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: fromDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) toDate.value = picked;
  }

  // =================== SUMMARY STATS ===================
  int get totalPresent =>
      attendanceRecords.where((r) => r.status == 'Complete').length;

  int get totalIncomplete =>
      attendanceRecords.where((r) => r.status != 'Complete').length;

  double get totalWorkHours => attendanceRecords.fold(
        0,
        (sum, r) => sum + (r.totalHours ?? 0),
      );
}
