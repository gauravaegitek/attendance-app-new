// lib/controllers/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/utils/response_handler.dart';

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
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'loadNotifications',
        fallback: 'Unable to load notifications. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      unreadCount.value = await ApiService.getUnreadCount();
    } catch (_) {
      // silent — badge failure shouldn't interrupt UX
    }
  }

  // ── Mark single read ──────────────────────────────────────────────────────
  Future<void> markRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      final ok = await ApiService.markNotificationRead(n.id);
      if (ok) {
        final idx = notifications.indexWhere((x) => x.id == n.id);
        if (idx != -1) {
          notifications[idx] = n.copyWith(isRead: true);
          if (unreadCount.value > 0) unreadCount.value--;
        }
      }
    } catch (_) {
      // silent
    }
  }

  // ── Mark all read ─────────────────────────────────────────────────────────
  Future<void> markAllRead() async {
    if (notifications.every((n) => n.isRead)) return;
    try {
      final ok = await ApiService.markAllNotificationsRead();
      if (ok) {
        notifications.assignAll(
          notifications.map((n) => n.copyWith(isRead: true)).toList(),
        );
        unreadCount.value = 0;
      }
    } catch (_) {
      // silent
    }
  }

  // ── Send notification (Admin only) ────────────────────────────────────────
  Future<void> sendNotification() async {
    if (!sendFormKey.currentState!.validate()) return;

    if (selectedUserId.value == null) {
      ResponseHandler.showWarning('Please select a user.');
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
        ResponseHandler.showSuccess(
          apiMessage: result.message,
          fallback:   'Notification sent successfully!',
        );
        await loadNotifications();
      } else {
        ResponseHandler.showError(
          apiMessage: result.message,
          fallback:   'Unable to send notification. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'sendNotification',
        fallback: 'Unable to send notification. Please try again.',
      );
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
