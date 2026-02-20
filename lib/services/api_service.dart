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






// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   // ✅ Returns full RoleModel list (with roleId + roleName)
//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   // ✅ Kept for backward compatibility
//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

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
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }









// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   /// User ka saved biometric device token fetch karta hai
//   /// Returns: { "inbiometric": "device_id", "outbiometric": "device_id" }
//   /// Dono null ho sakte hain agar pehle register nahi kiya
//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         // Response format: { "success": true, "data": { "inbiometric": "...", "outbiometric": "..." } }
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         // Direct format: { "inbiometric": "...", "outbiometric": "..." }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   /// Fingerprint registration ke baad device token DB mein save karta hai
//   /// [userId] — current logged in user ka ID
//   /// [type]   — 'in' (Check In ke liye) ya 'out' (Check Out ke liye)
//   /// [token]  — device_info_plus se mila device unique ID
//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       // DB column name decide karo type se
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow; // AuthController snackbar ke liye
//     }
//   }

//   /// ADMIN ONLY — specific user ka device clear karta hai
//   /// Server 2 kaam karta hai:
//   ///   1. inbiometric = NULL, outbiometric = NULL for [targetUserId]
//   ///   2. Us user ka auth token / session invalidate karta hai
//   ///      → Us phone mein DeviceSessionService ki polling "unauthorized" detect
//   ///        karti hai → auto logout ho jaata hai
//   ///
//   /// Backend endpoint: POST /admin/clear-biometrics
//   /// Request body: { "userId": targetUserId }
//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   /// Aaj ka attendance status fetch karta hai (Check In / Out times)
//   /// Returns: { "checkIn": "09:15 AM", "checkOut": "06:30 PM" }
//   /// checkIn ya checkOut null = abhi tak nahi kiya
//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     required File selfieImage,
//     required String biometricData, // ✅ NEW
//   }) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress;
//     request.fields['biometricData']   = biometricData; // ✅ NEW
//     request.files.add(
//       await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//     );

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     required File selfieImage,
//     required String biometricData, // ✅ NEW
//   }) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';
//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress;
//     request.fields['biometricData']   = biometricData; // ✅ NEW
//     request.files.add(
//       await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//     );

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

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
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }








// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow;
//     }
//   }

//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   /// ✅ UPDATED:
//   /// - name + userId send
//   /// - selfie optional (File?)
//   /// - locationAddress should be ONLY address text
//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress, // ✅ ONLY address
//     File? selfieImage,               // ✅ optional
//     required String biometricData,
//     required int userId,             // ✅ NEW
//     required String name,            // ✅ NEW
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();

//     // ✅ only address (never Lat/Lng)
//     request.fields['locationAddress'] = locationAddress.trim();

//     request.fields['biometricData'] = biometricData;

//     // ✅ send name & userid so DB name not null
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = name;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     return jsonDecode(response.body);
//   }

//   /// ✅ UPDATED:
//   /// - name + userId send
//   /// - selfie optional
//   /// - locationAddress ONLY address
//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress, // ✅ ONLY address
//     File? selfieImage,               // ✅ optional
//     required String biometricData,
//     required int userId,             // ✅ NEW
//     required String name,            // ✅ NEW
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();

//     // ✅ only address (never Lat/Lng)
//     request.fields['locationAddress'] = locationAddress.trim();

//     request.fields['biometricData'] = biometricData;

//     // ✅ send name & userid
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = name;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

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
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }










// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow;
//     }
//   }

//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   /// ✅ FINAL UPDATED:
//   /// - controller uses userName + userId
//   /// - backend expects name field => we send name=userName
//   /// - selfie optional
//   /// - locationAddress ONLY address
//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName, // ✅ FIXED (was name)
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;

//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName; // ✅ backend field name = "name"

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   /// ✅ FINAL UPDATED
//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName, // ✅ FIXED (was name)
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;

//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

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
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }








// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow;
//     }
//   }

//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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

//   // =================== ADMIN SUMMARY ===================

//   // ✅ "all" ho to sab roles ki parallel calls — backend role required hai
//   static Future<List<AttendanceRecord>> getAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role == 'all' && allRoles != null && allRoles.isNotEmpty) {
//       // ✅ 'all' ko exclude karo — sirf actual roles chahiye
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       debugPrint('getAdminSummary ALL roles: $actualRoles');

//       // ✅ Sab roles ke liye parallel calls
//       final futures = actualRoles.map((r) => _fetchSummaryForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);

//       // ✅ Sab results merge karo
//       final merged = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     // ✅ Single role — normal call
//     return _fetchSummaryForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   // ✅ Helper — ek role ke liye API call
//   static Future<List<AttendanceRecord>> _fetchSummaryForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((a) => AttendanceRecord.fromJson(a))
//           .toList();
//     }
//     return [];
//   }

//   // =================== EXPORT PDF ===================

//   // ✅ "all" ho to sab roles ke liye parallel export calls
//   static Future<bool> exportAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role.isEmpty && allRoles != null && allRoles.isNotEmpty) {
//       // ✅ "all" case — sab roles ke liye parallel export
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       final futures = actualRoles.map((r) => _exportForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     // ✅ Single role
//     return _exportForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   // ✅ Helper — ek role ke liye export call
//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate': toDate,
//     };

//     if (role.isNotEmpty) {
//       body['role'] = role;
//     }

//     debugPrint('exportAdminSummary body [$role]: $body');

//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
//           headers: _authHeaders,
//           body: jsonEncode(body),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('exportAdminSummary [$role] status: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }











// // lib/services/api_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import '../models/holiday_model.dart'; // HolidayModel
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow;
//     }
//   }

//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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

//   // =================== HOLIDAYS =================== ← NEW

//   static Future<List<HolidayModel>> getHolidays() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.holidayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getHolidays status: ${response.statusCode}');
//       debugPrint('getHolidays body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Handle both array response and { data: [...] } response
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else if (data['holidays'] != null) {
//           list = data['holidays'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => HolidayModel.fromJson(e)).toList();
//       }
//       throw Exception('Status ${response.statusCode}');
//     } catch (e) {
//       debugPrint('getHolidays error: $e');
//       rethrow;
//     }
//   }

//   // =================== ADMIN SUMMARY ===================

//   static Future<List<AttendanceRecord>> getAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role == 'all' && allRoles != null && allRoles.isNotEmpty) {
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       debugPrint('getAdminSummary ALL roles: $actualRoles');

//       final futures = actualRoles.map((r) => _fetchSummaryForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   static Future<List<AttendanceRecord>> _fetchSummaryForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((a) => AttendanceRecord.fromJson(a))
//           .toList();
//     }
//     return [];
//   }

//   // =================== EXPORT PDF ===================

//   static Future<bool> exportAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role.isEmpty && allRoles != null && allRoles.isNotEmpty) {
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       final futures = actualRoles.map((r) => _exportForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate': toDate,
//     };

//     if (role.isNotEmpty) {
//       body['role'] = role;
//     }

//     debugPrint('exportAdminSummary body [$role]: $body');

//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
//           headers: _authHeaders,
//           body: jsonEncode(body),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('exportAdminSummary [$role] status: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }








// // lib/services/api_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../models/models.dart';
// import '../models/holiday_model.dart'; // ✅ SAHI IMPORT
// import 'storage_service.dart';

// class ApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _headers => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   static Map<String, String> get _authHeaders => {
//         ..._headers,
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // =================== ROLES ===================

//   static Future<List<RoleModel>> getRoleModels() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.getRolesEndpoint}'),
//             headers: _headers,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('Roles RAW: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return (data['data'] as List)
//               .map((e) => RoleModel.fromJson(e))
//               .where((r) => r.roleName.isNotEmpty)
//               .toList();
//         }
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoleModels error: $e');
//       return [];
//     }
//   }

//   static Future<List<String>> getRoles() async {
//     final models = await getRoleModels();
//     if (models.isNotEmpty) {
//       return models.map((r) => r.roleName.toLowerCase()).toList();
//     }
//     return AppConstants.allRoles;
//   }

//   // =================== AUTH ===================

//   static Future<ApiResponse> register(RegisterRequest request) async {
//     try {
//       final url = '$_base${AppConstants.registerEndpoint}';
//       final body = jsonEncode(request.toJson());

//       debugPrint('=== REGISTER API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _headers,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('STATUS CODE  : ${response.statusCode}');
//       debugPrint('RAW RESPONSE : ${response.body}');
//       debugPrint('=========================');

//       final data = jsonDecode(response.body);

//       return ApiResponse(
//         success: data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('Register Exception: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//   // =================== BIOMETRIC ===================

//   static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserBiometric status: ${response.statusCode}');
//       debugPrint('getUserBiometric body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getUserBiometric error: $e');
//       return null;
//     }
//   }

//   static Future<void> saveBiometricToken({
//     required int userId,
//     required String type,
//     required String token,
//   }) async {
//     try {
//       final field = type == 'in' ? 'inbiometric' : 'outbiometric';

//       final response = await http
//           .patch(
//             Uri.parse('$_base/users/$userId/biometric'),
//             headers: _authHeaders,
//             body: jsonEncode({field: token}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
//       debugPrint('saveBiometricToken body              : ${response.body}');

//       if (response.statusCode != 200) {
//         throw Exception(
//           'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('saveBiometricToken error: $e');
//       rethrow;
//     }
//   }

//   static Future<void> clearUserBiometric(int targetUserId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('$_base/admin/clear-biometrics'),
//             headers: _authHeaders,
//             body: jsonEncode({'userId': targetUserId}),
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
//       debugPrint('clearUserBiometric body              : ${response.body}');

//       if (response.statusCode != 200) {
//         final msg = _parseErrorMessage(response.body);
//         throw Exception(msg.isNotEmpty
//             ? msg
//             : 'Clear failed. Check if User ID is correct.');
//       }
//     } catch (e) {
//       debugPrint('clearUserBiometric error: $e');
//       rethrow;
//     }
//   }

//   static String _parseErrorMessage(String body) {
//     try {
//       final data = jsonDecode(body);
//       return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
//     } catch (_) {
//       return '';
//     }
//   }

//   static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
//     try {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final uri = Uri.parse(
//         '$_base/attendance/$userId/today',
//       ).replace(queryParameters: {'date': today});

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayAttendance status: ${response.statusCode}');
//       debugPrint('getTodayAttendance body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           return data['data'] as Map<String, dynamic>;
//         }
//         return data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getTodayAttendance error: $e');
//       return null;
//     }
//   }

//   // =================== ATTENDANCE ===================

//   static Future<Map<String, dynamic>> markIn({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);
//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File? selfieImage,
//     required String biometricData,
//     required int userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate'] = attendanceDate;
//     request.fields['latitude'] = latitude.toString();
//     request.fields['longitude'] = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData'] = biometricData;
//     request.fields['userId'] = userId.toString();
//     request.fields['name'] = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
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

//   // =================== HOLIDAYS ===================

//   static Future<List<HolidayModel>> getHolidays() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.holidayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getHolidays status: ${response.statusCode}');
//       debugPrint('getHolidays body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else if (data['holidays'] != null) {
//           list = data['holidays'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => HolidayModel.fromJson(e)).toList();
//       }
//       throw Exception('Status ${response.statusCode}');
//     } catch (e) {
//       debugPrint('getHolidays error: $e');
//       rethrow;
//     }
//   }

//   // =================== ADMIN SUMMARY ===================

//   static Future<List<AttendanceRecord>> getAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role == 'all' && allRoles != null && allRoles.isNotEmpty) {
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       debugPrint('getAdminSummary ALL roles: $actualRoles');

//       final futures = actualRoles.map((r) => _fetchSummaryForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   static Future<List<AttendanceRecord>> _fetchSummaryForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final uri =
//         Uri.parse('$_base${AppConstants.adminSummaryEndpoint}').replace(
//       queryParameters: {
//         'role': role,
//         'fromDate': fromDate,
//         'toDate': toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((a) => AttendanceRecord.fromJson(a))
//           .toList();
//     }
//     return [];
//   }

//   // =================== EXPORT PDF ===================

//   static Future<bool> exportAdminSummary({
//     required String role,
//     required String fromDate,
//     required String toDate,
//     List<String>? allRoles,
//   }) async {
//     if (role.isEmpty && allRoles != null && allRoles.isNotEmpty) {
//       final actualRoles = allRoles.where((r) => r != 'all').toList();

//       final futures = actualRoles.map((r) => _exportForRole(
//             role: r,
//             fromDate: fromDate,
//             toDate: toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role: role,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate': toDate,
//     };

//     if (role.isNotEmpty) {
//       body['role'] = role;
//     }

//     debugPrint('exportAdminSummary body [$role]: $body');

//     final response = await http
//         .post(
//           Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
//           headers: _authHeaders,
//           body: jsonEncode(body),
//         )
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('exportAdminSummary [$role] status: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }
// }











// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/models.dart';
import '../models/holiday_model.dart';
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

  // =================== CLEAR DEVICE (Admin) ===================

  static Future<ApiResponse> clearUserDevice(int userId) async {
    try {
      final url = '$_base/Auth/cleardevice';
      final body = jsonEncode({'userId': userId});

      debugPrint('=== CLEAR DEVICE API CALL ===');
      debugPrint('URL  : $url');
      debugPrint('BODY : $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('clearUserDevice STATUS: ${response.statusCode}');
      debugPrint('clearUserDevice BODY  : ${response.body}');
      debugPrint('=============================');

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 && data['success'] == true,
        message:
            (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
        data: data['data'],
      );
    } catch (e) {
      debugPrint('clearUserDevice error: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // =================== BIOMETRIC ===================

  static Future<Map<String, dynamic>?> getUserBiometric(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base/users/$userId/biometric'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getUserBiometric status: ${response.statusCode}');
      debugPrint('getUserBiometric body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('getUserBiometric error: $e');
      return null;
    }
  }

  static Future<void> saveBiometricToken({
    required int userId,
    required String type,
    required String token,
  }) async {
    try {
      final field = type == 'in' ? 'inbiometric' : 'outbiometric';

      final response = await http
          .patch(
            Uri.parse('$_base/users/$userId/biometric'),
            headers: _authHeaders,
            body: jsonEncode({field: token}),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('saveBiometricToken [$field] status: ${response.statusCode}');
      debugPrint('saveBiometricToken body              : ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'saveBiometricToken failed — status: ${response.statusCode} | body: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('saveBiometricToken error: $e');
      rethrow;
    }
  }

  static Future<void> clearUserBiometric(int targetUserId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base/admin/clear-biometrics'),
            headers: _authHeaders,
            body: jsonEncode({'userId': targetUserId}),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint(
          'clearUserBiometric [$targetUserId] status: ${response.statusCode}');
      debugPrint('clearUserBiometric body              : ${response.body}');

      if (response.statusCode != 200) {
        final msg = _parseErrorMessage(response.body);
        throw Exception(msg.isNotEmpty
            ? msg
            : 'Clear failed. Check if User ID is correct.');
      }
    } catch (e) {
      debugPrint('clearUserBiometric error: $e');
      rethrow;
    }
  }

  static String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      return (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static Future<Map<String, dynamic>?> getTodayAttendance(int userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final uri = Uri.parse(
        '$_base/attendance/$userId/today',
      ).replace(queryParameters: {'date': today});

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getTodayAttendance status: ${response.statusCode}');
      debugPrint('getTodayAttendance body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('getTodayAttendance error: $e');
      return null;
    }
  }

  // =================== ATTENDANCE ===================

  static Future<Map<String, dynamic>> markIn({
    required String attendanceDate,
    required double latitude,
    required double longitude,
    required String locationAddress,
    File? selfieImage,
    required String biometricData,
    required int userId,
    required String userName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markInEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

    request.fields['attendanceDate'] = attendanceDate;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['locationAddress'] = locationAddress.trim();
    request.fields['biometricData'] = biometricData;
    request.fields['userId'] = userId.toString();
    request.fields['name'] = userName;

    if (selfieImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
      );
    }

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
    File? selfieImage,
    required String biometricData,
    required int userId,
    required String userName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markOutEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

    request.fields['attendanceDate'] = attendanceDate;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['locationAddress'] = locationAddress.trim();
    request.fields['biometricData'] = biometricData;
    request.fields['userId'] = userId.toString();
    request.fields['name'] = userName;

    if (selfieImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
      );
    }

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

  // =================== HOLIDAYS ===================

  static Future<List<HolidayModel>> getHolidays() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.holidayEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getHolidays status: ${response.statusCode}');
      debugPrint('getHolidays body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else if (data['holidays'] != null) {
          list = data['holidays'] as List;
        } else {
          list = [];
        }

        return list.map((e) => HolidayModel.fromJson(e)).toList();
      }
      throw Exception('Status ${response.statusCode}');
    } catch (e) {
      debugPrint('getHolidays error: $e');
      rethrow;
    }
  }

  // =================== ADMIN SUMMARY ===================

  static Future<List<AttendanceRecord>> getAdminSummary({
    required String role,
    required String fromDate,
    required String toDate,
    List<String>? allRoles,
  }) async {
    if (role == 'all' && allRoles != null && allRoles.isNotEmpty) {
      final actualRoles = allRoles.where((r) => r != 'all').toList();

      debugPrint('getAdminSummary ALL roles: $actualRoles');

      final futures = actualRoles.map((r) => _fetchSummaryForRole(
            role: r,
            fromDate: fromDate,
            toDate: toDate,
          ));

      final results = await Future.wait(futures);
      final merged = results.expand((list) => list).toList();
      debugPrint('getAdminSummary ALL: ${merged.length} total records');
      return merged;
    }

    return _fetchSummaryForRole(
      role: role,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  static Future<List<AttendanceRecord>> _fetchSummaryForRole({
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

    debugPrint('getAdminSummary URI [$role]: $uri');

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
    debugPrint('getAdminSummary [$role] body  : ${response.body}');

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      return (data['data'] as List)
          .map((a) => AttendanceRecord.fromJson(a))
          .toList();
    }
    return [];
  }

  // =================== EXPORT PDF ===================

  static Future<bool> exportAdminSummary({
    required String role,
    required String fromDate,
    required String toDate,
    List<String>? allRoles,
  }) async {
    if (role.isEmpty && allRoles != null && allRoles.isNotEmpty) {
      final actualRoles = allRoles.where((r) => r != 'all').toList();

      final futures = actualRoles.map((r) => _exportForRole(
            role: r,
            fromDate: fromDate,
            toDate: toDate,
          ));

      final results = await Future.wait(futures);
      return results.any((success) => success);
    }

    return _exportForRole(
      role: role,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  static Future<bool> _exportForRole({
    required String role,
    required String fromDate,
    required String toDate,
  }) async {
    final Map<String, dynamic> body = {
      'fromDate': fromDate,
      'toDate': toDate,
    };

    if (role.isNotEmpty) {
      body['role'] = role;
    }

    debugPrint('exportAdminSummary body [$role]: $body');

    final response = await http
        .post(
          Uri.parse('$_base${AppConstants.exportAdminSummaryEndpoint}'),
          headers: _authHeaders,
          body: jsonEncode(body),
        )
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    debugPrint('exportAdminSummary [$role] status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/admin_summary_$role.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return true;
    }
    return false;
  }
}