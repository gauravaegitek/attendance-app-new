// // lib/controllers/leave_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../models/leave_model.dart';
// import '../services/api_service.dart';

// class LeaveController extends GetxController {
//   // ── User: my leaves ──────────────────────────────────────
//   final myLeaves     = <LeaveModel>[].obs;
//   final isLoadingMy  = false.obs;

//   // ── Admin: all leaves ─────────────────────────────────────
//   final allLeaves    = <LeaveModel>[].obs;
//   final isLoadingAll = false.obs;

//   // ── Apply form ────────────────────────────────────────────
//   final isApplying   = false.obs;

//   final leaveTypeOptions = ['Casual', 'Sick', 'Earned', 'Maternity', 'Other'];

//   final selectedLeaveType = ''.obs;
//   final fromDate          = Rx<DateTime?>(null);
//   final toDate            = Rx<DateTime?>(null);
//   final reasonController  = TextEditingController();

//   // ── Filters ───────────────────────────────────────────────
//   final selectedStatus = 'All'.obs;
//   final filterYear     = DateTime.now().year.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchMyLeaves();
//   }

//   @override
//   void onClose() {
//     reasonController.dispose();
//     super.onClose();
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Fetch my leaves
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchMyLeaves() async {
//     isLoadingMy.value = true;
//     try {
//       final status = selectedStatus.value == 'All' ? null : selectedStatus.value;
//       final leaves = await ApiService.getMyLeaves(
//         status: status,
//         year:   filterYear.value,
//       );
//       myLeaves.assignAll(leaves);
//     } catch (e) {
//       _showSnack('Failed to load leaves: $e', isError: true);
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Apply for leave
//   // ─────────────────────────────────────────────────────────
//   Future<bool> applyLeave() async {
//     if (selectedLeaveType.value.isEmpty) {
//       _showSnack('Please select leave type', isError: true);
//       return false;
//     }
//     if (fromDate.value == null || toDate.value == null) {
//       _showSnack('Please select from and to dates', isError: true);
//       return false;
//     }
//     if (toDate.value!.isBefore(fromDate.value!)) {
//       _showSnack('To date cannot be before from date', isError: true);
//       return false;
//     }
//     if (reasonController.text.trim().isEmpty) {
//       _showSnack('Please enter reason', isError: true);
//       return false;
//     }

//     isApplying.value = true;
//     try {
//       final result = await ApiService.applyLeave(
//         leaveType: selectedLeaveType.value,
//         fromDate:  DateFormat('yyyy-MM-dd').format(fromDate.value!),
//         toDate:    DateFormat('yyyy-MM-dd').format(toDate.value!),
//         reason:    reasonController.text.trim(),
//       );
//       if (result.success) {
//         _showSnack('Leave applied successfully!');
//         _clearForm();
//         await fetchMyLeaves();
//         return true;
//       } else {
//         _showSnack(result.message.isNotEmpty ? result.message : 'Apply failed', isError: true);
//         return false;
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//       return false;
//     } finally {
//       isApplying.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Cancel leave
//   // ─────────────────────────────────────────────────────────
//   Future<void> cancelLeave(int leaveId) async {
//     try {
//       final success = await ApiService.cancelLeave(leaveId);
//       if (success) {
//         _showSnack('Leave cancelled');
//         await fetchMyLeaves();
//       } else {
//         _showSnack('Cancel failed', isError: true);
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  ADMIN: Fetch all leaves
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchAllLeaves() async {
//     isLoadingAll.value = true;
//     try {
//       final status = selectedStatus.value == 'All' ? null : selectedStatus.value;
//       final leaves = await ApiService.getAllLeaves(
//         status:   status,
//         fromDate: null,
//         toDate:   null,
//       );
//       allLeaves.assignAll(leaves);
//     } catch (e) {
//       _showSnack('Failed to load leaves: $e', isError: true);
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  ADMIN: Approve / Reject leave
//   // ─────────────────────────────────────────────────────────
//   Future<void> takeLeaveAction({
//     required int    leaveId,
//     required String status,   // 'Approved' or 'Rejected'
//     String?         adminRemark,
//   }) async {
//     try {
//       final result = await ApiService.leaveAction(
//         leaveId:     leaveId,
//         status:      status,
//         adminRemark: adminRemark ?? '',
//       );
//       if (result.success) {
//         _showSnack('Leave $status successfully!');
//         await fetchAllLeaves();
//       } else {
//         _showSnack(result.message.isNotEmpty ? result.message : 'Action failed', isError: true);
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  HELPERS
//   // ─────────────────────────────────────────────────────────
//   void _clearForm() {
//     selectedLeaveType.value = '';
//     fromDate.value          = null;
//     toDate.value            = null;
//     reasonController.clear();
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       snackPosition:   SnackPosition.BOTTOM,
//       backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
//       colorText:       const Color(0xFFFFFFFF),
//       margin:          const EdgeInsets.all(16),
//       borderRadius:    14,
//     );
//   }
// }










// lib/controllers/leave_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/leave_model.dart';
import '../services/api_service.dart';

class LeaveController extends GetxController {
  // ── User: my leaves ──────────────────────────────────────
  final myLeaves    = <LeaveModel>[].obs;
  final isLoadingMy = false.obs;

  // ── Admin: all leaves ─────────────────────────────────────
  final allLeaves    = <LeaveModel>[].obs;
  final isLoadingAll = false.obs;

  // ── Apply form ────────────────────────────────────────────
  final isApplying = false.obs;

  final leaveTypeOptions = ['Casual', 'Sick', 'Earned', 'Maternity', 'Other'];

  final selectedLeaveType = ''.obs;
  final fromDate         = Rx<DateTime?>(null);
  final toDate           = Rx<DateTime?>(null);
  final reasonController = TextEditingController();

  // ── Filters ───────────────────────────────────────────────
  final selectedStatus = 'All'.obs;
  final filterYear     = DateTime.now().year.obs;

  // ✅ FIX: Loaded flags — dobara unnecessary API call nahi hogi
  bool _myLeavesLoaded  = false;
  bool _allLeavesLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // ✅ FIX: onInit me direct call hataya — screen se explicitly call hogi
    // Isse controller recreate hone pe double call nahi hogi
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Fetch my leaves
  // ─────────────────────────────────────────────────────────

  /// [forceRefresh] = true karo jab pull-to-refresh ya filter change ho
  Future<void> fetchMyLeaves({bool forceRefresh = false}) async {
    // ✅ Already loaded hai aur force refresh nahi → skip
    if (_myLeavesLoaded && !forceRefresh) return;

    isLoadingMy.value = true;
    try {
      final status = selectedStatus.value == 'All' ? null : selectedStatus.value;
      final leaves = await ApiService.getMyLeaves(
        status: status,
        year:   filterYear.value,
      );
      myLeaves.assignAll(leaves);
      _myLeavesLoaded = true; // ✅ mark as loaded
    } catch (e) {
      _showSnack('Failed to load leaves: $e', isError: true);
    } finally {
      isLoadingMy.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Apply for leave
  // ─────────────────────────────────────────────────────────
  Future<bool> applyLeave() async {
    if (selectedLeaveType.value.isEmpty) {
      _showSnack('Please select leave type', isError: true);
      return false;
    }
    if (fromDate.value == null || toDate.value == null) {
      _showSnack('Please select from and to dates', isError: true);
      return false;
    }
    if (toDate.value!.isBefore(fromDate.value!)) {
      _showSnack('To date cannot be before from date', isError: true);
      return false;
    }
    if (reasonController.text.trim().isEmpty) {
      _showSnack('Please enter reason', isError: true);
      return false;
    }

    isApplying.value = true;
    try {
      final result = await ApiService.applyLeave(
        leaveType: selectedLeaveType.value,
        fromDate:  DateFormat('yyyy-MM-dd').format(fromDate.value!),
        toDate:    DateFormat('yyyy-MM-dd').format(toDate.value!),
        reason:    reasonController.text.trim(),
      );
      if (result.success) {
        _showSnack('Leave applied successfully!');
        _clearForm();
        // ✅ Apply ke baad force refresh karo
        await fetchMyLeaves(forceRefresh: true);
        return true;
      } else {
        _showSnack(
            result.message.isNotEmpty ? result.message : 'Apply failed',
            isError: true);
        return false;
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Cancel leave
  // ─────────────────────────────────────────────────────────
  Future<void> cancelLeave(int leaveId) async {
    try {
      final success = await ApiService.cancelLeave(leaveId);
      if (success) {
        _showSnack('Leave cancelled');
        await fetchMyLeaves(forceRefresh: true);
      } else {
        _showSnack('Cancel failed', isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN: Fetch all leaves
  // ─────────────────────────────────────────────────────────

  /// [forceRefresh] = true karo jab pull-to-refresh ya filter change ho
  Future<void> fetchAllLeaves({bool forceRefresh = false}) async {
    // ✅ Already loaded hai aur force refresh nahi → skip
    if (_allLeavesLoaded && !forceRefresh) return;

    isLoadingAll.value = true;
    try {
      final status = selectedStatus.value == 'All' ? null : selectedStatus.value;
      final leaves = await ApiService.getAllLeaves(
        status:   status,
        fromDate: null,
        toDate:   null,
      );
      allLeaves.assignAll(leaves);
      _allLeavesLoaded = true; // ✅ mark as loaded
    } catch (e) {
      _showSnack('Failed to load leaves: $e', isError: true);
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN: Approve / Reject leave
  // ─────────────────────────────────────────────────────────
  Future<void> takeLeaveAction({
    required int    leaveId,
    required String status,
    String?         adminRemark,
  }) async {
    try {
      final result = await ApiService.leaveAction(
        leaveId:     leaveId,
        status:      status,
        adminRemark: adminRemark ?? '',
      );
      if (result.success) {
        _showSnack('Leave $status successfully!');
        await fetchAllLeaves(forceRefresh: true);
      } else {
        _showSnack(
            result.message.isNotEmpty ? result.message : 'Action failed',
            isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
  void _clearForm() {
    selectedLeaveType.value = '';
    fromDate.value          = null;
    toDate.value            = null;
    reasonController.clear();
  }

  void _showSnack(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      msg,
      snackPosition:   SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFFEF4444)
          : const Color(0xFF22C55E),
      colorText:    const Color(0xFFFFFFFF),
      margin:       const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}