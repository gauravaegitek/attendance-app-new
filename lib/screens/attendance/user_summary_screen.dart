// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// class UserSummaryScreen extends StatefulWidget {
//   const UserSummaryScreen({super.key});

//   @override
//   State<UserSummaryScreen> createState() => _UserSummaryScreenState();
// }

// class _UserSummaryScreenState extends State<UserSummaryScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchUserSummary();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Attendance Summary')),
//       body: Column(
//         children: [
//           // =================== FILTER ===================
//           Container(
//             color: AppTheme.primary,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _DateField(
//                     label: 'From',
//                     date: controller.fromDate.value,
//                     onTap: () => controller.pickFromDate(context),
//                     obs: controller.fromDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _DateField(
//                     label: 'To',
//                     date: controller.toDate.value,
//                     onTap: () => controller.pickToDate(context),
//                     obs: controller.toDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Obx(() => ElevatedButton(
//                   onPressed: controller.isFetchingSummary.value
//                       ? null
//                       : controller.fetchUserSummary,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppTheme.primary,
//                     minimumSize: const Size(0, 44),
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                   child: controller.isFetchingSummary.value
//                       ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppTheme.primary,
//                           ),
//                         )
//                       : const Icon(Icons.search),
//                 )),
//               ],
//             ),
//           ),

//           // =================== STATS ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   child: Row(
//                     children: [
//                       _StatChip(
//                         label: 'Total',
//                         value: controller.attendanceRecords.length.toString(),
//                         color: AppTheme.primary,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Complete',
//                         value: controller.totalPresent.toString(),
//                         color: AppTheme.success,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Incomplete',
//                         value: controller.totalIncomplete.toString(),
//                         color: AppTheme.warning,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Hours',
//                         value: AppUtils.formatHours(
//                             controller.totalWorkHours),
//                         color: AppTheme.accent,
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== LIST ===================
//           Expanded(
//             child: Obx(() {
//               if (controller.isFetchingSummary.value) {
//                 return const Center(
//                     child: CircularProgressIndicator(
//                         color: AppTheme.primary));
//               }

//               if (controller.attendanceRecords.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.calendar_today_outlined,
//                           size: 60, color: AppTheme.textHint),
//                       const SizedBox(height: 16),
//                       const Text('No records found',
//                           style: AppTheme.headline3),
//                       const SizedBox(height: 8),
//                       const Text('Select a date range and search',
//                           style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: controller.attendanceRecords.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (_, i) {
//                   final record = controller.attendanceRecords[i];
//                   return _AttendanceCard(record: record);
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final VoidCallback onTap;
//   final Rx<DateTime> obs;

//   const _DateField({
//     required this.label,
//     required this.date,
//     required this.onTap,
//     required this.obs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white.withOpacity(0.3)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 10,
//                   fontFamily: 'Poppins'),
//             ),
//             const SizedBox(height: 2),
//             Obx(() => Text(
//               AppUtils.formatDate(obs.value),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Poppins',
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatChip({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AttendanceCard extends StatelessWidget {
//   final dynamic record;

//   const _AttendanceCard({required this.record});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 AppUtils.formatDateDisplay(record.attendanceDate),
//                 style: AppTheme.headline3,
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppUtils.getStatusBgColor(record.status),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   record.status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppUtils.getStatusColor(record.status),
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),

//           // Time Row
//           Row(
//             children: [
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check In',
//                   time: AppUtils.formatTime(record.inTime),
//                   icon: Icons.login,
//                   color: AppTheme.success,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check Out',
//                   time: AppUtils.formatTime(record.outTime),
//                   icon: Icons.logout,
//                   color: AppTheme.error,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Total Hours',
//                   time: AppUtils.formatHours(record.totalHours),
//                   icon: Icons.timer_outlined,
//                   color: AppTheme.primary,
//                 ),
//               ),
//             ],
//           ),

//           if (record.inLocation != null) ...[
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 14, color: AppTheme.textSecondary),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     record.inLocation ?? '',
//                     style: AppTheme.caption,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _TimeInfo extends StatelessWidget {
//   final String label;
//   final String time;
//   final IconData icon;
//   final Color color;

//   const _TimeInfo({
//     required this.label,
//     required this.time,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 12, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: time == '--:--' ? AppTheme.textHint : AppTheme.textPrimary,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ],
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// class UserSummaryScreen extends StatefulWidget {
//   const UserSummaryScreen({super.key});

//   @override
//   State<UserSummaryScreen> createState() => _UserSummaryScreenState();
// }

// class _UserSummaryScreenState extends State<UserSummaryScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchUserSummary();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Attendance Summary')),
//       body: Column(
//         children: [
//           // =================== FILTER ===================
//           Container(
//             color: AppTheme.primary,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _DateField(
//                     label: 'From',
//                     date: controller.fromDate.value,
//                     onTap: () => controller.pickFromDate(context),
//                     obs: controller.fromDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _DateField(
//                     label: 'To',
//                     date: controller.toDate.value,
//                     onTap: () => controller.pickToDate(context),
//                     obs: controller.toDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Obx(() => ElevatedButton(
//                       onPressed: controller.isFetchingSummary.value
//                           ? null
//                           : controller.fetchUserSummary,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppTheme.primary,
//                         minimumSize: const Size(0, 44),
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                       child: controller.isFetchingSummary.value
//                           ? const SizedBox(
//                               height: 16,
//                               width: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: AppTheme.primary,
//                               ),
//                             )
//                           : const Icon(Icons.search),
//                     )),
//               ],
//             ),
//           ),

//           // =================== STATS ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   child: Row(
//                     children: [
//                       _StatChip(
//                         label: 'Total',
//                         value:
//                             controller.attendanceRecords.length.toString(),
//                         color: AppTheme.primary,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Complete',
//                         value: controller.totalPresent.toString(),
//                         color: AppTheme.success,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Incomplete',
//                         value: controller.totalIncomplete.toString(),
//                         color: AppTheme.warning,
//                       ),
//                       const SizedBox(width: 8),
//                       _StatChip(
//                         label: 'Hours',
//                         value: AppUtils.formatHours(
//                             controller.totalWorkHours),
//                         color: AppTheme.accent,
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== PERIOD SUMMARY CARD ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Period Summary',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           _SummaryTile(
//                             label: 'Total Days',
//                             value:
//                                 controller.totalDaysInRange.toString(),
//                             icon: Icons.calendar_month_outlined,
//                             color: AppTheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           _SummaryTile(
//                             label: 'Present',
//                             value: controller.totalPresent.toString(),
//                             icon: Icons.check_circle_outline,
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: 8),
//                           _SummaryTile(
//                             label: 'Absent',
//                             value: controller.totalAbsent.toString(),
//                             icon: Icons.cancel_outlined,
//                             color: AppTheme.error,
//                           ),
//                           const SizedBox(width: 8),
//                           _SummaryTile(
//                             label: 'Sundays',
//                             value: controller.totalSundays.toString(),
//                             icon: Icons.wb_sunny_outlined,
//                             color: Colors.orange,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== LIST ===================
//           Expanded(
//             child: Obx(() {
//               if (controller.isFetchingSummary.value) {
//                 return const Center(
//                     child: CircularProgressIndicator(
//                         color: AppTheme.primary));
//               }

//               if (controller.attendanceRecords.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.calendar_today_outlined,
//                           size: 60, color: AppTheme.textHint),
//                       const SizedBox(height: 16),
//                       const Text('No records found',
//                           style: AppTheme.headline3),
//                       const SizedBox(height: 8),
//                       const Text('Select a date range and search',
//                           style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: controller.attendanceRecords.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (_, i) {
//                   final record = controller.attendanceRecords[i];
//                   return _AttendanceCard(record: record);
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== DATE FIELD ===================
// class _DateField extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final VoidCallback onTap;
//   final Rx<DateTime> obs;

//   const _DateField({
//     required this.label,
//     required this.date,
//     required this.onTap,
//     required this.obs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white.withOpacity(0.3)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 10,
//                   fontFamily: 'Poppins'),
//             ),
//             const SizedBox(height: 2),
//             Obx(() => Text(
//                   AppUtils.formatDate(obs.value),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins',
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== STAT CHIP ===================
// class _StatChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatChip({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== SUMMARY TILE ===================
// class _SummaryTile extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _SummaryTile({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 18, color: color),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 9,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== ATTENDANCE CARD ===================
// class _AttendanceCard extends StatelessWidget {
//   final dynamic record;

//   const _AttendanceCard({required this.record});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 AppUtils.formatDateDisplay(record.attendanceDate),
//                 style: AppTheme.headline3,
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppUtils.getStatusBgColor(record.status),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   record.status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppUtils.getStatusColor(record.status),
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),

//           // Time Row
//           Row(
//             children: [
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check In',
//                   time: AppUtils.formatTime(record.inTime),
//                   icon: Icons.login,
//                   color: AppTheme.success,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check Out',
//                   time: AppUtils.formatTime(record.outTime),
//                   icon: Icons.logout,
//                   color: AppTheme.error,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Total Hours',
//                   time: AppUtils.formatHours(record.totalHours),
//                   icon: Icons.timer_outlined,
//                   color: AppTheme.primary,
//                 ),
//               ),
//             ],
//           ),

//           if (record.inLocation != null) ...[
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 14, color: AppTheme.textSecondary),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     record.inLocation ?? '',
//                     style: AppTheme.caption,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // =================== TIME INFO ===================
// class _TimeInfo extends StatelessWidget {
//   final String label;
//   final String time;
//   final IconData icon;
//   final Color color;

//   const _TimeInfo({
//     required this.label,
//     required this.time,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 12, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: time == '--:--'
//                 ? AppTheme.textHint
//                 : AppTheme.textPrimary,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ],
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// class UserSummaryScreen extends StatefulWidget {
//   const UserSummaryScreen({super.key});

//   @override
//   State<UserSummaryScreen> createState() => _UserSummaryScreenState();
// }

// class _UserSummaryScreenState extends State<UserSummaryScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchUserSummary();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Attendance Summary')),
//       body: Column(
//         children: [
//           // =================== FILTER ===================
//           Container(
//             color: AppTheme.primary,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _DateField(
//                     label: 'From',
//                     date: controller.fromDate.value,
//                     onTap: () => controller.pickFromDate(context),
//                     obs: controller.fromDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _DateField(
//                     label: 'To',
//                     date: controller.toDate.value,
//                     onTap: () => controller.pickToDate(context),
//                     obs: controller.toDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Obx(() => ElevatedButton(
//                       onPressed: controller.isFetchingSummary.value
//                           ? null
//                           : controller.fetchUserSummary,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppTheme.primary,
//                         minimumSize: const Size(0, 44),
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                       child: controller.isFetchingSummary.value
//                           ? const SizedBox(
//                               height: 16,
//                               width: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: AppTheme.primary,
//                               ),
//                             )
//                           : const Icon(Icons.search),
//                     )),
//               ],
//             ),
//           ),

//           // =================== PERIOD SUMMARY CARD ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Monthly Summary',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           _StatChip(
//                             label: 'Total Days',
//                             value: controller.totalDaysInRange.toString(),
//                             color: AppTheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Present',
//                             value: controller.totalPresent.toString(),
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Absent',
//                             value: controller.totalAbsent.toString(),
//                             color: AppTheme.error,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Sundays',
//                             value: controller.totalSundays.toString(),
//                             color: Colors.orange,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )),


//           // =================== ATTENDANCE SUMMARY CARD ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Attendance Summary',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           _StatChip(
//                             label: 'Total',
//                             value: controller.attendanceRecords.length
//                                 .toString(),
//                             color: AppTheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Complete',
//                             value: controller.totalPresent.toString(),
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Incomplete',
//                             value: controller.totalIncomplete.toString(),
//                             color: AppTheme.warning,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Hours',
//                             value: AppUtils.formatHours(
//                                 controller.totalWorkHours),
//                             color: AppTheme.accent,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== LIST ===================
//           Expanded(
//             child: Obx(() {
//               if (controller.isFetchingSummary.value) {
//                 return const Center(
//                     child: CircularProgressIndicator(
//                         color: AppTheme.primary));
//               }

//               if (controller.attendanceRecords.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.calendar_today_outlined,
//                           size: 60, color: AppTheme.textHint),
//                       const SizedBox(height: 16),
//                       const Text('No records found',
//                           style: AppTheme.headline3),
//                       const SizedBox(height: 8),
//                       const Text('Select a date range and search',
//                           style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: controller.attendanceRecords.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (_, i) {
//                   final record = controller.attendanceRecords[i];
//                   return _AttendanceCard(record: record);
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== DATE FIELD ===================
// class _DateField extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final VoidCallback onTap;
//   final Rx<DateTime> obs;

//   const _DateField({
//     required this.label,
//     required this.date,
//     required this.onTap,
//     required this.obs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white.withOpacity(0.3)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 10,
//                   fontFamily: 'Poppins'),
//             ),
//             const SizedBox(height: 2),
//             Obx(() => Text(
//                   AppUtils.formatDate(obs.value),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins',
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== STAT CHIP ===================
// // Used in both Attendance Summary and Period Summary cards
// class _StatChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatChip({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== ATTENDANCE CARD ===================
// class _AttendanceCard extends StatelessWidget {
//   final dynamic record;

//   const _AttendanceCard({required this.record});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 AppUtils.formatDateDisplay(record.attendanceDate),
//                 style: AppTheme.headline3,
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppUtils.getStatusBgColor(record.status),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   record.status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppUtils.getStatusColor(record.status),
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),

//           // Time Row
//           Row(
//             children: [
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check In',
//                   time: AppUtils.formatTime(record.inTime),
//                   icon: Icons.login,
//                   color: AppTheme.success,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check Out',
//                   time: AppUtils.formatTime(record.outTime),
//                   icon: Icons.logout,
//                   color: AppTheme.error,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Total Hours',
//                   time: AppUtils.formatHours(record.totalHours),
//                   icon: Icons.timer_outlined,
//                   color: AppTheme.primary,
//                 ),
//               ),
//             ],
//           ),

//           if (record.inLocation != null) ...[
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 14, color: AppTheme.textSecondary),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     record.inLocation ?? '',
//                     style: AppTheme.caption,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // =================== TIME INFO ===================
// class _TimeInfo extends StatelessWidget {
//   final String label;
//   final String time;
//   final IconData icon;
//   final Color color;

//   const _TimeInfo({
//     required this.label,
//     required this.time,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 12, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: time == '--:--'
//                 ? AppTheme.textHint
//                 : AppTheme.textPrimary,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ],
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/attendance_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// class UserSummaryScreen extends StatefulWidget {
//   const UserSummaryScreen({super.key});

//   @override
//   State<UserSummaryScreen> createState() => _UserSummaryScreenState();
// }

// class _UserSummaryScreenState extends State<UserSummaryScreen> {
//   final controller = Get.put(AttendanceController());

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchUserSummary();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Attendance Summary')),
//       body: Column(
//         children: [
//           // =================== FILTER ===================
//           Container(
//             color: AppTheme.primary,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _DateField(
//                     label: 'From',
//                     date: controller.fromDate.value,
//                     onTap: () => controller.pickFromDate(context),
//                     obs: controller.fromDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _DateField(
//                     label: 'To',
//                     date: controller.toDate.value,
//                     onTap: () => controller.pickToDate(context),
//                     obs: controller.toDate,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Obx(() => ElevatedButton(
//                       onPressed: controller.isFetchingSummary.value
//                           ? null
//                           : controller.fetchUserSummary,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppTheme.primary,
//                         minimumSize: const Size(0, 44),
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                       ),
//                       child: controller.isFetchingSummary.value
//                           ? const SizedBox(
//                               height: 16,
//                               width: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: AppTheme.primary,
//                               ),
//                             )
//                           : const Icon(Icons.search),
//                     )),
//               ],
//             ),
//           ),

//           // =================== PERIOD SUMMARY CARD ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Month Summary',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           _StatChip(
//                             label: 'Total Days',
//                             value: controller.totalDaysInRange.toString(),
//                             color: AppTheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Present',
//                             value: controller.totalPresent.toString(),
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Absent',
//                             value: controller.totalAbsent.toString(),
//                             color: AppTheme.error,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Sundays',
//                             value: controller.totalSundays.toString(),
//                             color: Colors.orange,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== ATTENDANCE SUMMARY CARD ===================
//           Obx(() => controller.attendanceRecords.isEmpty
//               ? const SizedBox()
//               : Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: AppTheme.cardDecoration(),
//                   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Attendance Summary',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.textPrimary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           _StatChip(
//                             label: 'Total',
//                             value: controller.attendanceRecords.length
//                                 .toString(),
//                             color: AppTheme.primary,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Complete',
//                             value: controller.totalPresent.toString(),
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Incomplete',
//                             value: controller.totalIncomplete.toString(),
//                             color: AppTheme.warning,
//                           ),
//                           const SizedBox(width: 8),
//                           _StatChip(
//                             label: 'Hours',
//                             value: AppUtils.formatHours(
//                                 controller.totalWorkHours),
//                             color: AppTheme.accent,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )),

//           // =================== LIST ===================
//           Expanded(
//             child: Obx(() {
//               if (controller.isFetchingSummary.value) {
//                 return const Center(
//                     child: CircularProgressIndicator(
//                         color: AppTheme.primary));
//               }

//               if (controller.attendanceRecords.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.calendar_today_outlined,
//                           size: 60, color: AppTheme.textHint),
//                       const SizedBox(height: 16),
//                       const Text('No records found',
//                           style: AppTheme.headline3),
//                       const SizedBox(height: 8),
//                       const Text('Select a date range and search',
//                           style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: controller.attendanceRecords.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (_, i) {
//                   final record = controller.attendanceRecords[i];
//                   return _AttendanceCard(record: record);
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== DATE FIELD ===================
// class _DateField extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final VoidCallback onTap;
//   final Rx<DateTime> obs;

//   const _DateField({
//     required this.label,
//     required this.date,
//     required this.onTap,
//     required this.obs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.white.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 10,
//                       fontFamily: 'Poppins'),
//                 ),
//                 const SizedBox(height: 2),
//                 Obx(() => Text(
//                       AppUtils.formatDate(obs.value),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins',
//                       ),
//                     )),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: onTap,
//             child: Icon(
//               Icons.calendar_month_outlined,
//               size: 18,
//               color: Colors.white.withOpacity(0.85),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =================== STAT CHIP ===================
// class _StatChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatChip({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // =================== ATTENDANCE CARD ===================
// class _AttendanceCard extends StatelessWidget {
//   final dynamic record;

//   const _AttendanceCard({required this.record});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 AppUtils.formatDateDisplay(record.attendanceDate),
//                 style: AppTheme.headline3,
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppUtils.getStatusBgColor(record.status),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   record.status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppUtils.getStatusColor(record.status),
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),

//           // Time Row
//           Row(
//             children: [
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check In',
//                   time: AppUtils.formatTime(record.inTime),
//                   icon: Icons.login,
//                   color: AppTheme.success,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Check Out',
//                   time: AppUtils.formatTime(record.outTime),
//                   icon: Icons.logout,
//                   color: AppTheme.error,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _TimeInfo(
//                   label: 'Total Hours',
//                   time: AppUtils.formatHours(record.totalHours),
//                   icon: Icons.timer_outlined,
//                   color: AppTheme.primary,
//                 ),
//               ),
//             ],
//           ),

//           if (record.inLocation != null) ...[
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 14, color: AppTheme.textSecondary),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     record.inLocation ?? '',
//                     style: AppTheme.caption,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // =================== TIME INFO ===================
// class _TimeInfo extends StatelessWidget {
//   final String label;
//   final String time;
//   final IconData icon;
//   final Color color;

//   const _TimeInfo({
//     required this.label,
//     required this.time,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 12, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.textSecondary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: time == '--:--'
//                 ? AppTheme.textHint
//                 : AppTheme.textPrimary,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ],
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class UserSummaryScreen extends StatefulWidget {
  const UserSummaryScreen({super.key});

  @override
  State<UserSummaryScreen> createState() => _UserSummaryScreenState();
}

class _UserSummaryScreenState extends State<UserSummaryScreen> {
  final controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();
    // ✅ Auto-fetch removed — sirf search button pe call hogi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance Summary')),
      body: Column(
        children: [
          // =================== FILTER ===================
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'From',
                    date: controller.fromDate.value,
                    onTap: () => controller.pickFromDate(context),
                    obs: controller.fromDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'To',
                    date: controller.toDate.value,
                    onTap: () => controller.pickToDate(context),
                    obs: controller.toDate,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                      onPressed: controller.isFetchingSummary.value
                          ? null
                          : controller.fetchUserSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: controller.isFetchingSummary.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            )
                          : const Icon(Icons.search),
                    )),
              ],
            ),
          ),

          // =================== PERIOD SUMMARY CARD ===================
          Obx(() => controller.attendanceRecords.isEmpty
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Month Summary',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Total Days',
                            value: controller.totalDaysInRange.toString(),
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Present',
                            value: controller.totalPresent.toString(),
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Absent',
                            value: controller.totalAbsent.toString(),
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Sundays',
                            value: controller.totalSundays.toString(),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),

          // =================== ATTENDANCE SUMMARY CARD ===================
          Obx(() => controller.attendanceRecords.isEmpty
              ? const SizedBox()
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration(),
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Summary',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Total',
                            value: controller.attendanceRecords.length
                                .toString(),
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Complete',
                            value: controller.totalPresent.toString(),
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Incomplete',
                            value: controller.totalIncomplete.toString(),
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Hours',
                            value: AppUtils.formatHours(
                                controller.totalWorkHours),
                            color: AppTheme.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),

          // =================== LIST ===================
          Expanded(
            child: Obx(() {
              if (controller.isFetchingSummary.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary));
              }

              // ✅ Search abhi tak nahi hua
              if (!controller.hasSearched.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_search_rounded,
                          size: 64, color: AppTheme.textHint),
                      SizedBox(height: 16),
                      Text('Search Attendance', style: AppTheme.headline3),
                      Text('Select date range, then tap 🔍',
                          style: AppTheme.bodySmall),
                    ],
                  ),
                );
              }

              if (controller.attendanceRecords.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 60, color: AppTheme.textHint),
                      SizedBox(height: 16),
                      Text('No records found', style: AppTheme.headline3),
                      SizedBox(height: 8),
                      Text('Try a different date range',
                          style: AppTheme.bodySmall),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.attendanceRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final record = controller.attendanceRecords[i];
                  return _AttendanceCard(record: record);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =================== DATE FIELD ===================
class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final Rx<DateTime> obs;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.obs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      AppUtils.formatDate(obs.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// =================== STAT CHIP ===================
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =================== ATTENDANCE CARD ===================
class _AttendanceCard extends StatelessWidget {
  final dynamic record;

  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppUtils.formatDateDisplay(record.attendanceDate),
                style: AppTheme.headline3,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppUtils.getStatusBgColor(record.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppUtils.getStatusColor(record.status),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _TimeInfo(
                  label: 'Check In',
                  time: AppUtils.formatTime(record.inTime),
                  icon: Icons.login,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimeInfo(
                  label: 'Check Out',
                  time: AppUtils.formatTime(record.outTime),
                  icon: Icons.logout,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimeInfo(
                  label: 'Total Hours',
                  time: AppUtils.formatHours(record.totalHours),
                  icon: Icons.timer_outlined,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          if (record.inLocation != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    record.inLocation ?? '',
                    style: AppTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =================== TIME INFO ===================
class _TimeInfo extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeInfo({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: time == '--:--'
                ? AppTheme.textHint
                : AppTheme.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}