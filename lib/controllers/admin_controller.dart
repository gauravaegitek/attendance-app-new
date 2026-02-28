// lib/controllers/admin_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/response_handler.dart';

class AdminController extends GetxController {
  // =================== STATE ===================
  final isLoadingSummary = false.obs;
  final isExporting      = false.obs;
  final isLoadingUsers   = false.obs;
  final isLoadingRoles   = false.obs;

  final hasSearched = false.obs;

  bool _rolesInitializing = false;

  final adminRecords = <AttendanceRecord>[].obs;
  final allUsers     = <UserModel>[].obs;
  final roles        = <String>[].obs;

  final selectedRole = ''.obs;
  final fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final toDate   = DateTime.now().obs;

  // =================== LIFECYCLE ===================
  @override
  void onInit() {
    super.onInit();
    fetchRoles();
  }

  // =================== ROLES ===================
  Future<void> fetchRoles() async {
    _rolesInitializing = true;
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
      ResponseHandler.handleException(
        e,
        context: 'fetchRoles',
        fallback: 'Unable to load roles. Please try again.',
      );
      roles.value = ['all', ...AppConstants.allRoles];
      selectedRole.value = 'all';
    } finally {
      isLoadingRoles.value = false;
      _rolesInitializing = false;
    }
  }

  // =================== ADMIN SUMMARY ===================
  Future<void> fetchAdminSummary() async {
    if (_rolesInitializing) return;

    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      ResponseHandler.showWarning(
        'Date range cannot exceed 31 days.',
      );
      return;
    }

    isLoadingSummary.value = true;
    try {
      final records = await ApiService.getAdminSummary(
        role:     selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate:   AppUtils.formatDateApi(toDate.value),
        allRoles: roles,
      );

      records.sort((a, b) {
        final dateCompare = b.attendanceDate.compareTo(a.attendanceDate);
        if (dateCompare != 0) return dateCompare;
        final aTime = a.inTime ?? '';
        final bTime = b.inTime ?? '';
        return bTime.compareTo(aTime);
      });

      adminRecords.value = records;
      hasSearched.value  = true;
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchAdminSummary',
        fallback: 'Unable to load summary. Please try again.',
      );
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // =================== EXPORT PDF ===================
  Future<void> exportPdf() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      ResponseHandler.showWarning('Date range cannot exceed 31 days.');
      return;
    }

    isExporting.value = true;
    try {
      final success = await ApiService.exportAdminSummary(
        role:     selectedRole.value == 'all' ? '' : selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate:   AppUtils.formatDateApi(toDate.value),
        allRoles: roles,
      );

      if (success) {
        ResponseHandler.showSuccess(
          apiMessage: 'PDF exported successfully!',
        );
      } else {
        ResponseHandler.showError(
          apiMessage: '',
          fallback: 'Unable to export PDF. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'exportPdf',
        fallback: 'Unable to export PDF. Please try again.',
      );
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
      ResponseHandler.handleException(
        e,
        context: 'fetchAllUsers',
        fallback: 'Unable to load users. Please try again.',
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // =================== DATE PICKERS ===================
  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: fromDate.value,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value.isBefore(picked) ||
          toDate.value.difference(picked).inDays > 31) {
        final newToDate = picked.add(const Duration(days: 30));
        toDate.value =
            newToDate.isAfter(DateTime.now()) ? DateTime.now() : newToDate;
      }
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final maxToDate        = fromDate.value.add(const Duration(days: 31));
    final effectiveLastDate =
        maxToDate.isAfter(DateTime.now()) ? DateTime.now() : maxToDate;

    final picked = await showDatePicker(
      context:     context,
      initialDate: toDate.value.isAfter(effectiveLastDate)
          ? effectiveLastDate
          : toDate.value,
      firstDate:   fromDate.value,
      lastDate:    effectiveLastDate,
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
