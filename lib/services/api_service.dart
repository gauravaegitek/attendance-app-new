// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/holiday_model.dart';
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart'; // ✅ ADD
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     request.fields['latitude']       = latitude.toString();
//     request.fields['longitude']      = longitude.toString();
//     request.fields['locationAddress']= locationAddress.trim();
//     request.fields['biometricData']  = biometricData;
//     request.fields['userId']         = userId.toString();
//     request.fields['name']           = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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
//     request.fields['latitude']       = latitude.toString();
//     request.fields['longitude']      = longitude.toString();
//     request.fields['locationAddress']= locationAddress.trim();
//     request.fields['biometricData']  = biometricData;
//     request.fields['userId']         = userId.toString();
//     request.fields['name']           = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//       final merged  = results.expand((list) => list).toList();
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int) return data;
//         if (data['count'] != null) return data['count'] as int;
//         if (data['data']  != null) return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> sendNotification({
//     required int userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // Admin only
//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE — FILE KI LAST LINE









// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/holiday_model.dart';
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // Admin only
//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}'); // ✅ body log
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE








// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/holiday_model.dart';
// import '../models/leave_model.dart';            // ✅ ADD
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // Admin only
//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   // Admin only
//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== LEAVE ===================          // ✅ ADD

//   // User: Apply for leave
//   static Future<ApiResponse> applyLeave({
//     required String leaveType,
//     required String fromDate,
//     required String toDate,
//     required String reason,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'leaveType': leaveType,
//         'fromDate':  fromDate,
//         'toDate':    toDate,
//         'reason':    reason,
//       });

//       debugPrint('applyLeave body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('applyLeave status: ${response.statusCode}');
//       debugPrint('applyLeave body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('applyLeave error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // User: Get my leaves
//   static Future<List<LeaveModel>> getMyLeaves({
//     String? status,
//     int?    year,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status != null && status.isNotEmpty) params['status'] = status;
//       if (year   != null) params['year'] = year.toString();

//       final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLeaves status: ${response.statusCode}');
//       debugPrint('getMyLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLeaves error: $e');
//       return [];
//     }
//   }

//   // User: Cancel leave
//   static Future<bool> cancelLeave(int leaveId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
//       debugPrint('cancelLeave body             : ${response.body}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('cancelLeave error: $e');
//       return false;
//     }
//   }

//   // Admin: Get all leaves
//   static Future<List<LeaveModel>> getAllLeaves({
//     String? status,
//     int?    userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status   != null && status.isNotEmpty)   params['status']   = status;
//       if (userId   != null)                         params['userId']   = userId.toString();
//       if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

//       final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllLeaves status: ${response.statusCode}');
//       debugPrint('getAllLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllLeaves error: $e');
//       return [];
//     }
//   }

//   // Admin: Approve / Reject leave
//   static Future<ApiResponse> leaveAction({
//     required int    leaveId,
//     required String status,
//     String?         adminRemark,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'status':      status,
//         'adminRemark': adminRemark ?? '',
//       });

//       debugPrint('leaveAction [$leaveId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
//       debugPrint('leaveAction [$leaveId] body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('leaveAction error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE











// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/daily_task_model.dart';         // ✅ ADD
// import '../models/holiday_model.dart';
// import '../models/leave_model.dart';
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== LEAVE ===================

//   static Future<ApiResponse> applyLeave({
//     required String leaveType,
//     required String fromDate,
//     required String toDate,
//     required String reason,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'leaveType': leaveType,
//         'fromDate':  fromDate,
//         'toDate':    toDate,
//         'reason':    reason,
//       });

//       debugPrint('applyLeave body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('applyLeave status: ${response.statusCode}');
//       debugPrint('applyLeave body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('applyLeave error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<LeaveModel>> getMyLeaves({
//     String? status,
//     int?    year,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status != null && status.isNotEmpty) params['status'] = status;
//       if (year   != null) params['year'] = year.toString();

//       final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLeaves status: ${response.statusCode}');
//       debugPrint('getMyLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<bool> cancelLeave(int leaveId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
//       debugPrint('cancelLeave body             : ${response.body}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('cancelLeave error: $e');
//       return false;
//     }
//   }

//   static Future<List<LeaveModel>> getAllLeaves({
//     String? status,
//     int?    userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status   != null && status.isNotEmpty)   params['status']   = status;
//       if (userId   != null)                         params['userId']   = userId.toString();
//       if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

//       final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllLeaves status: ${response.statusCode}');
//       debugPrint('getAllLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> leaveAction({
//     required int    leaveId,
//     required String status,
//     String?         adminRemark,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'status':      status,
//         'adminRemark': adminRemark ?? '',
//       });

//       debugPrint('leaveAction [$leaveId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
//       debugPrint('leaveAction [$leaveId] body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('leaveAction error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== DAILY TASK ===================         // ✅ ADD

//   // User: Add daily task
//   static Future<ApiResponse> addDailyTask({
//     required String taskDate,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskDate':        taskDate,
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('addDailyTask body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.dailyTaskAddEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDailyTask status: ${response.statusCode}');
//       debugPrint('addDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // User: Update daily task
//   static Future<ApiResponse> updateDailyTask({
//     required int    taskId,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('updateDailyTask [$taskId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskUpdateEndpoint}/$taskId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('updateDailyTask status: ${response.statusCode}');
//       debugPrint('updateDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('updateDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // User: Delete daily task
//   static Future<bool> deleteDailyTask(int taskId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskDeleteEndpoint}/$taskId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('deleteDailyTask [$taskId] status: ${response.statusCode}');
//       _checkSession(response);
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('deleteDailyTask error: $e');
//       return false;
//     }
//   }

//   // User: Get my tasks
//   static Future<List<DailyTaskModel>> getMyTasks({
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasks status: ${response.statusCode}');
//       debugPrint('getMyTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasks error: $e');
//       return [];
//     }
//   }

//   // User: Get my today tasks
//   static Future<List<DailyTaskModel>> getMyTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskMyTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasksToday status: ${response.statusCode}');
//       debugPrint('getMyTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasksToday error: $e');
//       return [];
//     }
//   }

//   // Admin: Get all tasks
//   static Future<List<DailyTaskModel>> getAllTasks({
//     int?    userId,
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (userId   != null)                        params['userId']   = userId.toString();
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasks status: ${response.statusCode}');
//       debugPrint('getAllTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasks error: $e');
//       return [];
//     }
//   }

//   // Admin: Get all today tasks
//   static Future<List<DailyTaskModel>> getAllTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskAllTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasksToday status: ${response.statusCode}');
//       debugPrint('getAllTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasksToday error: $e');
//       return [];
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE











// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/daily_task_model.dart';
// import '../models/holiday_model.dart';
// import '../models/leave_model.dart';
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== LEAVE ===================

//   static Future<ApiResponse> applyLeave({
//     required String leaveType,
//     required String fromDate,
//     required String toDate,
//     required String reason,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'leaveType': leaveType,
//         'fromDate':  fromDate,
//         'toDate':    toDate,
//         'reason':    reason,
//       });

//       debugPrint('applyLeave body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('applyLeave status: ${response.statusCode}');
//       debugPrint('applyLeave body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('applyLeave error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<LeaveModel>> getMyLeaves({
//     String? status,
//     int?    year,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status != null && status.isNotEmpty) params['status'] = status;
//       if (year   != null) params['year'] = year.toString();

//       final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLeaves status: ${response.statusCode}');
//       debugPrint('getMyLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<bool> cancelLeave(int leaveId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
//       debugPrint('cancelLeave body             : ${response.body}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('cancelLeave error: $e');
//       return false;
//     }
//   }

//   static Future<List<LeaveModel>> getAllLeaves({
//     String? status,
//     int?    userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status   != null && status.isNotEmpty)   params['status']   = status;
//       if (userId   != null)                         params['userId']   = userId.toString();
//       if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

//       final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllLeaves status: ${response.statusCode}');
//       debugPrint('getAllLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> leaveAction({
//     required int    leaveId,
//     required String status,
//     String?         adminRemark,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'status':      status,
//         'adminRemark': adminRemark ?? '',
//       });

//       debugPrint('leaveAction [$leaveId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
//       debugPrint('leaveAction [$leaveId] body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('leaveAction error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== DAILY TASK ===================

//   // User: Add daily task
//   static Future<ApiResponse> addDailyTask({
//     required String taskDate,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskDate':        taskDate,
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('addDailyTask body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.dailyTaskAddEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDailyTask status: ${response.statusCode}');
//       debugPrint('addDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // User: Update daily task
//   static Future<ApiResponse> updateDailyTask({
//     required int    taskId,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('updateDailyTask [$taskId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskUpdateEndpoint}/$taskId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('updateDailyTask status: ${response.statusCode}');
//       debugPrint('updateDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('updateDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // User: Delete daily task
//   static Future<bool> deleteDailyTask(int taskId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskDeleteEndpoint}/$taskId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('deleteDailyTask [$taskId] status: ${response.statusCode}');
//       _checkSession(response);
//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('deleteDailyTask error: $e');
//       return false;
//     }
//   }

//   // User: Get my tasks (with filters)
//   static Future<List<DailyTaskModel>> getMyTasks({
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasks status: ${response.statusCode}');
//       debugPrint('getMyTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           // nested object case — tasks inside
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasks error: $e');
//       return [];
//     }
//   }

//   // User: Get today's tasks
//   // API response: { "data": { "userId": 17, "tasks": [...] } }
//   static Future<List<DailyTaskModel>> getMyTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskMyTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasksToday status: ${response.statusCode}');
//       debugPrint('getMyTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];

//         if (data is List) {
//           // Direct array
//           list = data;
//         } else if (data['data'] is List) {
//           // data is a flat list
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           // ✅ Today's endpoint — data is object, tasks inside
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }

//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasksToday error: $e');
//       return [];
//     }
//   }

//   // Admin: Get all tasks (with filters)
//   static Future<List<DailyTaskModel>> getAllTasks({
//     int?    userId,
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (userId   != null)                        params['userId']   = userId.toString();
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasks status: ${response.statusCode}');
//       debugPrint('getAllTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasks error: $e');
//       return [];
//     }
//   }

//   // Admin: Get all today's tasks
//   static Future<List<DailyTaskModel>> getAllTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskAllTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasksToday status: ${response.statusCode}');
//       debugPrint('getAllTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasksToday error: $e');
//       return [];
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE









// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/daily_task_model.dart';
// import '../models/holiday_model.dart';
// import '../models/leave_model.dart';
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // Admin: Get all contact messages
//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   // ✅ NEW: User — Get my own contact messages
//   // GET /api/HelpSupport/contact/my-messages
//   static Future<List<ContactMessageModel>> getMyContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/my-messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyContactMessages status: ${response.statusCode}');
//       debugPrint('getMyContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyContactMessages error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== LEAVE ===================

//   static Future<ApiResponse> applyLeave({
//     required String leaveType,
//     required String fromDate,
//     required String toDate,
//     required String reason,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'leaveType': leaveType,
//         'fromDate':  fromDate,
//         'toDate':    toDate,
//         'reason':    reason,
//       });

//       debugPrint('applyLeave body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('applyLeave status: ${response.statusCode}');
//       debugPrint('applyLeave body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('applyLeave error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<LeaveModel>> getMyLeaves({
//     String? status,
//     int?    year,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status != null && status.isNotEmpty) params['status'] = status;
//       if (year   != null) params['year'] = year.toString();

//       final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLeaves status: ${response.statusCode}');
//       debugPrint('getMyLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse<void>> cancelLeave(int leaveId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
//       debugPrint('cancelLeave body             : ${response.body}');

//       _checkSession(response);

//       final data    = jsonDecode(response.body);
//       final success = response.statusCode == 200 && (data['success'] == true);
//       final message = (data['message'] ?? '').toString();
//       return ApiResponse(success: success, message: message);
//     } catch (e) {
//       debugPrint('cancelLeave error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<List<LeaveModel>> getAllLeaves({
//     String? status,
//     int?    userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status   != null && status.isNotEmpty)   params['status']   = status;
//       if (userId   != null)                         params['userId']   = userId.toString();
//       if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

//       final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllLeaves status: ${response.statusCode}');
//       debugPrint('getAllLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> leaveAction({
//     required int    leaveId,
//     required String status,
//     String?         adminRemark,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'status':      status,
//         'adminRemark': adminRemark ?? '',
//       });

//       debugPrint('leaveAction [$leaveId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
//       debugPrint('leaveAction [$leaveId] body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('leaveAction error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== DAILY TASK ===================

//   static Future<ApiResponse> addDailyTask({
//     required String taskDate,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskDate':        taskDate,
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('addDailyTask body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.dailyTaskAddEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDailyTask status: ${response.statusCode}');
//       debugPrint('addDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> updateDailyTask({
//     required int    taskId,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('updateDailyTask [$taskId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskUpdateEndpoint}/$taskId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('updateDailyTask status: ${response.statusCode}');
//       debugPrint('updateDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('updateDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse<void>> deleteDailyTask(int taskId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskDeleteEndpoint}/$taskId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('deleteDailyTask [$taskId] status: ${response.statusCode}');
//       _checkSession(response);

//       final data    = jsonDecode(response.body);
//       final success = response.statusCode == 200 && (data['success'] == true);
//       final message = (data['message'] ?? '').toString();
//       return ApiResponse(success: success, message: message);
//     } catch (e) {
//       debugPrint('deleteDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<List<DailyTaskModel>> getMyTasks({
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasks status: ${response.statusCode}');
//       debugPrint('getMyTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasks error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getMyTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskMyTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasksToday status: ${response.statusCode}');
//       debugPrint('getMyTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];

//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }

//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasksToday error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getAllTasks({
//     int?    userId,
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (userId   != null)                        params['userId']   = userId.toString();
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasks status: ${response.statusCode}');
//       debugPrint('getAllTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasks error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getAllTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskAllTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasksToday status: ${response.statusCode}');
//       debugPrint('getAllTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasksToday error: $e');
//       return [];
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE












// // lib/services/api_service.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../core/constants/app_constants.dart';
// import '../core/routes.dart';
// import '../models/models.dart';
// import '../models/daily_task_model.dart';
// import '../models/holiday_model.dart';
// import '../models/leave_model.dart';
// import '../models/login_history_model.dart';   // ✅ NEW import
// import '../models/notification_model.dart';
// import '../models/help_support_model.dart';
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

//   // =================== SESSION CHECK ===================

//   static void _checkSession(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleSessionExpired();
//       return;
//     }
//     try {
//       final data = jsonDecode(response.body);
//       if (data is Map &&
//           data['success'] == false &&
//           data['message'] == 'SESSION_EXPIRED') {
//         _handleSessionExpired();
//       }
//     } catch (_) {}
//   }

//   static void _handleSessionExpired() {
//     if (Get.currentRoute == AppRoutes.sessionExpired) return;
//     StorageService.clearAll();
//     Get.offAllNamed(AppRoutes.sessionExpired);
//   }

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
//       final url  = '$_base${AppConstants.registerEndpoint}';
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

//       _checkSession(response);
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

//     _checkSession(response);

//     final data = jsonDecode(response.body);
//     if (data['success'] == true && data['data'] != null) {
//       return (data['data'] as List)
//           .map((u) => UserModel.fromJson(u))
//           .toList();
//     }
//     return [];
//   }

//   // =================== CLEAR DEVICE (Admin) ===================

//   static Future<ApiResponse> clearUserDevice(int userId) async {
//     try {
//       final url  = '$_base/Auth/cleardevice';
//       final body = jsonEncode({'userId': userId});

//       debugPrint('=== CLEAR DEVICE API CALL ===');
//       debugPrint('URL  : $url');
//       debugPrint('BODY : $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('clearUserDevice STATUS: ${response.statusCode}');
//       debugPrint('clearUserDevice BODY  : ${response.body}');
//       debugPrint('=============================');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 && data['success'] == true,
//         message:
//             (data['message'] ?? data['msg'] ?? data['error'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('clearUserDevice error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
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

//       _checkSession(response);

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
//     required int    userId,
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

//       _checkSession(response);

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

//       _checkSession(response);

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

//       _checkSession(response);

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
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markInEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

//     return jsonDecode(response.body);
//   }

//   static Future<Map<String, dynamic>> markOut({
//     required String attendanceDate,
//     required double latitude,
//     required double longitude,
//     required String locationAddress,
//     File?   selfieImage,
//     required String biometricData,
//     required int    userId,
//     required String userName,
//   }) async {
//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$_base${AppConstants.markOutEndpoint}'),
//     );

//     request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

//     request.fields['attendanceDate']  = attendanceDate;
//     request.fields['latitude']        = latitude.toString();
//     request.fields['longitude']       = longitude.toString();
//     request.fields['locationAddress'] = locationAddress.trim();
//     request.fields['biometricData']   = biometricData;
//     request.fields['userId']          = userId.toString();
//     request.fields['name']            = userName;

//     if (selfieImage != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
//       );
//     }

//     final streamedResponse = await request.send().timeout(
//           const Duration(milliseconds: AppConstants.connectTimeout),
//         );
//     final response = await http.Response.fromStream(streamedResponse);

//     _checkSession(response);

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

//     _checkSession(response);

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

//       _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       final merged  = results.expand((list) => list).toList();
//       debugPrint('getAdminSummary ALL: ${merged.length} total records');
//       return merged;
//     }

//     return _fetchSummaryForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
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
//         'role':     role,
//         'fromDate': fromDate,
//         'toDate':   toDate,
//       },
//     );

//     debugPrint('getAdminSummary URI [$role]: $uri');

//     final response = await http
//         .get(uri, headers: _authHeaders)
//         .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//     debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
//     debugPrint('getAdminSummary [$role] body  : ${response.body}');

//     _checkSession(response);

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
//             role:     r,
//             fromDate: fromDate,
//             toDate:   toDate,
//           ));

//       final results = await Future.wait(futures);
//       return results.any((success) => success);
//     }

//     return _exportForRole(
//       role:     role,
//       fromDate: fromDate,
//       toDate:   toDate,
//     );
//   }

//   static Future<bool> _exportForRole({
//     required String role,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     final Map<String, dynamic> body = {
//       'fromDate': fromDate,
//       'toDate':   toDate,
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

//     _checkSession(response);

//     if (response.statusCode == 200) {
//       final tempDir = Directory.systemTemp;
//       final file    = File('${tempDir.path}/admin_summary_$role.pdf');
//       await file.writeAsBytes(response.bodyBytes);
//       return true;
//     }
//     return false;
//   }

//   // =================== NOTIFICATIONS ===================

//   static Future<List<NotificationModel>> getNotifications() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getNotifications status: ${response.statusCode}');
//       debugPrint('getNotifications body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }

//         return list.map((e) => NotificationModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/Notification/unread-count'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUnreadCount status: ${response.statusCode}');
//       debugPrint('getUnreadCount body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is int)              return data;
//         if (data['count'] != null)    return data['count'] as int;
//         if (data['data']  != null)    return data['data']  as int;
//         return 0;
//       }
//       return 0;
//     } catch (e) {
//       debugPrint('getUnreadCount error: $e');
//       return 0;
//     }
//   }

//   static Future<bool> markNotificationRead(int notificationId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read/$notificationId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint(
//           'markNotificationRead [$notificationId] status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markNotificationRead error: $e');
//       return false;
//     }
//   }

//   static Future<bool> markAllNotificationsRead() async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/Notification/read-all'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('markAllRead status: ${response.statusCode}');

//       _checkSession(response);

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('markAllRead error: $e');
//       return false;
//     }
//   }

//   static Future<ApiResponse> sendNotification({
//     required int    userId,
//     required String title,
//     required String message,
//     required String type,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'userId':  userId,
//         'title':   title,
//         'message': message,
//         'type':    type,
//       });

//       debugPrint('sendNotification body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base/Notification/send'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendNotification status: ${response.statusCode}');
//       debugPrint('sendNotification body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 &&
//             (data['success'] == true || data is Map),
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data: data['data'],
//       );
//     } catch (e) {
//       debugPrint('sendNotification error: $e');
//       return ApiResponse(
//         success: false,
//         message: 'Network error: ${e.toString()}',
//         data: null,
//       );
//     }
//   }

//   // =================== HELP & SUPPORT ===================

//   static Future<List<FaqModel>> getFaqs() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getFaqs status: ${response.statusCode}');
//       debugPrint('getFaqs body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => FaqModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getFaqs error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> createFaq({
//     required String question,
//     required String answer,
//     required String category,
//     required int    sortOrder,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'question':  question,
//         'answer':    answer,
//         'category':  category,
//         'sortOrder': sortOrder,
//       });
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/faqs'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('createFaq status: ${response.statusCode}');
//       debugPrint('createFaq body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> sendContactMessage({
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final body = jsonEncode({'subject': subject, 'message': message});
//       final response = await http
//           .post(
//             Uri.parse('$_base/HelpSupport/contact'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('sendContact status: ${response.statusCode}');
//       debugPrint('sendContact body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // Admin: Get all contact messages
//   static Future<List<ContactMessageModel>> getContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getContactMessages status: ${response.statusCode}');
//       debugPrint('getContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getContactMessages error: $e');
//       return [];
//     }
//   }

//   // User: Get my own contact messages
//   static Future<List<ContactMessageModel>> getMyContactMessages() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base/HelpSupport/contact/my-messages'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyContactMessages status: ${response.statusCode}');
//       debugPrint('getMyContactMessages body  : ${response.body}');
//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => ContactMessageModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyContactMessages error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> resolveContact(int contactId) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse('$_base/HelpSupport/contact/resolve/$contactId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
//       debugPrint('resolveContact [$contactId] body  : ${response.body}');
//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== LEAVE ===================

//   static Future<ApiResponse> applyLeave({
//     required String leaveType,
//     required String fromDate,
//     required String toDate,
//     required String reason,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'leaveType': leaveType,
//         'fromDate':  fromDate,
//         'toDate':    toDate,
//         'reason':    reason,
//       });

//       debugPrint('applyLeave body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('applyLeave status: ${response.statusCode}');
//       debugPrint('applyLeave body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('applyLeave error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<List<LeaveModel>> getMyLeaves({
//     String? status,
//     int?    year,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status != null && status.isNotEmpty) params['status'] = status;
//       if (year   != null) params['year'] = year.toString();

//       final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLeaves status: ${response.statusCode}');
//       debugPrint('getMyLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse<void>> cancelLeave(int leaveId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
//       debugPrint('cancelLeave body             : ${response.body}');

//       _checkSession(response);

//       final data    = jsonDecode(response.body);
//       final success = response.statusCode == 200 && (data['success'] == true);
//       final message = (data['message'] ?? '').toString();
//       return ApiResponse(success: success, message: message);
//     } catch (e) {
//       debugPrint('cancelLeave error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<List<LeaveModel>> getAllLeaves({
//     String? status,
//     int?    userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (status   != null && status.isNotEmpty)   params['status']   = status;
//       if (userId   != null)                         params['userId']   = userId.toString();
//       if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

//       final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllLeaves URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllLeaves status: ${response.statusCode}');
//       debugPrint('getAllLeaves body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list;
//         if (data is List) {
//           list = data;
//         } else if (data['data'] != null) {
//           list = data['data'] as List;
//         } else {
//           list = [];
//         }
//         return list.map((e) => LeaveModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllLeaves error: $e');
//       return [];
//     }
//   }

//   static Future<ApiResponse> leaveAction({
//     required int    leaveId,
//     required String status,
//     String?         adminRemark,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'status':      status,
//         'adminRemark': adminRemark ?? '',
//       });

//       debugPrint('leaveAction [$leaveId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
//       debugPrint('leaveAction [$leaveId] body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('leaveAction error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   // =================== DAILY TASK ===================

//   static Future<ApiResponse> addDailyTask({
//     required String taskDate,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskDate':        taskDate,
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('addDailyTask body: $body');

//       final response = await http
//           .post(
//             Uri.parse('$_base${AppConstants.dailyTaskAddEndpoint}'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('addDailyTask status: ${response.statusCode}');
//       debugPrint('addDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200 || response.statusCode == 201,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('addDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse> updateDailyTask({
//     required int    taskId,
//     required String taskTitle,
//     required String taskDescription,
//     required String projectName,
//     required String status,
//     required double hoursSpent,
//     required String remarks,
//   }) async {
//     try {
//       final body = jsonEncode({
//         'taskTitle':       taskTitle,
//         'taskDescription': taskDescription,
//         'projectName':     projectName,
//         'status':          status,
//         'hoursSpent':      hoursSpent,
//         'remarks':         remarks,
//       });

//       debugPrint('updateDailyTask [$taskId] body: $body');

//       final response = await http
//           .put(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskUpdateEndpoint}/$taskId'),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('updateDailyTask status: ${response.statusCode}');
//       debugPrint('updateDailyTask body  : ${response.body}');

//       _checkSession(response);

//       final data = jsonDecode(response.body);
//       return ApiResponse(
//         success: response.statusCode == 200,
//         message: (data['message'] ?? data['msg'] ?? '').toString(),
//         data:    data['data'],
//       );
//     } catch (e) {
//       debugPrint('updateDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString(), data: null);
//     }
//   }

//   static Future<ApiResponse<void>> deleteDailyTask(int taskId) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse(
//                 '$_base${AppConstants.dailyTaskDeleteEndpoint}/$taskId'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('deleteDailyTask [$taskId] status: ${response.statusCode}');
//       _checkSession(response);

//       final data    = jsonDecode(response.body);
//       final success = response.statusCode == 200 && (data['success'] == true);
//       final message = (data['message'] ?? '').toString();
//       return ApiResponse(success: success, message: message);
//     } catch (e) {
//       debugPrint('deleteDailyTask error: $e');
//       return ApiResponse(success: false, message: e.toString());
//     }
//   }

//   static Future<List<DailyTaskModel>> getMyTasks({
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskMyEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasks status: ${response.statusCode}');
//       debugPrint('getMyTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasks error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getMyTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskMyTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyTasksToday status: ${response.statusCode}');
//       debugPrint('getMyTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];

//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }

//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyTasksToday error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getAllTasks({
//     int?    userId,
//     String? date,
//     String? fromDate,
//     String? toDate,
//     String? status,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (userId   != null)                        params['userId']   = userId.toString();
//       if (date     != null && date.isNotEmpty)     params['date']     = date;
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
//       if (status   != null && status.isNotEmpty)   params['status']   = status;

//       final uri = Uri.parse('$_base${AppConstants.dailyTaskAllEndpoint}')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getAllTasks URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasks status: ${response.statusCode}');
//       debugPrint('getAllTasks body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasks error: $e');
//       return [];
//     }
//   }

//   static Future<List<DailyTaskModel>> getAllTasksToday() async {
//     try {
//       final response = await http
//           .get(
//             Uri.parse('$_base${AppConstants.dailyTaskAllTodayEndpoint}'),
//             headers: _authHeaders,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getAllTasksToday status: ${response.statusCode}');
//       debugPrint('getAllTasksToday body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         } else if (data['data'] is Map) {
//           final dataObj = data['data'] as Map<String, dynamic>;
//           list = (dataObj['tasks'] ?? []) as List<dynamic>;
//         }
//         return list.map((e) => DailyTaskModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getAllTasksToday error: $e');
//       return [];
//     }
//   }

//   // =================== LOGIN HISTORY ===================

//   /// GET /api/LoginHistory/today — aaj ke login sessions (current user)
//   static Future<List<LoginHistoryModel>> getTodayLoginHistory({
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

//       final uri = Uri.parse('$_base/LoginHistory/today')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getTodayLoginHistory URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getTodayLoginHistory status: ${response.statusCode}');
//       debugPrint('getTodayLoginHistory body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         }
//         return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getTodayLoginHistory error: $e');
//       return [];
//     }
//   }

//   /// GET /api/LoginHistory/me — current user ki full login history
//   static Future<List<LoginHistoryModel>> getMyLoginHistory({
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

//       final uri = Uri.parse('$_base/LoginHistory/me')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getMyLoginHistory URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyLoginHistory status: ${response.statusCode}');
//       debugPrint('getMyLoginHistory body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         }
//         return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getMyLoginHistory error: $e');
//       return [];
//     }
//   }

//   /// GET /api/LoginHistory/user/{userId} — Admin: kisi bhi user ki history
//   static Future<List<LoginHistoryModel>> getUserLoginHistory({
//     required int userId,
//     String? fromDate,
//     String? toDate,
//   }) async {
//     try {
//       final params = <String, String>{};
//       if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
//       if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

//       final uri = Uri.parse('$_base/LoginHistory/user/$userId')
//           .replace(queryParameters: params.isNotEmpty ? params : null);

//       debugPrint('getUserLoginHistory [$userId] URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getUserLoginHistory [$userId] status: ${response.statusCode}');
//       debugPrint('getUserLoginHistory [$userId] body  : ${response.body}');

//       _checkSession(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data['data'] is List) {
//           list = data['data'] as List;
//         }
//         return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getUserLoginHistory error: $e');
//       return [];
//     }
//   }

// } // ← ApiService CLASS KA CLOSING BRACE








// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../core/routes.dart';
import '../models/models.dart';
import '../models/daily_task_model.dart';
import '../models/holiday_model.dart';
import '../models/leave_model.dart';
import '../models/login_history_model.dart';
import '../models/notification_model.dart';
import '../models/help_support_model.dart';
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

  // =================== SESSION CHECK ===================

  static void _checkSession(http.Response response) {
    if (response.statusCode == 401) {
      _handleSessionExpired();
      return;
    }
    try {
      final data = jsonDecode(response.body);
      if (data is Map &&
          data['success'] == false &&
          data['message'] == 'SESSION_EXPIRED') {
        _handleSessionExpired();
      }
    } catch (_) {}
  }

  static void _handleSessionExpired() {
    if (Get.currentRoute == AppRoutes.sessionExpired) return;
    StorageService.clearAll();
    Get.offAllNamed(AppRoutes.sessionExpired);
  }

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
      final url  = '$_base${AppConstants.registerEndpoint}';
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

      _checkSession(response);
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

    _checkSession(response);

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
      final url  = '$_base${AppConstants.clearDeviceEndpoint}';
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

      _checkSession(response);

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

      _checkSession(response);

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
    required int    userId,
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

      _checkSession(response);

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

      _checkSession(response);

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

      _checkSession(response);

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
    File?   selfieImage,
    required String biometricData,
    required int    userId,
    required String userName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markInEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

    request.fields['attendanceDate']  = attendanceDate;
    request.fields['latitude']        = latitude.toString();
    request.fields['longitude']       = longitude.toString();
    request.fields['locationAddress'] = locationAddress.trim();
    request.fields['biometricData']   = biometricData;
    request.fields['userId']          = userId.toString();
    request.fields['name']            = userName;

    if (selfieImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
      );
    }

    final streamedResponse = await request.send().timeout(
          const Duration(milliseconds: AppConstants.connectTimeout),
        );
    final response = await http.Response.fromStream(streamedResponse);

    _checkSession(response);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markOut({
    required String attendanceDate,
    required double latitude,
    required double longitude,
    required String locationAddress,
    File?   selfieImage,
    required String biometricData,
    required int    userId,
    required String userName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base${AppConstants.markOutEndpoint}'),
    );

    request.headers['Authorization'] = 'Bearer ${StorageService.getToken()}';

    request.fields['attendanceDate']  = attendanceDate;
    request.fields['latitude']        = latitude.toString();
    request.fields['longitude']       = longitude.toString();
    request.fields['locationAddress'] = locationAddress.trim();
    request.fields['biometricData']   = biometricData;
    request.fields['userId']          = userId.toString();
    request.fields['name']            = userName;

    if (selfieImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('selfieImage', selfieImage.path),
      );
    }

    final streamedResponse = await request.send().timeout(
          const Duration(milliseconds: AppConstants.connectTimeout),
        );
    final response = await http.Response.fromStream(streamedResponse);

    _checkSession(response);

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

    _checkSession(response);

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

      _checkSession(response);

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
            role:     r,
            fromDate: fromDate,
            toDate:   toDate,
          ));

      final results = await Future.wait(futures);
      final merged  = results.expand((list) => list).toList();
      debugPrint('getAdminSummary ALL: ${merged.length} total records');
      return merged;
    }

    return _fetchSummaryForRole(
      role:     role,
      fromDate: fromDate,
      toDate:   toDate,
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
        'role':     role,
        'fromDate': fromDate,
        'toDate':   toDate,
      },
    );

    debugPrint('getAdminSummary URI [$role]: $uri');

    final response = await http
        .get(uri, headers: _authHeaders)
        .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

    debugPrint('getAdminSummary [$role] status: ${response.statusCode}');
    debugPrint('getAdminSummary [$role] body  : ${response.body}');

    _checkSession(response);

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
            role:     r,
            fromDate: fromDate,
            toDate:   toDate,
          ));

      final results = await Future.wait(futures);
      return results.any((success) => success);
    }

    return _exportForRole(
      role:     role,
      fromDate: fromDate,
      toDate:   toDate,
    );
  }

  static Future<bool> _exportForRole({
    required String role,
    required String fromDate,
    required String toDate,
  }) async {
    final Map<String, dynamic> body = {
      'fromDate': fromDate,
      'toDate':   toDate,
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

    _checkSession(response);

    if (response.statusCode == 200) {
      final tempDir = Directory.systemTemp;
      final file    = File('${tempDir.path}/admin_summary_$role.pdf');
      await file.writeAsBytes(response.bodyBytes);
      return true;
    }
    return false;
  }

  // =================== NOTIFICATIONS ===================

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base/Notification'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getNotifications status: ${response.statusCode}');
      debugPrint('getNotifications body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }

        return list.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getNotifications error: $e');
      return [];
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base/Notification/unread-count'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getUnreadCount status: ${response.statusCode}');
      debugPrint('getUnreadCount body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is int)              return data;
        if (data['count'] != null)    return data['count'] as int;
        if (data['data']  != null)    return data['data']  as int;
        return 0;
      }
      return 0;
    } catch (e) {
      debugPrint('getUnreadCount error: $e');
      return 0;
    }
  }

  static Future<bool> markNotificationRead(int notificationId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_base/Notification/read/$notificationId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint(
          'markNotificationRead [$notificationId] status: ${response.statusCode}');

      _checkSession(response);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('markNotificationRead error: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead() async {
    try {
      final response = await http
          .put(
            Uri.parse('$_base/Notification/read-all'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('markAllRead status: ${response.statusCode}');

      _checkSession(response);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('markAllRead error: $e');
      return false;
    }
  }

  static Future<ApiResponse> sendNotification({
    required int    userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final body = jsonEncode({
        'userId':  userId,
        'title':   title,
        'message': message,
        'type':    type,
      });

      debugPrint('sendNotification body: $body');

      final response = await http
          .post(
            Uri.parse('$_base/Notification/send'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('sendNotification status: ${response.statusCode}');
      debugPrint('sendNotification body  : ${response.body}');

      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 &&
            (data['success'] == true || data is Map),
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data: data['data'],
      );
    } catch (e) {
      debugPrint('sendNotification error: $e');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  // =================== HELP & SUPPORT ===================

  static Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.helpFaqsEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getFaqs status: ${response.statusCode}');
      debugPrint('getFaqs body  : ${response.body}');
      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        return list.map((e) => FaqModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getFaqs error: $e');
      return [];
    }
  }

  static Future<ApiResponse> createFaq({
    required String question,
    required String answer,
    required String category,
    required int    sortOrder,
  }) async {
    try {
      final body = jsonEncode({
        'question':  question,
        'answer':    answer,
        'category':  category,
        'sortOrder': sortOrder,
      });
      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.helpFaqsEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('createFaq status: ${response.statusCode}');
      debugPrint('createFaq body  : ${response.body}');
      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> sendContactMessage({
    required String subject,
    required String message,
  }) async {
    try {
      final body = jsonEncode({'subject': subject, 'message': message});
      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.helpContactEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('sendContact status: ${response.statusCode}');
      debugPrint('sendContact body  : ${response.body}');
      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  static Future<List<ContactMessageModel>> getContactMessages() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.helpContactMsgsEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getContactMessages status: ${response.statusCode}');
      debugPrint('getContactMessages body  : ${response.body}');
      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        return list.map((e) => ContactMessageModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getContactMessages error: $e');
      return [];
    }
  }

  static Future<List<ContactMessageModel>> getMyContactMessages() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base/HelpSupport/contact/my-messages'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyContactMessages status: ${response.statusCode}');
      debugPrint('getMyContactMessages body  : ${response.body}');
      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        return list.map((e) => ContactMessageModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMyContactMessages error: $e');
      return [];
    }
  }

  static Future<ApiResponse> resolveContact(int contactId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_base${AppConstants.helpContactResolveEndpoint}/$contactId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('resolveContact [$contactId] status: ${response.statusCode}');
      debugPrint('resolveContact [$contactId] body  : ${response.body}');
      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // =================== LEAVE ===================

  static Future<ApiResponse> applyLeave({
    required String leaveType,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    try {
      final body = jsonEncode({
        'leaveType': leaveType,
        'fromDate':  fromDate,
        'toDate':    toDate,
        'reason':    reason,
      });

      debugPrint('applyLeave body: $body');

      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.leaveApplyEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('applyLeave status: ${response.statusCode}');
      debugPrint('applyLeave body  : ${response.body}');

      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      debugPrint('applyLeave error: $e');
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  static Future<List<LeaveModel>> getMyLeaves({
    String? status,
    int?    year,
  }) async {
    try {
      final params = <String, String>{};
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (year   != null) params['year'] = year.toString();

      final uri = Uri.parse('$_base${AppConstants.leaveMyEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getMyLeaves URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyLeaves status: ${response.statusCode}');
      debugPrint('getMyLeaves body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        return list.map((e) => LeaveModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMyLeaves error: $e');
      return [];
    }
  }

  static Future<ApiResponse<void>> cancelLeave(int leaveId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_base${AppConstants.leaveCancelEndpoint}/$leaveId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('cancelLeave [$leaveId] status: ${response.statusCode}');
      debugPrint('cancelLeave body             : ${response.body}');

      _checkSession(response);

      final data    = jsonDecode(response.body);
      final success = response.statusCode == 200 && (data['success'] == true);
      final message = (data['message'] ?? '').toString();
      return ApiResponse(success: success, message: message);
    } catch (e) {
      debugPrint('cancelLeave error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static Future<List<LeaveModel>> getAllLeaves({
    String? status,
    int?    userId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final params = <String, String>{};
      if (status   != null && status.isNotEmpty)   params['status']   = status;
      if (userId   != null)                         params['userId']   = userId.toString();
      if (fromDate != null && fromDate.isNotEmpty)  params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)    params['toDate']   = toDate;

      final uri = Uri.parse('$_base${AppConstants.leaveAllEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getAllLeaves URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getAllLeaves status: ${response.statusCode}');
      debugPrint('getAllLeaves body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['data'] != null) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        return list.map((e) => LeaveModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getAllLeaves error: $e');
      return [];
    }
  }

  static Future<ApiResponse> leaveAction({
    required int    leaveId,
    required String status,
    String?         adminRemark,
  }) async {
    try {
      final body = jsonEncode({
        'status':      status,
        'adminRemark': adminRemark ?? '',
      });

      debugPrint('leaveAction [$leaveId] body: $body');

      final response = await http
          .put(
            Uri.parse('$_base${AppConstants.leaveActionEndpoint}/$leaveId'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('leaveAction [$leaveId] status: ${response.statusCode}');
      debugPrint('leaveAction [$leaveId] body  : ${response.body}');

      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      debugPrint('leaveAction error: $e');
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  // =================== DAILY TASK ===================

  static Future<ApiResponse> addDailyTask({
    required String taskDate,
    required String taskTitle,
    required String taskDescription,
    required String projectName,
    required String status,
    required double hoursSpent,
    required String remarks,
  }) async {
    try {
      final body = jsonEncode({
        'taskDate':        taskDate,
        'taskTitle':       taskTitle,
        'taskDescription': taskDescription,
        'projectName':     projectName,
        'status':          status,
        'hoursSpent':      hoursSpent,
        'remarks':         remarks,
      });

      debugPrint('addDailyTask body: $body');

      final response = await http
          .post(
            Uri.parse('$_base${AppConstants.dailyTaskAddEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('addDailyTask status: ${response.statusCode}');
      debugPrint('addDailyTask body  : ${response.body}');

      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      debugPrint('addDailyTask error: $e');
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse> updateDailyTask({
    required int    taskId,
    required String taskTitle,
    required String taskDescription,
    required String projectName,
    required String status,
    required double hoursSpent,
    required String remarks,
  }) async {
    try {
      final body = jsonEncode({
        'taskTitle':       taskTitle,
        'taskDescription': taskDescription,
        'projectName':     projectName,
        'status':          status,
        'hoursSpent':      hoursSpent,
        'remarks':         remarks,
      });

      debugPrint('updateDailyTask [$taskId] body: $body');

      final response = await http
          .put(
            Uri.parse('$_base${AppConstants.dailyTaskUpdateEndpoint}/$taskId'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('updateDailyTask status: ${response.statusCode}');
      debugPrint('updateDailyTask body  : ${response.body}');

      _checkSession(response);

      final data = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200,
        message: (data['message'] ?? data['msg'] ?? '').toString(),
        data:    data['data'],
      );
    } catch (e) {
      debugPrint('updateDailyTask error: $e');
      return ApiResponse(success: false, message: e.toString(), data: null);
    }
  }

  static Future<ApiResponse<void>> deleteDailyTask(int taskId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_base${AppConstants.dailyTaskDeleteEndpoint}/$taskId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('deleteDailyTask [$taskId] status: ${response.statusCode}');
      _checkSession(response);

      final data    = jsonDecode(response.body);
      final success = response.statusCode == 200 && (data['success'] == true);
      final message = (data['message'] ?? '').toString();
      return ApiResponse(success: success, message: message);
    } catch (e) {
      debugPrint('deleteDailyTask error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static Future<List<DailyTaskModel>> getMyTasks({
    String? date,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (date     != null && date.isNotEmpty)     params['date']     = date;
      if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
      if (status   != null && status.isNotEmpty)   params['status']   = status;

      final uri = Uri.parse('$_base${AppConstants.dailyTaskMyEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getMyTasks URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyTasks status: ${response.statusCode}');
      debugPrint('getMyTasks body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['data'] is Map) {
          final dataObj = data['data'] as Map<String, dynamic>;
          list = (dataObj['tasks'] ?? []) as List<dynamic>;
        }
        return list.map((e) => DailyTaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMyTasks error: $e');
      return [];
    }
  }

  static Future<List<DailyTaskModel>> getMyTasksToday() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.dailyTaskMyTodayEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyTasksToday status: ${response.statusCode}');
      debugPrint('getMyTasksToday body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['data'] is Map) {
          final dataObj = data['data'] as Map<String, dynamic>;
          list = (dataObj['tasks'] ?? []) as List<dynamic>;
        }
        return list.map((e) => DailyTaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMyTasksToday error: $e');
      return [];
    }
  }

  static Future<List<DailyTaskModel>> getAllTasks({
    int?    userId,
    String? date,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final params = <String, String>{};
      if (userId   != null)                        params['userId']   = userId.toString();
      if (date     != null && date.isNotEmpty)     params['date']     = date;
      if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;
      if (status   != null && status.isNotEmpty)   params['status']   = status;

      final uri = Uri.parse('$_base${AppConstants.dailyTaskAllEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getAllTasks URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getAllTasks status: ${response.statusCode}');
      debugPrint('getAllTasks body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['data'] is Map) {
          final dataObj = data['data'] as Map<String, dynamic>;
          list = (dataObj['tasks'] ?? []) as List<dynamic>;
        }
        return list.map((e) => DailyTaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getAllTasks error: $e');
      return [];
    }
  }

  static Future<List<DailyTaskModel>> getAllTasksToday() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_base${AppConstants.dailyTaskAllTodayEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getAllTasksToday status: ${response.statusCode}');
      debugPrint('getAllTasksToday body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        } else if (data['data'] is Map) {
          final dataObj = data['data'] as Map<String, dynamic>;
          list = (dataObj['tasks'] ?? []) as List<dynamic>;
        }
        return list.map((e) => DailyTaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getAllTasksToday error: $e');
      return [];
    }
  }

  // =================== LOGIN HISTORY ===================

  /// GET /api/LoginHistory/today
  static Future<List<LoginHistoryModel>> getTodayLoginHistory({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final params = <String, String>{};
      if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

      final uri = Uri.parse('$_base${AppConstants.loginHistoryTodayEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getTodayLoginHistory URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getTodayLoginHistory status: ${response.statusCode}');
      debugPrint('getTodayLoginHistory body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        }
        return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getTodayLoginHistory error: $e');
      return [];
    }
  }

  /// GET /api/LoginHistory/me
  static Future<List<LoginHistoryModel>> getMyLoginHistory({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final params = <String, String>{};
      if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

      final uri = Uri.parse('$_base${AppConstants.loginHistoryMeEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getMyLoginHistory URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyLoginHistory status: ${response.statusCode}');
      debugPrint('getMyLoginHistory body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        }
        return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMyLoginHistory error: $e');
      return [];
    }
  }

  /// GET /api/LoginHistory/user/{userId} — Admin only
  static Future<List<LoginHistoryModel>> getUserLoginHistory({
    required int userId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final params = <String, String>{};
      if (fromDate != null && fromDate.isNotEmpty) params['fromDate'] = fromDate;
      if (toDate   != null && toDate.isNotEmpty)   params['toDate']   = toDate;

      final uri = Uri.parse(
              '$_base${AppConstants.loginHistoryUserEndpoint}/$userId')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('getUserLoginHistory [$userId] URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getUserLoginHistory [$userId] status: ${response.statusCode}');
      debugPrint('getUserLoginHistory [$userId] body  : ${response.body}');

      _checkSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data['data'] is List) {
          list = data['data'] as List;
        }
        return list.map((e) => LoginHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getUserLoginHistory error: $e');
      return [];
    }
  }

} // ← ApiService CLASS KA CLOSING BRACE