// lib/controllers/leave_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/leave_model.dart';
import '../services/api_service.dart';
import '../core/utils/response_handler.dart';

class LeaveController extends GetxController {
  // ── User: my leaves ──────────────────────────────────────
  final myLeaves    = <LeaveModel>[].obs;
  final isLoadingMy = false.obs;

  // ── Admin: all leaves ─────────────────────────────────────
  final allLeaves    = <LeaveModel>[].obs;
  final isLoadingAll = false.obs;

  // ── Apply form ────────────────────────────────────────────
  final isApplying = false.obs;

  // ✅ API accepted values: casual, sick, earned, halfday, unpaid (lowercase)
  static const leaveTypeMap = <String, String>{
    'Casual':   'casual',
    'Sick':     'sick',
    'Earned':   'earned',
    'Half Day': 'halfday',
    'Unpaid':   'unpaid',
  };
  final leaveTypeOptions = ['Casual', 'Sick', 'Earned', 'Half Day', 'Unpaid'];

  final selectedLeaveType = ''.obs;
  final fromDate          = Rx<DateTime?>(null);
  final toDate            = Rx<DateTime?>(null);
  final reasonController  = TextEditingController();

  // ── Filters ───────────────────────────────────────────────
  final selectedStatus = 'All'.obs;
  final filterYear     = DateTime.now().year.obs;

  bool _myLeavesLoaded  = false;
  bool _allLeavesLoaded = false;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  // ─── USER: Fetch my leaves ────────────────────────────────
  Future<void> fetchMyLeaves({bool forceRefresh = false}) async {
    if (_myLeavesLoaded && !forceRefresh) return;

    isLoadingMy.value = true;
    try {
      final status = selectedStatus.value == 'All' ? null : selectedStatus.value;
      final leaves = await ApiService.getMyLeaves(
        status: status,
        year:   filterYear.value,
      );
      myLeaves.assignAll(leaves);
      _myLeavesLoaded = true;
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchMyLeaves',
        fallback: 'Unable to load leaves. Please try again.',
      );
    } finally {
      isLoadingMy.value = false;
    }
  }

  // ─── USER: Apply for leave ────────────────────────────────
  Future<bool> applyLeave() async {
    if (selectedLeaveType.value.isEmpty) {
      ResponseHandler.showWarning('Please select leave type.');
      return false;
    }
    if (fromDate.value == null || toDate.value == null) {
      ResponseHandler.showWarning('Please select from and to dates.');
      return false;
    }
    if (toDate.value!.isBefore(fromDate.value!)) {
      ResponseHandler.showWarning('To date cannot be before from date.');
      return false;
    }
    if (reasonController.text.trim().isEmpty) {
      ResponseHandler.showWarning('Please enter reason.');
      return false;
    }

    isApplying.value = true;
    try {
      final result = await ApiService.applyLeave(
        leaveType: leaveTypeMap[selectedLeaveType.value] ?? selectedLeaveType.value.toLowerCase(),
        fromDate:  DateFormat('yyyy-MM-dd').format(fromDate.value!),
        toDate:    DateFormat('yyyy-MM-dd').format(toDate.value!),
        reason:    reasonController.text.trim(),
      );

      if (result.success) {
        ResponseHandler.showSuccess(
          apiMessage: result.message,
          fallback:   'Leave applied successfully!',
        );
        _clearForm();
        await fetchMyLeaves(forceRefresh: true);
        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: result.message,
          fallback:   'Unable to apply leave. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'applyLeave',
        fallback: 'Unable to apply leave. Please try again.',
      );
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  // ─── USER: Cancel leave ───────────────────────────────────
  Future<void> cancelLeave(int leaveId) async {
    try {
      final res = await ApiService.cancelLeave(leaveId);
      if (res.success) {
        ResponseHandler.showSuccess(
          apiMessage: res.message,
          fallback:   'Leave cancelled successfully.',
        );
        await fetchMyLeaves(forceRefresh: true);
      } else {
        ResponseHandler.showError(
          apiMessage: res.message,
          fallback:   'Unable to cancel leave. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'cancelLeave',
        fallback: 'Unable to cancel leave. Please try again.',
      );
    }
  }

  // ─── ADMIN: Fetch all leaves ──────────────────────────────
  Future<void> fetchAllLeaves({bool forceRefresh = false}) async {
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
      _allLeavesLoaded = true;
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchAllLeaves',
        fallback: 'Unable to load leaves. Please try again.',
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─── ADMIN: Approve / Reject leave ───────────────────────
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
        ResponseHandler.showSuccess(
          apiMessage: result.message,
          fallback:   'Leave $status successfully!',
        );
        await fetchAllLeaves(forceRefresh: true);
      } else {
        ResponseHandler.showError(
          apiMessage: result.message,
          fallback:   'Unable to process leave action. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'takeLeaveAction',
        fallback: 'Unable to process leave action. Please try again.',
      );
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────
  void _clearForm() {
    selectedLeaveType.value = '';
    fromDate.value          = null;
    toDate.value            = null;
    reasonController.clear();
  }
}