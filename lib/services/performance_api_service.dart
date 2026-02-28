// // lib/services/performance_api_service.dart

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// import '../core/constants/app_constants.dart';
// import '../models/performance_model.dart';
// import 'storage_service.dart';

// class PerformanceApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _authHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // ─── GET /api/Role ─────────────────────────────────────────────────────────
//   // Department filter chips ke liye roles API se fetch karo
//   static Future<List<String>> getRoles() async {
//     try {
//       final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}/Role');

//       debugPrint('getRoles URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getRoles status: ${response.statusCode}');
//       debugPrint('getRoles body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data is Map && data['data'] != null) {
//           list = data['data'] as List;
//         }

//         // roleName field extract karo
//         return list
//             .map((e) {
//               if (e is Map) {
//                 return (e['roleName'] ?? e['name'] ?? e['role'] ?? '')
//                     .toString();
//               }
//               return e.toString();
//             })
//             .where((s) => s.isNotEmpty)
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoles error: $e');
//       return [];
//     }
//   }

//   // ─── GET /api/Performance/employeescore ────────────────────────────────────
//   static Future<EmployeeScoreModel?> getEmployeeScore({
//     required int month,
//     required int year,
//     required int userId,
//   }) async {
//     try {
//       final uri = Uri.parse('$_base/Performance/employeescore').replace(
//         queryParameters: {
//           'month':  month.toString(),
//           'year':   year.toString(),
//           'userId': userId.toString(),
//         },
//       );

//       debugPrint('getEmployeeScore URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getEmployeeScore status: ${response.statusCode}');
//       debugPrint('getEmployeeScore body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data is Map && data['data'] != null) {
//           final d = data['data'];
//           if (d is List && d.isNotEmpty) {
//             return EmployeeScoreModel.fromJson(d.first);
//           } else if (d is Map<String, dynamic>) {
//             return EmployeeScoreModel.fromJson(d);
//           }
//         }
//         if (data is Map<String, dynamic> && data.containsKey('userId')) {
//           return EmployeeScoreModel.fromJson(data);
//         }
//         if (data is List && data.isNotEmpty) {
//           return EmployeeScoreModel.fromJson(data.first);
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getEmployeeScore error: $e');
//       return null;
//     }
//   }

//   // ─── GET /api/Performance/ranking ─────────────────────────────────────────
//   // ✅ FIX: Nested response — { data: [ { department, rankings: [...] } ] }
//   static Future<List<RankingModel>> getRanking({
//     required int month,
//     required int year,
//     String? department,
//   }) async {
//     try {
//       final Map<String, String> params = {
//         'month': month.toString(),
//         'year':  year.toString(),
//       };
//       if (department != null && department.isNotEmpty) {
//         params['department'] = department;
//       }

//       final uri = Uri.parse('$_base/Performance/ranking')
//           .replace(queryParameters: params);

//       debugPrint('getRanking URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getRanking status: ${response.statusCode}');
//       debugPrint('getRanking body  : ${response.body}');

//       if (response.statusCode != 200) return [];

//       final body = jsonDecode(response.body);
//       final List<RankingModel> result = [];

//       // ✅ Structure: { data: [ { department, rankings: [ {rank,userId,...} ] } ] }
//       if (body is Map && body['data'] is List) {
//         final deptGroups = body['data'] as List;

//         for (final group in deptGroups) {
//           if (group is! Map) continue;

//           final dept = group['department']?.toString() ?? '';
//           final rankList = group['rankings'];

//           if (rankList is! List) continue;

//           for (final item in rankList) {
//             if (item is! Map<String, dynamic>) continue;

//             // department inject karo agar item mein nahi hai
//             final map = Map<String, dynamic>.from(item);
//             if (map['department'] == null || map['department'].toString().isEmpty) {
//               map['department'] = dept;
//             }

//             result.add(RankingModel.fromJson(map));
//           }
//         }

//         // ✅ Global rank assign karo score ke basis par (all departments)
//         result.sort((a, b) => b.finalScore.compareTo(a.finalScore));
//         for (int i = 0; i < result.length; i++) {
//           result[i] = RankingModel(
//             rank:                 i + 1,
//             userId:               result[i].userId,
//             userName:             result[i].userName,
//             department:           result[i].department,
//             performanceScore:     result[i].performanceScore,
//             grade:                result[i].grade,
//             presentDays:          result[i].presentDays,
//             attendancePercentage: result[i].attendancePercentage,
//           );
//         }

//         return result;
//       }

//       // Fallback: flat list
//       if (body is List) {
//         return body
//             .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }

//       return [];
//     } catch (e) {
//       debugPrint('getRanking error: $e');
//       return [];
//     }
//   }

//   // ─── GET /api/Performance/reviews ─────────────────────────────────────────
//   static Future<List<ReviewModel>> getReviews({
//     required int month,
//     required int year,
//   }) async {
//     try {
//       final uri = Uri.parse('$_base/Performance/reviews').replace(
//         queryParameters: {
//           'month': month.toString(),
//           'year':  year.toString(),
//         },
//       );

//       debugPrint('getReviews URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getReviews status: ${response.statusCode}');
//       debugPrint('getReviews body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data is Map && data['data'] != null) {
//           list = data['data'] as List;
//         }

//         return list
//             .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getReviews error: $e');
//       return [];
//     }
//   }

//   // ─── POST /api/Performance/review ─────────────────────────────────────────
//   static Future<bool> submitReview(ReviewRequestModel request) async {
//     try {
//       final url = '$_base/Performance/review';
//       final body = jsonEncode(request.toJson());

//       debugPrint('submitReview URL : $url');
//       debugPrint('submitReview BODY: $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('submitReview status: ${response.statusCode}');
//       debugPrint('submitReview body  : ${response.body}');

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('submitReview error: $e');
//       return false;
//     }
//   }
// }







// // lib/services/performance_api_service.dart

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// import '../core/constants/app_constants.dart';
// import '../models/performance_model.dart';
// import 'storage_service.dart';

// class PerformanceApiService {
//   static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

//   static Map<String, String> get _authHeaders => {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer ${StorageService.getToken()}',
//       };

//   // ─── GET /api/Role ─────────────────────────────────────────────────────────
//   static Future<List<String>> getRoles() async {
//     try {
//       final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}/Role');

//       debugPrint('getRoles URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getRoles status: ${response.statusCode}');
//       debugPrint('getRoles body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data is Map && data['data'] != null) {
//           list = data['data'] as List;
//         }

//         return list
//             .map((e) {
//               if (e is Map) {
//                 return (e['roleName'] ?? e['name'] ?? e['role'] ?? '')
//                     .toString();
//               }
//               return e.toString();
//             })
//             .where((s) => s.isNotEmpty)
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getRoles error: $e');
//       return [];
//     }
//   }

//   // ─── GET /api/Performance/employeescore ────────────────────────────────────
//   static Future<EmployeeScoreModel?> getEmployeeScore({
//     required int month,
//     required int year,
//     required int userId,
//   }) async {
//     try {
//       final uri = Uri.parse('$_base/Performance/employeescore').replace(
//         queryParameters: {
//           'month':  month.toString(),
//           'year':   year.toString(),
//           'userId': userId.toString(),
//         },
//       );

//       debugPrint('getEmployeeScore URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getEmployeeScore status: ${response.statusCode}');
//       debugPrint('getEmployeeScore body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data is Map && data['data'] != null) {
//           final d = data['data'];
//           if (d is List && d.isNotEmpty) {
//             return EmployeeScoreModel.fromJson(d.first);
//           } else if (d is Map<String, dynamic>) {
//             return EmployeeScoreModel.fromJson(d);
//           }
//         }
//         if (data is Map<String, dynamic> && data.containsKey('userId')) {
//           return EmployeeScoreModel.fromJson(data);
//         }
//         if (data is List && data.isNotEmpty) {
//           return EmployeeScoreModel.fromJson(data.first);
//         }
//       }
//       return null;
//     } catch (e) {
//       debugPrint('getEmployeeScore error: $e');
//       return null;
//     }
//   }

//   // ─── GET /api/Performance/ranking ─────────────────────────────────────────
//   static Future<List<RankingModel>> getRanking({
//     required int month,
//     required int year,
//     String? department,
//   }) async {
//     try {
//       final Map<String, String> params = {
//         'month': month.toString(),
//         'year':  year.toString(),
//       };
//       if (department != null && department.isNotEmpty) {
//         params['department'] = department;
//       }

//       final uri = Uri.parse('$_base/Performance/ranking')
//           .replace(queryParameters: params);

//       debugPrint('getRanking URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getRanking status: ${response.statusCode}');
//       debugPrint('getRanking body  : ${response.body}');

//       if (response.statusCode != 200) return [];

//       final body = jsonDecode(response.body);
//       final List<RankingModel> result = [];

//       if (body is Map && body['data'] is List) {
//         final deptGroups = body['data'] as List;

//         for (final group in deptGroups) {
//           if (group is! Map) continue;

//           final dept     = group['department']?.toString() ?? '';
//           final rankList = group['rankings'];

//           if (rankList is! List) continue;

//           for (final item in rankList) {
//             if (item is! Map<String, dynamic>) continue;

//             final map = Map<String, dynamic>.from(item);
//             if (map['department'] == null ||
//                 map['department'].toString().isEmpty) {
//               map['department'] = dept;
//             }

//             result.add(RankingModel.fromJson(map));
//           }
//         }

//         result.sort((a, b) => b.finalScore.compareTo(a.finalScore));
//         for (int i = 0; i < result.length; i++) {
//           result[i] = RankingModel(
//             rank:                 i + 1,
//             userId:               result[i].userId,
//             userName:             result[i].userName,
//             department:           result[i].department,
//             performanceScore:     result[i].performanceScore,
//             grade:                result[i].grade,
//             presentDays:          result[i].presentDays,
//             attendancePercentage: result[i].attendancePercentage,
//           );
//         }

//         return result;
//       }

//       if (body is List) {
//         return body
//             .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }

//       return [];
//     } catch (e) {
//       debugPrint('getRanking error: $e');
//       return [];
//     }
//   }

//   // ─── GET /api/Performance/reviews ─────────────────────────────────────────
//   static Future<List<ReviewModel>> getReviews({
//     required int month,
//     required int year,
//   }) async {
//     try {
//       final uri = Uri.parse('$_base/Performance/reviews').replace(
//         queryParameters: {
//           'month': month.toString(),
//           'year':  year.toString(),
//         },
//       );

//       debugPrint('getReviews URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getReviews status: ${response.statusCode}');
//       debugPrint('getReviews body  : ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data is Map && data['data'] != null) {
//           list = data['data'] as List;
//         }

//         return list
//             .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('getReviews error: $e');
//       return [];
//     }
//   }

//   // ─── GET /api/Performance/myreviews ✅ NEW ─────────────────────────────────
//   // Employee ke apne reviews fetch karta hai — month + year filter ke saath
//   static Future<List<ReviewModel>> getMyReviews({
//     required int month,
//     required int year,
//   }) async {
//     try {
//       final uri = Uri.parse('$_base/Performance/myreviews').replace(
//         queryParameters: {
//           'month': month.toString(),
//           'year':  year.toString(),
//         },
//       );

//       debugPrint('getMyReviews URI: $uri');

//       final response = await http
//           .get(uri, headers: _authHeaders)
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('getMyReviews status: ${response.statusCode}');
//       debugPrint('getMyReviews body  : ${response.body}');

//       // 404 = is month koi review nahi — error nahi
//       if (response.statusCode == 404) return [];

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         List<dynamic> list = [];
//         if (data is List) {
//           list = data;
//         } else if (data is Map && data['data'] != null) {
//           list = data['data'] as List;
//         } else if (data is Map && data['reviews'] != null) {
//           list = data['reviews'] as List;
//         }

//         return list
//             .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }

//       throw Exception(
//           'getMyReviews failed: ${response.statusCode} ${response.body}');
//     } catch (e) {
//       debugPrint('getMyReviews error: $e');
//       rethrow;
//     }
//   }

//   // ─── POST /api/Performance/review ─────────────────────────────────────────
//   static Future<bool> submitReview(ReviewRequestModel request) async {
//     try {
//       final url  = '$_base/Performance/review';
//       final body = jsonEncode(request.toJson());

//       debugPrint('submitReview URL : $url');
//       debugPrint('submitReview BODY: $body');

//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: _authHeaders,
//             body: body,
//           )
//           .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

//       debugPrint('submitReview status: ${response.statusCode}');
//       debugPrint('submitReview body  : ${response.body}');

//       return response.statusCode == 200;
//     } catch (e) {
//       debugPrint('submitReview error: $e');
//       return false;
//     }
//   }
// }








// lib/services/performance_api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/performance_model.dart';
import 'storage_service.dart';

class PerformanceApiService {
  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // ─── GET /api/Role ─────────────────────────────────────────────────────────
  static Future<List<String>> getRoles() async {
    try {
      final uri =
          Uri.parse('${AppConstants.baseUrl}${AppConstants.apiVersion}/Role');

      debugPrint('getRoles URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getRoles status: ${response.statusCode}');
      debugPrint('getRoles body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] != null) {
          list = data['data'] as List;
        }

        return list
            .map((e) {
              if (e is Map) {
                return (e['roleName'] ?? e['name'] ?? e['role'] ?? '')
                    .toString();
              }
              return e.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('getRoles error: $e');
      return [];
    }
  }

  // ─── GET /api/Performance/employeescore ────────────────────────────────────
  static Future<EmployeeScoreModel?> getEmployeeScore({
    required int month,
    required int year,
    required int userId,
  }) async {
    try {
      final uri = Uri.parse('$_base/Performance/employeescore').replace(
        queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
          'userId': userId.toString(),
        },
      );

      debugPrint('getEmployeeScore URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getEmployeeScore status: ${response.statusCode}');
      debugPrint('getEmployeeScore body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final d = data['data'];
          if (d is List && d.isNotEmpty) {
            return EmployeeScoreModel.fromJson(d.first);
          } else if (d is Map<String, dynamic>) {
            return EmployeeScoreModel.fromJson(d);
          }
        }
        if (data is Map<String, dynamic> && data.containsKey('userId')) {
          return EmployeeScoreModel.fromJson(data);
        }
        if (data is List && data.isNotEmpty) {
          return EmployeeScoreModel.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('getEmployeeScore error: $e');
      return null;
    }
  }

  // ─── GET /api/Performance/ranking ─────────────────────────────────────────
  static Future<List<RankingModel>> getRanking({
    required int month,
    required int year,
    String? department,
  }) async {
    try {
      final Map<String, String> params = {
        'month': month.toString(),
        'year': year.toString(),
      };
      if (department != null && department.isNotEmpty) {
        params['department'] = department;
      }

      final uri = Uri.parse('$_base/Performance/ranking')
          .replace(queryParameters: params);

      debugPrint('getRanking URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getRanking status: ${response.statusCode}');
      debugPrint('getRanking body  : ${response.body}');

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      final List<RankingModel> result = [];

      if (body is Map && body['data'] is List) {
        final deptGroups = body['data'] as List;

        for (final group in deptGroups) {
          if (group is! Map) continue;

          final dept = group['department']?.toString() ?? '';
          final rankList = group['rankings'];

          if (rankList is! List) continue;

          for (final item in rankList) {
            if (item is! Map<String, dynamic>) continue;

            final map = Map<String, dynamic>.from(item);
            if (map['department'] == null ||
                map['department'].toString().isEmpty) {
              map['department'] = dept;
            }

            result.add(RankingModel.fromJson(map));
          }
        }

        result.sort((a, b) => b.finalScore.compareTo(a.finalScore));
        for (int i = 0; i < result.length; i++) {
          result[i] = RankingModel(
            rank: i + 1,
            userId: result[i].userId,
            userName: result[i].userName,
            department: result[i].department,
            performanceScore: result[i].performanceScore,
            grade: result[i].grade,
            presentDays: result[i].presentDays,
            attendancePercentage: result[i].attendancePercentage,
          );
        }

        return result;
      }

      if (body is List) {
        return body
            .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('getRanking error: $e');
      return [];
    }
  }

  // ─── GET /api/Performance/reviews ─────────────────────────────────────────
  static Future<List<ReviewModel>> getReviews({
    required int month,
    required int year,
  }) async {
    try {
      final uri = Uri.parse('$_base/Performance/reviews').replace(
        queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
        },
      );

      debugPrint('getReviews URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getReviews status: ${response.statusCode}');
      debugPrint('getReviews body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] != null) {
          list = data['data'] as List;
        }

        return list
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('getReviews error: $e');
      return [];
    }
  }

  // ─── GET /api/Performance/myreviews ────────────────────────────────────────
  static Future<List<ReviewModel>> getMyReviews({
    required int month,
    required int year,
  }) async {
    try {
      final uri = Uri.parse('$_base/Performance/myreviews').replace(
        queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
        },
      );

      debugPrint('getMyReviews URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('getMyReviews status: ${response.statusCode}');
      debugPrint('getMyReviews body  : ${response.body}');

      if (response.statusCode == 404) return [];

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] != null) {
          list = data['data'] as List;
        } else if (data is Map && data['reviews'] != null) {
          list = data['reviews'] as List;
        }

        return list
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
          'getMyReviews failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('getMyReviews error: $e');
      rethrow;
    }
  }

  // ─── POST /api/Performance/review ─────────────────────────────────────────
  // ✅ UPDATED: returns SubmitReviewResponse (success + message + data)
  static Future<SubmitReviewResponse> submitReview(
      ReviewRequestModel request) async {
    try {
      final url = '$_base/Performance/review';
      final body = jsonEncode(request.toJson());

      debugPrint('submitReview URL : $url');
      debugPrint('submitReview BODY: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('submitReview status: ${response.statusCode}');
      debugPrint('submitReview body  : ${response.body}');

      if (response.statusCode != 200) {
        return SubmitReviewResponse(
          success: false,
          message: 'HTTP ${response.statusCode}: ${response.body}',
          data: null,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SubmitReviewResponse.fromJson(json);
    } catch (e) {
      debugPrint('submitReview error: $e');
      return SubmitReviewResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}