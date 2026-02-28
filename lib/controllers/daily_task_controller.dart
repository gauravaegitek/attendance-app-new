// lib/controllers/daily_task_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/daily_task_model.dart';
import '../services/api_service.dart';
import '../core/utils/response_handler.dart';

class DailyTaskController extends GetxController {
  // ── User: my tasks ────────────────────────────────────────
  final myTasks        = <DailyTaskModel>[].obs;
  final todayMyTasks   = <DailyTaskModel>[].obs;
  final isLoadingMy    = false.obs;
  final isLoadingToday = false.obs;

  // ── Admin: all tasks ──────────────────────────────────────
  final allTasks          = <DailyTaskModel>[].obs;
  final todayAllTasks     = <DailyTaskModel>[].obs;
  final isLoadingAll      = false.obs;
  final isLoadingAllToday = false.obs;

  // ── Add/Edit form ─────────────────────────────────────────
  final isSubmitting = false.obs;

  final taskTitleCtrl   = TextEditingController();
  final taskDescCtrl    = TextEditingController();
  final projectNameCtrl = TextEditingController();
  final remarksCtrl     = TextEditingController();
  final hoursSpentCtrl  = TextEditingController();
  final selectedStatus   = 'Pending'.obs;
  final selectedTaskDate = Rx<DateTime>(DateTime.now());

  final statusOptions = ['Pending', 'In Progress', 'Completed'];

  // ── Separate filters for each tab ─────────────────────────
  final myFilterStatus  = 'All'.obs;
  final allFilterStatus = 'All'.obs;

  final filterFromDate = Rx<DateTime?>(null);
  final filterToDate   = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    taskTitleCtrl.dispose();
    taskDescCtrl.dispose();
    projectNameCtrl.dispose();
    remarksCtrl.dispose();
    hoursSpentCtrl.dispose();
    super.onClose();
  }

  // ─── API STATUS ENCODER ───────────────────────────────────
  String? _encodeStatus(String filter) {
    if (filter == 'All') return null;
    switch (filter.toLowerCase().trim()) {
      case 'in progress': return 'inprogress';
      case 'completed':   return 'completed';
      case 'pending':     return 'pending';
      default:            return null;
    }
  }

  // ─── UI STATUS NORMALIZER ─────────────────────────────────
  String _normalizeStatus(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'completed':   return 'Completed';
      case 'inprogress':
      case 'in progress': return 'In Progress';
      case 'pending':
      default:            return 'Pending';
    }
  }

  // ─── USER: Today's tasks ──────────────────────────────────
  Future<void> fetchTodayMyTasks() async {
    isLoadingToday.value = true;
    try {
      final tasks = await ApiService.getMyTasksToday();
      todayMyTasks.assignAll(tasks);
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchTodayMyTasks',
        fallback: 'Unable to load today\'s tasks. Please try again.',
      );
    } finally {
      isLoadingToday.value = false;
    }
  }

  // ─── USER: My tasks with filters ──────────────────────────
  Future<void> fetchMyTasks() async {
    isLoadingMy.value = true;
    try {
      final tasks = await ApiService.getMyTasks(
        status:   _encodeStatus(myFilterStatus.value),
        fromDate: filterFromDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
            : null,
        toDate: filterToDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
            : null,
      );
      myTasks.assignAll(tasks);
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchMyTasks',
        fallback: 'Unable to load tasks. Please try again.',
      );
    } finally {
      isLoadingMy.value = false;
    }
  }

  // ─── USER: Add task ───────────────────────────────────────
  Future<bool> addTask() async {
    if (taskTitleCtrl.text.trim().isEmpty) {
      ResponseHandler.showWarning('Task title is required.');
      return false;
    }
    if (projectNameCtrl.text.trim().isEmpty) {
      ResponseHandler.showWarning('Project name is required.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final result = await ApiService.addDailyTask(
        taskDate: DateFormat("yyyy-MM-dd'T'HH:mm:ss.000'Z'")
            .format(selectedTaskDate.value),
        taskTitle:       taskTitleCtrl.text.trim(),
        taskDescription: taskDescCtrl.text.trim(),
        projectName:     projectNameCtrl.text.trim(),
        status:          selectedStatus.value,
        hoursSpent:      double.tryParse(hoursSpentCtrl.text.trim()) ?? 0,
        remarks:         remarksCtrl.text.trim(),
      );

      if (result.success) {
        ResponseHandler.showSuccess(
          apiMessage: result.message,
          fallback:   'Task added successfully!',
        );
        _clearForm();
        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: result.message,
          fallback:   'Unable to add task. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'addTask',
        fallback: 'Unable to add task. Please try again.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── USER: Update task ────────────────────────────────────
  Future<bool> updateTask(int taskId) async {
    if (taskTitleCtrl.text.trim().isEmpty) {
      ResponseHandler.showWarning('Task title is required.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final result = await ApiService.updateDailyTask(
        taskId:          taskId,
        taskTitle:       taskTitleCtrl.text.trim(),
        taskDescription: taskDescCtrl.text.trim(),
        projectName:     projectNameCtrl.text.trim(),
        status:          selectedStatus.value,
        hoursSpent:      double.tryParse(hoursSpentCtrl.text.trim()) ?? 0,
        remarks:         remarksCtrl.text.trim(),
      );

      if (result.success) {
        _clearForm();
        Get.back();

        final tabCtrl = DefaultTabController.maybeOf(Get.context!);
        tabCtrl?.animateTo(1);

        await fetchTodayMyTasks();
        await fetchMyTasks();

        ResponseHandler.showSuccess(
          apiMessage: result.message,
          fallback:   'Task updated successfully!',
        );
        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: result.message,
          fallback:   'Unable to update task. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'updateTask',
        fallback: 'Unable to update task. Please try again.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── USER: Delete task ────────────────────────────────────
  Future<void> deleteTask(int taskId) async {
    try {
      final res = await ApiService.deleteDailyTask(taskId);
      if (res.success) {
        ResponseHandler.showSuccess(
          apiMessage: res.message,
          fallback:   'Task deleted successfully.',
        );
        await fetchTodayMyTasks();
        await fetchMyTasks();
      } else {
        ResponseHandler.showError(
          apiMessage: res.message,
          fallback:   'Unable to delete task. Please try again.',
        );
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'deleteTask',
        fallback: 'Unable to delete task. Please try again.',
      );
    }
  }

  // ─── ADMIN: All today tasks ───────────────────────────────
  Future<void> fetchAllTasksToday() async {
    isLoadingAllToday.value = true;
    try {
      final tasks = await ApiService.getAllTasksToday();
      todayAllTasks.assignAll(tasks);
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchAllTasksToday',
        fallback: 'Unable to load tasks. Please try again.',
      );
    } finally {
      isLoadingAllToday.value = false;
    }
  }

  // ─── ADMIN: All tasks with filters ───────────────────────
  Future<void> fetchAllTasks({int? userId}) async {
    isLoadingAll.value = true;
    try {
      final tasks = await ApiService.getAllTasks(
        userId:   userId,
        status:   _encodeStatus(allFilterStatus.value),
        fromDate: filterFromDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
            : null,
        toDate: filterToDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
            : null,
      );
      allTasks.assignAll(tasks);
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'fetchAllTasks',
        fallback: 'Unable to load tasks. Please try again.',
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────
  void prefillForEdit(DailyTaskModel task) {
    taskTitleCtrl.text   = task.taskTitle;
    taskDescCtrl.text    = task.taskDescription;
    projectNameCtrl.text = task.projectName;
    remarksCtrl.text     = task.remarks;
    hoursSpentCtrl.text  = task.hoursSpent.toString();
    selectedStatus.value =
        _normalizeStatus(task.status);
    selectedTaskDate.value =
        DateTime.tryParse(task.taskDate) ?? DateTime.now();
  }

  void clearForm() => _clearForm();

  void _clearForm() {
    taskTitleCtrl.clear();
    taskDescCtrl.clear();
    projectNameCtrl.clear();
    remarksCtrl.clear();
    hoursSpentCtrl.clear();
    selectedStatus.value   = 'Pending';
    selectedTaskDate.value = DateTime.now();
  }
}
