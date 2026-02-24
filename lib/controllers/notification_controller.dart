// lib/controllers/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final notifications = <NotificationModel>[].obs;
  final unreadCount   = 0.obs;
  final isLoading     = false.obs;
  final isSending     = false.obs;

  // ── Send form (Admin only) ─────────────────────────────────────────────────
  final sendFormKey    = GlobalKey<FormState>();
  final titleCtrl      = TextEditingController();
  final messageCtrl    = TextEditingController();
  final selectedUserId = Rx<int?>(null);
  final selectedType   = 'info'.obs;

  // ── Role helper ───────────────────────────────────────────────────────────
  bool get isAdmin => StorageService.isAdmin();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }

  // ── Load notifications ────────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final list = await ApiService.getNotifications();
      list.sort((a, b) {
        if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
      notifications.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    unreadCount.value = await ApiService.getUnreadCount();
  }

  // ── Mark single read ──────────────────────────────────────────────────────
  Future<void> markRead(NotificationModel n) async {
    if (n.isRead) return;
    final ok = await ApiService.markNotificationRead(n.id);
    if (ok) {
      final idx = notifications.indexWhere((x) => x.id == n.id);
      if (idx != -1) {
        notifications[idx] = n.copyWith(isRead: true);
        if (unreadCount.value > 0) unreadCount.value--;
      }
    }
  }

  // ── Mark all read ─────────────────────────────────────────────────────────
  Future<void> markAllRead() async {
    if (notifications.every((n) => n.isRead)) return;
    final ok = await ApiService.markAllNotificationsRead();
    if (ok) {
      notifications.assignAll(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
      unreadCount.value = 0;
    }
  }

  // ── Send notification (Admin only) ────────────────────────────────────────
  Future<void> sendNotification() async {
    if (!sendFormKey.currentState!.validate()) return;
    if (selectedUserId.value == null) {
      Get.snackbar(
        'Error', 'Please select a user',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isSending.value = true;
    try {
      final result = await ApiService.sendNotification(
        userId:  selectedUserId.value!,
        title:   titleCtrl.text.trim(),
        message: messageCtrl.text.trim(),
        type:    selectedType.value,
      );

      if (result.success) {
        Get.back();
        _resetForm();
        Get.snackbar(
          '✅ Sent', 'Notification sent successfully!',
          backgroundColor: const Color(0xFF050B14),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 3),
        );
        await loadNotifications();
      } else {
        Get.snackbar(
          'Failed', result.message,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
        );
      }
    } finally {
      isSending.value = false;
    }
  }

  void _resetForm() {
    titleCtrl.clear();
    messageCtrl.clear();
    selectedUserId.value = null;
    selectedType.value   = 'info';
  }
}