// lib/controllers/profile_controller.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_constants.dart';
import '../models/profile_model.dart';
import '../services/storage_service.dart';

class ProfileController extends GetxController {
  // ── Observables ──────────────────────────
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;
  final isUploading = false.obs;
  final isSaving = false.obs;
  final isChangingPassword = false.obs;

  // ── Form Controllers ──────────────────────
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController(); // ✅ NEW

  // ── Password Form ─────────────────────────
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ── Helpers ───────────────────────────────
  String get _token => StorageService.getToken() ?? '';

  Uri _uri(String path) =>
      Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    departmentCtrl.dispose();
    designationCtrl.dispose();
    emergencyContactCtrl.dispose(); // ✅ NEW
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  void _populateForm(ProfileModel p) {
    nameCtrl.text = p.name;
    phoneCtrl.text = p.phone ?? '';
    addressCtrl.text = p.address ?? '';
    departmentCtrl.text = p.department ?? '';
    designationCtrl.text = p.designation ?? '';
    emergencyContactCtrl.text = p.emergencyContact ?? ''; // ✅ NEW
  }

  // ── GET /api/Profile ─────────────────────
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      debugPrint('🔑 [fetchProfile] token: $_token');
      debugPrint('🌐 [fetchProfile] url: ${_uri('/Profile')}');

      final res = await http
          .get(_uri('/Profile'), headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [fetchProfile] status: ${res.statusCode}');
      debugPrint('📥 [fetchProfile] body: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data =
            (body is Map && body['data'] != null) ? body['data'] : body;
        final p = ProfileModel.fromJson(data as Map<String, dynamic>);
        profile.value = p;
        _populateForm(p);
      } else {
        _showError(_parseError(res.body));
      }
    } on SocketException {
      _showError('No internet connection');
    } catch (e) {
      debugPrint('❌ [fetchProfile] exception: $e');
      _showError('Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  // ── PUT /api/Profile ─────────────────────
  Future<bool> updateProfile() async {
    if (profile.value == null) return false;
    try {
      isSaving.value = true;

      // ✅ emergencyContact added to payload
      final body = jsonEncode({
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'department': departmentCtrl.text.trim(),
        'designation': designationCtrl.text.trim(),
        'emergencyContact': emergencyContactCtrl.text.trim(),
      });

      final res = await http
          .put(_uri('/Profile'), headers: _headers, body: body)
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [updateProfile] status: ${res.statusCode}');
      debugPrint('📥 [updateProfile] body: ${res.body}');

      if (res.statusCode == 200) {
        // ✅ Local profile update with emergencyContact
        profile.value = profile.value!.copyWith(
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          department: departmentCtrl.text.trim(),
          designation: designationCtrl.text.trim(),
          emergencyContact: emergencyContactCtrl.text.trim(),
        );
        _showSuccess('Profile updated successfully');
        return true;
      }
      _showError(_parseError(res.body));
      return false;
    } on SocketException {
      _showError('No internet connection');
      return false;
    } catch (e) {
      debugPrint('❌ [updateProfile] exception: $e');
      _showError('Failed to update profile');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ── POST /api/Profile/changepassword ─────
  // ✅ NOTE: Validation is done in UI (_formKey.validate())
  // Controller only does the API call here
  Future<bool> changePassword() async {
    final current = currentPasswordCtrl.text.trim();
    final newPass = newPasswordCtrl.text.trim();
    final confirm = confirmPasswordCtrl.text.trim();

    // Fallback validation (in case called directly)
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showError('All password fields are required');
      return false;
    }
    if (newPass.length < 6) {
      _showError('New password must be at least 6 characters');
      return false;
    }
    if (newPass != confirm) {
      _showError('Passwords do not match');
      return false;
    }

    try {
      isChangingPassword.value = true;

      final body = jsonEncode({'currentPassword': current, 'newPassword': newPass, 'confirmPassword': confirm});

      debugPrint('🌐 [changePassword] url: ${_uri('/Profile/changepassword')}');
      debugPrint('📤 [changePassword] body: $body');

      final res = await http
          .post(_uri('/Profile/changepassword'),
              headers: _headers, body: body)
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [changePassword] status: ${res.statusCode}');
      debugPrint('📥 [changePassword] body: ${res.body}');

      if (res.statusCode == 200) {
        currentPasswordCtrl.clear();
        newPasswordCtrl.clear();
        confirmPasswordCtrl.clear();
        _showSuccess('Password changed successfully');
        return true;
      }

      // ✅ Better error handling for common password errors
      final errMsg = _parseError(res.body);
      _showError(errMsg);
      return false;
    } on SocketException {
      _showError('No internet connection');
      return false;
    } catch (e) {
      debugPrint('❌ [changePassword] exception: $e');
      _showError('Failed to change password');
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Upload Photo (multipart PUT /api/Profile/photo) ──
  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    try {
      isUploading.value = true;
      final request =
          http.MultipartRequest('PUT', _uri('/Profile/photo'))
            ..headers['Authorization'] = 'Bearer $_token'
            ..files.add(await http.MultipartFile.fromPath(
              'photo',
              picked.path,
              filename: 'photo.jpg',
            ));

      final streamed = await request.send().timeout(
          const Duration(milliseconds: AppConstants.receiveTimeout));
      final res = await http.Response.fromStream(streamed);

      debugPrint('📥 [pickAndUploadPhoto] status: ${res.statusCode}');
      debugPrint('📥 [pickAndUploadPhoto] body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final newUrl =
            (data['photoUrl'] ?? data['profilePhoto']) as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          profile.value = profile.value?.copyWith(photoUrl: newUrl);
        }
        _showSuccess('Photo updated');
      } else {
        _showError(_parseError(res.body));
      }
    } on SocketException {
      _showError('No internet connection');
    } catch (e) {
      debugPrint('❌ [pickAndUploadPhoto] exception: $e');
      _showError('Failed to upload photo');
    } finally {
      isUploading.value = false;
    }
  }

  // ── DELETE /api/Profile/photo ────────────
  Future<void> deletePhoto() async {
    try {
      isUploading.value = true;
      final res = await http
          .delete(_uri('/Profile/photo'), headers: _headers)
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [deletePhoto] status: ${res.statusCode}');
      debugPrint('📥 [deletePhoto] body: ${res.body}');

      if (res.statusCode == 200) {
        profile.value = profile.value?.copyWith(photoUrl: '');
        _showSuccess('Photo removed');
      } else {
        _showError(_parseError(res.body));
      }
    } on SocketException {
      _showError('No internet connection');
    } catch (e) {
      debugPrint('❌ [deletePhoto] exception: $e');
      _showError('Failed to remove photo');
    } finally {
      isUploading.value = false;
    }
  }

  // ── Error parsing ─────────────────────────
  String _parseError(String body) {
    debugPrint('❌ [_parseError] raw body: $body');
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        // ✅ Common API error field names checked in order
        return (data['message'] ??
                data['error'] ??
                data['msg'] ??
                data['title'] ??
                'Server error')
            .toString();
      }
    } catch (_) {}
    return body.isNotEmpty ? body : 'Server error';
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Success', msg,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(Icons.check_circle_outline,
          color: Color(0xFFFFFFFF)),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error', msg,
      backgroundColor: const Color(0xFFF44336),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(Icons.error_outline, color: Color(0xFFFFFFFF)),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}