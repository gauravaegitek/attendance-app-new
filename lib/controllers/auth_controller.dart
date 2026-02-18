// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AuthController extends GetxController {
//   // =================== STATE ===================
//   final isLoading = false.obs;
//   final isPasswordVisible = false.obs;
//   final isConfirmPasswordVisible = false.obs;
//   final selectedRole = 'employee'.obs;

//   // Login Form
//   final loginEmailController = TextEditingController();
//   final loginPasswordController = TextEditingController();
//   final loginFormKey = GlobalKey<FormState>();

//   // Register Form
//   final registerNameController = TextEditingController();
//   final registerEmailController = TextEditingController();
//   final registerPasswordController = TextEditingController();
//   final registerFormKey = GlobalKey<FormState>();

//   // User Info
//   final userName = ''.obs;
//   final userEmail = ''.obs;
//   final userRole = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserInfo();
//   }

//   void _loadUserInfo() {
//     userName.value = StorageService.getUserName();
//     userEmail.value = StorageService.getUserEmail();
//     userRole.value = StorageService.getUserRole();
//   }

//   bool get isAdmin =>
//       userRole.value.toLowerCase() == AppConstants.roleAdmin;

//   // =================== LOGIN ===================
//   Future<void> login() async {
//     if (!loginFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       // Get/Generate device ID
//       String? deviceId = StorageService.getDeviceId();
//       if (deviceId == null || deviceId.isEmpty) {
//         deviceId = AppUtils.generateDeviceId();
//         await StorageService.saveDeviceId(deviceId);
//       }

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
//           _loadUserInfo();
//           AppUtils.showSuccess('Welcome back, ${data.userName}!');
//           Get.offAllNamed('/home');
//         } else {
//           AppUtils.showError('Login failed. No token received.');
//         }
//       } else {
//         AppUtils.showError(response.message);
//       }
//     } catch (e) {
//       AppUtils.showError('Network error. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // =================== REGISTER ===================
//   Future<void> register() async {
//     if (!registerFormKey.currentState!.validate()) return;

//     isLoading.value = true;
//     try {
//       final response = await ApiService.register(
//         RegisterRequest(
//           userName: registerNameController.text.trim(),
//           email: registerEmailController.text.trim(),
//           password: registerPasswordController.text,
//           role: selectedRole.value,
//         ),
//       );

//       if (response.success) {
//         AppUtils.showSuccess('Registered successfully! Please login.');
//         Get.back(); // Go back to login
//         clearRegisterForm();
//       } else {
//         AppUtils.showError(response.message);
//       }
//     } catch (e) {
//       AppUtils.showError('Network error. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // =================== LOGOUT ===================
//   Future<void> logout() async {
//     Get.defaultDialog(
//       title: 'Logout',
//       middleText: 'Are you sure you want to logout?',
//       textCancel: 'Cancel',
//       textConfirm: 'Logout',
//       confirmTextColor: Colors.white,
//       onConfirm: () async {
//         Get.back();
//         isLoading.value = true;
//         await ApiService.logout();
//         await StorageService.clearAll();
//         isLoading.value = false;
//         Get.offAllNamed('/login');
//       },
//     );
//   }

//   // =================== HELPERS ===================
//   void togglePasswordVisibility() =>
//       isPasswordVisible.value = !isPasswordVisible.value;

//   void toggleConfirmPasswordVisibility() =>
//       isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

//   void clearRegisterForm() {
//     registerNameController.clear();
//     registerEmailController.clear();
//     registerPasswordController.clear();
//     selectedRole.value = 'employee';
//   }

//   @override
//   void onClose() {
//     loginEmailController.dispose();
//     loginPasswordController.dispose();
//     registerNameController.dispose();
//     registerEmailController.dispose();
//     registerPasswordController.dispose();
//     super.onClose();
//   }
// }










import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedRole = 'employee'.obs;
  final selectedRoleId = 0.obs; // ✅ ADDED — roleId track karne ke liye

  // Roles from API
  final rolesList = <String>[].obs;
  final rolesModelList = <RoleModel>[].obs; // ✅ ADDED — full role objects
  final isRolesLoading = false.obs;

  // Login Form
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  // Register Form
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController(); // ✅ ADDED
  final registerFormKey = GlobalKey<FormState>();

  // User Info
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    fetchRoles();
  }

  void _loadUserInfo() {
    userName.value = StorageService.getUserName();
    userEmail.value = StorageService.getUserEmail();
    userRole.value = StorageService.getUserRole();
  }

  bool get isAdmin =>
      userRole.value.toLowerCase() == AppConstants.roleAdmin;

  // ─── FETCH ROLES FROM API ───────────────────────────────────
  Future<void> fetchRoles() async {
    isRolesLoading.value = true;
    try {
      // ✅ Full RoleModel fetch (with roleId)
      final models = await ApiService.getRoleModels();

      if (models.isNotEmpty) {
        rolesModelList.value = models;
        rolesList.value = models.map((r) => r.roleName.toLowerCase()).toList();

        // Set default selection
        if (!rolesList.contains(selectedRole.value)) {
          selectedRole.value = rolesList.first;
          selectedRoleId.value = models.first.roleId;
        } else {
          // Set roleId for current selected role
          final match = models.firstWhereOrNull(
            (r) => r.roleName.toLowerCase() == selectedRole.value,
          );
          if (match != null) selectedRoleId.value = match.roleId;
        }

        debugPrint('Roles loaded: ${rolesList.map((r) => r).toList()}');
        debugPrint(
            'RoleIds loaded: ${rolesModelList.map((r) => r.roleId).toList()}');
      } else {
        _setFallbackRoles();
      }
    } catch (e) {
      debugPrint('fetchRoles error: $e');
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

  // ✅ Call this when user selects a role from dropdown
  void onRoleSelected(String roleName) {
    selectedRole.value = roleName;
    final match = rolesModelList.firstWhereOrNull(
      (r) => r.roleName.toLowerCase() == roleName.toLowerCase(),
    );
    selectedRoleId.value = match?.roleId ?? 0;
    debugPrint('Selected role: $roleName | roleId: ${selectedRoleId.value}');
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
          await StorageService.saveDeviceId(deviceId);
          _loadUserInfo();

          final userId = StorageService.getUserId();
          await DeviceSessionService.to.registerSession(
            userId: userId.toString(),
            deviceId: deviceId,
          );

          DeviceSessionService.to.startSessionPolling();
          ActivityService.to.start();

          AppUtils.showSuccess('Welcome back, ${data.userName}!');
          Get.offAllNamed('/home');
        } else {
          AppUtils.showError('Login failed. No token received.');
        }
      } else {
        final msg = (response.message).toLowerCase();
        if (msg.contains('device') ||
            msg.contains('another') ||
            msg.contains('session') ||
            msg.contains('conflict')) {
          _showDeviceConflictDialog();
        } else {
          AppUtils.showError(
            response.message.isNotEmpty
                ? response.message
                : 'Login failed. Please check your credentials.',
          );
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      AppUtils.showError('Network error. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── DEVICE CONFLICT DIALOG ────────────────────────────────
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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.block_rounded,
                    size: 38, color: Color(0xFFD32F2F)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Login Blocked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0A1628),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This account is already active on another device. Only one session is allowed at a time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFECB3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings_outlined,
                        size: 15, color: Color(0xFFF57C00)),
                    SizedBox(width: 6),
                    Text(
                      'Please connect to Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF57C00),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1628),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Understood',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
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
      final name = registerNameController.text.trim();
      final email = registerEmailController.text.trim();
      final password = registerPasswordController.text;
      final confirmPassword = registerConfirmPasswordController.text;
      final role = selectedRole.value;
      final roleId = selectedRoleId.value; // ✅ roleId include

      debugPrint('=== REGISTER REQUEST ===');
      debugPrint('Name     : $name');
      debugPrint('Email    : $email');
      debugPrint('Role     : $role');
      debugPrint('RoleId   : $roleId');
      debugPrint('========================');

      final response = await ApiService.register(
        RegisterRequest(
          userName: name,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          role: role,
          roleId: roleId, // ✅ ADDED
        ),
      );

      debugPrint('=== REGISTER RESPONSE ===');
      debugPrint('Success : ${response.success}');
      debugPrint('Message : ${response.message}');
      debugPrint('=========================');

      if (response.success) {
        AppUtils.showSuccess('Account created successfully! Please login.');
        Get.back();
        clearRegisterForm();
      } else {
        final msg = response.message.toLowerCase();

        if (msg.contains('email') && msg.contains('exist')) {
          AppUtils.showError('This email is already registered. Please login.');
        } else if (msg.contains('email')) {
          AppUtils.showError('Invalid email address.');
        } else if (msg.contains('password')) {
          AppUtils.showError('Password does not meet requirements.');
        } else if (msg.contains('role')) {
          AppUtils.showError('Invalid role selected.');
        } else if (msg.contains('network') || msg.contains('connect')) {
          AppUtils.showError('Network error. Check your internet connection.');
        } else if (response.message.isNotEmpty) {
          AppUtils.showError(response.message);
        } else {
          AppUtils.showError(
              'Registration failed. Please check your details and try again.');
        }
      }
    } catch (e) {
      debugPrint('Register exception: $e');
      AppUtils.showError(
          'Something went wrong. Please check your connection and try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOGOUT ─────────────────────────────────────────────────
  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: const TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w700),
      middleText: 'Are you sure you want to logout?',
      middleTextStyle: const TextStyle(fontFamily: 'Poppins'),
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF0A1628),
      onConfirm: () async {
        Get.back();
        isLoading.value = true;

        DeviceSessionService.to.stopSessionPolling();
        ActivityService.to.stop();

        final int userId = StorageService.getUserId();
        if (userId != 0) {
          await DeviceSessionService.to.removeSession(userId.toString());
        }

        await ApiService.logout();
        await StorageService.clearAll();
        isLoading.value = false;
        Get.offAllNamed('/login');
      },
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────
  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  void clearRegisterForm() {
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear(); // ✅ ADDED
    selectedRole.value =
        rolesList.isNotEmpty ? rolesList.first : AppConstants.roleEmployee;
    selectedRoleId.value =
        rolesModelList.isNotEmpty ? rolesModelList.first.roleId : 0; // ✅ ADDED
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose(); // ✅ ADDED
    super.onClose();
  }
}