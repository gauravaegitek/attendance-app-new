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
import '../core/utils/response_handler.dart';
import '../core/constants/app_constants.dart';

class AuthController extends GetxController {
  // ─── STATE ──────────────────────────────────────────────────
  final isLoading        = false.obs;
  final isLoggingOut     = false.obs;

  final isPasswordVisible        = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedRole   = 'employee'.obs;
  final selectedRoleId = 0.obs;

  // Roles from API
  final rolesList      = <String>[].obs;
  final rolesModelList = <RoleModel>[].obs;
  final isRolesLoading = false.obs;

  // Login Form
  final loginEmailController    = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginFormKey            = GlobalKey<FormState>();

  // Register Form
  final registerNameController            = TextEditingController();
  final registerEmailController           = TextEditingController();
  final registerPasswordController        = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerFormKey                   = GlobalKey<FormState>();

  // User Info
  final userName  = ''.obs;
  final userEmail = ''.obs;
  final userRole  = ''.obs;

  // ─── BIOMETRIC FIELDS ────────────────────────────────────────
  final inBiometric  = ''.obs;
  final outBiometric = ''.obs;

  // ─── TODAY'S ATTENDANCE STATE ────────────────────────────────
  final isCheckedIn  = false.obs;
  final isCheckedOut = false.obs;
  final checkInTime  = ''.obs;
  final checkOutTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    userName.value  = StorageService.getUserName();
    userEmail.value = StorageService.getUserEmail();
    userRole.value  = StorageService.getUserRole();
  }

  bool get isAdmin => userRole.value.toLowerCase() == AppConstants.roleAdmin;

  int get currentUserId => StorageService.getUserId();

  // ─── FETCH ROLES FROM API ────────────────────────────────────
  Future<void> fetchRoles() async {
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
          selectedRole.value   = rolesList.first;
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
      ResponseHandler.handleException(
        e,
        context: 'fetchRoles',
        fallback: 'Unable to load roles. Please try again.',
      );
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
        inBiometric.value  = bioData['inbiometric']  ?? '';
        outBiometric.value = bioData['outbiometric'] ?? '';
      }

      final todayData = await ApiService.getTodayAttendance(userId);
      if (todayData != null) {
        isCheckedIn.value  = todayData['checkIn'] != null;
        isCheckedOut.value = todayData['checkOut'] != null;
        checkInTime.value  = todayData['checkIn']  ?? '';
        checkOutTime.value = todayData['checkOut'] ?? '';
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'loadUserBiometricAndAttendance',
        fallback: 'Unable to load attendance data. Please try again.',
      );
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
        type:   type,
        token:  token,
      );

      if (type == 'in') {
        inBiometric.value = token;
      } else {
        outBiometric.value = token;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'saveBiometric',
        fallback: 'Unable to save biometric. Please try again.',
      );
      rethrow;
    }
  }

  // ─── CLEAR USER DEVICE (Admin Only) ─────────────────────────
  Future<bool> clearUserDevice(int userId) async {
    try {
      final response = await ApiService.clearUserDevice(userId);
      return response.success;
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'clearUserDevice',
        fallback: 'Unable to clear device. Please try again.',
      );
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
          email:    loginEmailController.text.trim(),
          password: loginPasswordController.text,
          deviceId: deviceId,
        ),
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        if (data.token != null) {
          await StorageService.saveToken(data.token!);
          await StorageService.saveUserData(
            userId:   data.userId,
            userName: data.userName,
            email:    data.email,
            role:     data.role,
          );
          await StorageService.saveRequiresSelfie(data.requiresSelfie);
          await StorageService.saveDeviceId(deviceId);

          _loadUserInfo();

          await DeviceSessionService.to.registerSession(
            userId:   data.userId.toString(),
            deviceId: deviceId,
          );

          DeviceSessionService.to.startSessionPolling();
          ActivityService.to.start();

          ResponseHandler.showSuccess(
            apiMessage: response.message,
            fallback:   'Welcome back, ${data.userName}!',
          );
          Get.offAllNamed('/home');

          unawaited(loadUserBiometricAndAttendance());
        } else {
          ResponseHandler.showError(
            apiMessage: '',
            fallback:   'Unable to login. No token received.',
          );
        }
      } else {
        final msg = response.message.toLowerCase();
        if (msg.contains('device')  ||
            msg.contains('another') ||
            msg.contains('session') ||
            msg.contains('conflict')) {
          _showDeviceConflictDialog();
        } else {
          ResponseHandler.showError(
            apiMessage: response.message,
            fallback:   'Unable to login. Please check your credentials.',
          );
        }
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'login',
        fallback: 'Unable to login. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── DEVICE CONFLICT DIALOG ─────────────────────────────────
  void _showDeviceConflictDialog() {
    Get.dialog(
      Dialog(
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          userName:        registerNameController.text.trim(),
          email:           registerEmailController.text.trim(),
          password:        registerPasswordController.text,
          confirmPassword: registerConfirmPasswordController.text,
          role:            selectedRole.value,
          roleId:          selectedRoleId.value,
        ),
      );

      if (response.success) {
        clearRegisterForm();
        rolesModelList.clear();
        rolesList.clear();
        Get.back();
        await Future.delayed(const Duration(milliseconds: 400));
        ResponseHandler.showSuccess(
          apiMessage: response.message,
          fallback:   'Registration successful! Please login.',
        );
      } else {
        ResponseHandler.showError(
          apiMessage: response.message,
          fallback:   'Unable to register. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'register',
        fallback: 'Unable to register. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;
    Get.offAllNamed('/login');

    try {
      ActivityService.to.stop();
      DeviceSessionService.to.stopSessionPolling();

      final int userId = StorageService.getUserId();
      if (userId != 0) {
        await DeviceSessionService.to.removeSession(userId.toString());
      }

      await ApiService.logout();
    } catch (_) {
      // silent ignore — logout flow continue karega
    } finally {
      await StorageService.clearAll();
      _resetState();
      isLoggingOut.value = false;
    }
  }

  void _resetState() {
    inBiometric.value  = '';
    outBiometric.value = '';
    isCheckedIn.value  = false;
    isCheckedOut.value = false;
    checkInTime.value  = '';
    checkOutTime.value = '';
    userName.value     = '';
    userEmail.value    = '';
    userRole.value     = '';
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
