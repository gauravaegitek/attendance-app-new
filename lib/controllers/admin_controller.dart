// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AdminController extends GetxController {
//   // =================== STATE ===================
//   final isLoadingSummary = false.obs;
//   final isExporting = false.obs;
//   final isLoadingUsers = false.obs;
//   final isLoadingRoles = false.obs;

//   final adminRecords = <AttendanceRecord>[].obs;
//   final allUsers = <UserModel>[].obs;
//   final roles = <String>[].obs;

//   final selectedRole = ''.obs;
//   final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
//   final toDate = DateTime.now().obs;

//   // =================== LIFECYCLE ===================
//   @override
//   void onInit() {
//     super.onInit();
//     fetchRoles();
//   }

//   // =================== ROLES ===================
//   Future<void> fetchRoles() async {
//     isLoadingRoles.value = true;
//     try {
//       final fetchedRoles = await ApiService.getRoles();
//       if (fetchedRoles.isNotEmpty) {
//         roles.value = ['all', ...fetchedRoles];
//         selectedRole.value = 'all';
//       } else {
//         roles.value = ['all', ...AppConstants.allRoles];
//         selectedRole.value = 'all';
//       }
//     } catch (e) {
//       AppUtils.showError('Error loading roles: ${e.toString()}');
//       roles.value = ['all', ...AppConstants.allRoles];
//       selectedRole.value = 'all';
//     } finally {
//       isLoadingRoles.value = false;
//     }
//   }

//   // =================== ADMIN SUMMARY ===================
//   Future<void> fetchAdminSummary() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Date range cannot exceed 31 days');
//       return;
//     }

//     isLoadingSummary.value = true;
//     try {
//       final records = await ApiService.getAdminSummary(
//         role: selectedRole.value,
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//         allRoles: roles,
//       );

//       // ✅ Descending order by date (latest pehle)
//       records.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));

//       adminRecords.value = records;
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isLoadingSummary.value = false;
//     }
//   }

//   // =================== EXPORT PDF ===================
//   Future<void> exportPdf() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Date range cannot exceed 31 days');
//       return;
//     }

//     isExporting.value = true;
//     try {
//       final success = await ApiService.exportAdminSummary(
//         role: selectedRole.value == 'all' ? '' : selectedRole.value,
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//         allRoles: roles,
//       );

//       if (success) {
//         AppUtils.showSuccess('PDF exported successfully!');
//       } else {
//         AppUtils.showError('Failed to export PDF');
//       }
//     } catch (e) {
//       AppUtils.showError('Export error: ${e.toString()}');
//     } finally {
//       isExporting.value = false;
//     }
//   }

//   // =================== GET ALL USERS ===================
//   Future<void> fetchAllUsers() async {
//     isLoadingUsers.value = true;
//     try {
//       final users = await ApiService.getAllUsers();
//       allUsers.value = users;
//     } catch (e) {
//       AppUtils.showError('Error: ${e.toString()}');
//     } finally {
//       isLoadingUsers.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       // ✅ Agar toDate picked se peeche ho ya 31 din se zyada aage ho to auto-adjust
//       if (toDate.value.isBefore(picked) ||
//           toDate.value.difference(picked).inDays > 31) {
//         final newToDate = picked.add(const Duration(days: 30));
//         toDate.value =
//             newToDate.isAfter(DateTime.now()) ? DateTime.now() : newToDate;
//       }
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     // ✅ toDate ki lastDate = fromDate + 31 days (ya aaj, jo pehle ho)
//     final maxToDate = fromDate.value.add(const Duration(days: 31));
//     final effectiveLastDate =
//         maxToDate.isAfter(DateTime.now()) ? DateTime.now() : maxToDate;

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: toDate.value.isAfter(effectiveLastDate)
//           ? effectiveLastDate
//           : toDate.value,
//       firstDate: fromDate.value,
//       lastDate: effectiveLastDate,
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   // =================== STATS ===================
//   int get totalPresent =>
//       adminRecords.where((r) => r.status == 'Complete').length;
//   int get totalIncomplete =>
//       adminRecords.where((r) => r.status != 'Complete').length;
//   double get totalWorkHours =>
//       adminRecords.fold(0, (sum, r) => sum + (r.totalHours ?? 0));
// }







// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../core/utils/app_utils.dart';
// import '../core/constants/app_constants.dart';

// class AdminController extends GetxController {
//   // =================== STATE ===================
//   final isLoadingSummary = false.obs;
//   final isExporting = false.obs;
//   final isLoadingUsers = false.obs;
//   final isLoadingRoles = false.obs;

//   final adminRecords = <AttendanceRecord>[].obs;
//   final allUsers = <UserModel>[].obs;
//   final roles = <String>[].obs;

//   final selectedRole = ''.obs;
//   final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
//   final toDate = DateTime.now().obs;

//   // =================== LIFECYCLE ===================
//   @override
//   void onInit() {
//     super.onInit();
//     fetchRoles();
//   }

//   // =================== ERROR HANDLER (UNABLE STYLE) ===================
//   void _showUnableError(String context, dynamic e) {
//     debugPrint('$context error: $e');

//     final msg = e.toString();
//     if (msg.contains('SocketException')) {
//       AppUtils.showError('Unable to connect. Please check your internet and try again.');
//       return;
//     }
//     if (msg.contains('TimeoutException')) {
//       AppUtils.showError('Unable to complete request. Please try again.');
//       return;
//     }

//     switch (context) {
//       case 'fetchRoles':
//         AppUtils.showError('Unable to load roles. Please try again.');
//         break;
//       case 'fetchAdminSummary':
//         AppUtils.showError('Unable to load summary. Please try again.');
//         break;
//       case 'exportPdf':
//         AppUtils.showError('Unable to export PDF. Please try again.');
//         break;
//       case 'fetchAllUsers':
//         AppUtils.showError('Unable to load users. Please try again.');
//         break;
//       default:
//         AppUtils.showError('Unable to process request. Please try again.');
//     }
//   }

//   // =================== ROLES ===================
//   Future<void> fetchRoles() async {
//     isLoadingRoles.value = true;
//     try {
//       final fetchedRoles = await ApiService.getRoles();
//       if (fetchedRoles.isNotEmpty) {
//         roles.value = ['all', ...fetchedRoles];
//         selectedRole.value = 'all';
//       } else {
//         roles.value = ['all', ...AppConstants.allRoles];
//         selectedRole.value = 'all';
//       }
//     } catch (e) {
//       _showUnableError('fetchRoles', e);
//       roles.value = ['all', ...AppConstants.allRoles];
//       selectedRole.value = 'all';
//     } finally {
//       isLoadingRoles.value = false;
//     }
//   }

//   // =================== ADMIN SUMMARY ===================
//   Future<void> fetchAdminSummary() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Unable to load summary. Date range cannot exceed 31 days.');
//       return;
//     }

//     isLoadingSummary.value = true;
//     try {
//       final records = await ApiService.getAdminSummary(
//         role: selectedRole.value,
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//         allRoles: roles,
//       );

//       // ✅ Descending order by date (latest pehle)
//       records.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));

//       adminRecords.value = records;
//     } catch (e) {
//       _showUnableError('fetchAdminSummary', e);
//     } finally {
//       isLoadingSummary.value = false;
//     }
//   }

//   // =================== EXPORT PDF ===================
//   Future<void> exportPdf() async {
//     final diff = toDate.value.difference(fromDate.value).inDays;
//     if (diff > 31) {
//       AppUtils.showError('Unable to export PDF. Date range cannot exceed 31 days.');
//       return;
//     }

//     isExporting.value = true;
//     try {
//       final success = await ApiService.exportAdminSummary(
//         role: selectedRole.value == 'all' ? '' : selectedRole.value,
//         fromDate: AppUtils.formatDateApi(fromDate.value),
//         toDate: AppUtils.formatDateApi(toDate.value),
//         allRoles: roles,
//       );

//       if (success) {
//         AppUtils.showSuccess('PDF exported successfully!');
//       } else {
//         AppUtils.showError('Unable to export PDF. Please try again.');
//       }
//     } catch (e) {
//       _showUnableError('exportPdf', e);
//     } finally {
//       isExporting.value = false;
//     }
//   }

//   // =================== GET ALL USERS ===================
//   Future<void> fetchAllUsers() async {
//     isLoadingUsers.value = true;
//     try {
//       final users = await ApiService.getAllUsers();
//       allUsers.value = users;
//     } catch (e) {
//       _showUnableError('fetchAllUsers', e);
//     } finally {
//       isLoadingUsers.value = false;
//     }
//   }

//   // =================== DATE PICKERS ===================
//   Future<void> pickFromDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       fromDate.value = picked;
//       // ✅ Agar toDate picked se peeche ho ya 31 din se zyada aage ho to auto-adjust
//       if (toDate.value.isBefore(picked) ||
//           toDate.value.difference(picked).inDays > 31) {
//         final newToDate = picked.add(const Duration(days: 30));
//         toDate.value =
//             newToDate.isAfter(DateTime.now()) ? DateTime.now() : newToDate;
//       }
//     }
//   }

//   Future<void> pickToDate(BuildContext context) async {
//     // ✅ toDate ki lastDate = fromDate + 31 days (ya aaj, jo pehle ho)
//     final maxToDate = fromDate.value.add(const Duration(days: 31));
//     final effectiveLastDate =
//         maxToDate.isAfter(DateTime.now()) ? DateTime.now() : maxToDate;

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: toDate.value.isAfter(effectiveLastDate)
//           ? effectiveLastDate
//           : toDate.value,
//       firstDate: fromDate.value,
//       lastDate: effectiveLastDate,
//     );
//     if (picked != null) toDate.value = picked;
//   }

//   // =================== STATS ===================
//   int get totalPresent =>
//       adminRecords.where((r) => r.status == 'Complete').length;

//   int get totalIncomplete =>
//       adminRecords.where((r) => r.status != 'Complete').length;

//   double get totalWorkHours =>
//       adminRecords.fold(0, (sum, r) => sum + (r.totalHours ?? 0));
// }








import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';

class AdminController extends GetxController {
  // =================== STATE ===================
  final isLoadingSummary = false.obs;
  final isExporting = false.obs;
  final isLoadingUsers = false.obs;
  final isLoadingRoles = false.obs;

  final adminRecords = <AttendanceRecord>[].obs;
  final allUsers = <UserModel>[].obs;
  final roles = <String>[].obs;

  final selectedRole = ''.obs;
  final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final toDate = DateTime.now().obs;

  // =================== LIFECYCLE ===================
  @override
  void onInit() {
    super.onInit();
    fetchRoles();
  }

  // =================== ERROR HANDLER (UNABLE STYLE) ===================
  void _showUnableError(String context, dynamic e) {
    debugPrint('$context error: $e');

    final msg = e.toString();
    if (msg.contains('SocketException')) {
      AppUtils.showError('Unable to connect. Please check your internet and try again.');
      return;
    }
    if (msg.contains('TimeoutException')) {
      AppUtils.showError('Unable to complete request. Please try again.');
      return;
    }

    switch (context) {
      case 'fetchRoles':
        AppUtils.showError('Unable to load roles. Please try again.');
        break;
      case 'fetchAdminSummary':
        AppUtils.showError('Unable to load summary. Please try again.');
        break;
      case 'exportPdf':
        AppUtils.showError('Unable to export PDF. Please try again.');
        break;
      case 'fetchAllUsers':
        AppUtils.showError('Unable to load users. Please try again.');
        break;
      default:
        AppUtils.showError('Unable to process request. Please try again.');
    }
  }

  // =================== ROLES ===================
  Future<void> fetchRoles() async {
    isLoadingRoles.value = true;
    try {
      final fetchedRoles = await ApiService.getRoles();
      if (fetchedRoles.isNotEmpty) {
        roles.value = ['all', ...fetchedRoles];
        selectedRole.value = 'all';
      } else {
        roles.value = ['all', ...AppConstants.allRoles];
        selectedRole.value = 'all';
      }
    } catch (e) {
      _showUnableError('fetchRoles', e);
      roles.value = ['all', ...AppConstants.allRoles];
      selectedRole.value = 'all';
    } finally {
      isLoadingRoles.value = false;
    }
  }

  // =================== ADMIN SUMMARY ===================
  Future<void> fetchAdminSummary() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      AppUtils.showError('Unable to load summary. Date range cannot exceed 31 days.');
      return;
    }

    isLoadingSummary.value = true;
    try {
      final records = await ApiService.getAdminSummary(
        role: selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate: AppUtils.formatDateApi(toDate.value),
        allRoles: roles,
      );

      // ✅ Pehle date descending, phir same date me inTime descending (latest entry top pe)
      records.sort((a, b) {
        final dateCompare = b.attendanceDate.compareTo(a.attendanceDate);
        if (dateCompare != 0) return dateCompare;
        final aTime = a.inTime ?? '';
        final bTime = b.inTime ?? '';
        return bTime.compareTo(aTime);
      });

      adminRecords.value = records;
    } catch (e) {
      _showUnableError('fetchAdminSummary', e);
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // =================== EXPORT PDF ===================
  Future<void> exportPdf() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      AppUtils.showError('Unable to export PDF. Date range cannot exceed 31 days.');
      return;
    }

    isExporting.value = true;
    try {
      final success = await ApiService.exportAdminSummary(
        role: selectedRole.value == 'all' ? '' : selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate: AppUtils.formatDateApi(toDate.value),
        allRoles: roles,
      );

      if (success) {
        AppUtils.showSuccess('PDF exported successfully!');
      } else {
        AppUtils.showError('Unable to export PDF. Please try again.');
      }
    } catch (e) {
      _showUnableError('exportPdf', e);
    } finally {
      isExporting.value = false;
    }
  }

  // =================== GET ALL USERS ===================
  Future<void> fetchAllUsers() async {
    isLoadingUsers.value = true;
    try {
      final users = await ApiService.getAllUsers();
      allUsers.value = users;
    } catch (e) {
      _showUnableError('fetchAllUsers', e);
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // =================== DATE PICKERS ===================
  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      // ✅ Agar toDate picked se peeche ho ya 31 din se zyada aage ho to auto-adjust
      if (toDate.value.isBefore(picked) ||
          toDate.value.difference(picked).inDays > 31) {
        final newToDate = picked.add(const Duration(days: 30));
        toDate.value =
            newToDate.isAfter(DateTime.now()) ? DateTime.now() : newToDate;
      }
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    // ✅ toDate ki lastDate = fromDate + 31 days (ya aaj, jo pehle ho)
    final maxToDate = fromDate.value.add(const Duration(days: 31));
    final effectiveLastDate =
        maxToDate.isAfter(DateTime.now()) ? DateTime.now() : maxToDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value.isAfter(effectiveLastDate)
          ? effectiveLastDate
          : toDate.value,
      firstDate: fromDate.value,
      lastDate: effectiveLastDate,
    );
    if (picked != null) toDate.value = picked;
  }

  // =================== STATS ===================
  int get totalPresent =>
      adminRecords.where((r) => r.status == 'Complete').length;

  int get totalIncomplete =>
      adminRecords.where((r) => r.status != 'Complete').length;

  double get totalWorkHours =>
      adminRecords.fold(0, (sum, r) => sum + (r.totalHours ?? 0));
}