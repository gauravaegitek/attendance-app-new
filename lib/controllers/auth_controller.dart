// // lib/controllers/auth_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:collection/collection.dart';

// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../services/device_session_service.dart';
// import '../services/activity_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AuthController extends GetxController {
//   // ─── STATE ──────────────────────────────────────────────────
//   final isLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final isConfirmPasswordVisible = false.obs;
//   final selectedRole = 'employee'.obs;
//   final selectedRoleId = 0.obs;

//   // Roles from API
//   final rolesList = <String>[].obs;
//   final rolesModelList = <RoleModel>[].obs;
//   final isRolesLoading = false.obs;

//   // Login Form
//   final loginEmailController = TextEditingController();
//   final loginPasswordController = TextEditingController();
//   final loginFormKey = GlobalKey<FormState>();

//   // Register Form
//   final registerNameController = TextEditingController();
//   final registerEmailController = TextEditingController();
//   final registerPasswordController = TextEditingController();
//   final registerConfirmPasswordController = TextEditingController();
//   final registerFormKey = GlobalKey<FormState>();

//   // User Info
//   final userName = ''.obs;
//   final userEmail = ''.obs;
//   final userRole = ''.obs;

//   // ─── BIOMETRIC FIELDS ────────────────────────────────────────
//   final inBiometric = ''.obs;
//   final outBiometric = ''.obs;

//   // ─── TODAY'S ATTENDANCE STATE ────────────────────────────────
//   final isCheckedIn = false.obs;
//   final isCheckedOut = false.obs;
//   final checkInTime = ''.obs;
//   final checkOutTime = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserInfo();
//     // fetchRoles() intentionally NOT called here —
//     // roles are only needed on RegisterScreen, called from there.
//   }

//   void _loadUserInfo() {
//     userName.value = StorageService.getUserName();
//     userEmail.value = StorageService.getUserEmail();
//     userRole.value = StorageService.getUserRole();
//   }

//   bool get isAdmin => userRole.value.toLowerCase() == AppConstants.roleAdmin;

//   // ─── FETCH ROLES FROM API ────────────────────────────────────
//   /// Call this only from RegisterScreen — not on app init.
//   Future<void> fetchRoles() async {
//     // Agar already loaded hai to dobara API call mat karo
//     if (rolesModelList.isNotEmpty) return;

//     isRolesLoading.value = true;
//     try {
//       final models = await ApiService.getRoleModels();

//       if (models.isNotEmpty) {
//         rolesModelList
//           ..clear()
//           ..addAll(models);

//         rolesList.value = models.map((r) => r.roleName.toLowerCase()).toList();

//         if (!rolesList.contains(selectedRole.value)) {
//           selectedRole.value = rolesList.first;
//           selectedRoleId.value = models.first.roleId;
//         } else {
//           final match = models.firstWhereOrNull(
//             (r) => r.roleName.toLowerCase() == selectedRole.value,
//           );
//           if (match != null) selectedRoleId.value = match.roleId;
//         }
//       } else {
//         _setFallbackRoles();
//       }
//     } catch (e) {
//       debugPrint('fetchRoles error: $e');
//       _setFallbackRoles();
//     } finally {
//       isRolesLoading.value = false;
//     }
//   }

//   void _setFallbackRoles() {
//     rolesList.value = AppConstants.allRoles;
//     if (!rolesList.contains(selectedRole.value)) {
//       selectedRole.value = AppConstants.roleEmployee;
//     }
//     selectedRoleId.value = 0;
//   }

//   void onRoleSelected(String roleName) {
//     selectedRole.value = roleName.toLowerCase();
//     final match = rolesModelList.firstWhereOrNull(
//       (r) => r.roleName.toLowerCase() == selectedRole.value,
//     );
//     selectedRoleId.value = match?.roleId ?? 0;
//   }

//   // ─── LOAD BIOMETRIC + ATTENDANCE DATA ───────────────────────
//   Future<void> loadUserBiometricAndAttendance() async {
//     try {
//       final userId = StorageService.getUserId();
//       if (userId == 0) return;

//       final bioData = await ApiService.getUserBiometric(userId);
//       if (bioData != null) {
//         inBiometric.value = bioData['inbiometric'] ?? '';
//         outBiometric.value = bioData['outbiometric'] ?? '';
//       }

//       final todayData = await ApiService.getTodayAttendance(userId);
//       if (todayData != null) {
//         isCheckedIn.value = todayData['checkIn'] != null;
//         isCheckedOut.value = todayData['checkOut'] != null;
//         checkInTime.value = todayData['checkIn'] ?? '';
//         checkOutTime.value = todayData['checkOut'] ?? '';
//       }
//     } catch (e) {
//       debugPrint('loadUserBiometricAndAttendance error: $e');
//     }
//   }

//   // ─── SAVE BIOMETRIC TOKEN ────────────────────────────────────
//   Future<void> saveBiometric({
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final userId = StorageService.getUserId();
//       await ApiService.saveBiometricToken(
//         userId: userId,
//         type: type,
//         token: token,
//       );

//       if (type == 'in') {
//         inBiometric.value = token;
//       } else {
//         outBiometric.value = token;
//       }
//     } catch (e) {
//       debugPrint('saveBiometric error: $e');
//       rethrow;
//     }
//   }

//   // ─── CLEAR USER DEVICE (Admin Only) ─────────────────────────
//   Future<bool> clearUserDevice(int userId) async {
//     try {
//       final response = await ApiService.clearUserDevice(userId);
//       return response.success;
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return false;
//     }
//   }

//   // ─── LOGIN ──────────────────────────────────────────────────
//   Future<void> login() async {
//     if (!loginFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final deviceId = await DeviceSessionService.to.getDeviceId();

//       final response = await ApiService.login(
//         LoginRequest(
//           email: loginEmailController.text.trim(),
//           password: loginPasswordController.text,
//           deviceId: deviceId,
//         ),
//       );

//       if (response.success && response.data != null) {
//         final data = response.data!;

//         if (data.token != null) {
//           await StorageService.saveToken(data.token!);
//           await StorageService.saveUserData(
//             userId: data.userId,
//             userName: data.userName,
//             email: data.email,
//             role: data.role,
//           );
//           await StorageService.saveRequiresSelfie(data.requiresSelfie);
//           await StorageService.saveDeviceId(deviceId);

//           _loadUserInfo();

//           await DeviceSessionService.to.registerSession(
//             userId: data.userId.toString(),
//             deviceId: deviceId,
//           );

//           DeviceSessionService.to.startSessionPolling();

//           ActivityService.to.start();

//           await loadUserBiometricAndAttendance();

//           AppUtils.showSuccess('Welcome back, ${data.userName}!');
//           Get.offAllNamed('/home');
//         } else {
//           AppUtils.showError('Login failed. No token received.');
//         }
//       } else {
//         final msg = response.message.toLowerCase();
//         if (msg.contains('device') ||
//             msg.contains('another') ||
//             msg.contains('session') ||
//             msg.contains('conflict')) {
//           _showDeviceConflictDialog();
//         } else {
//           AppUtils.showError(
//             response.message.isNotEmpty
//                 ? response.message
//                 : 'Login failed. Please check your credentials.',
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Login error: $e');
//       AppUtils.showError('Network error. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── DEVICE CONFLICT DIALOG ─────────────────────────────────
//   void _showDeviceConflictDialog() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.block_rounded, size: 50, color: Colors.red),
//               const SizedBox(height: 12),
//               const Text(
//                 'Login Blocked',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'This account is active on another device.\nPlease ask admin to clear your device.',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 18),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Get.back(),
//                   child: const Text('OK'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }

//   // ─── REGISTER ───────────────────────────────────────────────
//   Future<void> register() async {
//     if (!registerFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final response = await ApiService.register(
//         RegisterRequest(
//           userName: registerNameController.text.trim(),
//           email: registerEmailController.text.trim(),
//           password: registerPasswordController.text,
//           confirmPassword: registerConfirmPasswordController.text,
//           role: selectedRole.value,
//           roleId: selectedRoleId.value,
//         ),
//       );

//       if (response.success) {
//         clearRegisterForm();
//         // Roles cache reset karo
//         rolesModelList.clear();
//         rolesList.clear();
//         // Pehle navigate karo, phir snackbar dikhao ✅
//         Get.back();
//         await Future.delayed(const Duration(milliseconds: 400));
//         AppUtils.showSuccess('Registration successful! Please login. 🎉');
//       } else {
//         AppUtils.showError(response.message);
//       }
//     } catch (e) {
//       debugPrint('Register exception: $e');
//       AppUtils.showError('Something went wrong. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── LOGOUT ─────────────────────────────────────────────────
//   Future<void> logout() async {
//     isLoading.value = true;
//     try {
//       ActivityService.to.stop();

//       DeviceSessionService.to.stopSessionPolling();
//       final int userId = StorageService.getUserId();
//       if (userId != 0) {
//         await DeviceSessionService.to.removeSession(userId.toString());
//       }

//       await ApiService.logout();
//       await StorageService.clearAll();
//       _resetState();
//     } catch (e) {
//       debugPrint('Logout error: $e');
//       await StorageService.clearAll();
//       _resetState();
//     } finally {
//       isLoading.value = false;
//       Get.offAllNamed('/login');
//     }
//   }

//   void _resetState() {
//     inBiometric.value = '';
//     outBiometric.value = '';
//     isCheckedIn.value = false;
//     isCheckedOut.value = false;
//     checkInTime.value = '';
//     checkOutTime.value = '';
//     userName.value = '';
//     userEmail.value = '';
//     userRole.value = '';
//     // Roles bhi reset karo logout pe
//     rolesModelList.clear();
//     rolesList.clear();
//   }

//   void togglePasswordVisibility() =>
//       isPasswordVisible.value = !isPasswordVisible.value;

//   void toggleConfirmPasswordVisibility() =>
//       isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

//   void clearRegisterForm() {
//     registerNameController.clear();
//     registerEmailController.clear();
//     registerPasswordController.clear();
//     registerConfirmPasswordController.clear();
//   }

//   @override
//   void onClose() {
//     loginEmailController.dispose();
//     loginPasswordController.dispose();
//     registerNameController.dispose();
//     registerEmailController.dispose();
//     registerPasswordController.dispose();
//     registerConfirmPasswordController.dispose();
//     super.onClose();
//   }
// }









// // lib/controllers/auth_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:collection/collection.dart';

// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../services/device_session_service.dart';
// import '../services/activity_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AuthController extends GetxController {
//   // ─── STATE ──────────────────────────────────────────────────
//   final isLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final isConfirmPasswordVisible = false.obs;
//   final selectedRole = 'employee'.obs;
//   final selectedRoleId = 0.obs;

//   // Roles from API
//   final rolesList = <String>[].obs;
//   final rolesModelList = <RoleModel>[].obs;
//   final isRolesLoading = false.obs;

//   // Login Form
//   final loginEmailController = TextEditingController();
//   final loginPasswordController = TextEditingController();
//   final loginFormKey = GlobalKey<FormState>();

//   // Register Form
//   final registerNameController = TextEditingController();
//   final registerEmailController = TextEditingController();
//   final registerPasswordController = TextEditingController();
//   final registerConfirmPasswordController = TextEditingController();
//   final registerFormKey = GlobalKey<FormState>();

//   // User Info
//   final userName = ''.obs;
//   final userEmail = ''.obs;
//   final userRole = ''.obs;

//   // ─── BIOMETRIC FIELDS ────────────────────────────────────────
//   final inBiometric = ''.obs;
//   final outBiometric = ''.obs;

//   // ─── TODAY'S ATTENDANCE STATE ────────────────────────────────
//   final isCheckedIn = false.obs;
//   final isCheckedOut = false.obs;
//   final checkInTime = ''.obs;
//   final checkOutTime = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserInfo();
//     // fetchRoles() intentionally NOT called here —
//     // roles are only needed on RegisterScreen, called from there.
//   }

//   void _loadUserInfo() {
//     userName.value = StorageService.getUserName();
//     userEmail.value = StorageService.getUserEmail();
//     userRole.value = StorageService.getUserRole();
//   }

//   bool get isAdmin => userRole.value.toLowerCase() == AppConstants.roleAdmin;

//   // ─── ERROR HANDLER (UNABLE STYLE) ────────────────────────────
//   void _showUnableError(String context, dynamic e) {
//     debugPrint('$context error: $e');

//     final msg = e.toString();

//     // Network friendly messages
//     if (msg.contains('SocketException')) {
//       AppUtils.showError('Unable to connect. Please check your internet and try again.');
//       return;
//     }
//     if (msg.contains('TimeoutException')) {
//       AppUtils.showError('Unable to complete request. Please try again.');
//       return;
//     }

//     switch (context) {
//       case 'fetchRoles':
//         AppUtils.showError('Unable to load roles. Please try again.');
//         break;
//       case 'loadUserBiometricAndAttendance':
//         AppUtils.showError('Unable to load attendance data. Please try again.');
//         break;
//       case 'saveBiometric':
//         AppUtils.showError('Unable to save biometric. Please try again.');
//         break;
//       case 'clearUserDevice':
//         AppUtils.showError('Unable to clear device. Please try again.');
//         break;
//       case 'login':
//         AppUtils.showError('Unable to login. Please try again.');
//         break;
//       case 'register':
//         AppUtils.showError('Unable to register. Please try again.');
//         break;
//       case 'logout':
//         AppUtils.showError('Unable to logout. Please try again.');
//         break;
//       default:
//         AppUtils.showError('Unable to process request. Please try again.');
//     }
//   }

//   // ─── FETCH ROLES FROM API ────────────────────────────────────
//   /// Call this only from RegisterScreen — not on app init.
//   Future<void> fetchRoles() async {
//     // Agar already loaded hai to dobara API call mat karo
//     if (rolesModelList.isNotEmpty) return;

//     isRolesLoading.value = true;
//     try {
//       final models = await ApiService.getRoleModels();

//       if (models.isNotEmpty) {
//         rolesModelList
//           ..clear()
//           ..addAll(models);

//         rolesList.value = models.map((r) => r.roleName.toLowerCase()).toList();

//         if (!rolesList.contains(selectedRole.value)) {
//           selectedRole.value = rolesList.first;
//           selectedRoleId.value = models.first.roleId;
//         } else {
//           final match = models.firstWhereOrNull(
//             (r) => r.roleName.toLowerCase() == selectedRole.value,
//           );
//           if (match != null) selectedRoleId.value = match.roleId;
//         }
//       } else {
//         _setFallbackRoles();
//       }
//     } catch (e) {
//       _showUnableError('fetchRoles', e);
//       _setFallbackRoles();
//     } finally {
//       isRolesLoading.value = false;
//     }
//   }

//   void _setFallbackRoles() {
//     rolesList.value = AppConstants.allRoles;
//     if (!rolesList.contains(selectedRole.value)) {
//       selectedRole.value = AppConstants.roleEmployee;
//     }
//     selectedRoleId.value = 0;
//   }

//   void onRoleSelected(String roleName) {
//     selectedRole.value = roleName.toLowerCase();
//     final match = rolesModelList.firstWhereOrNull(
//       (r) => r.roleName.toLowerCase() == selectedRole.value,
//     );
//     selectedRoleId.value = match?.roleId ?? 0;
//   }

//   // ─── LOAD BIOMETRIC + ATTENDANCE DATA ───────────────────────
//   Future<void> loadUserBiometricAndAttendance() async {
//     try {
//       final userId = StorageService.getUserId();
//       if (userId == 0) return;

//       final bioData = await ApiService.getUserBiometric(userId);
//       if (bioData != null) {
//         inBiometric.value = bioData['inbiometric'] ?? '';
//         outBiometric.value = bioData['outbiometric'] ?? '';
//       }

//       final todayData = await ApiService.getTodayAttendance(userId);
//       if (todayData != null) {
//         isCheckedIn.value = todayData['checkIn'] != null;
//         isCheckedOut.value = todayData['checkOut'] != null;
//         checkInTime.value = todayData['checkIn'] ?? '';
//         checkOutTime.value = todayData['checkOut'] ?? '';
//       }
//     } catch (e) {
//       _showUnableError('loadUserBiometricAndAttendance', e);
//     }
//   }

//   // ─── SAVE BIOMETRIC TOKEN ────────────────────────────────────
//   Future<void> saveBiometric({
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final userId = StorageService.getUserId();
//       await ApiService.saveBiometricToken(
//         userId: userId,
//         type: type,
//         token: token,
//       );

//       if (type == 'in') {
//         inBiometric.value = token;
//       } else {
//         outBiometric.value = token;
//       }
//     } catch (e) {
//       _showUnableError('saveBiometric', e);
//       rethrow;
//     }
//   }

//   // ─── CLEAR USER DEVICE (Admin Only) ─────────────────────────
//   Future<bool> clearUserDevice(int userId) async {
//     try {
//       final response = await ApiService.clearUserDevice(userId);
//       return response.success;
//     } catch (e) {
//       _showUnableError('clearUserDevice', e);
//       return false;
//     }
//   }

//   // ─── LOGIN ──────────────────────────────────────────────────
//   Future<void> login() async {
//     if (!loginFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final deviceId = await DeviceSessionService.to.getDeviceId();

//       final response = await ApiService.login(
//         LoginRequest(
//           email: loginEmailController.text.trim(),
//           password: loginPasswordController.text,
//           deviceId: deviceId,
//         ),
//       );

//       if (response.success && response.data != null) {
//         final data = response.data!;

//         if (data.token != null) {
//           await StorageService.saveToken(data.token!);
//           await StorageService.saveUserData(
//             userId: data.userId,
//             userName: data.userName,
//             email: data.email,
//             role: data.role,
//           );
//           await StorageService.saveRequiresSelfie(data.requiresSelfie);
//           await StorageService.saveDeviceId(deviceId);

//           _loadUserInfo();

//           await DeviceSessionService.to.registerSession(
//             userId: data.userId.toString(),
//             deviceId: deviceId,
//           );

//           DeviceSessionService.to.startSessionPolling();

//           ActivityService.to.start();

//           await loadUserBiometricAndAttendance();

//           AppUtils.showSuccess('Welcome back, ${data.userName}!');
//           Get.offAllNamed('/home');
//         } else {
//           AppUtils.showError('Unable to login. No token received.');
//         }
//       } else {
//         final msg = response.message.toLowerCase();
//         if (msg.contains('device') ||
//             msg.contains('another') ||
//             msg.contains('session') ||
//             msg.contains('conflict')) {
//           _showDeviceConflictDialog();
//         } else {
//           AppUtils.showError(
//             response.message.isNotEmpty
//                 ? response.message
//                 : 'Unable to login. Please check your credentials.',
//           );
//         }
//       }
//     } catch (e) {
//       _showUnableError('login', e);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── DEVICE CONFLICT DIALOG ─────────────────────────────────
//   void _showDeviceConflictDialog() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.block_rounded, size: 50, color: Colors.red),
//               const SizedBox(height: 12),
//               const Text(
//                 'Login Blocked',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'This account is active on another device.\nPlease ask admin to clear your device.',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 18),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Get.back(),
//                   child: const Text('OK'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }

//   // ─── REGISTER ───────────────────────────────────────────────
//   Future<void> register() async {
//     if (!registerFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final response = await ApiService.register(
//         RegisterRequest(
//           userName: registerNameController.text.trim(),
//           email: registerEmailController.text.trim(),
//           password: registerPasswordController.text,
//           confirmPassword: registerConfirmPasswordController.text,
//           role: selectedRole.value,
//           roleId: selectedRoleId.value,
//         ),
//       );

//       if (response.success) {
//         clearRegisterForm();
//         // Roles cache reset karo
//         rolesModelList.clear();
//         rolesList.clear();
//         // Pehle navigate karo, phir snackbar dikhao ✅
//         Get.back();
//         await Future.delayed(const Duration(milliseconds: 400));
//         AppUtils.showSuccess('Registration successful! Please login. 🎉');
//       } else {
//         AppUtils.showError(response.message);
//       }
//     } catch (e) {
//       _showUnableError('register', e);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── LOGOUT ─────────────────────────────────────────────────
//   Future<void> logout() async {
//     isLoading.value = true;
//     try {
//       ActivityService.to.stop();

//       DeviceSessionService.to.stopSessionPolling();
//       final int userId = StorageService.getUserId();
//       if (userId != 0) {
//         await DeviceSessionService.to.removeSession(userId.toString());
//       }

//       await ApiService.logout();
//       await StorageService.clearAll();
//       _resetState();
//     } catch (e) {
//       // logout me user ko error dikhana optional hota hai; still keeping unable style
//       _showUnableError('logout', e);
//       await StorageService.clearAll();
//       _resetState();
//     } finally {
//       isLoading.value = false;
//       Get.offAllNamed('/login');
//     }
//   }

//   void _resetState() {
//     inBiometric.value = '';
//     outBiometric.value = '';
//     isCheckedIn.value = false;
//     isCheckedOut.value = false;
//     checkInTime.value = '';
//     checkOutTime.value = '';
//     userName.value = '';
//     userEmail.value = '';
//     userRole.value = '';
//     // Roles bhi reset karo logout pe
//     rolesModelList.clear();
//     rolesList.clear();
//   }

//   void togglePasswordVisibility() =>
//       isPasswordVisible.value = !isPasswordVisible.value;

//   void toggleConfirmPasswordVisibility() =>
//       isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

//   void clearRegisterForm() {
//     registerNameController.clear();
//     registerEmailController.clear();
//     registerPasswordController.clear();
//     registerConfirmPasswordController.clear();
//   }

//   @override
//   void onClose() {
//     loginEmailController.dispose();
//     loginPasswordController.dispose();
//     registerNameController.dispose();
//     registerEmailController.dispose();
//     registerPasswordController.dispose();
//     registerConfirmPasswordController.dispose();
//     super.onClose();
//   }
// }






// login 

// // lib/controllers/auth_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:collection/collection.dart';

// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../services/device_session_service.dart';
// import '../services/activity_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AuthController extends GetxController {
//   // ─── STATE ──────────────────────────────────────────────────
//   final isLoading = false.obs;

//   // ✅ NEW: prevents double tap / repeated logout
//   final isLoggingOut = false.obs;

//   final isPasswordVisible = false.obs;
//   final isConfirmPasswordVisible = false.obs;
//   final selectedRole = 'employee'.obs;
//   final selectedRoleId = 0.obs;

//   // Roles from API
//   final rolesList = <String>[].obs;
//   final rolesModelList = <RoleModel>[].obs;
//   final isRolesLoading = false.obs;

//   // Login Form
//   final loginEmailController = TextEditingController();
//   final loginPasswordController = TextEditingController();
//   final loginFormKey = GlobalKey<FormState>();

//   // Register Form
//   final registerNameController = TextEditingController();
//   final registerEmailController = TextEditingController();
//   final registerPasswordController = TextEditingController();
//   final registerConfirmPasswordController = TextEditingController();
//   final registerFormKey = GlobalKey<FormState>();

//   // User Info
//   final userName = ''.obs;
//   final userEmail = ''.obs;
//   final userRole = ''.obs;

//   // ─── BIOMETRIC FIELDS ────────────────────────────────────────
//   final inBiometric = ''.obs;
//   final outBiometric = ''.obs;

//   // ─── TODAY'S ATTENDANCE STATE ────────────────────────────────
//   final isCheckedIn = false.obs;
//   final isCheckedOut = false.obs;
//   final checkInTime = ''.obs;
//   final checkOutTime = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserInfo();
//     // fetchRoles() intentionally NOT called here —
//     // roles are only needed on RegisterScreen, called from there.
//   }

//   void _loadUserInfo() {
//     userName.value = StorageService.getUserName();
//     userEmail.value = StorageService.getUserEmail();
//     userRole.value = StorageService.getUserRole();
//   }

//   bool get isAdmin => userRole.value.toLowerCase() == AppConstants.roleAdmin;

//   // ✅ Performance module ke liye
//   int get currentUserId => StorageService.getUserId();

//   // ─── ERROR HANDLER (UNABLE STYLE) ────────────────────────────
//   void _showUnableError(String context, dynamic e) {
//     debugPrint('$context error: $e');

//     final msg = e.toString();

//     // Network friendly messages
//     if (msg.contains('SocketException')) {
//       AppUtils.showError(
//           'Unable to connect. Please check your internet and try again.');
//       return;
//     }
//     if (msg.contains('TimeoutException')) {
//       AppUtils.showError('Unable to complete request. Please try again.');
//       return;
//     }

//     switch (context) {
//       case 'fetchRoles':
//         AppUtils.showError('Unable to load roles. Please try again.');
//         break;
//       case 'loadUserBiometricAndAttendance':
//         AppUtils.showError('Unable to load attendance data. Please try again.');
//         break;
//       case 'saveBiometric':
//         AppUtils.showError('Unable to save biometric. Please try again.');
//         break;
//       case 'clearUserDevice':
//         AppUtils.showError('Unable to clear device. Please try again.');
//         break;
//       case 'login':
//         AppUtils.showError('Unable to login. Please try again.');
//         break;
//       case 'register':
//         AppUtils.showError('Unable to register. Please try again.');
//         break;
//       case 'logout':
//         AppUtils.showError('Unable to logout. Please try again.');
//         break;
//       default:
//         AppUtils.showError('Unable to process request. Please try again.');
//     }
//   }

//   // ─── FETCH ROLES FROM API ────────────────────────────────────
//   /// Call this only from RegisterScreen — not on app init.
//   Future<void> fetchRoles() async {
//     // Agar already loaded hai to dobara API call mat karo
//     if (rolesModelList.isNotEmpty) return;

//     isRolesLoading.value = true;
//     try {
//       final models = await ApiService.getRoleModels();

//       if (models.isNotEmpty) {
//         rolesModelList
//           ..clear()
//           ..addAll(models);

//         rolesList.value = models.map((r) => r.roleName.toLowerCase()).toList();

//         if (!rolesList.contains(selectedRole.value)) {
//           selectedRole.value = rolesList.first;
//           selectedRoleId.value = models.first.roleId;
//         } else {
//           final match = models.firstWhereOrNull(
//             (r) => r.roleName.toLowerCase() == selectedRole.value,
//           );
//           if (match != null) selectedRoleId.value = match.roleId;
//         }
//       } else {
//         _setFallbackRoles();
//       }
//     } catch (e) {
//       _showUnableError('fetchRoles', e);
//       _setFallbackRoles();
//     } finally {
//       isRolesLoading.value = false;
//     }
//   }

//   void _setFallbackRoles() {
//     rolesList.value = AppConstants.allRoles;
//     if (!rolesList.contains(selectedRole.value)) {
//       selectedRole.value = AppConstants.roleEmployee;
//     }
//     selectedRoleId.value = 0;
//   }

//   void onRoleSelected(String roleName) {
//     selectedRole.value = roleName.toLowerCase();
//     final match = rolesModelList.firstWhereOrNull(
//       (r) => r.roleName.toLowerCase() == selectedRole.value,
//     );
//     selectedRoleId.value = match?.roleId ?? 0;
//   }

//   // ─── LOAD BIOMETRIC + ATTENDANCE DATA ───────────────────────
//   Future<void> loadUserBiometricAndAttendance() async {
//     try {
//       final userId = StorageService.getUserId();
//       if (userId == 0) return;

//       final bioData = await ApiService.getUserBiometric(userId);
//       if (bioData != null) {
//         inBiometric.value = bioData['inbiometric'] ?? '';
//         outBiometric.value = bioData['outbiometric'] ?? '';
//       }

//       final todayData = await ApiService.getTodayAttendance(userId);
//       if (todayData != null) {
//         isCheckedIn.value = todayData['checkIn'] != null;
//         isCheckedOut.value = todayData['checkOut'] != null;
//         checkInTime.value = todayData['checkIn'] ?? '';
//         checkOutTime.value = todayData['checkOut'] ?? '';
//       }
//     } catch (e) {
//       _showUnableError('loadUserBiometricAndAttendance', e);
//     }
//   }

//   // ─── SAVE BIOMETRIC TOKEN ────────────────────────────────────
//   Future<void> saveBiometric({
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final userId = StorageService.getUserId();
//       await ApiService.saveBiometricToken(
//         userId: userId,
//         type: type,
//         token: token,
//       );

//       if (type == 'in') {
//         inBiometric.value = token;
//       } else {
//         outBiometric.value = token;
//       }
//     } catch (e) {
//       _showUnableError('saveBiometric', e);
//       rethrow;
//     }
//   }

//   // ─── CLEAR USER DEVICE (Admin Only) ─────────────────────────
//   Future<bool> clearUserDevice(int userId) async {
//     try {
//       final response = await ApiService.clearUserDevice(userId);
//       return response.success;
//     } catch (e) {
//       _showUnableError('clearUserDevice', e);
//       return false;
//     }
//   }

//   // ─── LOGIN ──────────────────────────────────────────────────
//   Future<void> login() async {
//     if (!loginFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final deviceId = await DeviceSessionService.to.getDeviceId();

//       final response = await ApiService.login(
//         LoginRequest(
//           email: loginEmailController.text.trim(),
//           password: loginPasswordController.text,
//           deviceId: deviceId,
//         ),
//       );

//       if (response.success && response.data != null) {
//         final data = response.data!;

//         if (data.token != null) {
//           await StorageService.saveToken(data.token!);
//           await StorageService.saveUserData(
//             userId: data.userId,
//             userName: data.userName,
//             email: data.email,
//             role: data.role,
//           );
//           await StorageService.saveRequiresSelfie(data.requiresSelfie);
//           await StorageService.saveDeviceId(deviceId);

//           _loadUserInfo();

//           await DeviceSessionService.to.registerSession(
//             userId: data.userId.toString(),
//             deviceId: deviceId,
//           );

//           DeviceSessionService.to.startSessionPolling();

//           ActivityService.to.start();

//           await loadUserBiometricAndAttendance();

//           AppUtils.showSuccess('Welcome back, ${data.userName}!');
//           Get.offAllNamed('/home');
//         } else {
//           AppUtils.showError('Unable to login. No token received.');
//         }
//       } else {
//         final msg = response.message.toLowerCase();
//         if (msg.contains('device') ||
//             msg.contains('another') ||
//             msg.contains('session') ||
//             msg.contains('conflict')) {
//           _showDeviceConflictDialog();
//         } else {
//           AppUtils.showError(
//             response.message.isNotEmpty
//                 ? response.message
//                 : 'Unable to login. Please check your credentials.',
//           );
//         }
//       }
//     } catch (e) {
//       _showUnableError('login', e);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── DEVICE CONFLICT DIALOG ─────────────────────────────────
//   void _showDeviceConflictDialog() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.block_rounded, size: 50, color: Colors.red),
//               const SizedBox(height: 12),
//               const Text(
//                 'Login Blocked',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'This account is active on another device.\nPlease ask admin to clear your device.',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 18),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Get.back(),
//                   child: const Text('OK'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }

//   // ─── REGISTER ───────────────────────────────────────────────
//   Future<void> register() async {
//     if (!registerFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final response = await ApiService.register(
//         RegisterRequest(
//           userName: registerNameController.text.trim(),
//           email: registerEmailController.text.trim(),
//           password: registerPasswordController.text,
//           confirmPassword: registerConfirmPasswordController.text,
//           role: selectedRole.value,
//           roleId: selectedRoleId.value,
//         ),
//       );

//       if (response.success) {
//         clearRegisterForm();
//         // Roles cache reset karo
//         rolesModelList.clear();
//         rolesList.clear();
//         // Pehle navigate karo, phir snackbar dikhao ✅
//         Get.back();
//         await Future.delayed(const Duration(milliseconds: 400));
//         AppUtils.showSuccess('Registration successful! Please login. 🎉');
//       } else {
//         AppUtils.showError(response.message);
//       }
//     } catch (e) {
//       _showUnableError('register', e);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─── LOGOUT (✅ Instant + No Flicker + No Double Tap) ────────
//   Future<void> logout() async {
//     // ✅ prevent double tap / multiple calls
//     if (isLoggingOut.value) return;

//     isLoggingOut.value = true;

//     // ✅ instant route change => dashboard pe name blank flicker nahi hoga
//     Get.offAllNamed('/login');

//     try {
//       ActivityService.to.stop();

//       DeviceSessionService.to.stopSessionPolling();
//       final int userId = StorageService.getUserId();
//       if (userId != 0) {
//         await DeviceSessionService.to.removeSession(userId.toString());
//       }

//       // best-effort server logout
//       await ApiService.logout();
//     } catch (e) {
//       // optional: show error or ignore
//       // _showUnableError('logout', e);
//     } finally {
//       await StorageService.clearAll();
//       _resetState();
//       isLoggingOut.value = false;
//     }
//   }

//   void _resetState() {
//     inBiometric.value = '';
//     outBiometric.value = '';
//     isCheckedIn.value = false;
//     isCheckedOut.value = false;
//     checkInTime.value = '';
//     checkOutTime.value = '';
//     userName.value = '';
//     userEmail.value = '';
//     userRole.value = '';
//     // Roles bhi reset karo logout pe
//     rolesModelList.clear();
//     rolesList.clear();
//   }

//   void togglePasswordVisibility() =>
//       isPasswordVisible.value = !isPasswordVisible.value;

//   void toggleConfirmPasswordVisibility() =>
//       isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

//   void clearRegisterForm() {
//     registerNameController.clear();
//     registerEmailController.clear();
//     registerPasswordController.clear();
//     registerConfirmPasswordController.clear();
//   }

//   @override
//   void onClose() {
//     loginEmailController.dispose();
//     loginPasswordController.dispose();
//     registerNameController.dispose();
//     registerEmailController.dispose();
//     registerPasswordController.dispose();
//     registerConfirmPasswordController.dispose();
//     super.onClose();
//   }
// }





// I/flutter: getUserBiometric status: 404   ← fail, time waste
// I/flutter: getTodayAttendance status: 404  ← fail, time waste
// tab jaake home navigate hota hai ❌

// lib/controllers/auth_controller.dart
import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/device_session_service.dart';
import '../services/activity_service.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';

class AuthController extends GetxController {
  // ─── STATE ──────────────────────────────────────────────────
  final isLoading = false.obs;

  // ✅ prevents double tap / repeated logout
  final isLoggingOut = false.obs;

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedRole = 'employee'.obs;
  final selectedRoleId = 0.obs;

  // Roles from API
  final rolesList = <String>[].obs;
  final rolesModelList = <RoleModel>[].obs;
  final isRolesLoading = false.obs;

  // Login Form
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  // Register Form
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerFormKey = GlobalKey<FormState>();

  // User Info
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = ''.obs;

  // ─── BIOMETRIC FIELDS ────────────────────────────────────────
  final inBiometric = ''.obs;
  final outBiometric = ''.obs;

  // ─── TODAY'S ATTENDANCE STATE ────────────────────────────────
  final isCheckedIn = false.obs;
  final isCheckedOut = false.obs;
  final checkInTime = ''.obs;
  final checkOutTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    // fetchRoles() intentionally NOT called here —
    // roles are only needed on RegisterScreen, called from there.
  }

  void _loadUserInfo() {
    userName.value = StorageService.getUserName();
    userEmail.value = StorageService.getUserEmail();
    userRole.value = StorageService.getUserRole();
  }

  bool get isAdmin => userRole.value.toLowerCase() == AppConstants.roleAdmin;

  // ✅ Performance module ke liye
  int get currentUserId => StorageService.getUserId();

  // ─── ERROR HANDLER (UNABLE STYLE) ────────────────────────────
  void _showUnableError(String context, dynamic e) {
    debugPrint('$context error: $e');

    final msg = e.toString();

    // Network friendly messages
    if (msg.contains('SocketException')) {
      AppUtils.showError(
          'Unable to connect. Please check your internet and try again.');
      return;
    }
    if (msg.contains('TimeoutException')) {
      AppUtils.showError('Unable to complete request. Please try again.');
      return;
    }

    switch (context) {
      case 'fetchRoles':
        AppUtils.showError('Unable to load roles. Please try again.');
        break;
      case 'loadUserBiometricAndAttendance':
        AppUtils.showError('Unable to load attendance data. Please try again.');
        break;
      case 'saveBiometric':
        AppUtils.showError('Unable to save biometric. Please try again.');
        break;
      case 'clearUserDevice':
        AppUtils.showError('Unable to clear device. Please try again.');
        break;
      case 'login':
        AppUtils.showError('Unable to login. Please try again.');
        break;
      case 'register':
        AppUtils.showError('Unable to register. Please try again.');
        break;
      case 'logout':
        AppUtils.showError('Unable to logout. Please try again.');
        break;
      default:
        AppUtils.showError('Unable to process request. Please try again.');
    }
  }

  // ─── FETCH ROLES FROM API ────────────────────────────────────
  /// Call this only from RegisterScreen — not on app init.
  Future<void> fetchRoles() async {
    // Agar already loaded hai to dobara API call mat karo
    if (rolesModelList.isNotEmpty) return;

    isRolesLoading.value = true;
    try {
      final models = await ApiService.getRoleModels();

      if (models.isNotEmpty) {
        rolesModelList
          ..clear()
          ..addAll(models);

        rolesList.value = models.map((r) => r.roleName.toLowerCase()).toList();

        if (!rolesList.contains(selectedRole.value)) {
          selectedRole.value = rolesList.first;
          selectedRoleId.value = models.first.roleId;
        } else {
          final match = models.firstWhereOrNull(
            (r) => r.roleName.toLowerCase() == selectedRole.value,
          );
          if (match != null) selectedRoleId.value = match.roleId;
        }
      } else {
        _setFallbackRoles();
      }
    } catch (e) {
      _showUnableError('fetchRoles', e);
      _setFallbackRoles();
    } finally {
      isRolesLoading.value = false;
    }
  }

  void _setFallbackRoles() {
    rolesList.value = AppConstants.allRoles;
    if (!rolesList.contains(selectedRole.value)) {
      selectedRole.value = AppConstants.roleEmployee;
    }
    selectedRoleId.value = 0;
  }

  void onRoleSelected(String roleName) {
    selectedRole.value = roleName.toLowerCase();
    final match = rolesModelList.firstWhereOrNull(
      (r) => r.roleName.toLowerCase() == selectedRole.value,
    );
    selectedRoleId.value = match?.roleId ?? 0;
  }

  // ─── LOAD BIOMETRIC + ATTENDANCE DATA ───────────────────────
  Future<void> loadUserBiometricAndAttendance() async {
    try {
      final userId = StorageService.getUserId();
      if (userId == 0) return;

      final bioData = await ApiService.getUserBiometric(userId);
      if (bioData != null) {
        inBiometric.value = bioData['inbiometric'] ?? '';
        outBiometric.value = bioData['outbiometric'] ?? '';
      }

      final todayData = await ApiService.getTodayAttendance(userId);
      if (todayData != null) {
        isCheckedIn.value = todayData['checkIn'] != null;
        isCheckedOut.value = todayData['checkOut'] != null;
        checkInTime.value = todayData['checkIn'] ?? '';
        checkOutTime.value = todayData['checkOut'] ?? '';
      }
    } catch (e) {
      _showUnableError('loadUserBiometricAndAttendance', e);
    }
  }

  // ─── SAVE BIOMETRIC TOKEN ────────────────────────────────────
  Future<void> saveBiometric({
    required String type,
    required String token,
  }) async {
    try {
      final userId = StorageService.getUserId();
      await ApiService.saveBiometricToken(
        userId: userId,
        type: type,
        token: token,
      );

      if (type == 'in') {
        inBiometric.value = token;
      } else {
        outBiometric.value = token;
      }
    } catch (e) {
      _showUnableError('saveBiometric', e);
      rethrow;
    }
  }

  // ─── CLEAR USER DEVICE (Admin Only) ─────────────────────────
  Future<bool> clearUserDevice(int userId) async {
    try {
      final response = await ApiService.clearUserDevice(userId);
      return response.success;
    } catch (e) {
      _showUnableError('clearUserDevice', e);
      return false;
    }
  }

  // ─── LOGIN ──────────────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final deviceId = await DeviceSessionService.to.getDeviceId();

      final response = await ApiService.login(
        LoginRequest(
          email: loginEmailController.text.trim(),
          password: loginPasswordController.text,
          deviceId: deviceId,
        ),
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        if (data.token != null) {
          await StorageService.saveToken(data.token!);
          await StorageService.saveUserData(
            userId: data.userId,
            userName: data.userName,
            email: data.email,
            role: data.role,
          );
          await StorageService.saveRequiresSelfie(data.requiresSelfie);
          await StorageService.saveDeviceId(deviceId);

          _loadUserInfo();

          await DeviceSessionService.to.registerSession(
            userId: data.userId.toString(),
            deviceId: deviceId,
          );

          DeviceSessionService.to.startSessionPolling();
          ActivityService.to.start();

          // ✅ FIX: Pehle navigate karo — user ko wait mat karao
          AppUtils.showSuccess('Welcome back, ${data.userName}!');
          Get.offAllNamed('/home');

          // ✅ FIX: Background me load karo — login speed block nahi hogi
          // getUserBiometric aur getTodayAttendance ke 404 errors
          // ab login ko slow nahi karenge
          unawaited(loadUserBiometricAndAttendance());

        } else {
          AppUtils.showError('Unable to login. No token received.');
        }
      } else {
        final msg = response.message.toLowerCase();
        if (msg.contains('device') ||
            msg.contains('another') ||
            msg.contains('session') ||
            msg.contains('conflict')) {
          _showDeviceConflictDialog();
        } else {
          AppUtils.showError(
            response.message.isNotEmpty
                ? response.message
                : 'Unable to login. Please check your credentials.',
          );
        }
      }
    } catch (e) {
      _showUnableError('login', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── DEVICE CONFLICT DIALOG ─────────────────────────────────
  void _showDeviceConflictDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block_rounded, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Login Blocked',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'This account is active on another device.\nPlease ask admin to clear your device.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ─── REGISTER ───────────────────────────────────────────────
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await ApiService.register(
        RegisterRequest(
          userName: registerNameController.text.trim(),
          email: registerEmailController.text.trim(),
          password: registerPasswordController.text,
          confirmPassword: registerConfirmPasswordController.text,
          role: selectedRole.value,
          roleId: selectedRoleId.value,
        ),
      );

      if (response.success) {
        clearRegisterForm();
        // Roles cache reset karo
        rolesModelList.clear();
        rolesList.clear();
        // Pehle navigate karo, phir snackbar dikhao ✅
        Get.back();
        await Future.delayed(const Duration(milliseconds: 400));
        AppUtils.showSuccess('Registration successful! Please login. 🎉');
      } else {
        AppUtils.showError(response.message);
      }
    } catch (e) {
      _showUnableError('register', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOGOUT (✅ Instant + No Flicker + No Double Tap) ────────
  Future<void> logout() async {
    // ✅ prevent double tap / multiple calls
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;

    // ✅ instant route change => dashboard pe name blank flicker nahi hoga
    Get.offAllNamed('/login');

    try {
      ActivityService.to.stop();

      DeviceSessionService.to.stopSessionPolling();
      final int userId = StorageService.getUserId();
      if (userId != 0) {
        await DeviceSessionService.to.removeSession(userId.toString());
      }

      // best-effort server logout
      await ApiService.logout();
    } catch (e) {
      // silent ignore — logout flow continue karega
    } finally {
      await StorageService.clearAll();
      _resetState();
      isLoggingOut.value = false;
    }
  }

  void _resetState() {
    inBiometric.value = '';
    outBiometric.value = '';
    isCheckedIn.value = false;
    isCheckedOut.value = false;
    checkInTime.value = '';
    checkOutTime.value = '';
    userName.value = '';
    userEmail.value = '';
    userRole.value = '';
    // Roles bhi reset karo logout pe
    rolesModelList.clear();
    rolesList.clear();
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  void clearRegisterForm() {
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }
}