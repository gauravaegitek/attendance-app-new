// // lib/controllers/profile_controller.dart

// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/profile_model.dart';
// import '../services/storage_service.dart';

// class ProfileController extends GetxController {
//   // ── Observables ──────────────────────────
//   final profile = Rxn<ProfileModel>();
//   final isLoading = false.obs;
//   final isUploading = false.obs;
//   final isSaving = false.obs;
//   final isChangingPassword = false.obs;

//   // ✅ Pending photo — selected but not yet sent (sent with profile save)
//   final pendingPhoto = Rxn<XFile>();
//   // ✅ Web: store bytes for preview (Image.file not supported on web)
//   final pendingPhotoBytes = Rxn<Uint8List>();

//   // ── Form Controllers ──────────────────────
//   final phoneCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final departmentCtrl = TextEditingController();
//   final designationCtrl = TextEditingController();
//   final emergencyContactCtrl = TextEditingController();
//   final dobCtrl = TextEditingController(); // ✅ DOB — display only

//   // ── Internal DOB value (ISO format for API) ───
//   DateTime? _selectedDob;

//   // ── Password Form ─────────────────────────
//   final currentPasswordCtrl = TextEditingController();
//   final newPasswordCtrl = TextEditingController();
//   final confirmPasswordCtrl = TextEditingController();

//   // ── Helpers ───────────────────────────────
//   String get _token => StorageService.getToken() ?? '';

//   Uri _uri(String path) =>
//       Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}$path');

//   Map<String, String> get _authHeader => {
//         'Authorization': 'Bearer $_token',
//       };

//   @override
//   void onInit() {
//     super.onInit();
//     fetchProfile();
//   }

//   @override
//   void onClose() {
//     phoneCtrl.dispose();
//     addressCtrl.dispose();
//     departmentCtrl.dispose();
//     designationCtrl.dispose();
//     emergencyContactCtrl.dispose();
//     dobCtrl.dispose();
//     currentPasswordCtrl.dispose();
//     newPasswordCtrl.dispose();
//     confirmPasswordCtrl.dispose();
//     super.onClose();
//   }

//   void _populateForm(ProfileModel p) {
//     phoneCtrl.text = p.phone ?? '';
//     addressCtrl.text = p.address ?? '';
//     departmentCtrl.text = p.department ?? '';
//     designationCtrl.text = p.designation ?? '';
//     emergencyContactCtrl.text = p.emergencyContact ?? '';

//     // ✅ DOB — parse and display
//     if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
//       try {
//         // Try parsing common formats
//         DateTime? parsed;
//         for (final fmt in ['dd-MMM-yyyy', 'yyyy-MM-dd', 'dd/MM/yyyy']) {
//           try {
//             parsed = DateFormat(fmt).parse(p.dateOfBirth!);
//             break;
//           } catch (_) {}
//         }
//         if (parsed != null) {
//           _selectedDob = parsed;
//           dobCtrl.text = DateFormat('dd-MMM-yyyy').format(parsed);
//         } else {
//           dobCtrl.text = p.dateOfBirth!;
//         }
//       } catch (_) {
//         dobCtrl.text = p.dateOfBirth ?? '';
//       }
//     }
//   }

//   // ── Open Date Picker ─────────────────────
//   Future<void> pickDateOfBirth(BuildContext context) async {
//     final now = DateTime.now();
//     final initial = _selectedDob ?? DateTime(now.year - 25);

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(1950),
//       lastDate: DateTime(now.year - 10),
//       helpText: 'SELECT DATE OF BIRTH',
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF1976D2), // Use your AppTheme.primary color
//             onPrimary: Colors.white,
//             surface: Colors.white,
//             onSurface: Colors.black87,
//           ),
//         ),
//         child: child!,
//       ),
//     );

//     if (picked != null) {
//       _selectedDob = picked;
//       dobCtrl.text = DateFormat('dd-MMM-yyyy').format(picked);
//     }
//   }

//   // ── GET /api/Profile ─────────────────────
//   Future<void> fetchProfile() async {
//     try {
//       isLoading.value = true;
//       debugPrint('🌐 [fetchProfile] url: ${_uri('/Profile')}');

//       final res = await http
//           .get(_uri('/Profile'), headers: {
//             ..._authHeader,
//             'Content-Type': 'application/json',
//           })
//           .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

//       debugPrint('📥 [fetchProfile] status: ${res.statusCode}');
//       debugPrint('📥 [fetchProfile] body: ${res.body}');

//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final data =
//             (body is Map && body['data'] != null) ? body['data'] : body;
//         final p = ProfileModel.fromJson(data as Map<String, dynamic>);
//         profile.value = p;
//         _populateForm(p);
//       } else {
//         _showError(_parseError(res.body));
//       }
//     } on SocketException {
//       _showError('No internet connection');
//     } catch (e) {
//       debugPrint('❌ [fetchProfile] exception: $e');
//       _showError('Failed to load profile');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ── PUT /api/Profile (multipart/form-data) ──────────
//   // ✅ ROOT CAUSE FIX: API has ProfilePhoto as binary → must use multipart
//   Future<bool> updateProfile() async {
//     if (profile.value == null) return false;
//     try {
//       isSaving.value = true;

//       final request =
//           http.MultipartRequest('PUT', _uri('/Profile'))
//             ..headers.addAll(_authHeader);

//       // ── Text fields (PascalCase as per swagger) ──
//       void addField(String key, String value) {
//         if (value.isNotEmpty) request.fields[key] = value;
//       }

//       addField('Phone', phoneCtrl.text.trim());
//       addField('Department', departmentCtrl.text.trim());
//       addField('Designation', designationCtrl.text.trim());
//       addField('Address', addressCtrl.text.trim());
//       addField('EmergencyContact', emergencyContactCtrl.text.trim());

//       // ── DOB — send in yyyy-MM-dd format ──
//       if (_selectedDob != null) {
//         request.fields['DateOfBirth'] =
//             DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDob!);
//       }

//       // ── Pending photo (if user picked one) ──
//       if (pendingPhoto.value != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'ProfilePhoto',
//           pendingPhoto.value!.path,
//           filename: 'photo.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         ));
//       }

//       debugPrint('📤 [updateProfile] fields: ${request.fields}');
//       debugPrint(
//           '📤 [updateProfile] files: ${request.files.map((f) => f.filename)}');

//       final streamed = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.receiveTimeout));
//       final res = await http.Response.fromStream(streamed);

//       debugPrint('📥 [updateProfile] status: ${res.statusCode}');
//       debugPrint('📥 [updateProfile] body: ${res.body}');

//       if (res.statusCode == 200) {
//         // Parse updated data from response
//         try {
//           final body = jsonDecode(res.body);
//           final data =
//               (body is Map && body['data'] != null) ? body['data'] : body;
//           if (data is Map<String, dynamic>) {
//             final updated = ProfileModel.fromJson(data);
//             profile.value = updated;
//             _populateForm(updated);
//           }
//         } catch (_) {
//           // If response doesn't have data, update locally
//           profile.value = profile.value!.copyWith(
//             phone: phoneCtrl.text.trim(),
//             address: addressCtrl.text.trim(),
//             department: departmentCtrl.text.trim(),
//             designation: designationCtrl.text.trim(),
//             emergencyContact: emergencyContactCtrl.text.trim(),
//             dateOfBirth: _selectedDob != null
//                 ? DateFormat('dd-MMM-yyyy').format(_selectedDob!)
//                 : null,
//           );
//         }

//         // ✅ Clear pending photo after successful save
//         pendingPhoto.value = null;
//         _showSuccess('Profile updated successfully');
//         return true;
//       }

//       _showError(_parseError(res.body));
//       return false;
//     } on SocketException {
//       _showError('No internet connection');
//       return false;
//     } catch (e) {
//       debugPrint('❌ [updateProfile] exception: $e');
//       _showError('Failed to update profile: $e');
//       return false;
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   // ── POST /api/Profile/changepassword ─────
//   Future<bool> changePassword() async {
//     final current = currentPasswordCtrl.text.trim();
//     final newPass = newPasswordCtrl.text.trim();
//     final confirm = confirmPasswordCtrl.text.trim();

//     if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
//       _showError('All password fields are required');
//       return false;
//     }
//     if (newPass.length < 6) {
//       _showError('New password must be at least 6 characters');
//       return false;
//     }
//     if (newPass != confirm) {
//       _showError('Passwords do not match');
//       return false;
//     }

//     try {
//       isChangingPassword.value = true;

//       final body = jsonEncode({
//         'currentPassword': current,
//         'newPassword': newPass,
//         'confirmPassword': confirm,
//       });

//       debugPrint('🌐 [changePassword] url: ${_uri('/Profile/changepassword')}');

//       final res = await http
//           .post(
//             _uri('/Profile/changepassword'),
//             headers: {
//               ..._authHeader,
//               'Content-Type': 'application/json',
//             },
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

//       debugPrint('📥 [changePassword] status: ${res.statusCode}');
//       debugPrint('📥 [changePassword] body: ${res.body}');

//       if (res.statusCode == 200) {
//         currentPasswordCtrl.clear();
//         newPasswordCtrl.clear();
//         confirmPasswordCtrl.clear();
//         _showSuccess('Password changed successfully');
//         return true;
//       }

//       _showError(_parseError(res.body));
//       return false;
//     } on SocketException {
//       _showError('No internet connection');
//       return false;
//     } catch (e) {
//       debugPrint('❌ [changePassword] exception: $e');
//       _showError('Failed to change password: $e');
//       return false;
//     } finally {
//       isChangingPassword.value = false;
//     }
//   }

//   // ── Pick photo (stores locally, sends with profile save) ──
//   // ✅ FIX: Photo is attached to multipart PUT, not separate endpoint
//   Future<void> pickAndUploadPhoto() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(
//         source: ImageSource.gallery, imageQuality: 70);
//     if (picked == null) return;

//     // Store pending photo — will be sent on next "Save Changes"
//     pendingPhoto.value = picked;

//     // ✅ Web fix: read bytes for preview (Image.file not supported on web)
//     if (kIsWeb) {
//       final bytes = await picked.readAsBytes();
//       pendingPhotoBytes.value = bytes;
//     }

//     // ✅ Show local preview immediately
//     profile.value = profile.value?.copyWith(
//       photoUrl: picked.path, // local path for preview (mobile only)
//     );

//     _showSuccess('Photo selected! Tap "Save Changes" to upload.');
//   }

//   // ── DELETE /api/Profile/photo ────────────
//   Future<void> deletePhoto() async {
//     try {
//       isUploading.value = true;
//       final res = await http
//           .delete(_uri('/Profile/photo'), headers: {
//             ..._authHeader,
//             'Content-Type': 'application/json',
//           })
//           .timeout(const Duration(milliseconds: AppConstants.receiveTimeout));

//       debugPrint('📥 [deletePhoto] status: ${res.statusCode}');

//       if (res.statusCode == 200) {
//         pendingPhoto.value = null;
//         profile.value = profile.value?.copyWith(photoUrl: '');
//         _showSuccess('Photo removed');
//       } else {
//         _showError(_parseError(res.body));
//       }
//     } on SocketException {
//       _showError('No internet connection');
//     } catch (e) {
//       debugPrint('❌ [deletePhoto] exception: $e');
//       _showError('Failed to remove photo');
//     } finally {
//       isUploading.value = false;
//     }
//   }

//   // ── Error parsing ─────────────────────────
//   String _parseError(String body) {
//     try {
//       final data = jsonDecode(body);
//       if (data is Map) {
//         return (data['message'] ??
//                 data['error'] ??
//                 data['msg'] ??
//                 data['title'] ??
//                 'Server error')
//             .toString();
//       }
//     } catch (_) {}
//     return body.isNotEmpty ? body : 'Server error';
//   }

//   void _showSuccess(String msg) {
//     Get.snackbar(
//       'Success', msg,
//       backgroundColor: const Color(0xFF4CAF50),
//       colorText: Colors.white,
//       icon: const Icon(Icons.check_circle_outline, color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }

//   void _showError(String msg) {
//     Get.snackbar(
//       'Error', msg,
//       backgroundColor: const Color(0xFFF44336),
//       colorText: Colors.white,
//       icon: const Icon(Icons.error_outline, color: Colors.white),
//       snackPosition: SnackPosition.BOTTOM,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }
// }









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

class ProfileController extends GetxController {
  // ── Observables ──────────────────────────
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;
  final isUploading = false.obs;
  final isSaving = false.obs;
  final isChangingPassword = false.obs;

  // ✅ Pending photo — selected but not yet sent (sent with profile save)
  final pendingPhoto = Rxn<XFile>();
  // ✅ Web: store bytes for preview (Image.file not supported on web)
  final pendingPhotoBytes = Rxn<Uint8List>();

  // ── Form Controllers ──────────────────────
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  // ── Internal DOB value (ISO format for API) ───
  DateTime? _selectedDob;

  // ── Password Form ─────────────────────────
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
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
    phoneCtrl.text = p.phone ?? '';
    addressCtrl.text = p.address ?? '';
    departmentCtrl.text = p.department ?? '';
    designationCtrl.text = p.designation ?? '';
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
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 25);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10),
      helpText: 'SELECT DATE OF BIRTH',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1976D2),
            onPrimary: Colors.white,
            surface: Colors.white,
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

  // ── PUT /api/Profile (multipart/form-data) ──────────
  Future<bool> updateProfile() async {
    if (profile.value == null) return false;
    try {
      isSaving.value = true;

      final request =
          http.MultipartRequest('PUT', _uri('/Profile'))
            ..headers.addAll(_authHeader);

      void addField(String key, String value) {
        if (value.isNotEmpty) request.fields[key] = value;
      }

      addField('Phone', phoneCtrl.text.trim());
      addField('Department', departmentCtrl.text.trim());
      addField('Designation', designationCtrl.text.trim());
      addField('Address', addressCtrl.text.trim());
      addField('EmergencyContact', emergencyContactCtrl.text.trim());

      if (_selectedDob != null) {
        request.fields['DateOfBirth'] =
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDob!);
      }

      if (pendingPhoto.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'ProfilePhoto',
          pendingPhoto.value!.path,
          filename: 'photo.jpg',
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
        } catch (_) {
          profile.value = profile.value!.copyWith(
            phone: phoneCtrl.text.trim(),
            address: addressCtrl.text.trim(),
            department: departmentCtrl.text.trim(),
            designation: designationCtrl.text.trim(),
            emergencyContact: emergencyContactCtrl.text.trim(),
            dateOfBirth: _selectedDob != null
                ? DateFormat('dd-MMM-yyyy').format(_selectedDob!)
                : null,
          );
        }

        pendingPhoto.value = null;
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
      _showError('Failed to update profile: $e');
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

      final body = jsonEncode({
        'currentPassword': current,
        'newPassword': newPass,
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
        _showSuccess('Password changed successfully');
        return true;
      }

      _showError(_parseError(res.body));
      return false;
    } on SocketException {
      _showError('No internet connection');
      return false;
    } catch (e) {
      debugPrint('❌ [changePassword] exception: $e');
      _showError('Failed to change password: $e');
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ── Pick photo ────────────────────────────
  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    pendingPhoto.value = picked;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      pendingPhotoBytes.value = bytes;
    }

    profile.value = profile.value?.copyWith(
      photoUrl: picked.path,
    );

    _showSuccess('Photo selected! Tap "Save Changes" to upload.');
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

  // ✅ FIX: SnackPosition.TOP (was BOTTOM)
  void _showSuccess(String msg) {
    Get.snackbar(
      'Success', msg,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  // ✅ FIX: SnackPosition.TOP (was BOTTOM)
  void _showError(String msg) {
    Get.snackbar(
      'Error', msg,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}