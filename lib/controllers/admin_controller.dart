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

  final adminRecords = <AttendanceRecord>[].obs;
  final allUsers = <UserModel>[].obs;

  final selectedRole = 'employee'.obs;
  final fromDate = DateTime.now().subtract(const Duration(days: 6)).obs;
  final toDate = DateTime.now().obs;

  // =================== ADMIN SUMMARY ===================
  Future<void> fetchAdminSummary() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      AppUtils.showError('Date range cannot exceed 31 days');
      return;
    }

    isLoadingSummary.value = true;
    try {
      final records = await ApiService.getAdminSummary(
        role: selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate: AppUtils.formatDateApi(toDate.value),
      );
      adminRecords.value = records;
    } catch (e) {
      AppUtils.showError('Error: ${e.toString()}');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // =================== EXPORT PDF ===================
  Future<void> exportPdf() async {
    final diff = toDate.value.difference(fromDate.value).inDays;
    if (diff > 31) {
      AppUtils.showError('Date range cannot exceed 31 days');
      return;
    }

    isExporting.value = true;
    try {
      final success = await ApiService.exportAdminSummary(
        role: selectedRole.value,
        fromDate: AppUtils.formatDateApi(fromDate.value),
        toDate: AppUtils.formatDateApi(toDate.value),
      );

      if (success) {
        AppUtils.showSuccess('PDF exported successfully!');
      } else {
        AppUtils.showError('Failed to export PDF');
      }
    } catch (e) {
      AppUtils.showError('Export error: ${e.toString()}');
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
      AppUtils.showError('Error: ${e.toString()}');
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
      if (toDate.value.isBefore(picked)) toDate.value = picked;
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: fromDate.value,
      lastDate: DateTime.now(),
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

  List<String> get roleOptions => AppConstants.allRoles;
}
