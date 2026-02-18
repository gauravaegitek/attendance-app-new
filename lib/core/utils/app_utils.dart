import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AppUtils {
  // =================== DATE & TIME ===================
  static String formatDate(DateTime date) =>
      DateFormat('dd-MMM-yyyy').format(date);

  static String formatDateApi(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  static String formatHours(double? hours) {
    if (hours == null) return '0h 0m';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  static String formatDateDisplay(String? dateStr) {
    if (dateStr == null) return '--';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // =================== SNACKBARS ===================
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppTheme.successLight,
      colorText: AppTheme.success,
      icon: const Icon(Icons.check_circle, color: AppTheme.success),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppTheme.errorLight,
      colorText: AppTheme.error,
      icon: const Icon(Icons.error, color: AppTheme.error),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: AppTheme.warningLight,
      colorText: AppTheme.warning,
      icon: const Icon(Icons.warning, color: AppTheme.warning),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // =================== LOADING ===================
  static void showLoading({String message = 'Please wait...'}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(message, style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // =================== VALIDATION ===================
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  // =================== STATUS COLOR ===================
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return AppTheme.success;
      case 'incomplete':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return AppTheme.successLight;
      case 'incomplete':
        return AppTheme.warningLight;
      default:
        return AppTheme.background;
    }
  }

  // =================== DEVICE ID ===================
  static String generateDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
