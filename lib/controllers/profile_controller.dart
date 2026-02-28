// lib/controllers/profile_controller.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/profile_model.dart';
import '../services/storage_service.dart';
import '../core/utils/response_handler.dart';

class ProfileController extends GetxController {
  // ── Observables ──────────────────────────
  final profile             = Rxn<ProfileModel>();
  final isLoading           = false.obs;
  final isUploading         = false.obs;
  final isSaving            = false.obs;
  final isChangingPassword  = false.obs;

  final pendingPhoto      = Rxn<XFile>();
  final pendingPhotoBytes = Rxn<Uint8List>();

  // ── Form Controllers ──────────────────────
  final phoneCtrl            = TextEditingController();
  final addressCtrl          = TextEditingController();
  final departmentCtrl       = TextEditingController();
  final designationCtrl      = TextEditingController();
  final emergencyContactCtrl = TextEditingController();
  final dobCtrl              = TextEditingController();

  DateTime? _selectedDob;

  // ── Password Form ─────────────────────────
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl     = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ── Helpers ───────────────────────────────
  String get _token => StorageService.getToken() ?? '';

  Uri _uri(String path) =>
      Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$path');

  Map<String, String> get _authHeader => {
        'Authorization': 'Bearer $_token',
      };

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    addressCtrl.dispose();
    departmentCtrl.dispose();
    designationCtrl.dispose();
    emergencyContactCtrl.dispose();
    dobCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  void _populateForm(ProfileModel p) {
    phoneCtrl.text            = p.phone ?? '';
    addressCtrl.text          = p.address ?? '';
    departmentCtrl.text       = p.department ?? '';
    designationCtrl.text      = p.designation ?? '';
    emergencyContactCtrl.text = p.emergencyContact ?? '';

    if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
      try {
        DateTime? parsed;
        for (final fmt in ['dd-MMM-yyyy', 'yyyy-MM-dd', 'dd/MM/yyyy']) {
          try {
            parsed = DateFormat(fmt).parse(p.dateOfBirth!);
            break;
          } catch (_) {}
        }
        if (parsed != null) {
          _selectedDob = parsed;
          dobCtrl.text = DateFormat('dd-MMM-yyyy').format(parsed);
        } else {
          dobCtrl.text = p.dateOfBirth!;
        }
      } catch (_) {
        dobCtrl.text = p.dateOfBirth ?? '';
      }
    }
  }

  // ── Open Date Picker ─────────────────────
  Future<void> pickDateOfBirth(BuildContext context) async {
    final now     = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 25);

    final picked = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   DateTime(1950),
      lastDate:    DateTime(now.year - 10),
      helpText:    'SELECT DATE OF BIRTH',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   Color(0xFF1976D2),
            onPrimary: Colors.white,
            surface:   Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      _selectedDob = picked;
      dobCtrl.text = DateFormat('dd-MMM-yyyy').format(picked);
    }
  }

  // ── GET /api/Profile ─────────────────────
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      debugPrint('🌐 [fetchProfile] url: ${_uri('/Profile')}');

      final res = await http
          .get(_uri('/Profile'), headers: {
            ..._authHeader,
            'Content-Type': 'application/json',
          })
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
        ResponseHandler.showError(
          apiMessage: _parseError(res.body),
          fallback:   'Unable to load profile. Please try again.',
        );
      }
    } on SocketException {
      ResponseHandler.showError(
        apiMessage: '',
        fallback:   'Unable to connect. Please check your internet and try again.',
      );
    } catch (e) {
      debugPrint('❌ [fetchProfile] exception: $e');
      ResponseHandler.handleException(
        e,
        context: 'fetchProfile',
        fallback: 'Unable to load profile. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── PUT /api/Profile (multipart/form-data) ──────────
  Future<bool> updateProfile() async {
    if (profile.value == null) return false;
    try {
      isSaving.value = true;

      final request = http.MultipartRequest('PUT', _uri('/Profile'))
        ..headers.addAll(_authHeader);

      void addField(String key, String value) {
        if (value.isNotEmpty) request.fields[key] = value;
      }

      addField('Phone',            phoneCtrl.text.trim());
      addField('Department',       departmentCtrl.text.trim());
      addField('Designation',      designationCtrl.text.trim());
      addField('Address',          addressCtrl.text.trim());
      addField('EmergencyContact', emergencyContactCtrl.text.trim());

      if (_selectedDob != null) {
        request.fields['DateOfBirth'] =
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDob!);
      }

      if (pendingPhoto.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'ProfilePhoto',
          pendingPhoto.value!.path,
          filename:    'photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      debugPrint('📤 [updateProfile] fields: ${request.fields}');
      debugPrint(
          '📤 [updateProfile] files: ${request.files.map((f) => f.filename)}');

      final streamed = await request.send().timeout(
          const Duration(milliseconds: AppConstants.receiveTimeout));
      final res = await http.Response.fromStream(streamed);

      debugPrint('📥 [updateProfile] status: ${res.statusCode}');
      debugPrint('📥 [updateProfile] body: ${res.body}');

      if (res.statusCode == 200) {
        try {
          final body = jsonDecode(res.body);
          final data =
              (body is Map && body['data'] != null) ? body['data'] : body;
          if (data is Map<String, dynamic>) {
            final updated = ProfileModel.fromJson(data);
            profile.value = updated;
            _populateForm(updated);
          }

          // API message prefer karo
          final apiMsg = (body is Map)
              ? (body['message'] ?? body['msg'] ?? '').toString()
              : '';
          ResponseHandler.showSuccess(
            apiMessage: apiMsg,
            fallback:   'Profile updated successfully.',
          );
        } catch (_) {
          profile.value = profile.value!.copyWith(
            phone:            phoneCtrl.text.trim(),
            address:          addressCtrl.text.trim(),
            department:       departmentCtrl.text.trim(),
            designation:      designationCtrl.text.trim(),
            emergencyContact: emergencyContactCtrl.text.trim(),
            dateOfBirth: _selectedDob != null
                ? DateFormat('dd-MMM-yyyy').format(_selectedDob!)
                : null,
          );
          ResponseHandler.showSuccess(
            apiMessage: '',
            fallback:   'Profile updated successfully.',
          );
        }

        pendingPhoto.value = null;
        return true;
      }

      ResponseHandler.showError(
        apiMessage: _parseError(res.body),
        fallback:   'Unable to update profile. Please try again.',
      );
      return false;
    } on SocketException {
      ResponseHandler.showError(
        apiMessage: '',
        fallback:   'Unable to connect. Please check your internet and try again.',
      );
      return false;
    } catch (e) {
      debugPrint('❌ [updateProfile] exception: $e');
      ResponseHandler.handleException(
        e,
        context: 'updateProfile',
        fallback: 'Unable to update profile. Please try again.',
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ── POST /api/Profile/changepassword ─────
  Future<bool> changePassword() async {
    final current = currentPasswordCtrl.text.trim();
    final newPass = newPasswordCtrl.text.trim();
    final confirm = confirmPasswordCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ResponseHandler.showWarning('All password fields are required.');
      return false;
    }
    if (newPass.length < 6) {
      ResponseHandler.showWarning('New password must be at least 6 characters.');
      return false;
    }
    if (newPass != confirm) {
      ResponseHandler.showWarning('Passwords do not match.');
      return false;
    }

    try {
      isChangingPassword.value = true;

      final body = jsonEncode({
        'currentPassword': current,
        'newPassword':     newPass,
        'confirmPassword': confirm,
      });

      debugPrint('🌐 [changePassword] url: ${_uri('/Profile/changepassword')}');

      final res = await http
          .post(
            _uri('/Profile/changepassword'),
            headers: {
              ..._authHeader,
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [changePassword] status: ${res.statusCode}');
      debugPrint('📥 [changePassword] body: ${res.body}');

      if (res.statusCode == 200) {
        currentPasswordCtrl.clear();
        newPasswordCtrl.clear();
        confirmPasswordCtrl.clear();

        final data   = jsonDecode(res.body);
        final apiMsg = (data is Map)
            ? (data['message'] ?? data['msg'] ?? '').toString()
            : '';
        ResponseHandler.showSuccess(
          apiMessage: apiMsg,
          fallback:   'Password changed successfully.',
        );
        return true;
      }

      ResponseHandler.showError(
        apiMessage: _parseError(res.body),
        fallback:   'Unable to change password. Please try again.',
      );
      return false;
    } on SocketException {
      ResponseHandler.showError(
        apiMessage: '',
        fallback:   'Unable to connect. Please check your internet and try again.',
      );
      return false;
    } catch (e) {
      debugPrint('❌ [changePassword] exception: $e');
      ResponseHandler.handleException(
        e,
        context: 'changePassword',
        fallback: 'Unable to change password. Please try again.',
      );
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Pick photo ────────────────────────────
  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 70,
    );
    if (picked == null) return;

    pendingPhoto.value = picked;

    if (kIsWeb) {
      final bytes            = await picked.readAsBytes();
      pendingPhotoBytes.value = bytes;
    }

    profile.value = profile.value?.copyWith(photoUrl: picked.path);

    ResponseHandler.showInfo('Photo selected! Tap "Save Changes" to upload.');
  }

  // ── DELETE /api/Profile/photo ────────────
  Future<void> deletePhoto() async {
    try {
      isUploading.value = true;
      final res = await http
          .delete(_uri('/Profile/photo'), headers: {
            ..._authHeader,
            'Content-Type': 'application/json',
          })
          .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

      debugPrint('📥 [deletePhoto] status: ${res.statusCode}');

      if (res.statusCode == 200) {
        pendingPhoto.value = null;
        profile.value = profile.value?.copyWith(photoUrl: '');

        final data   = jsonDecode(res.body);
        final apiMsg = (data is Map)
            ? (data['message'] ?? data['msg'] ?? '').toString()
            : '';
        ResponseHandler.showSuccess(
          apiMessage: apiMsg,
          fallback:   'Photo removed successfully.',
        );
      } else {
        ResponseHandler.showError(
          apiMessage: _parseError(res.body),
          fallback:   'Unable to remove photo. Please try again.',
        );
      }
    } on SocketException {
      ResponseHandler.showError(
        apiMessage: '',
        fallback:   'Unable to connect. Please check your internet and try again.',
      );
    } catch (e) {
      debugPrint('❌ [deletePhoto] exception: $e');
      ResponseHandler.handleException(
        e,
        context: 'deletePhoto',
        fallback: 'Unable to remove photo. Please try again.',
      );
    } finally {
      isUploading.value = false;
    }
  }

  // ── Error parsing ─────────────────────────
  String _parseError(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map) {
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
}
