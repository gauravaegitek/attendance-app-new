// // lib/controllers/login_history_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../models/login_history_model.dart';
// import '../services/api_service.dart';

// class LoginHistoryController extends GetxController {
//   // ── State ─────────────────────────────────────────────────────────────────
//   final RxList<LoginHistoryModel> myHistory      = <LoginHistoryModel>[].obs;
//   final RxList<LoginHistoryModel> todayHistory   = <LoginHistoryModel>[].obs;
//   final RxList<LoginHistoryModel> userHistory    = <LoginHistoryModel>[].obs;

//   final RxBool isLoadingMy    = false.obs;
//   final RxBool isLoadingToday = false.obs;
//   final RxBool isLoadingUser  = false.obs;

//   final RxString errorMy    = ''.obs;
//   final RxString errorToday = ''.obs;
//   final RxString errorUser  = ''.obs;

//   // Date filter for "My History" tab
//   final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
//   final Rx<DateTime?> toDate   = Rx<DateTime?>(null);

//   // ── Formatters ────────────────────────────────────────────────────────────
//   static final _apiDateFmt = DateFormat('yyyy-MM-ddTHH:mm:ss');
//   static final _queryFmt   = DateFormat('yyyy-MM-dd');

//   // ── Lifecycle ─────────────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();
//     fetchTodayHistory();
//     fetchMyHistory();
//   }

//   // ── Fetch: today ──────────────────────────────────────────────────────────
//   Future<void> fetchTodayHistory() async {
//     isLoadingToday.value = true;
//     errorToday.value     = '';
//     try {
//       todayHistory.value = await ApiService.getTodayLoginHistory();
//     } catch (e) {
//       errorToday.value = e.toString();
//     } finally {
//       isLoadingToday.value = false;
//     }
//   }

//   // ── Fetch: my history ─────────────────────────────────────────────────────
//   Future<void> fetchMyHistory({DateTime? from, DateTime? to}) async {
//     isLoadingMy.value = true;
//     errorMy.value     = '';
//     try {
//       final f = from ?? fromDate.value;
//       final t = to   ?? toDate.value;
//       myHistory.value = await ApiService.getMyLoginHistory(
//         fromDate: f != null ? _queryFmt.format(f) : null,
//         toDate:   t != null ? _queryFmt.format(t) : null,
//       );
//     } catch (e) {
//       errorMy.value = e.toString();
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   // ── Fetch: specific user (admin) ──────────────────────────────────────────
//   Future<void> fetchUserHistory(int userId, {DateTime? from, DateTime? to}) async {
//     isLoadingUser.value = true;
//     errorUser.value     = '';
//     userHistory.clear();
//     try {
//       userHistory.value = await ApiService.getUserLoginHistory(
//         userId:   userId,
//         fromDate: from != null ? _queryFmt.format(from) : null,
//         toDate:   to   != null ? _queryFmt.format(to)   : null,
//       );
//     } catch (e) {
//       errorUser.value = e.toString();
//     } finally {
//       isLoadingUser.value = false;
//     }
//   }

//   // ── Date filter helpers ───────────────────────────────────────────────────
//   void applyDateFilter(DateTime? from, DateTime? to) {
//     fromDate.value = from;
//     toDate.value   = to;
//     fetchMyHistory(from: from, to: to);
//   }

//   void clearDateFilter() {
//     fromDate.value = null;
//     toDate.value   = null;
//     fetchMyHistory();
//   }

//   // ── Display helpers ───────────────────────────────────────────────────────
//   String formatLoginTime(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('dd MMM yyyy  hh:mm a').format(dt);
//     } catch (_) {
//       return raw;
//     }
//   }

//   String formatShortTime(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('hh:mm a').format(dt);
//     } catch (_) {
//       return '--';
//     }
//   }

//   String formatDate(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('dd MMM yyyy').format(dt);
//     } catch (_) {
//       return '--';
//     }
//   }

//   Color statusColor(LoginHistoryModel record) {
//     if (record.isActive) return const Color(0xFF22C55E);   // green
//     return const Color(0xFF94A3B8);                        // grey
//   }
// }











// // lib/controllers/login_history_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../models/login_history_model.dart';
// import '../services/api_service.dart';

// class LoginHistoryController extends GetxController {
//   // ── State ──────────────────────────────────────────────────────────
//   final RxList<LoginHistoryModel> myHistory    = <LoginHistoryModel>[].obs;
//   final RxList<LoginHistoryModel> todayHistory = <LoginHistoryModel>[].obs;
//   final RxList<LoginHistoryModel> userHistory  = <LoginHistoryModel>[].obs;

//   final RxBool isLoadingMy    = false.obs;
//   final RxBool isLoadingToday = false.obs;
//   final RxBool isLoadingUser  = false.obs;

//   final RxString errorMy    = ''.obs;
//   final RxString errorToday = ''.obs;
//   final RxString errorUser  = ''.obs;

//   final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
//   final Rx<DateTime?> toDate   = Rx<DateTime?>(null);

//   static final _queryFmt = DateFormat('yyyy-MM-dd');

//   // ── Lifecycle ──────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();
//     fetchTodayHistory();
//     fetchMyHistory();
//   }

//   // ── Fetch: today ───────────────────────────────────────────────────
//   Future<void> fetchTodayHistory() async {
//     isLoadingToday.value = true;
//     errorToday.value     = '';
//     try {
//       todayHistory.value = await ApiService.getTodayLoginHistory();
//     } catch (e) {
//       errorToday.value = e.toString();
//     } finally {
//       isLoadingToday.value = false;
//     }
//   }

//   // ── Fetch: my history ──────────────────────────────────────────────
//   Future<void> fetchMyHistory({DateTime? from, DateTime? to}) async {
//     isLoadingMy.value = true;
//     errorMy.value     = '';
//     try {
//       final f = from ?? fromDate.value;
//       final t = to   ?? toDate.value;
//       myHistory.value = await ApiService.getMyLoginHistory(
//         fromDate: f != null ? _queryFmt.format(f) : null,
//         toDate:   t != null ? _queryFmt.format(t) : null,
//       );
//     } catch (e) {
//       errorMy.value = e.toString();
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   // ── Fetch: specific user (admin) ───────────────────────────────────
//   Future<void> fetchUserHistory(int userId, {DateTime? from, DateTime? to}) async {
//     isLoadingUser.value = true;
//     errorUser.value     = '';
//     userHistory.clear();
//     try {
//       userHistory.value = await ApiService.getUserLoginHistory(
//         userId:   userId,
//         fromDate: from != null ? _queryFmt.format(from) : null,
//         toDate:   to   != null ? _queryFmt.format(to)   : null,
//       );
//     } catch (e) {
//       errorUser.value = e.toString();
//     } finally {
//       isLoadingUser.value = false;
//     }
//   }

//   // ── Date filter helpers ────────────────────────────────────────────
//   void applyDateFilter(DateTime? from, DateTime? to) {
//     fromDate.value = from;
//     toDate.value   = to;
//     fetchMyHistory(from: from, to: to);
//   }

//   void clearDateFilter() {
//     fromDate.value = null;
//     toDate.value   = null;
//     fetchMyHistory();
//   }

//   // ── Display helpers ────────────────────────────────────────────────
//   String formatLoginTime(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('dd MMM yyyy  hh:mm a').format(dt);
//     } catch (_) {
//       // Sirf time string "HH:mm:ss"
//       try {
//         final parts = raw.split(':');
//         if (parts.length >= 2) {
//           final now = DateTime.now();
//           final dt  = DateTime(now.year, now.month, now.day,
//               int.parse(parts[0]), int.parse(parts[1]));
//           return DateFormat('hh:mm a').format(dt);
//         }
//       } catch (_) {}
//       return raw;
//     }
//   }

//   String formatShortTime(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('hh:mm a').format(dt);
//     } catch (_) {
//       return '--';
//     }
//   }

//   String formatDate(String raw) {
//     try {
//       final dt = DateTime.parse(raw).toLocal();
//       return DateFormat('dd MMM yyyy').format(dt);
//     } catch (_) {
//       return '--';
//     }
//   }

//   // ✅ UPDATED — sessionStatus se color decide hoga
//   Color statusColor(LoginHistoryModel record) {
//     switch (record.sessionStatus) {
//       case 'Active':    return const Color(0xFF22C55E);  // green
//       case 'Expired':   return const Color(0xFFF97316);  // orange
//       case 'LoggedOut': return const Color(0xFF94A3B8);  // grey
//       default:
//         return record.isActive
//             ? const Color(0xFF22C55E)
//             : const Color(0xFF94A3B8);
//     }
//   }

//   // ✅ NEW — LogoutReason se label
//   String reasonLabel(String? reason) {
//     switch (reason) {
//       case 'manual':         return 'Manual Logout';
//       case 'expired':        return 'Session Expired';
//       case 'device_cleared': return 'Device Cleared';
//       case 'token_mismatch': return 'Token Mismatch';
//       default:               return reason ?? '';
//     }
//   }

//   // ✅ NEW — LogoutReason se color
//   Color reasonColor(String? reason) {
//     switch (reason) {
//       case 'manual':         return const Color(0xFF22C55E);  // green
//       case 'expired':        return const Color(0xFFF97316);  // orange
//       case 'device_cleared': return const Color(0xFFEF4444);  // red
//       case 'token_mismatch': return const Color(0xFF8B5CF6);  // purple
//       default:               return const Color(0xFF94A3B8);  // grey
//     }
//   }

//   // ✅ NEW — LogoutReason se icon
//   IconData reasonIcon(String? reason) {
//     switch (reason) {
//       case 'manual':         return Icons.logout_rounded;
//       case 'expired':        return Icons.timer_off_rounded;
//       case 'device_cleared': return Icons.phonelink_erase_rounded;
//       case 'token_mismatch': return Icons.sync_problem_rounded;
//       default:               return Icons.info_outline_rounded;
//     }
//   }
// }










// lib/controllers/login_history_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/login_history_model.dart';
import '../services/api_service.dart';

class LoginHistoryController extends GetxController {

  final RxList<LoginHistoryModel> myHistory    = <LoginHistoryModel>[].obs;
  final RxList<LoginHistoryModel> todayHistory = <LoginHistoryModel>[].obs;
  final RxList<LoginHistoryModel> userHistory  = <LoginHistoryModel>[].obs;

  final RxBool isLoadingMy    = false.obs;
  final RxBool isLoadingToday = false.obs;
  final RxBool isLoadingUser  = false.obs;

  final RxString errorMy    = ''.obs;
  final RxString errorToday = ''.obs;
  final RxString errorUser  = ''.obs;

  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate   = Rx<DateTime?>(null);

  static final _queryFmt = DateFormat('yyyy-MM-dd');

  @override
  void onInit() {
    super.onInit();
    fetchTodayHistory();
    fetchMyHistory();
  }

  Future<void> fetchTodayHistory() async {
    isLoadingToday.value = true;
    errorToday.value     = '';
    try {
      todayHistory.value = await ApiService.getTodayLoginHistory();
    } catch (e) {
      errorToday.value = e.toString();
    } finally {
      isLoadingToday.value = false;
    }
  }

  Future<void> fetchMyHistory({DateTime? from, DateTime? to}) async {
    isLoadingMy.value = true;
    errorMy.value     = '';
    try {
      final f = from ?? fromDate.value;
      final t = to   ?? toDate.value;
      myHistory.value = await ApiService.getMyLoginHistory(
        fromDate: f != null ? _queryFmt.format(f) : null,
        toDate:   t != null ? _queryFmt.format(t) : null,
      );
    } catch (e) {
      errorMy.value = e.toString();
    } finally {
      isLoadingMy.value = false;
    }
  }

  Future<void> fetchUserHistory(
    int userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    isLoadingUser.value = true;
    errorUser.value     = '';
    userHistory.clear();
    try {
      userHistory.value = await ApiService.getUserLoginHistory(
        userId:   userId,
        fromDate: from != null ? _queryFmt.format(from) : null,
        toDate:   to   != null ? _queryFmt.format(to)   : null,
      );
    } catch (e) {
      errorUser.value = e.toString();
    } finally {
      isLoadingUser.value = false;
    }
  }

  void applyDateFilter(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value   = to;
    fetchMyHistory(from: from, to: to);
  }

  void clearDateFilter() {
    fromDate.value = null;
    toDate.value   = null;
    fetchMyHistory();
  }

  // ─────────────────────────────────────────────────────────────────
  //  FORMAT METHODS
  // ─────────────────────────────────────────────────────────────────

  /// Full datetime: "01 Mar 2026  03:47 PM"
  String formatLoginTime(String raw) {
    if (raw.isEmpty || raw == '--') return '--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy  hh:mm a').format(dt);
    } catch (_) {
      try {
        final parts = raw.split(':');
        if (parts.length >= 2) {
          final now = DateTime.now();
          final dt  = DateTime(now.year, now.month, now.day,
              int.parse(parts[0]), int.parse(parts[1]));
          return DateFormat('hh:mm a').format(dt);
        }
      } catch (_) {}
      return raw;
    }
  }

  /// Date only: "01 Mar 2026"
  String formatDateOnly(String raw) {
    if (raw.isEmpty || raw == '--') return '--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '--';
    }
  }

  /// Time only: "03:47 PM"
  String formatTimeOnly(String raw) {
    if (raw.isEmpty || raw == '--') return '--:--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      try {
        final parts = raw.split(':');
        if (parts.length >= 2) {
          final now = DateTime.now();
          final dt  = DateTime(now.year, now.month, now.day,
              int.parse(parts[0]), int.parse(parts[1]));
          return DateFormat('hh:mm a').format(dt);
        }
      } catch (_) {}
      return '--:--';
    }
  }

  String formatShortTime(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '--';
    }
  }

  String formatDate(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '--';
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  STATUS & REASON HELPERS
  // ─────────────────────────────────────────────────────────────────

  Color statusColor(LoginHistoryModel record) {
    switch (record.sessionStatus) {
      case 'Active':    return const Color(0xFF22C55E);
      case 'Expired':   return const Color(0xFFF97316);
      case 'LoggedOut': return const Color(0xFF94A3B8);
      default:
        return record.isActive
            ? const Color(0xFF22C55E)
            : const Color(0xFF94A3B8);
    }
  }

  String reasonLabel(String? reason) {
    switch (reason) {
      case 'manual':          return 'Manual Logout';
      case 'expired':         return 'Session Expired';
      case 'device_cleared':  return 'Device Cleared';
      case 'token_mismatch':  return 'Token Mismatch';
      case 'device_mismatch': return 'Device Mismatch';
      default:                return reason ?? '';
    }
  }

  Color reasonColor(String? reason) {
    switch (reason) {
      case 'manual':          return const Color(0xFF22C55E);
      case 'expired':         return const Color(0xFFF97316);
      case 'device_cleared':  return const Color(0xFFEF4444);
      case 'token_mismatch':  return const Color(0xFF8B5CF6);
      case 'device_mismatch': return const Color(0xFFEC4899);
      default:                return const Color(0xFF94A3B8);
    }
  }

  IconData reasonIcon(String? reason) {
    switch (reason) {
      case 'manual':          return Icons.logout_rounded;
      case 'expired':         return Icons.timer_off_rounded;
      case 'device_cleared':  return Icons.phonelink_erase_rounded;
      case 'token_mismatch':  return Icons.sync_problem_rounded;
      case 'device_mismatch': return Icons.devices_other_rounded;
      default:                return Icons.info_outline_rounded;
    }
  }
}