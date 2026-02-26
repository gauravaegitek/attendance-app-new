// // lib/controllers/daily_task_controller.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../models/daily_task_model.dart';
// import '../services/api_service.dart';

// class DailyTaskController extends GetxController {
//   // ── User: my tasks ────────────────────────────────────────
//   final myTasks        = <DailyTaskModel>[].obs;
//   final todayMyTasks   = <DailyTaskModel>[].obs;
//   final isLoadingMy    = false.obs;
//   final isLoadingToday = false.obs;

//   // ── Admin: all tasks ──────────────────────────────────────
//   final allTasks          = <DailyTaskModel>[].obs;
//   final todayAllTasks     = <DailyTaskModel>[].obs;
//   final isLoadingAll      = false.obs;
//   final isLoadingAllToday = false.obs;

//   // ── Add/Edit form ─────────────────────────────────────────
//   final isSubmitting = false.obs;

//   final taskTitleCtrl       = TextEditingController();
//   final taskDescCtrl        = TextEditingController();
//   final projectNameCtrl     = TextEditingController();
//   final remarksCtrl         = TextEditingController();
//   final hoursSpentCtrl      = TextEditingController();
//   final selectedStatus      = 'Pending'.obs;
//   final selectedTaskDate    = Rx<DateTime>(DateTime.now());

//   final statusOptions = ['Pending', 'In Progress', 'Completed'];

//   // ── Filters ───────────────────────────────────────────────
//   final filterStatus   = 'All'.obs;
//   final filterFromDate = Rx<DateTime?>(null);
//   final filterToDate   = Rx<DateTime?>(null);

//   @override
//   void onInit() {
//     super.onInit();
//     fetchTodayMyTasks();
//     fetchMyTasks();
//   }

//   @override
//   void onClose() {
//     taskTitleCtrl.dispose();
//     taskDescCtrl.dispose();
//     projectNameCtrl.dispose();
//     remarksCtrl.dispose();
//     hoursSpentCtrl.dispose();
//     super.onClose();
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Today's tasks
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchTodayMyTasks() async {
//     isLoadingToday.value = true;
//     try {
//       final tasks = await ApiService.getMyTasksToday();
//       todayMyTasks.assignAll(tasks);
//     } catch (e) {
//       _showSnack('Failed to load today tasks: $e', isError: true);
//     } finally {
//       isLoadingToday.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: My tasks with filters
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchMyTasks() async {
//     isLoadingMy.value = true;
//     try {
//       final status = filterStatus.value == 'All' ? null : filterStatus.value;
//       final tasks = await ApiService.getMyTasks(
//         status:   status,
//         fromDate: filterFromDate.value != null
//             ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
//             : null,
//         toDate: filterToDate.value != null
//             ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
//             : null,
//       );
//       myTasks.assignAll(tasks);
//     } catch (e) {
//       _showSnack('Failed to load tasks: $e', isError: true);
//     } finally {
//       isLoadingMy.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Add task
//   // ─────────────────────────────────────────────────────────
//   Future<bool> addTask() async {
//     if (taskTitleCtrl.text.trim().isEmpty) {
//       _showSnack('Task title required', isError: true);
//       return false;
//     }
//     if (projectNameCtrl.text.trim().isEmpty) {
//       _showSnack('Project name required', isError: true);
//       return false;
//     }

//     isSubmitting.value = true;
//     try {
//       final result = await ApiService.addDailyTask(
//         taskDate:        DateFormat("yyyy-MM-dd'T'HH:mm:ss.000'Z'")
//             .format(selectedTaskDate.value),
//         taskTitle:       taskTitleCtrl.text.trim(),
//         taskDescription: taskDescCtrl.text.trim(),
//         projectName:     projectNameCtrl.text.trim(),
//         status:          selectedStatus.value,
//         hoursSpent:      double.tryParse(hoursSpentCtrl.text.trim()) ?? 0,
//         remarks:         remarksCtrl.text.trim(),
//       );
//       if (result.success) {
//         _showSnack('Task added successfully!');
//         _clearForm();
//         await fetchTodayMyTasks();
//         await fetchMyTasks();
//         return true;
//       } else {
//         _showSnack(result.message.isNotEmpty ? result.message : 'Add failed',
//             isError: true);
//         return false;
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Update task
//   // ─────────────────────────────────────────────────────────
//   Future<bool> updateTask(int taskId) async {
//     if (taskTitleCtrl.text.trim().isEmpty) {
//       _showSnack('Task title required', isError: true);
//       return false;
//     }

//     isSubmitting.value = true;
//     try {
//       final result = await ApiService.updateDailyTask(
//         taskId:          taskId,
//         taskTitle:       taskTitleCtrl.text.trim(),
//         taskDescription: taskDescCtrl.text.trim(),
//         projectName:     projectNameCtrl.text.trim(),
//         status:          selectedStatus.value,
//         hoursSpent:      double.tryParse(hoursSpentCtrl.text.trim()) ?? 0,
//         remarks:         remarksCtrl.text.trim(),
//       );
//       if (result.success) {
//         _showSnack('Task updated!');
//         _clearForm();
//         await fetchTodayMyTasks();
//         await fetchMyTasks();
//         return true;
//       } else {
//         _showSnack(result.message.isNotEmpty ? result.message : 'Update failed',
//             isError: true);
//         return false;
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  USER: Delete task
//   // ─────────────────────────────────────────────────────────
//   Future<void> deleteTask(int taskId) async {
//     try {
//       final success = await ApiService.deleteDailyTask(taskId);
//       if (success) {
//         _showSnack('Task deleted');
//         await fetchTodayMyTasks();
//         await fetchMyTasks();
//       } else {
//         _showSnack('Delete failed', isError: true);
//       }
//     } catch (e) {
//       _showSnack('Error: $e', isError: true);
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  ADMIN: All today tasks
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchAllTasksToday() async {
//     isLoadingAllToday.value = true;
//     try {
//       final tasks = await ApiService.getAllTasksToday();
//       todayAllTasks.assignAll(tasks);
//     } catch (e) {
//       _showSnack('Failed to load tasks: $e', isError: true);
//     } finally {
//       isLoadingAllToday.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  ADMIN: All tasks with filters
//   // ─────────────────────────────────────────────────────────
//   Future<void> fetchAllTasks({int? userId}) async {
//     isLoadingAll.value = true;
//     try {
//       final status = filterStatus.value == 'All' ? null : filterStatus.value;
//       final tasks = await ApiService.getAllTasks(
//         userId:   userId,
//         status:   status,
//         fromDate: filterFromDate.value != null
//             ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
//             : null,
//         toDate: filterToDate.value != null
//             ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
//             : null,
//       );
//       allTasks.assignAll(tasks);
//     } catch (e) {
//       _showSnack('Failed to load tasks: $e', isError: true);
//     } finally {
//       isLoadingAll.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   //  HELPERS
//   // ─────────────────────────────────────────────────────────
//   void prefillForEdit(DailyTaskModel task) {
//     taskTitleCtrl.text       = task.taskTitle;
//     taskDescCtrl.text        = task.taskDescription;
//     projectNameCtrl.text     = task.projectName;
//     remarksCtrl.text         = task.remarks;
//     hoursSpentCtrl.text      = task.hoursSpent.toString();
//     selectedStatus.value     = task.status;
//     selectedTaskDate.value   =
//         DateTime.tryParse(task.taskDate) ?? DateTime.now();
//   }

//   void _clearForm() {
//     taskTitleCtrl.clear();
//     taskDescCtrl.clear();
//     projectNameCtrl.clear();
//     remarksCtrl.clear();
//     hoursSpentCtrl.clear();
//     selectedStatus.value   = 'Pending';
//     selectedTaskDate.value = DateTime.now();
//   }

//   void _showSnack(String msg, {bool isError = false}) {
//     Get.snackbar(
//       isError ? 'Error' : 'Success',
//       msg,
//       snackPosition:   SnackPosition.BOTTOM,
//       backgroundColor: isError
//           ? const Color(0xFFEF4444)
//           : const Color(0xFF22C55E),
//       colorText:    const Color(0xFFFFFFFF),
//       margin:       const EdgeInsets.all(16),
//       borderRadius: 14,
//     );
//   }
// }









// lib/controllers/daily_task_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/daily_task_model.dart';
import '../services/api_service.dart';

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

  final taskTitleCtrl       = TextEditingController();
  final taskDescCtrl        = TextEditingController();
  final projectNameCtrl     = TextEditingController();
  final remarksCtrl         = TextEditingController();
  final hoursSpentCtrl      = TextEditingController();
  final selectedStatus      = 'Pending'.obs;
  final selectedTaskDate    = Rx<DateTime>(DateTime.now());

  final statusOptions = ['Pending', 'In Progress', 'Completed'];

  // ── Filters ───────────────────────────────────────────────
  final filterStatus   = 'All'.obs;
  final filterFromDate = Rx<DateTime?>(null);
  final filterToDate   = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchTodayMyTasks();
    fetchMyTasks();
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

  // ─────────────────────────────────────────────────────────
  //  STATUS NORMALIZER  ← FIX: converts API lowercase → Title Case
  // ─────────────────────────────────────────────────────────
  String _normalizeStatus(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'completed':
        return 'Completed';
      case 'in progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Today's tasks
  // ─────────────────────────────────────────────────────────
  Future<void> fetchTodayMyTasks() async {
    isLoadingToday.value = true;
    try {
      final tasks = await ApiService.getMyTasksToday();
      todayMyTasks.assignAll(tasks);
    } catch (e) {
      _showSnack('Failed to load today tasks: $e', isError: true);
    } finally {
      isLoadingToday.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: My tasks with filters
  // ─────────────────────────────────────────────────────────
  Future<void> fetchMyTasks() async {
    isLoadingMy.value = true;
    try {
      final status = filterStatus.value == 'All' ? null : filterStatus.value;
      final tasks = await ApiService.getMyTasks(
        status:   status,
        fromDate: filterFromDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
            : null,
        toDate: filterToDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
            : null,
      );
      myTasks.assignAll(tasks);
    } catch (e) {
      _showSnack('Failed to load tasks: $e', isError: true);
    } finally {
      isLoadingMy.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Add task
  // ─────────────────────────────────────────────────────────
  Future<bool> addTask() async {
    if (taskTitleCtrl.text.trim().isEmpty) {
      _showSnack('Task title required', isError: true);
      return false;
    }
    if (projectNameCtrl.text.trim().isEmpty) {
      _showSnack('Project name required', isError: true);
      return false;
    }

    isSubmitting.value = true;
    try {
      final result = await ApiService.addDailyTask(
        taskDate:        DateFormat("yyyy-MM-dd'T'HH:mm:ss.000'Z'")
            .format(selectedTaskDate.value),
        taskTitle:       taskTitleCtrl.text.trim(),
        taskDescription: taskDescCtrl.text.trim(),
        projectName:     projectNameCtrl.text.trim(),
        status:          selectedStatus.value,
        hoursSpent:      double.tryParse(hoursSpentCtrl.text.trim()) ?? 0,
        remarks:         remarksCtrl.text.trim(),
      );
      if (result.success) {
        _showSnack('Task added successfully!');
        _clearForm();
        await fetchTodayMyTasks();
        await fetchMyTasks();
        return true;
      } else {
        _showSnack(result.message.isNotEmpty ? result.message : 'Add failed',
            isError: true);
        return false;
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Update task
  // ─────────────────────────────────────────────────────────
  Future<bool> updateTask(int taskId) async {
    if (taskTitleCtrl.text.trim().isEmpty) {
      _showSnack('Task title required', isError: true);
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
        _showSnack('Task updated!');
        _clearForm();
        await fetchTodayMyTasks();
        await fetchMyTasks();
        return true;
      } else {
        _showSnack(result.message.isNotEmpty ? result.message : 'Update failed',
            isError: true);
        return false;
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  USER: Delete task
  // ─────────────────────────────────────────────────────────
  Future<void> deleteTask(int taskId) async {
    try {
      final success = await ApiService.deleteDailyTask(taskId);
      if (success) {
        _showSnack('Task deleted');
        await fetchTodayMyTasks();
        await fetchMyTasks();
      } else {
        _showSnack('Delete failed', isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN: All today tasks
  // ─────────────────────────────────────────────────────────
  Future<void> fetchAllTasksToday() async {
    isLoadingAllToday.value = true;
    try {
      final tasks = await ApiService.getAllTasksToday();
      todayAllTasks.assignAll(tasks);
    } catch (e) {
      _showSnack('Failed to load tasks: $e', isError: true);
    } finally {
      isLoadingAllToday.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ADMIN: All tasks with filters
  // ─────────────────────────────────────────────────────────
  Future<void> fetchAllTasks({int? userId}) async {
    isLoadingAll.value = true;
    try {
      final status = filterStatus.value == 'All' ? null : filterStatus.value;
      final tasks = await ApiService.getAllTasks(
        userId:   userId,
        status:   status,
        fromDate: filterFromDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate.value!)
            : null,
        toDate: filterToDate.value != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate.value!)
            : null,
      );
      allTasks.assignAll(tasks);
    } catch (e) {
      _showSnack('Failed to load tasks: $e', isError: true);
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────

  /// Prefill edit form — status is normalized from API lowercase → Title Case
  void prefillForEdit(DailyTaskModel task) {
    taskTitleCtrl.text     = task.taskTitle;
    taskDescCtrl.text      = task.taskDescription;
    projectNameCtrl.text   = task.projectName;
    remarksCtrl.text       = task.remarks;
    hoursSpentCtrl.text    = task.hoursSpent.toString();
    selectedStatus.value   = _normalizeStatus(task.status); // ← FIX
    selectedTaskDate.value = DateTime.tryParse(task.taskDate) ?? DateTime.now();
  }

  /// Call this whenever edit sheet is closed without saving
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