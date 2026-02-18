// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };

//   static Map<String, String> get _authHeaders => {
//     ..._headers,
//     'Authorization': 'Bearer ${StorageService.getToken()}',
//   };

//   // =================== AUTH ===================

//   static Future<AuthResponse> register(RegisterRequest request) async {
//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.registerEndpoint}'),
//           headers: _headers,
//           body: jsonEncode(request.toJson()),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     final data = jsonDecode(response.body);
//     return AuthResponse.fromJson(data);
//   }

//   static Future<AuthResponse> login(LoginRequest request) async {
//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.loginEndpoint}'),
//           headers: _headers,
//           body: jsonEncode(request.toJson()),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     final data = jsonDecode(response.body);
//     return AuthResponse.fromJson(data);
//   }

//   static Future<bool> logout() async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.logoutEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
//       return response.statusCode == 200;
//     } catch (_) {
//       return false;
//     }
//   }

//   static Future<List<UserModel>> getAllUsers() async {
//     final response = await http
//         .get(
//           Uri.parse('$_base${AppConstants.getAllUsersEndpoint}'),
//           headers: _authHeaders,
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== ATTENDANCE ===================

//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     required File selfieImage,
//   }) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress;
//     request.files.add(
//       await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//     );

//     final streamedResponse = await request.send().timeout(
//       const Duration(milliseconds: AppConstants.connectTimeout),
//     );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     required File selfieImage,
//   }) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress;
//     request.files.add(
//       await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//     );

//     final streamedResponse = await request.send().timeout(
//       const Duration(milliseconds: AppConstants.connectTimeout),
//     );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<List<AttendanceRecord>> getUserSummary({
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final uri = Uri.parse('$_base${AppConstants.userSummaryEndpoint}')
//         .replace(queryParameters: {'fromDate': fromDate, 'toDate': toDate});

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((a) => AttendanceRecord.fromJson(a))
//           .toList();
//     }
//     return [];
//   }

//   static Future<List<AttendanceRecord>> getAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final uri = Uri.parse('$_base${AppConstants.adminSummaryEndpoint}')
//         .replace(queryParameters: {
//       'role': role,
//       'fromDate': fromDate,
//       'toDate': toDate,
//     });

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((a) => AttendanceRecord.fromJson(a))
//           .toList();
//     }
//     return [];
//   }

//   static Future<bool> exportAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
//           headers: _authHeaders,
//           body: jsonEncode({
//             'role': role,
//             'fromDate': fromDate,
//             'toDate': toDate,
//           }),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     if (response.statusCode == 200) {
//       // Save PDF to temp directory
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }






import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/models.dart';
import 'storage_service.dart';

class ApiService {
  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> get _authHeaders => {
        ..._headers,
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // =================== ROLES ===================

  // ✅ Returns full RoleModel list (with roleId + roleName)
  static Future<List<RoleModel>> getRoleModels() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
            headers: _headers,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('Roles RAW: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((e) => RoleModel.fromJson(e))
              .where((r) => r.roleName.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('getRoleModels error: $e');
      return [];
    }
  }

  // ✅ Kept for backward compatibility
  static Future<List<String>> getRoles() async {
    final models = await getRoleModels();
    if (models.isNotEmpty) {
      return models.map((r) => r.roleName.toLowerCase()).toList();
    }
    return AppConstants.allRoles;
  }

  // =================== AUTH ===================

  static Future<ApiResponse> register(RegisterRequest request) async {
    try {
      final url = '$_base${AppConstants.registerEndpoint}';
      final body = jsonEncode(request.toJson());

      debugPrint('=== REGISTER API CALL ===');
      debugPrint('URL  : $url');
      debugPrint('BODY : $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('STATUS CODE  : ${response.statusCode}');
      debugPrint('RAW RESPONSE : ${response.body}');
      debugPrint('=========================');

      final data = jsonDecode(response.body);

      return ApiResponse(
        success: data['success'] == true,
        message:
            (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
        data: data['data'],
      );
    } catch (e) {
      debugPrint('Register Exception: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await http
        .post(
          Uri.parse('$_base${AppConstants.loginEndpoint}'),
          headers: _headers,
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    final data = jsonDecode(response.body);
    return AuthResponse.fromJson(data);
  }

  static Future<bool> logout() async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.logoutEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    final response = await http
        .get(
          Uri.parse('$_base${AppConstants.getAllUsersEndpoint}'),
          headers: _authHeaders,
        )
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List)
          .map((u) => UserModel.fromJson(u))
          .toList();
    }
    return [];
  }

  // =================== ATTENDANCE ===================

  static Future<Map<String, dynamic>> markIn({
    required String attendanceDate,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required File selfieImage,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markInEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
    request.fields['attendanceDate'] = attendanceDate;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['locationAddress'] = locationAddress;
    request.files.add(
      await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
    );

    final streamedResponse = await request.send().timeout(
          const Duration(milliseconds: AppConstants.connectTimeout),
        );
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markOut({
    required String attendanceDate,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required File selfieImage,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markOutEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
    request.fields['attendanceDate'] = attendanceDate;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['locationAddress'] = locationAddress;
    request.files.add(
      await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
    );

    final streamedResponse = await request.send().timeout(
          const Duration(milliseconds: AppConstants.connectTimeout),
        );
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<List<AttendanceRecord>> getUserSummary({
    required String fromDate,
    required String toDate,
  }) async {
    final uri = Uri.parse('$_base${AppConstants.userSummaryEndpoint}')
        .replace(queryParameters: {'fromDate': fromDate, 'toDate': toDate});

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List)
          .map((a) => AttendanceRecord.fromJson(a))
          .toList();
    }
    return [];
  }

  static Future<List<AttendanceRecord>> getAdminSummary({
    required String role,
    required String fromDate,
    required String toDate,
  }) async {
    final uri =
        Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
      queryParameters: {
        'role': role,
        'fromDate': fromDate,
        'toDate': toDate,
      },
    );

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List)
          .map((a) => AttendanceRecord.fromJson(a))
          .toList();
    }
    return [];
  }

  static Future<bool> exportAdminSummary({
    required String role,
    required String fromDate,
    required String toDate,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
          headers: _authHeaders,
          body: jsonEncode({
            'role': role,
            'fromDate': fromDate,
            'toDate': toDate,
          }),
        )
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    if (response.statusCode == 200) {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/admin_summary.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return true;
    }
    return false;
  }
}