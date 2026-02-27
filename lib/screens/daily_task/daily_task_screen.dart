// // lib/screens/daily_task/daily_task_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/daily_task_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/daily_task_model.dart';

// class DailyTaskScreen extends StatelessWidget {
//   const DailyTaskScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController());
//     }

//     return Obx(() {
//       final isAdmin = auth.isAdmin;

//       if (isAdmin) {
//         return DefaultTabController(
//           length: 3,
//           child: Scaffold(
//             backgroundColor: AppTheme.background,
//             appBar: _buildAppBar(isAdmin: true),
//             body: const TabBarView(children: [
//               _AddTaskTab(),
//               _MyTasksTab(),
//               _AdminAllTasksTab(), // Admin only
//             ]),
//           ),
//         );
//       }

//       return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: AppTheme.background,
//           appBar: _buildAppBar(isAdmin: false),
//           body: const TabBarView(children: [
//             _AddTaskTab(),
//             _MyTasksTab(),
//           ]),
//         ),
//       );
//     });
//   }

//   PreferredSizeWidget _buildAppBar({required bool isAdmin}) {
//     return AppBar(
//       backgroundColor: AppTheme.cardBackground,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_rounded,
//             color: AppTheme.textPrimary, size: 20),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         isAdmin ? 'Daily Task Management' : 'My Daily Tasks',
//         style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//             color: AppTheme.textPrimary),
//       ),
//       bottom: TabBar(
//         labelColor: AppTheme.primary,
//         unselectedLabelColor: AppTheme.textSecondary,
//         indicatorColor: AppTheme.primary,
//         labelStyle: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 13),
//         tabs: [
//           const Tab(text: 'Add Task'),
//           const Tab(text: 'My Tasks'),
//           if (isAdmin) const Tab(text: 'All Tasks'),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADD TASK TAB
// // ─────────────────────────────────────────────────────────────
// class _AddTaskTab extends StatelessWidget {
//   const _AddTaskTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(18),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const SizedBox(height: 8),

//         // Task Date
//         _Label('Task Date'),
//         const SizedBox(height: 8),
//         Obx(() => _DatePickerField(
//               label: DateFormat('dd MMM yyyy').format(ctrl.selectedTaskDate.value),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: ctrl.selectedTaskDate.value,
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime(2030),
//                 );
//                 if (picked != null) ctrl.selectedTaskDate.value = picked;
//               },
//             )),

//         const SizedBox(height: 16),
//         _Label('Task Title *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskTitleCtrl,
//           hint: 'e.g. Implement login screen',
//         ),

//         const SizedBox(height: 16),
//         _Label('Task Description'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskDescCtrl,
//           hint: 'Describe your task...',
//           maxLines: 3,
//         ),

//         const SizedBox(height: 16),
//         _Label('Project Name *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.projectNameCtrl,
//           hint: 'e.g. Attendance App',
//         ),

//         const SizedBox(height: 16),
//         Row(children: [
//           Expanded(
//             flex: 2,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Status'),
//               const SizedBox(height: 8),
//               Obx(() => Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 4),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         isExpanded: true,
//                         value: ctrl.selectedStatus.value,
//                         items: ctrl.statusOptions
//                             .map((s) => DropdownMenuItem(
//                                   value: s,
//                                   child: Text(s,
//                                       style: const TextStyle(
//                                           fontFamily: 'Poppins',
//                                           fontSize: 13)),
//                                 ))
//                             .toList(),
//                         onChanged: (v) =>
//                             ctrl.selectedStatus.value = v ?? 'Pending',
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Hours Spent'),
//               const SizedBox(height: 8),
//               _TextField(
//                 controller: ctrl.hoursSpentCtrl,
//                 hint: '0',
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(
//                       RegExp(r'^\d+\.?\d{0,1}')),
//                 ],
//               ),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 16),
//         _Label('Remarks'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.remarksCtrl,
//           hint: 'Any additional notes...',
//           maxLines: 2,
//         ),

//         const SizedBox(height: 28),
//         Obx(() => SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: ctrl.isSubmitting.value ? null : () => ctrl.addTask(),
//                 icon: ctrl.isSubmitting.value
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                     : const Icon(Icons.add_task_rounded,
//                         color: Colors.white),
//                 label: Text(
//                     ctrl.isSubmitting.value ? 'Adding...' : 'Add Task',
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                         color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   elevation: 0,
//                 ),
//               ),
//             )),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  MY TASKS TAB (User)
// // ─────────────────────────────────────────────────────────────
// class _MyTasksTab extends StatelessWidget {
//   const _MyTasksTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       // Today's summary banner
//       Obx(() {
//         if (ctrl.isLoadingToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayMyTasks.length;
//         final done = ctrl.todayMyTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours = ctrl.todayMyTasks
//             .fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours);
//       }),

//       // Filters
//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchMyTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () async {
//               await ctrl.fetchTodayMyTasks();
//               await ctrl.fetchMyTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingMy.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.myTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.task_alt_rounded,
//               title: 'No tasks found',
//               sub: 'Add a task to get started',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchMyTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.myTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.myTasks[i],
//                 isAdmin: false,
//                 onEdit: () =>
//                     _showEditDialog(context, ctrl, ctrl.myTasks[i]),
//                 onDelete: () =>
//                     _confirmDelete(context, ctrl, ctrl.myTasks[i].id),
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }

//   void _showEditDialog(
//       BuildContext context, DailyTaskController ctrl, DailyTaskModel task) {
//     ctrl.prefillForEdit(task);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _EditTaskSheet(taskId: task.id),
//     );
//   }

//   void _confirmDelete(
//       BuildContext context, DailyTaskController ctrl, int taskId) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Delete Task?',
//             style: TextStyle(
//                 fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         content: const Text(
//             'This action cannot be undone.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               ctrl.deleteTask(taskId);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.error,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Delete',
//                 style: TextStyle(
//                     color: Colors.white, fontFamily: 'Poppins')),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADMIN: ALL TASKS TAB
// // ─────────────────────────────────────────────────────────────
// class _AdminAllTasksTab extends StatefulWidget {
//   const _AdminAllTasksTab();

//   @override
//   State<_AdminAllTasksTab> createState() => _AdminAllTasksTabState();
// }

// class _AdminAllTasksTabState extends State<_AdminAllTasksTab>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final ctrl = Get.find<DailyTaskController>();
//       ctrl.fetchAllTasksToday();
//       ctrl.fetchAllTasks();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       // Today banner
//       Obx(() {
//         if (ctrl.isLoadingAllToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayAllTasks.length;
//         final done = ctrl.todayAllTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours = ctrl.todayAllTasks
//             .fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours, isAdmin: true);
//       }),

//       // Filters
//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchAllTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () {
//               ctrl.fetchAllTasksToday();
//               ctrl.fetchAllTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingAll.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.allTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.inbox_rounded,
//               title: 'No tasks found',
//               sub: 'No tasks for selected filter',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchAllTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.allTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.allTasks[i],
//                 isAdmin: true,
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  EDIT TASK BOTTOM SHEET
// // ─────────────────────────────────────────────────────────────
// class _EditTaskSheet extends StatelessWidget {
//   final int taskId;
//   const _EditTaskSheet({required this.taskId});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Container(
//       padding: EdgeInsets.fromLTRB(
//           20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
//       decoration: const BoxDecoration(
//         color: AppTheme.cardBackground,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//           Center(
//             child: Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                   color: AppTheme.divider,
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text('Edit Task',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: AppTheme.textPrimary)),
//           const SizedBox(height: 16),

//           _Label('Task Title *'),
//           const SizedBox(height: 8),
//           _TextField(controller: ctrl.taskTitleCtrl, hint: 'Task title'),

//           const SizedBox(height: 12),
//           _Label('Task Description'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.taskDescCtrl,
//               hint: 'Description',
//               maxLines: 2),

//           const SizedBox(height: 12),
//           _Label('Project Name'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.projectNameCtrl, hint: 'Project name'),

//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(
//               flex: 2,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Status'),
//                 const SizedBox(height: 8),
//                 Obx(() => Container(
//                       decoration: AppTheme.cardDecoration(),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: ctrl.selectedStatus.value,
//                           items: ctrl.statusOptions
//                               .map((s) => DropdownMenuItem(
//                                     value: s,
//                                     child: Text(s,
//                                         style: const TextStyle(
//                                             fontFamily: 'Poppins',
//                                             fontSize: 13)),
//                                   ))
//                               .toList(),
//                           onChanged: (v) =>
//                               ctrl.selectedStatus.value = v ?? 'Pending',
//                         ),
//                       ),
//                     )),
//               ]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Hours'),
//                 const SizedBox(height: 8),
//                 _TextField(
//                   controller: ctrl.hoursSpentCtrl,
//                   hint: '0',
//                   keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                         RegExp(r'^\d+\.?\d{0,1}')),
//                   ],
//                 ),
//               ]),
//             ),
//           ]),

//           const SizedBox(height: 12),
//           _Label('Remarks'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.remarksCtrl,
//               hint: 'Remarks...',
//               maxLines: 2),

//           const SizedBox(height: 20),
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: ctrl.isSubmitting.value
//                       ? null
//                       : () async {
//                           final ok = await ctrl.updateTask(taskId);
//                           if (ok) Get.back();
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     elevation: 0,
//                   ),
//                   child: ctrl.isSubmitting.value
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text('Update Task',
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white)),
//                 ),
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED: TASK CARD
// // ─────────────────────────────────────────────────────────────
// class _TaskCard extends StatelessWidget {
//   final DailyTaskModel task;
//   final bool           isAdmin;
//   final VoidCallback?  onEdit;
//   final VoidCallback?  onDelete;

//   const _TaskCard({
//     required this.task,
//     required this.isAdmin,
//     this.onEdit,
//     this.onDelete,
//   });

//   Color get _statusColor {
//     switch (task.status.toLowerCase()) {
//       case 'completed':   return AppTheme.success;
//       case 'in progress': return AppTheme.primary;
//       default:            return AppTheme.warning;
//     }
//   }

//   IconData get _statusIcon {
//     switch (task.status.toLowerCase()) {
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'in progress': return Icons.timelapse_rounded;
//       default:            return Icons.schedule_rounded;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateStr = task.taskDate.isNotEmpty
//         ? DateFormat('dd MMM yyyy')
//             .format(DateTime.tryParse(task.taskDate) ?? DateTime.now())
//         : '—';

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Header
//         Row(children: [
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: AppTheme.primary.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Text(task.projectName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.primary)),
//           ),
//           const Spacer(),
//           // Status badge
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: _statusColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(_statusIcon, color: _statusColor, size: 13),
//               const SizedBox(width: 4),
//               Text(task.status,
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: _statusColor)),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 10),

//         // Admin sees employee name
//         if (isAdmin)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(children: [
//               const Icon(Icons.person_outline_rounded,
//                   size: 15, color: AppTheme.textSecondary),
//               const SizedBox(width: 6),
//               Text(task.userName,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary)),
//             ]),
//           ),

//         // Title
//         Text(task.taskTitle,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textPrimary)),

//         if (task.taskDescription.isNotEmpty) ...[
//           const SizedBox(height: 4),
//           Text(task.taskDescription,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textSecondary)),
//         ],

//         const SizedBox(height: 10),

//         // Meta row
//         Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text(dateStr,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//           const SizedBox(width: 14),
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text('${task.hoursSpent}h',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//         ]),

//         if (task.remarks.isNotEmpty) ...[
//           const SizedBox(height: 6),
//           Row(crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//             const Icon(Icons.notes_rounded,
//                 size: 13, color: AppTheme.info),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(task.remarks,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: AppTheme.info,
//                       fontStyle: FontStyle.italic)),
//             ),
//           ]),
//         ],

//         // User: Edit / Delete buttons
//         if (!isAdmin) ...[
//           const SizedBox(height: 12),
//           const Divider(color: AppTheme.divider, height: 1),
//           const SizedBox(height: 10),
//           Row(children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: onEdit,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.edit_rounded,
//                             color: AppTheme.primary, size: 16),
//                         SizedBox(width: 6),
//                         Text('Edit',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.primary,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GestureDetector(
//                 onTap: onDelete,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.error.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.delete_outline_rounded,
//                             color: AppTheme.error, size: 16),
//                         SizedBox(width: 6),
//                         Text('Delete',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.error,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  TODAY SUMMARY BANNER
// // ─────────────────────────────────────────────────────────────
// class _TodaySummaryBanner extends StatelessWidget {
//   final int    total;
//   final int    done;
//   final double hours;
//   final bool   isAdmin;

//   const _TodaySummaryBanner({
//     required this.total,
//     required this.done,
//     required this.hours,
//     this.isAdmin = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primary,
//             AppTheme.primary.withOpacity(0.75),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(children: [
//         const Icon(Icons.today_rounded, color: Colors.white, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             isAdmin ? "Today's Team Tasks" : "Today's Tasks",
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//                 fontSize: 14),
//           ),
//         ),
//         _StatChip(label: '$total Total', icon: Icons.list_rounded),
//         const SizedBox(width: 8),
//         _StatChip(
//             label: '$done Done',
//             icon: Icons.check_rounded,
//             color: AppTheme.success),
//         const SizedBox(width: 8),
//         _StatChip(
//             label: '${hours}h',
//             icon: Icons.access_time_rounded),
//       ]),
//     );
//   }
// }

// class _StatChip extends StatelessWidget {
//   final String   label;
//   final IconData icon;
//   final Color    color;
//   const _StatChip({
//     required this.label,
//     required this.icon,
//     this.color = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8)),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 3),
//           Text(label,
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: color)),
//         ]),
//       );
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED SMALL WIDGETS
// // ─────────────────────────────────────────────────────────────

// class _StatusFilter extends StatelessWidget {
//   final String selected;
//   final void Function(String) onChanged;
//   const _StatusFilter(
//       {required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     const options = ['All', 'Pending', 'In Progress', 'Completed'];
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: options.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (_, i) {
//           final isSelected = selected == options[i];
//           return GestureDetector(
//             onTap: () => onChanged(options[i]),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppTheme.primary
//                     : AppTheme.cardBackground,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                     color: isSelected
//                         ? AppTheme.primary
//                         : AppTheme.divider),
//               ),
//               alignment: Alignment.center,
//               child: Text(options[i],
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected
//                           ? Colors.white
//                           : AppTheme.textSecondary)),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _DatePickerField extends StatelessWidget {
//   final String       label;
//   final VoidCallback onTap;
//   const _DatePickerField(
//       {required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               color: AppTheme.primary, size: 18),
//           const SizedBox(width: 10),
//           Text(label,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textPrimary)),
//         ]),
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final TextEditingController     controller;
//   final String                    hint;
//   final int                       maxLines;
//   final TextInputType?            keyboardType;
//   final List<TextInputFormatter>? inputFormatters;

//   const _TextField({
//     required this.controller,
//     required this.hint,
//     this.maxLines = 1,
//     this.keyboardType,
//     this.inputFormatters,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child: TextField(
//         controller:      controller,
//         maxLines:        maxLines,
//         keyboardType:    keyboardType,
//         inputFormatters: inputFormatters,
//         style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               color: AppTheme.textHint,
//               fontSize: 14),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.all(14),
//         ),
//       ),
//     );
//   }
// }

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textSecondary));
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   title;
//   final String   sub;
//   const _EmptyState(
//       {required this.icon, required this.title, required this.sub});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 64, color: AppTheme.divider),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textSecondary)),
//         const SizedBox(height: 6),
//         Text(sub,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: AppTheme.textHint)),
//       ]),
//     );
//   }
// }






// // lib/screens/daily_task/daily_task_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/daily_task_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/daily_task_model.dart';

// class DailyTaskScreen extends StatelessWidget {
//   const DailyTaskScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController());
//     }

//     return Obx(() {
//       final isAdmin = auth.isAdmin;

//       if (isAdmin) {
//         return DefaultTabController(
//           length: 3,
//           child: Scaffold(
//             backgroundColor: AppTheme.background,
//             appBar: _buildAppBar(isAdmin: true),
//             body: const TabBarView(children: [
//               _AddTaskTab(),
//               _MyTasksTab(),
//               _AdminAllTasksTab(),
//             ]),
//           ),
//         );
//       }

//       return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: AppTheme.background,
//           appBar: _buildAppBar(isAdmin: false),
//           body: const TabBarView(children: [
//             _AddTaskTab(),
//             _MyTasksTab(),
//           ]),
//         ),
//       );
//     });
//   }

//   PreferredSizeWidget _buildAppBar({required bool isAdmin}) {
//     return AppBar(
//       backgroundColor: AppTheme.cardBackground,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_rounded,
//             color: AppTheme.textPrimary, size: 20),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         isAdmin ? 'Daily Task Management' : 'My Daily Tasks',
//         style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//             color: AppTheme.textPrimary),
//       ),
//       bottom: TabBar(
//         labelColor: AppTheme.primary,
//         unselectedLabelColor: AppTheme.textSecondary,
//         indicatorColor: AppTheme.primary,
//         labelStyle: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 13),
//         tabs: [
//           const Tab(text: 'Add Task'),
//           const Tab(text: 'My Tasks'),
//           if (isAdmin) const Tab(text: 'All Tasks'),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADD TASK TAB
// // ─────────────────────────────────────────────────────────────
// class _AddTaskTab extends StatelessWidget {
//   const _AddTaskTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(18),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const SizedBox(height: 8),

//         // Task Date
//         _Label('Task Date'),
//         const SizedBox(height: 8),
//         Obx(() => _DatePickerField(
//               label: DateFormat('dd MMM yyyy').format(ctrl.selectedTaskDate.value),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: ctrl.selectedTaskDate.value,
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime(2030),
//                 );
//                 if (picked != null) ctrl.selectedTaskDate.value = picked;
//               },
//             )),

//         const SizedBox(height: 16),
//         _Label('Task Title *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskTitleCtrl,
//           hint: 'e.g. Implement login screen',
//         ),

//         const SizedBox(height: 16),
//         _Label('Task Description'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskDescCtrl,
//           hint: 'Describe your task...',
//           maxLines: 3,
//         ),

//         const SizedBox(height: 16),
//         _Label('Project Name *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.projectNameCtrl,
//           hint: 'e.g. Attendance App',
//         ),

//         const SizedBox(height: 16),
//         Row(children: [
//           Expanded(
//             flex: 2,
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Status'),
//               const SizedBox(height: 8),
//               Obx(() => Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 4),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         isExpanded: true,
//                         value: ctrl.selectedStatus.value,
//                         items: ctrl.statusOptions
//                             .map((s) => DropdownMenuItem(
//                                   value: s,
//                                   child: Text(s,
//                                       style: const TextStyle(
//                                           fontFamily: 'Poppins',
//                                           fontSize: 13)),
//                                 ))
//                             .toList(),
//                         onChanged: (v) =>
//                             ctrl.selectedStatus.value = v ?? 'Pending',
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Hours Spent'),
//               const SizedBox(height: 8),
//               _TextField(
//                 controller: ctrl.hoursSpentCtrl,
//                 hint: '0',
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(
//                       RegExp(r'^\d+\.?\d{0,1}')),
//                 ],
//               ),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 16),
//         _Label('Remarks'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.remarksCtrl,
//           hint: 'Any additional notes...',
//           maxLines: 2,
//         ),

//         const SizedBox(height: 28),
//         Obx(() => SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: ctrl.isSubmitting.value ? null : () => ctrl.addTask(),
//                 icon: ctrl.isSubmitting.value
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                     : const Icon(Icons.add_task_rounded,
//                         color: Colors.white),
//                 label: Text(
//                     ctrl.isSubmitting.value ? 'Adding...' : 'Add Task',
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                         color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   elevation: 0,
//                 ),
//               ),
//             )),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  MY TASKS TAB (User)
// // ─────────────────────────────────────────────────────────────
// class _MyTasksTab extends StatelessWidget {
//   const _MyTasksTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       // Today's summary banner
//       Obx(() {
//         if (ctrl.isLoadingToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayMyTasks.length;
//         final done = ctrl.todayMyTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours = ctrl.todayMyTasks
//             .fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours);
//       }),

//       // Filters
//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchMyTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () async {
//               await ctrl.fetchTodayMyTasks();
//               await ctrl.fetchMyTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingMy.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.myTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.task_alt_rounded,
//               title: 'No tasks found',
//               sub: 'Add a task to get started',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchMyTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.myTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.myTasks[i],
//                 isAdmin: false,
//                 onEdit: () =>
//                     _showEditDialog(context, ctrl, ctrl.myTasks[i]),
//                 onDelete: () =>
//                     _confirmDelete(context, ctrl, ctrl.myTasks[i].id),
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }

//   void _showEditDialog(
//       BuildContext context, DailyTaskController ctrl, DailyTaskModel task) {
//     ctrl.prefillForEdit(task);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _EditTaskSheet(taskId: task.id),
//     ).whenComplete(() {
//       // ← FIX: always clear form on dismiss so Add Task tab stays clean
//       ctrl.clearForm();
//     });
//   }

//   void _confirmDelete(
//       BuildContext context, DailyTaskController ctrl, int taskId) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Delete Task?',
//             style: TextStyle(
//                 fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         content: const Text(
//             'This action cannot be undone.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               ctrl.deleteTask(taskId);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.error,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Delete',
//                 style: TextStyle(
//                     color: Colors.white, fontFamily: 'Poppins')),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADMIN: ALL TASKS TAB
// // ─────────────────────────────────────────────────────────────
// class _AdminAllTasksTab extends StatefulWidget {
//   const _AdminAllTasksTab();

//   @override
//   State<_AdminAllTasksTab> createState() => _AdminAllTasksTabState();
// }

// class _AdminAllTasksTabState extends State<_AdminAllTasksTab>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final ctrl = Get.find<DailyTaskController>();
//       ctrl.fetchAllTasksToday();
//       ctrl.fetchAllTasks();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       // Today banner
//       Obx(() {
//         if (ctrl.isLoadingAllToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayAllTasks.length;
//         final done = ctrl.todayAllTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours = ctrl.todayAllTasks
//             .fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours, isAdmin: true);
//       }),

//       // Filters
//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchAllTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () {
//               ctrl.fetchAllTasksToday();
//               ctrl.fetchAllTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingAll.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.allTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.inbox_rounded,
//               title: 'No tasks found',
//               sub: 'No tasks for selected filter',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchAllTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.allTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.allTasks[i],
//                 isAdmin: true,
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  EDIT TASK BOTTOM SHEET
// // ─────────────────────────────────────────────────────────────
// class _EditTaskSheet extends StatelessWidget {
//   final int taskId;
//   const _EditTaskSheet({required this.taskId});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Container(
//       padding: EdgeInsets.fromLTRB(
//           20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
//       decoration: const BoxDecoration(
//         color: AppTheme.cardBackground,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//           Center(
//             child: Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                   color: AppTheme.divider,
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text('Edit Task',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: AppTheme.textPrimary)),
//           const SizedBox(height: 16),

//           _Label('Task Title *'),
//           const SizedBox(height: 8),
//           _TextField(controller: ctrl.taskTitleCtrl, hint: 'Task title'),

//           const SizedBox(height: 12),
//           _Label('Task Description'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.taskDescCtrl,
//               hint: 'Description',
//               maxLines: 2),

//           const SizedBox(height: 12),
//           _Label('Project Name'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.projectNameCtrl, hint: 'Project name'),

//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(
//               flex: 2,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Status'),
//                 const SizedBox(height: 8),
//                 Obx(() => Container(
//                       decoration: AppTheme.cardDecoration(),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: ctrl.selectedStatus.value,
//                           items: ctrl.statusOptions
//                               .map((s) => DropdownMenuItem(
//                                     value: s,
//                                     child: Text(s,
//                                         style: const TextStyle(
//                                             fontFamily: 'Poppins',
//                                             fontSize: 13)),
//                                   ))
//                               .toList(),
//                           onChanged: (v) =>
//                               ctrl.selectedStatus.value = v ?? 'Pending',
//                         ),
//                       ),
//                     )),
//               ]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Hours'),
//                 const SizedBox(height: 8),
//                 _TextField(
//                   controller: ctrl.hoursSpentCtrl,
//                   hint: '0',
//                   keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                         RegExp(r'^\d+\.?\d{0,1}')),
//                   ],
//                 ),
//               ]),
//             ),
//           ]),

//           const SizedBox(height: 12),
//           _Label('Remarks'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.remarksCtrl,
//               hint: 'Remarks...',
//               maxLines: 2),

//           const SizedBox(height: 20),
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: ctrl.isSubmitting.value
//                       ? null
//                       : () async {
//                           final ok = await ctrl.updateTask(taskId);
//                           if (ok) Get.back();
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     elevation: 0,
//                   ),
//                   child: ctrl.isSubmitting.value
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text('Update Task',
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white)),
//                 ),
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED: TASK CARD
// // ─────────────────────────────────────────────────────────────
// class _TaskCard extends StatelessWidget {
//   final DailyTaskModel task;
//   final bool           isAdmin;
//   final VoidCallback?  onEdit;
//   final VoidCallback?  onDelete;

//   const _TaskCard({
//     required this.task,
//     required this.isAdmin,
//     this.onEdit,
//     this.onDelete,
//   });

//   // ── FIX: compare lowercase so API values like "completed" work too ──
//   Color get _statusColor {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':   return AppTheme.success;
//       case 'in progress': return AppTheme.primary;
//       default:            return AppTheme.warning;
//     }
//   }

//   IconData get _statusIcon {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'in progress': return Icons.timelapse_rounded;
//       default:            return Icons.schedule_rounded;
//     }
//   }

//   /// Display status in Title Case regardless of what the API returns
//   String get _statusLabel {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':   return 'Completed';
//       case 'in progress': return 'In Progress';
//       default:            return 'Pending';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateStr = task.taskDate.isNotEmpty
//         ? DateFormat('dd MMM yyyy')
//             .format(DateTime.tryParse(task.taskDate) ?? DateTime.now())
//         : '—';

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // Header
//         Row(children: [
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: AppTheme.primary.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Text(task.projectName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.primary)),
//           ),
//           const Spacer(),
//           // Status badge
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: _statusColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(_statusIcon, color: _statusColor, size: 13),
//               const SizedBox(width: 4),
//               Text(_statusLabel, // ← uses normalized label
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: _statusColor)),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 10),

//         // Admin sees employee name
//         if (isAdmin)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(children: [
//               const Icon(Icons.person_outline_rounded,
//                   size: 15, color: AppTheme.textSecondary),
//               const SizedBox(width: 6),
//               Text(task.userName,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary)),
//             ]),
//           ),

//         // Title
//         Text(task.taskTitle,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textPrimary)),

//         if (task.taskDescription.isNotEmpty) ...[
//           const SizedBox(height: 4),
//           Text(task.taskDescription,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textSecondary)),
//         ],

//         const SizedBox(height: 10),

//         // Meta row
//         Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text(dateStr,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//           const SizedBox(width: 14),
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text('${task.hoursSpent}h',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//         ]),

//         if (task.remarks.isNotEmpty) ...[
//           const SizedBox(height: 6),
//           Row(crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//             const Icon(Icons.notes_rounded,
//                 size: 13, color: AppTheme.info),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(task.remarks,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: AppTheme.info,
//                       fontStyle: FontStyle.italic)),
//             ),
//           ]),
//         ],

//         // User: Edit / Delete buttons
//         if (!isAdmin) ...[
//           const SizedBox(height: 12),
//           const Divider(color: AppTheme.divider, height: 1),
//           const SizedBox(height: 10),
//           Row(children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: onEdit,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.edit_rounded,
//                             color: AppTheme.primary, size: 16),
//                         SizedBox(width: 6),
//                         Text('Edit',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.primary,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GestureDetector(
//                 onTap: onDelete,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.error.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.delete_outline_rounded,
//                             color: AppTheme.error, size: 16),
//                         SizedBox(width: 6),
//                         Text('Delete',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.error,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  TODAY SUMMARY BANNER
// // ─────────────────────────────────────────────────────────────
// class _TodaySummaryBanner extends StatelessWidget {
//   final int    total;
//   final int    done;
//   final double hours;
//   final bool   isAdmin;

//   const _TodaySummaryBanner({
//     required this.total,
//     required this.done,
//     required this.hours,
//     this.isAdmin = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primary,
//             AppTheme.primary.withOpacity(0.75),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(children: [
//         const Icon(Icons.today_rounded, color: Colors.white, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             isAdmin ? "Today's Team Tasks" : "Today's Tasks",
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//                 fontSize: 14),
//           ),
//         ),
//         _StatChip(label: '$total Total', icon: Icons.list_rounded),
//         const SizedBox(width: 8),
//         _StatChip(
//             label: '$done Done',
//             icon: Icons.check_rounded,
//             color: AppTheme.success),
//         const SizedBox(width: 8),
//         _StatChip(
//             label: '${hours}h',
//             icon: Icons.access_time_rounded),
//       ]),
//     );
//   }
// }

// class _StatChip extends StatelessWidget {
//   final String   label;
//   final IconData icon;
//   final Color    color;
//   const _StatChip({
//     required this.label,
//     required this.icon,
//     this.color = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8)),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 3),
//           Text(label,
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: color)),
//         ]),
//       );
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED SMALL WIDGETS
// // ─────────────────────────────────────────────────────────────

// class _StatusFilter extends StatelessWidget {
//   final String selected;
//   final void Function(String) onChanged;
//   const _StatusFilter(
//       {required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     const options = ['All', 'Pending', 'In Progress', 'Completed'];
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: options.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (_, i) {
//           final isSelected = selected == options[i];
//           return GestureDetector(
//             onTap: () => onChanged(options[i]),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppTheme.primary
//                     : AppTheme.cardBackground,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                     color: isSelected
//                         ? AppTheme.primary
//                         : AppTheme.divider),
//               ),
//               alignment: Alignment.center,
//               child: Text(options[i],
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected
//                           ? Colors.white
//                           : AppTheme.textSecondary)),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _DatePickerField extends StatelessWidget {
//   final String       label;
//   final VoidCallback onTap;
//   const _DatePickerField(
//       {required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               color: AppTheme.primary, size: 18),
//           const SizedBox(width: 10),
//           Text(label,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textPrimary)),
//         ]),
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final TextEditingController     controller;
//   final String                    hint;
//   final int                       maxLines;
//   final TextInputType?            keyboardType;
//   final List<TextInputFormatter>? inputFormatters;

//   const _TextField({
//     required this.controller,
//     required this.hint,
//     this.maxLines = 1,
//     this.keyboardType,
//     this.inputFormatters,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child: TextField(
//         controller:      controller,
//         maxLines:        maxLines,
//         keyboardType:    keyboardType,
//         inputFormatters: inputFormatters,
//         style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               color: AppTheme.textHint,
//               fontSize: 14),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.all(14),
//         ),
//       ),
//     );
//   }
// }

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textSecondary));
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String   title;
//   final String   sub;
//   const _EmptyState(
//       {required this.icon, required this.title, required this.sub});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 64, color: AppTheme.divider),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textSecondary)),
//         const SizedBox(height: 6),
//         Text(sub,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: AppTheme.textHint)),
//       ]),
//     );
//   }
// }








// // lib/screens/daily_task/daily_task_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/daily_task_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/daily_task_model.dart';

// class DailyTaskScreen extends StatelessWidget {
//   const DailyTaskScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthController>();
//     if (!Get.isRegistered<DailyTaskController>()) {
//       Get.put(DailyTaskController());
//     }

//     return Obx(() {
//       final isAdmin = auth.isAdmin;

//       if (isAdmin) {
//         return DefaultTabController(
//           length: 3,
//           child: Scaffold(
//             backgroundColor: AppTheme.background,
//             appBar: _buildAppBar(isAdmin: true),
//             body: const TabBarView(children: [
//               _AddTaskTab(),
//               _MyTasksTab(),
//               _AdminAllTasksTab(),
//             ]),
//           ),
//         );
//       }

//       return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: AppTheme.background,
//           appBar: _buildAppBar(isAdmin: false),
//           body: const TabBarView(children: [
//             _AddTaskTab(),
//             _MyTasksTab(),
//           ]),
//         ),
//       );
//     });
//   }

//   PreferredSizeWidget _buildAppBar({required bool isAdmin}) {
//     return AppBar(
//       backgroundColor: AppTheme.cardBackground,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_rounded,
//             color: AppTheme.textPrimary, size: 20),
//         onPressed: () => Get.back(),
//       ),
//       title: Text(
//         isAdmin ? 'Daily Task Management' : 'My Daily Tasks',
//         style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//             color: AppTheme.textPrimary),
//       ),
//       bottom: TabBar(
//         labelColor: AppTheme.primary,
//         unselectedLabelColor: AppTheme.textSecondary,
//         indicatorColor: AppTheme.primary,
//         labelStyle: const TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 13),
//         tabs: [
//           const Tab(text: 'Add Task'),
//           const Tab(text: 'My Tasks'),
//           if (isAdmin) const Tab(text: 'All Tasks'),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADD TASK TAB
// // ─────────────────────────────────────────────────────────────
// class _AddTaskTab extends StatelessWidget {
//   const _AddTaskTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(18),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const SizedBox(height: 8),

//         _Label('Task Date'),
//         const SizedBox(height: 8),
//         Obx(() => _DatePickerField(
//               label: DateFormat('dd MMM yyyy')
//                   .format(ctrl.selectedTaskDate.value),
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: ctrl.selectedTaskDate.value,
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime(2030),
//                 );
//                 if (picked != null) ctrl.selectedTaskDate.value = picked;
//               },
//             )),

//         const SizedBox(height: 16),
//         _Label('Task Title *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskTitleCtrl,
//           hint: 'e.g. Implement login screen',
//         ),

//         const SizedBox(height: 16),
//         _Label('Task Description'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.taskDescCtrl,
//           hint: 'Describe your task...',
//           maxLines: 3,
//         ),

//         const SizedBox(height: 16),
//         _Label('Project Name *'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.projectNameCtrl,
//           hint: 'e.g. Attendance App',
//         ),

//         const SizedBox(height: 16),
//         Row(children: [
//           Expanded(
//             flex: 2,
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Status'),
//               const SizedBox(height: 8),
//               Obx(() => Container(
//                     decoration: AppTheme.cardDecoration(),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 4),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         isExpanded: true,
//                         value: ctrl.selectedStatus.value,
//                         items: ctrl.statusOptions
//                             .map((s) => DropdownMenuItem(
//                                   value: s,
//                                   child: Text(s,
//                                       style: const TextStyle(
//                                           fontFamily: 'Poppins',
//                                           fontSize: 13)),
//                                 ))
//                             .toList(),
//                         onChanged: (v) =>
//                             ctrl.selectedStatus.value = v ?? 'Pending',
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               _Label('Hours Spent'),
//               const SizedBox(height: 8),
//               _TextField(
//                 controller: ctrl.hoursSpentCtrl,
//                 hint: '0',
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(
//                       RegExp(r'^\d+\.?\d{0,1}')),
//                 ],
//               ),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 16),
//         _Label('Remarks'),
//         const SizedBox(height: 8),
//         _TextField(
//           controller: ctrl.remarksCtrl,
//           hint: 'Any additional notes...',
//           maxLines: 2,
//         ),

//         const SizedBox(height: 28),
//         Obx(() => SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed:
//                     ctrl.isSubmitting.value ? null : () => ctrl.addTask(),
//                 icon: ctrl.isSubmitting.value
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                     : const Icon(Icons.add_task_rounded,
//                         color: Colors.white),
//                 label: Text(
//                     ctrl.isSubmitting.value ? 'Adding...' : 'Add Task',
//                     style: const TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 15,
//                         color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   elevation: 0,
//                 ),
//               ),
//             )),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  MY TASKS TAB
// // ─────────────────────────────────────────────────────────────
// class _MyTasksTab extends StatelessWidget {
//   const _MyTasksTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       Obx(() {
//         if (ctrl.isLoadingToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayMyTasks.length;
//         final done = ctrl.todayMyTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours =
//             ctrl.todayMyTasks.fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours);
//       }),

//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchMyTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () async {
//               await ctrl.fetchTodayMyTasks();
//               await ctrl.fetchMyTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingMy.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.myTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.task_alt_rounded,
//               title: 'No tasks found',
//               sub: 'Add a task to get started',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchMyTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.myTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.myTasks[i],
//                 isAdmin: false,
//                 onEdit: () =>
//                     _showEditDialog(context, ctrl, ctrl.myTasks[i]),
//                 onDelete: () =>
//                     _confirmDelete(context, ctrl, ctrl.myTasks[i].id),
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }

//   void _showEditDialog(
//       BuildContext context, DailyTaskController ctrl, DailyTaskModel task) {
//     ctrl.prefillForEdit(task);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _EditTaskSheet(taskId: task.id),
//     ).whenComplete(() => ctrl.clearForm());
//   }

//   void _confirmDelete(
//       BuildContext context, DailyTaskController ctrl, int taskId) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Delete Task?',
//             style: TextStyle(
//                 fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         content: const Text('This action cannot be undone.',
//             style: TextStyle(
//                 fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               ctrl.deleteTask(taskId);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.error,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Delete',
//                 style: TextStyle(
//                     color: Colors.white, fontFamily: 'Poppins')),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  ADMIN: ALL TASKS TAB
// // ─────────────────────────────────────────────────────────────
// class _AdminAllTasksTab extends StatefulWidget {
//   const _AdminAllTasksTab();

//   @override
//   State<_AdminAllTasksTab> createState() => _AdminAllTasksTabState();
// }

// class _AdminAllTasksTabState extends State<_AdminAllTasksTab>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final ctrl = Get.find<DailyTaskController>();
//       ctrl.fetchAllTasksToday();
//       ctrl.fetchAllTasks();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final ctrl = Get.find<DailyTaskController>();

//     return Column(children: [
//       Obx(() {
//         if (ctrl.isLoadingAllToday.value) return const SizedBox.shrink();
//         final total = ctrl.todayAllTasks.length;
//         final done = ctrl.todayAllTasks
//             .where((t) => t.status.toLowerCase() == 'completed')
//             .length;
//         final hours =
//             ctrl.todayAllTasks.fold<double>(0, (s, t) => s + t.hoursSpent);
//         return _TodaySummaryBanner(
//             total: total, done: done, hours: hours, isAdmin: true);
//       }),

//       Padding(
//         padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
//         child: Row(children: [
//           Expanded(
//             child: Obx(() => _StatusFilter(
//                   selected: ctrl.filterStatus.value,
//                   onChanged: (v) {
//                     ctrl.filterStatus.value = v;
//                     ctrl.fetchAllTasks();
//                   },
//                 )),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () {
//               ctrl.fetchAllTasksToday();
//               ctrl.fetchAllTasks();
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: AppTheme.primaryLight,
//                   borderRadius: BorderRadius.circular(12)),
//               child: const Icon(Icons.refresh_rounded,
//                   color: AppTheme.primary, size: 20),
//             ),
//           ),
//         ]),
//       ),
//       const SizedBox(height: 10),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingAll.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.allTasks.isEmpty) {
//             return _EmptyState(
//               icon: Icons.inbox_rounded,
//               title: 'No tasks found',
//               sub: 'No tasks for selected filter',
//             );
//           }
//           return RefreshIndicator(
//             onRefresh: ctrl.fetchAllTasks,
//             child: ListView.separated(
//               padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
//               itemCount: ctrl.allTasks.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (_, i) => _TaskCard(
//                 task: ctrl.allTasks[i],
//                 isAdmin: true,
//               ),
//             ),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  EDIT TASK BOTTOM SHEET
// // ─────────────────────────────────────────────────────────────
// class _EditTaskSheet extends StatelessWidget {
//   final int taskId;
//   const _EditTaskSheet({required this.taskId});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<DailyTaskController>();

//     return Container(
//       padding: EdgeInsets.fromLTRB(
//           20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
//       decoration: const BoxDecoration(
//         color: AppTheme.cardBackground,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//           Center(
//             child: Container(
//               width: 44,
//               height: 5,
//               decoration: BoxDecoration(
//                   color: AppTheme.divider,
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text('Edit Task',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                   color: AppTheme.textPrimary)),
//           const SizedBox(height: 16),

//           _Label('Task Title *'),
//           const SizedBox(height: 8),
//           _TextField(controller: ctrl.taskTitleCtrl, hint: 'Task title'),

//           const SizedBox(height: 12),
//           _Label('Task Description'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.taskDescCtrl,
//               hint: 'Description',
//               maxLines: 2),

//           const SizedBox(height: 12),
//           _Label('Project Name'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.projectNameCtrl, hint: 'Project name'),

//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(
//               flex: 2,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Status'),
//                 const SizedBox(height: 8),
//                 Obx(() => Container(
//                       decoration: AppTheme.cardDecoration(),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: ctrl.selectedStatus.value,
//                           items: ctrl.statusOptions
//                               .map((s) => DropdownMenuItem(
//                                     value: s,
//                                     child: Text(s,
//                                         style: const TextStyle(
//                                             fontFamily: 'Poppins',
//                                             fontSize: 13)),
//                                   ))
//                               .toList(),
//                           onChanged: (v) =>
//                               ctrl.selectedStatus.value = v ?? 'Pending',
//                         ),
//                       ),
//                     )),
//               ]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 _Label('Hours'),
//                 const SizedBox(height: 8),
//                 _TextField(
//                   controller: ctrl.hoursSpentCtrl,
//                   hint: '0',
//                   keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                         RegExp(r'^\d+\.?\d{0,1}')),
//                   ],
//                 ),
//               ]),
//             ),
//           ]),

//           const SizedBox(height: 12),
//           _Label('Remarks'),
//           const SizedBox(height: 8),
//           _TextField(
//               controller: ctrl.remarksCtrl,
//               hint: 'Remarks...',
//               maxLines: 2),

//           const SizedBox(height: 20),
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   // ── FIX: Get.back() removed here — controller handles it ──
//                   onPressed: ctrl.isSubmitting.value
//                       ? null
//                       : () => ctrl.updateTask(taskId),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                     elevation: 0,
//                   ),
//                   child: ctrl.isSubmitting.value
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text('Update Task',
//                           style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white)),
//                 ),
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED: TASK CARD
// // ─────────────────────────────────────────────────────────────
// class _TaskCard extends StatelessWidget {
//   final DailyTaskModel task;
//   final bool isAdmin;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const _TaskCard({
//     required this.task,
//     required this.isAdmin,
//     this.onEdit,
//     this.onDelete,
//   });

//   Color get _statusColor {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':
//         return AppTheme.success;
//       case 'inprogress':
//       case 'in progress':
//         return AppTheme.primary;
//       default:
//         return AppTheme.warning;
//     }
//   }

//   IconData get _statusIcon {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':
//         return Icons.check_circle_rounded;
//       case 'inprogress':
//       case 'in progress':
//         return Icons.timelapse_rounded;
//       default:
//         return Icons.schedule_rounded;
//     }
//   }

//   String get _statusLabel {
//     switch (task.status.toLowerCase().trim()) {
//       case 'completed':
//         return 'Completed';
//       case 'inprogress':
//       case 'in progress':
//         return 'In Progress';
//       default:
//         return 'Pending';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateStr = task.taskDate.isNotEmpty
//         ? DateFormat('dd MMM yyyy')
//             .format(DateTime.tryParse(task.taskDate) ?? DateTime.now())
//         : '—';

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(16),
//       child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: AppTheme.primary.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Text(task.projectName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.primary)),
//           ),
//           const Spacer(),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: _statusColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8)),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(_statusIcon, color: _statusColor, size: 13),
//               const SizedBox(width: 4),
//               Text(_statusLabel,
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: _statusColor)),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 10),

//         if (isAdmin)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(children: [
//               const Icon(Icons.person_outline_rounded,
//                   size: 15, color: AppTheme.textSecondary),
//               const SizedBox(width: 6),
//               Text(task.userName,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary)),
//             ]),
//           ),

//         Text(task.taskTitle,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textPrimary)),

//         if (task.taskDescription.isNotEmpty) ...[
//           const SizedBox(height: 4),
//           Text(task.taskDescription,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textSecondary)),
//         ],

//         const SizedBox(height: 10),

//         Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text(dateStr,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//           const SizedBox(width: 14),
//           const Icon(Icons.access_time_rounded,
//               size: 13, color: AppTheme.textSecondary),
//           const SizedBox(width: 4),
//           Text('${task.hoursSpent}h',
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.textSecondary)),
//         ]),

//         if (task.remarks.isNotEmpty) ...[
//           const SizedBox(height: 6),
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Icon(Icons.notes_rounded,
//                 size: 13, color: AppTheme.info),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(task.remarks,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: AppTheme.info,
//                       fontStyle: FontStyle.italic)),
//             ),
//           ]),
//         ],

//         if (!isAdmin) ...[
//           const SizedBox(height: 12),
//           const Divider(color: AppTheme.divider, height: 1),
//           const SizedBox(height: 10),
//           Row(children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: onEdit,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.primary.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.edit_rounded,
//                             color: AppTheme.primary, size: 16),
//                         SizedBox(width: 6),
//                         Text('Edit',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.primary,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GestureDetector(
//                 onTap: onDelete,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                       color: AppTheme.error.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.delete_outline_rounded,
//                             color: AppTheme.error, size: 16),
//                         SizedBox(width: 6),
//                         Text('Delete',
//                             style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 color: AppTheme.error,
//                                 fontWeight: FontWeight.w700)),
//                       ]),
//                 ),
//               ),
//             ),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// //  TODAY SUMMARY BANNER
// // ─────────────────────────────────────────────────────────────
// class _TodaySummaryBanner extends StatelessWidget {
//   final int total;
//   final int done;
//   final double hours;
//   final bool isAdmin;

//   const _TodaySummaryBanner({
//     required this.total,
//     required this.done,
//     required this.hours,
//     this.isAdmin = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.primary,
//             AppTheme.primary.withOpacity(0.75),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Row(children: [
//         const Icon(Icons.today_rounded, color: Colors.white, size: 22),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             isAdmin ? "Today's Team Tasks" : "Today's Tasks",
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//                 fontSize: 14),
//           ),
//         ),
//         _StatChip(label: '$total Total', icon: Icons.list_rounded),
//         const SizedBox(width: 8),
//         _StatChip(
//             label: '$done Done',
//             icon: Icons.check_rounded,
//             color: AppTheme.success),
//         const SizedBox(width: 8),
//         _StatChip(label: '${hours}h', icon: Icons.access_time_rounded),
//       ]),
//     );
//   }
// }

// class _StatChip extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _StatChip({
//     required this.label,
//     required this.icon,
//     this.color = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8)),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 3),
//           Text(label,
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: color)),
//         ]),
//       );
// }

// // ─────────────────────────────────────────────────────────────
// //  SHARED SMALL WIDGETS
// // ─────────────────────────────────────────────────────────────
// class _StatusFilter extends StatelessWidget {
//   final String selected;
//   final void Function(String) onChanged;
//   const _StatusFilter(
//       {required this.selected, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     const options = ['All', 'Pending', 'In Progress', 'Completed'];
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: options.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (_, i) {
//           final isSelected = selected == options[i];
//           return GestureDetector(
//             onTap: () => onChanged(options[i]),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppTheme.primary
//                     : AppTheme.cardBackground,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                     color: isSelected
//                         ? AppTheme.primary
//                         : AppTheme.divider),
//               ),
//               alignment: Alignment.center,
//               child: Text(options[i],
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected
//                           ? Colors.white
//                           : AppTheme.textSecondary)),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _DatePickerField extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _DatePickerField({required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: AppTheme.cardDecoration(),
//         child: Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               color: AppTheme.primary, size: 18),
//           const SizedBox(width: 10),
//           Text(label,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textPrimary)),
//         ]),
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final int maxLines;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;

//   const _TextField({
//     required this.controller,
//     required this.hint,
//     this.maxLines = 1,
//     this.keyboardType,
//     this.inputFormatters,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               color: AppTheme.textHint,
//               fontSize: 14),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.all(14),
//         ),
//       ),
//     );
//   }
// }

// class _Label extends StatelessWidget {
//   final String text;
//   const _Label(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textSecondary));
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String sub;
//   const _EmptyState(
//       {required this.icon, required this.title, required this.sub});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 64, color: AppTheme.divider),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textSecondary)),
//         const SizedBox(height: 6),
//         Text(sub,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: AppTheme.textHint)),
//       ]),
//     );
//   }
// }














// lib/screens/daily_task/daily_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/daily_task_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/daily_task_model.dart';

class DailyTaskScreen extends StatelessWidget {
  const DailyTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (!Get.isRegistered<DailyTaskController>()) {
      Get.put(DailyTaskController());
    }
    final ctrl = Get.find<DailyTaskController>();

    return Obx(() {
      final isAdmin = auth.isAdmin;

      if (isAdmin) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: _buildAppBar(isAdmin: true, ctrl: ctrl),
            body: const TabBarView(children: [
              _AddTaskTab(),
              _MyTasksTab(),
              _AdminAllTasksTab(),
            ]),
          ),
        );
      }

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _buildAppBar(isAdmin: false, ctrl: ctrl),
          body: const TabBarView(children: [
            _AddTaskTab(),
            _MyTasksTab(),
          ]),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar({
    required bool isAdmin,
    required DailyTaskController ctrl,
  }) {
    return AppBar(
      backgroundColor: AppTheme.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppTheme.textPrimary, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        isAdmin ? 'Daily Task Management' : 'My Daily Tasks',
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.textPrimary),
      ),
      bottom: TabBar(
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primary,
        labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13),
        // ── FIX: API call only on tab tap ──
        onTap: (index) {
          if (isAdmin) {
            switch (index) {
              case 1: // My Tasks
                ctrl.fetchTodayMyTasks();
                ctrl.fetchMyTasks();
                break;
              case 2: // All Tasks
                ctrl.fetchAllTasksToday();
                ctrl.fetchAllTasks();
                break;
            }
          } else {
            if (index == 1) {
              ctrl.fetchTodayMyTasks();
              ctrl.fetchMyTasks();
            }
          }
        },
        tabs: [
          const Tab(text: 'Add Task'),
          const Tab(text: 'My Tasks'),
          if (isAdmin) const Tab(text: 'All Tasks'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD TASK TAB
// ─────────────────────────────────────────────────────────────
class _AddTaskTab extends StatelessWidget {
  const _AddTaskTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DailyTaskController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),

        _Label('Task Date'),
        const SizedBox(height: 8),
        Obx(() => _DatePickerField(
              label: DateFormat('dd MMM yyyy')
                  .format(ctrl.selectedTaskDate.value),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: ctrl.selectedTaskDate.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) ctrl.selectedTaskDate.value = picked;
              },
            )),

        const SizedBox(height: 16),
        _Label('Task Title *'),
        const SizedBox(height: 8),
        _TextField(
          controller: ctrl.taskTitleCtrl,
          hint: 'e.g. Implement login screen',
        ),

        const SizedBox(height: 16),
        _Label('Task Description'),
        const SizedBox(height: 8),
        _TextField(
          controller: ctrl.taskDescCtrl,
          hint: 'Describe your task...',
          maxLines: 3,
        ),

        const SizedBox(height: 16),
        _Label('Project Name *'),
        const SizedBox(height: 8),
        _TextField(
          controller: ctrl.projectNameCtrl,
          hint: 'e.g. Attendance App',
        ),

        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            flex: 2,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _Label('Status'),
              const SizedBox(height: 8),
              Obx(() => Container(
                    decoration: AppTheme.cardDecoration(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: ctrl.selectedStatus.value,
                        items: ctrl.statusOptions
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            ctrl.selectedStatus.value = v ?? 'Pending',
                      ),
                    ),
                  )),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _Label('Hours Spent'),
              const SizedBox(height: 8),
              _TextField(
                controller: ctrl.hoursSpentCtrl,
                hint: '0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,1}')),
                ],
              ),
            ]),
          ),
        ]),

        const SizedBox(height: 16),
        _Label('Remarks'),
        const SizedBox(height: 8),
        _TextField(
          controller: ctrl.remarksCtrl,
          hint: 'Any additional notes...',
          maxLines: 2,
        ),

        const SizedBox(height: 28),
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    ctrl.isSubmitting.value ? null : () => ctrl.addTask(),
                icon: ctrl.isSubmitting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.add_task_rounded,
                        color: Colors.white),
                label: Text(
                    ctrl.isSubmitting.value ? 'Adding...' : 'Add Task',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MY TASKS TAB
// ─────────────────────────────────────────────────────────────
class _MyTasksTab extends StatelessWidget {
  const _MyTasksTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DailyTaskController>();

    return Column(children: [
      Obx(() {
        if (ctrl.isLoadingToday.value) return const SizedBox.shrink();
        final total = ctrl.todayMyTasks.length;
        final done = ctrl.todayMyTasks
            .where((t) => t.status.toLowerCase() == 'completed')
            .length;
        final hours =
            ctrl.todayMyTasks.fold<double>(0, (s, t) => s + t.hoursSpent);
        return _TodaySummaryBanner(total: total, done: done, hours: hours);
      }),

      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Row(children: [
          Expanded(
            child: Obx(() => _StatusFilter(
                  selected: ctrl.myFilterStatus.value,
                  onChanged: (v) {
                    ctrl.myFilterStatus.value = v;
                    ctrl.fetchMyTasks();
                  },
                )),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await ctrl.fetchTodayMyTasks();
              await ctrl.fetchMyTasks();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.refresh_rounded,
                  color: AppTheme.primary, size: 20),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),

      Expanded(
        child: Obx(() {
          if (ctrl.isLoadingMy.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.myTasks.isEmpty) {
            return _EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'No tasks found',
              sub: 'Tap "My Tasks" tab to load',
            );
          }
          return RefreshIndicator(
            onRefresh: ctrl.fetchMyTasks,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              itemCount: ctrl.myTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TaskCard(
                task: ctrl.myTasks[i],
                isAdmin: false,
                onEdit: () =>
                    _showEditDialog(context, ctrl, ctrl.myTasks[i]),
                onDelete: () =>
                    _confirmDelete(context, ctrl, ctrl.myTasks[i].id),
              ),
            ),
          );
        }),
      ),
    ]);
  }

  void _showEditDialog(
      BuildContext context, DailyTaskController ctrl, DailyTaskModel task) {
    ctrl.prefillForEdit(task);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTaskSheet(taskId: task.id),
    ).whenComplete(() => ctrl.clearForm());
  }

  void _confirmDelete(
      BuildContext context, DailyTaskController ctrl, int taskId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task?',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(
                fontFamily: 'Poppins', color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteTask(taskId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADMIN: ALL TASKS TAB
// ─────────────────────────────────────────────────────────────
class _AdminAllTasksTab extends StatelessWidget {
  const _AdminAllTasksTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DailyTaskController>();

    return Column(children: [
      Obx(() {
        if (ctrl.isLoadingAllToday.value) return const SizedBox.shrink();
        final total = ctrl.todayAllTasks.length;
        final done = ctrl.todayAllTasks
            .where((t) => t.status.toLowerCase() == 'completed')
            .length;
        final hours =
            ctrl.todayAllTasks.fold<double>(0, (s, t) => s + t.hoursSpent);
        return _TodaySummaryBanner(
            total: total, done: done, hours: hours, isAdmin: true);
      }),

      Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
        child: Row(children: [
          Expanded(
            child: Obx(() => _StatusFilter(
                  selected: ctrl.allFilterStatus.value,
                  onChanged: (v) {
                    ctrl.allFilterStatus.value = v;
                    ctrl.fetchAllTasks();
                  },
                )),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ctrl.fetchAllTasksToday();
              ctrl.fetchAllTasks();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.refresh_rounded,
                  color: AppTheme.primary, size: 20),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 10),

      Expanded(
        child: Obx(() {
          if (ctrl.isLoadingAll.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.allTasks.isEmpty) {
            return _EmptyState(
              icon: Icons.inbox_rounded,
              title: 'No tasks found',
              sub: 'Tap "All Tasks" tab to load',
            );
          }
          return RefreshIndicator(
            onRefresh: ctrl.fetchAllTasks,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              itemCount: ctrl.allTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TaskCard(
                task: ctrl.allTasks[i],
                isAdmin: true,
              ),
            ),
          );
        }),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
//  EDIT TASK BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class _EditTaskSheet extends StatelessWidget {
  final int taskId;
  const _EditTaskSheet({required this.taskId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DailyTaskController>();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Edit Task',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),

          _Label('Task Title *'),
          const SizedBox(height: 8),
          _TextField(controller: ctrl.taskTitleCtrl, hint: 'Task title'),

          const SizedBox(height: 12),
          _Label('Task Description'),
          const SizedBox(height: 8),
          _TextField(
              controller: ctrl.taskDescCtrl,
              hint: 'Description',
              maxLines: 2),

          const SizedBox(height: 12),
          _Label('Project Name'),
          const SizedBox(height: 8),
          _TextField(
              controller: ctrl.projectNameCtrl, hint: 'Project name'),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              flex: 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _Label('Status'),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: ctrl.selectedStatus.value,
                          items: ctrl.statusOptions
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              ctrl.selectedStatus.value = v ?? 'Pending',
                        ),
                      ),
                    )),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _Label('Hours'),
                const SizedBox(height: 8),
                _TextField(
                  controller: ctrl.hoursSpentCtrl,
                  hint: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 12),
          _Label('Remarks'),
          const SizedBox(height: 8),
          _TextField(
              controller: ctrl.remarksCtrl,
              hint: 'Remarks...',
              maxLines: 2),

          const SizedBox(height: 20),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : () => ctrl.updateTask(taskId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: ctrl.isSubmitting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Update Task',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED: TASK CARD
// ─────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final DailyTaskModel task;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TaskCard({
    required this.task,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  });

  Color get _statusColor {
    switch (task.status.toLowerCase().trim()) {
      case 'completed':   return AppTheme.success;
      case 'inprogress':
      case 'in progress': return AppTheme.primary;
      default:            return AppTheme.warning;
    }
  }

  IconData get _statusIcon {
    switch (task.status.toLowerCase().trim()) {
      case 'completed':   return Icons.check_circle_rounded;
      case 'inprogress':
      case 'in progress': return Icons.timelapse_rounded;
      default:            return Icons.schedule_rounded;
    }
  }

  String get _statusLabel {
    switch (task.status.toLowerCase().trim()) {
      case 'completed':   return 'Completed';
      case 'inprogress':
      case 'in progress': return 'In Progress';
      default:            return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = task.taskDate.isNotEmpty
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.tryParse(task.taskDate) ?? DateTime.now())
        : '—';

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
            child: Text(task.projectName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_statusIcon, color: _statusColor, size: 13),
              const SizedBox(width: 4),
              Text(_statusLabel,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor)),
            ]),
          ),
        ]),

        const SizedBox(height: 10),

        if (isAdmin)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(task.userName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ]),
          ),

        Text(task.taskTitle,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),

        if (task.taskDescription.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(task.taskDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
        ],

        const SizedBox(height: 10),

        Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(dateStr,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.textSecondary)),
          const SizedBox(width: 14),
          const Icon(Icons.access_time_rounded,
              size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text('${task.hoursSpent}h',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppTheme.textSecondary)),
        ]),

        if (task.remarks.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.notes_rounded, size: 13, color: AppTheme.info),
            const SizedBox(width: 4),
            Expanded(
              child: Text(task.remarks,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppTheme.info,
                      fontStyle: FontStyle.italic)),
            ),
          ]),
        ],

        if (!isAdmin) ...[
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded,
                            color: AppTheme.primary, size: 16),
                        SizedBox(width: 6),
                        Text('Edit',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            color: AppTheme.error, size: 16),
                        SizedBox(width: 6),
                        Text('Delete',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppTheme.error,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TODAY SUMMARY BANNER
// ─────────────────────────────────────────────────────────────
class _TodaySummaryBanner extends StatelessWidget {
  final int total;
  final int done;
  final double hours;
  final bool isAdmin;

  const _TodaySummaryBanner({
    required this.total,
    required this.done,
    required this.hours,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        const Icon(Icons.today_rounded, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isAdmin ? "Today's Team Tasks" : "Today's Tasks",
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 14),
          ),
        ),
        _StatChip(label: '$total Total', icon: Icons.list_rounded),
        const SizedBox(width: 8),
        _StatChip(
            label: '$done Done',
            icon: Icons.check_rounded,
            color: AppTheme.success),
        const SizedBox(width: 8),
        _StatChip(label: '${hours}h', icon: Icons.access_time_rounded),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatChip({
    required this.label,
    required this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────
class _StatusFilter extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _StatusFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = ['All', 'Pending', 'In Progress', 'Completed'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = selected == options[i];
          return GestureDetector(
            onTap: () => onChanged(options[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.divider),
              ),
              alignment: Alignment.center,
              child: Text(options[i],
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: AppTheme.cardDecoration(),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded,
              color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: AppTheme.textHint,
              fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _EmptyState(
      {required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: AppTheme.divider),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text(sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textHint)),
      ]),
    );
  }
}