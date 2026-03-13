// // lib/screens/payroll/payroll_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/payroll_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
// import '../../models/models.dart';
// import '../../models/payroll_model.dart';

// // ─────────────────────────────────────────────
// //  PAYROLL SCREEN  (Admin + User)
// // ─────────────────────────────────────────────
// class PayrollScreen extends StatefulWidget {
//   const PayrollScreen({super.key});

//   @override
//   State<PayrollScreen> createState() => _PayrollScreenState();
// }

// class _PayrollScreenState extends State<PayrollScreen>
//     with SingleTickerProviderStateMixin {
//   final _ctrl = Get.find<PayrollController>();
//   final _auth = Get.find<AuthController>();
//   late final TabController _tab;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//     if (_auth.isAdmin) {
//       _ctrl.getAllPayrolls();
//     } else {
//       _ctrl.loadMyPayroll(_auth.currentUserId);
//     }
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         title: const Text('Payroll'),
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         bottom: _auth.isAdmin
//             ? TabBar(
//                 controller: _tab,
//                 indicatorColor: Colors.white,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white70,
//                 labelStyle: const TextStyle(
//                     fontFamily: 'Poppins', fontWeight: FontWeight.w600),
//                 tabs: const [
//                   Tab(text: 'All Payrolls'),
//                   Tab(text: 'Process Payroll'),
//                 ],
//               )
//             : null,
//       ),
//       body: _auth.isAdmin
//           ? TabBarView(
//               controller: _tab,
//               children: const [
//                 _AdminAllPayrollTab(),
//                 _AdminProcessTab(),
//               ],
//             )
//           : const _UserPayrollView(),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  ADMIN — ALL PAYROLLS TAB
// // ═══════════════════════════════════════════
// class _AdminAllPayrollTab extends StatelessWidget {
//   const _AdminAllPayrollTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     return Column(children: [
//       // ── Month / Year navigator ───────────────
//       Container(
//         color: AppTheme.cardBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Obx(() => Row(children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left_rounded),
//                 onPressed: () {
//                   ctrl.prevMonth();
//                   ctrl.getAllPayrolls();
//                 },
//               ),
//               Expanded(
//                 child: Text(ctrl.periodLabel,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary,
//                     )),
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right_rounded,
//                     color: ctrl.canGoNext
//                         ? AppTheme.textPrimary
//                         : AppTheme.divider),
//                 onPressed: ctrl.canGoNext
//                     ? () {
//                         ctrl.nextMonth();
//                         ctrl.getAllPayrolls();
//                       }
//                     : null,
//               ),
//             ])),
//       ),
//       const Divider(height: 1),

//       // ── List ────────────────────────────────
//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingAll.value) {
//             return Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Icon(Icons.account_balance_wallet_rounded,
//                       color: AppTheme.primary, size: 32),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Loading payrolls…',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const CircularProgressIndicator(color: AppTheme.primary),
//               ]),
//             );
//           }

//           if (ctrl.allPayrolls.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.receipt_long_rounded,
//                       size: 60, color: AppTheme.textHint),
//                   const SizedBox(height: 12),
//                   Text('No payrolls for ${ctrl.periodLabel}',
//                       style: AppTheme.bodyMedium
//                           .copyWith(color: AppTheme.textSecondary)),
//                   const SizedBox(height: 8),
//                   TextButton.icon(
//                     icon: const Icon(Icons.refresh_rounded),
//                     label: const Text('Refresh'),
//                     onPressed: ctrl.getAllPayrolls,
//                   ),
//                 ],
//               ),
//             );
//           }

//           final paid =
//               ctrl.allPayrolls.where((s) => s.isPaid).length;
//           final approved = ctrl.allPayrolls
//               .where((s) => s.isApproved && !s.isPaid)
//               .length;
//           final pending =
//               ctrl.allPayrolls.where((s) => s.isPending).length;
//           final notDone =
//               ctrl.allPayrolls.where((s) => s.isNotProcessed).length;

//           return RefreshIndicator(
//             color: AppTheme.primary,
//             onRefresh: ctrl.getAllPayrolls,
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               children: [
//                 Row(children: [
//                   _StatusChip(
//                       label: 'Paid',
//                       count: paid,
//                       color: const Color(0xFF22C55E)),
//                   const SizedBox(width: 8),
//                   _StatusChip(
//                       label: 'Approved',
//                       count: approved,
//                       color: const Color(0xFF3B82F6)),
//                   const SizedBox(width: 8),
//                   _StatusChip(
//                       label: 'Pending',
//                       count: pending,
//                       color: const Color(0xFFF97316)),
//                   const SizedBox(width: 8),
//                   _StatusChip(
//                       label: 'N/A',
//                       count: notDone,
//                       color: const Color(0xFF94A3B8)),
//                 ]),
//                 const SizedBox(height: 12),
//                 ...ctrl.allPayrolls.asMap().entries.map((e) => Padding(
//                       padding: EdgeInsets.only(
//                           bottom: e.key < ctrl.allPayrolls.length - 1
//                               ? 10
//                               : 0),
//                       child: _PayrollListCard(slip: e.value),
//                     )),
//               ],
//             ),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  Status summary chip
// // ─────────────────────────────────────────────
// class _StatusChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//   const _StatusChip(
//       {required this.label, required this.count, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(children: [
//           Text('$count',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'Poppins',
//                 color: color,
//               )),
//           Text(label,
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Poppins',
//                 color: color,
//               )),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Admin payroll list card
// // ─────────────────────────────────────────────
// class _PayrollListCard extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PayrollListCard({required this.slip});

//   bool get _isNotProcessed => slip.isNotProcessed;

//   // ✅ 0 present days → show ₹0 net salary in list
//   double get _displayNet =>
//       slip.presentDays == 0 ? 0.0 : slip.netSalary;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     final color = Color(ctrl.statusColorValue(slip.status));
//     final initials = slip.employeeName.isNotEmpty
//         ? slip.employeeName.split(' ').map((w) => w[0]).take(2).join()
//         : '?';

//     return GestureDetector(
//       onTap: () {
//         if (_isNotProcessed) {
//           Get.snackbar(
//             'Not Processed',
//             '${slip.employeeName}\'s payroll has not been calculated yet.\nGo to "Process Payroll" tab to calculate.',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: const Color(0xFF94A3B8),
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//             icon: const Icon(Icons.info_outline_rounded,
//                 color: Colors.white),
//           );
//           return;
//         }
//         _showPayrollDetail(context, slip);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: AppTheme.cardDecoration().copyWith(
//           color: _isNotProcessed
//               ? AppTheme.background
//               : AppTheme.cardBackground,
//         ),
//         child: Row(children: [
//           // Avatar
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               color: _isNotProcessed
//                   ? const Color(0xFF94A3B8).withOpacity(0.12)
//                   : AppTheme.primary.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Center(
//               child: Text(
//                 initials.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w800,
//                   color: _isNotProcessed
//                       ? const Color(0xFF94A3B8)
//                       : AppTheme.primary,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   slip.employeeName,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: _isNotProcessed
//                         ? AppTheme.textSecondary
//                         : AppTheme.textPrimary,
//                   ),
//                 ),
//                 Text(
//                   _isNotProcessed
//                       ? (slip.designation ?? 'Employee') +
//                           ' · Not yet calculated'
//                       // ✅ show ₹0 when no attendance
//                       : slip.presentDays == 0
//                           ? 'No attendance · ₹0'
//                           : '₹${_displayNet.toStringAsFixed(0)}  •  ${slip.presentDays}P / ${slip.absentDays}A / ${slip.lateDays}L',
//                   style: AppTheme.caption,
//                 ),
//               ],
//             ),
//           ),

//           // Status chip
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               _isNotProcessed ? 'N/A' : slip.statusLabel,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: color,
//               ),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Icon(
//             _isNotProcessed
//                 ? Icons.add_circle_outline_rounded
//                 : Icons.chevron_right_rounded,
//             color: _isNotProcessed
//                 ? const Color(0xFF94A3B8)
//                 : AppTheme.textHint,
//             size: 18,
//           ),
//         ]),
//       ),
//     );
//   }

//   void _showPayrollDetail(BuildContext context, PayrollSlipModel slip) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PayrollDetailSheet(slip: slip),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Payroll detail bottom sheet (admin actions)
// // ─────────────────────────────────────────────
// class _PayrollDetailSheet extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PayrollDetailSheet({required this.slip});

//   // ✅ If 0 present days → net = 0
//   double get _netToShow =>
//       slip.presentDays == 0 ? 0.0 : slip.netSalary;

//   bool get _hasNoAttendance => slip.presentDays == 0;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     final color = Color(ctrl.statusColorValue(slip.status));

//     return DraggableScrollableSheet(
//       initialChildSize: 0.82,
//       maxChildSize: 0.95,
//       minChildSize: 0.5,
//       builder: (_, scrollCtrl) => Container(
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         child: Column(children: [
//           // Handle
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(10)),
//           ),
//           const SizedBox(height: 16),

//           // Header
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(children: [
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: AppTheme.primary.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Center(
//                   child: Text(
//                     slip.employeeName.isNotEmpty
//                         ? slip.employeeName
//                             .split(' ')
//                             .map((w) => w[0])
//                             .take(2)
//                             .join()
//                             .toUpperCase()
//                         : '?',
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         color: AppTheme.primary,
//                         fontFamily: 'Poppins'),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(slip.employeeName, style: AppTheme.headline3),
//                       Text(
//                         '${_monthName(slip.month)} ${slip.year}',
//                         style: AppTheme.bodySmall,
//                       ),
//                     ]),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 5),
//                 decoration: BoxDecoration(
//                     color: color.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(20)),
//                 child: Text(slip.statusLabel,
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins',
//                         color: color)),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 16),
//           const Divider(height: 1),

//           // Scrollable content
//           Expanded(
//             child: ListView(
//               controller: scrollCtrl,
//               padding: const EdgeInsets.all(20),
//               children: [

//                 // ✅ No Attendance Warning Banner
//                 if (_hasNoAttendance) ...[
//                   _NoAttendanceBanner(employeeName: slip.employeeName),
//                   const SizedBox(height: 12),
//                 ],

//                 // ── Late warning ─────────────────────────────
//                 if (!_hasNoAttendance && slip.lateDays > 0 && slip.lateDays < 3) ...[
//                   _LateWarningBanner(
//                       lateDays: slip.lateDays, isDeduction: false),
//                   const SizedBox(height: 12),
//                 ],
//                 if (!_hasNoAttendance && slip.lateDays >= 3) ...[
//                   _LateWarningBanner(
//                       lateDays: slip.lateDays, isDeduction: true),
//                   const SizedBox(height: 12),
//                 ],

//                 // ── Salary breakdown ─────────────────────────
//                 _SectionTitle('Salary Breakdown'),
//                 const SizedBox(height: 8),
//                 _BreakdownCard(rows: [
//                   _Row('Basic Salary',
//                       '₹${slip.basicSalary.toStringAsFixed(2)}'),
//                   _Row('Gross Salary',
//                       _hasNoAttendance
//                           ? '₹0.00'
//                           : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//                 ]),
//                 const SizedBox(height: 14),

//                 // ── Attendance ───────────────────────────────
//                 _SectionTitle('Attendance'),
//                 const SizedBox(height: 8),
//                 _BreakdownCard(rows: [
//                   _Row('Present Days', '${slip.presentDays} days',
//                       valueColor: slip.presentDays == 0
//                           ? AppTheme.error
//                           : null),
//                   // ✅ 0 present → absent = totalCalendarDays (all days of month)
//                   _Row('Absent Days',
//                       '${slip.presentDays == 0 ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//                   _Row('Late Arrivals', '${slip.lateDays} days'),
//                   // ✅ Per Day = basicSalary ÷ totalCalendarDays (4 decimal precision)
//                   _Row('Per Day Salary',
//                       '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//                 ]),
//                 const SizedBox(height: 14),

//                 // ── Deductions ───────────────────────────────
//                 _SectionTitle('Deductions'),
//                 const SizedBox(height: 8),
//                 _BreakdownCard(rows: [
//                   _Row('Absent Deduction',
//                       '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
//                       valueColor: AppTheme.error),
//                   _Row(
//                       'Late Deduction',
//                       slip.lateDays >= 3
//                           ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
//                           : '₹0.00 (< 3 late days)',
//                       valueColor: slip.lateDays >= 3
//                           ? AppTheme.error
//                           : AppTheme.textSecondary),
//                   _Row(
//                       'Other Deductions',
//                       slip.manualDeduction > 0
//                           ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
//                           : '₹0.00',
//                       valueColor: slip.manualDeduction > 0
//                           ? AppTheme.error
//                           : AppTheme.textSecondary),
//                   _Row(
//                       'Total Deductions',
//                       '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
//                       valueColor: AppTheme.error,
//                       isBold: true),
//                 ]),
//                 const SizedBox(height: 14),

//                 // ── Net Pay ──────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     // ✅ Grey gradient if 0 net pay
//                     gradient: _hasNoAttendance
//                         ? const LinearGradient(colors: [
//                             Color(0xFF94A3B8),
//                             Color(0xFF64748B)
//                           ])
//                         : const LinearGradient(
//                             colors: [AppTheme.primary, AppTheme.secondary]),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(children: [
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Net Pay',
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 12,
//                                   fontFamily: 'Poppins')),
//                           Text(
//                             _hasNoAttendance
//                                 ? '(No attendance this month)'
//                                 : '(After all deductions)',
//                             style: const TextStyle(
//                                 color: Colors.white54,
//                                 fontSize: 10,
//                                 fontFamily: 'Poppins'),
//                           ),
//                         ]),
//                     const Spacer(),
//                     // ✅ Show ₹0 if no attendance
//                     Text('₹${_netToShow.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                             color: Colors.white,
//                             fontFamily: 'Poppins')),
//                   ]),
//                 ),
//                 const SizedBox(height: 20),

//                 // ── Manual deductions list ────────────────────
//                 if (slip.deductions.isNotEmpty) ...[
//                   _SectionTitle('Manual Deductions'),
//                   const SizedBox(height: 8),
//                   ...slip.deductions.map((d) => _DeductionChip(d)),
//                   const SizedBox(height: 14),
//                 ],

//                 // ── Admin Action Buttons ──────────────────────
//                 Obx(() {
//                   final loading =
//                       Get.find<PayrollController>().isActionLoading.value;
//                   return Column(children: [
//                     // Add Deduction — hide if no attendance
//                     if (!_hasNoAttendance)
//                       _ActionBtn(
//                         icon: Icons.remove_circle_outline_rounded,
//                         label: 'Add Deduction',
//                         color: AppTheme.warning,
//                         loading: loading,
//                         onTap: () =>
//                             _showAddDeductionDialog(context, slip),
//                       ),

//                     if (!_hasNoAttendance)
//                       const SizedBox(height: 10),

//                     // ✅ Approve — BLOCKED if no attendance
//                     if (slip.isPending)
//                       _hasNoAttendance
//                           ? _BlockedBtn(
//                               icon: Icons.block_rounded,
//                               label:
//                                   'Cannot Approve — No Attendance',
//                               color: const Color(0xFF94A3B8),
//                             )
//                           : _ActionBtn(
//                               icon: Icons.check_circle_outline_rounded,
//                               label: 'Approve Payroll',
//                               color: AppTheme.info,
//                               loading: loading,
//                               onTap: () => _showActionDialog(
//                                 context: context,
//                                 title: 'Approve Payroll',
//                                 subtitle:
//                                     'Approve payroll for ${slip.employeeName}?',
//                                 icon: Icons.check_circle_rounded,
//                                 color: AppTheme.info,
//                                 onConfirm: (remarks) async {
//                                   final res =
//                                       await Get.find<PayrollController>()
//                                           .approvePayroll(
//                                     employeeId: slip.employeeId,
//                                     remarks: remarks,
//                                     month: slip.month,
//                                     year: slip.year,
//                                   );
//                                   Get.back();
//                                   if (res.success) {
//                                     Get.back();
//                                     ResponseHandler.showSuccess(
//                                         apiMessage: '',
//                                         fallback: 'Payroll approved');
//                                   } else {
//                                     ResponseHandler.showError(
//                                         apiMessage: '',
//                                         fallback: res.message);
//                                   }
//                                 },
//                               ),
//                             ),

//                     // Mark Paid
//                     if (slip.isApproved && !slip.isPaid) ...[
//                       const SizedBox(height: 10),
//                       _ActionBtn(
//                         icon: Icons.payments_rounded,
//                         label: 'Mark as Paid',
//                         color: AppTheme.success,
//                         loading: loading,
//                         onTap: () => _showActionDialog(
//                           context: context,
//                           title: 'Mark as Paid',
//                           subtitle:
//                               'Mark salary as paid for ${slip.employeeName}?',
//                           icon: Icons.payments_rounded,
//                           color: AppTheme.success,
//                           onConfirm: (remarks) async {
//                             final res =
//                                 await Get.find<PayrollController>()
//                                     .markPaid(
//                               employeeId: slip.employeeId,
//                               remarks: remarks,
//                               month: slip.month,
//                               year: slip.year,
//                             );
//                             Get.back();
//                             if (res.success) {
//                               Get.back();
//                               ResponseHandler.showSuccess(
//                                   apiMessage: '',
//                                   fallback: 'Marked as Paid!');
//                             } else {
//                               ResponseHandler.showError(
//                                   apiMessage: '',
//                                   fallback: res.message);
//                             }
//                           },
//                         ),
//                       ),
//                     ],

//                     // Paid label
//                     if (slip.isPaid)
//                       Container(
//                         margin: const EdgeInsets.only(top: 8),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                             color: AppTheme.successLight,
//                             borderRadius: BorderRadius.circular(14)),
//                         child: Row(children: [
//                           const Icon(Icons.check_circle_rounded,
//                               color: AppTheme.success),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               slip.paidAt != null
//                                   ? 'Salary Paid\n${_fmtDateTime(slip.paidAt)}'
//                                   : 'Salary Paid',
//                               style: const TextStyle(
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.success,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ]),
//                       ),
//                   ]);
//                 }),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _showAddDeductionDialog(
//       BuildContext context, PayrollSlipModel slip) {
//     final amtCtrl = TextEditingController();
//     final reasonCtrl = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           const Icon(Icons.remove_circle_outline_rounded,
//               color: AppTheme.warning),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text('Add Deduction for ${slip.employeeName}',
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 15)),
//           ),
//         ]),
//         content: Form(
//           key: formKey,
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             TextFormField(
//               controller: amtCtrl,
//               keyboardType:
//                   const TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(
//                     RegExp(r'^\d+\.?\d{0,2}'))
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Amount (₹)',
//                 prefixIcon: const Icon(Icons.currency_rupee_rounded),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'Enter amount';
//                 if (double.tryParse(v) == null ||
//                     double.parse(v) <= 0) {
//                   return 'Enter valid amount';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: reasonCtrl,
//               maxLines: 2,
//               decoration: InputDecoration(
//                 labelText: 'Reason',
//                 prefixIcon: const Icon(Icons.edit_note_rounded),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               validator: (v) => (v == null || v.trim().isEmpty)
//                   ? 'Enter reason'
//                   : null,
//             ),
//           ]),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           Obx(() {
//             final loading =
//                 Get.find<PayrollController>().isActionLoading.value;
//             return ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.warning,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10))),
//               onPressed: loading
//                   ? null
//                   : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final res =
//                           await Get.find<PayrollController>()
//                               .addDeduction(
//                         employeeId: slip.employeeId,
//                         amount: double.parse(amtCtrl.text),
//                         reason: reasonCtrl.text.trim(),
//                         month: slip.month,
//                         year: slip.year,
//                       );
//                       Get.back();
//                       if (res.success) {
//                         ResponseHandler.showSuccess(
//                             apiMessage: '',
//                             fallback: 'Deduction added successfully');
//                       } else {
//                         ResponseHandler.showError(
//                             apiMessage: '', fallback: res.message);
//                       }
//                     },
//               child: loading
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2))
//                   : const Text('Add',
//                       style: TextStyle(
//                           fontFamily: 'Poppins',
//                           color: Colors.white)),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   void _showActionDialog({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required Future<void> Function(String remarks) onConfirm,
//   }) {
//     final remarksCtrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: color),
//           const SizedBox(width: 10),
//           Text(title,
//               style: const TextStyle(
//                   fontFamily: 'Poppins', fontSize: 16)),
//         ]),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           Text(subtitle,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   color: AppTheme.textSecondary)),
//           const SizedBox(height: 12),
//           TextField(
//             controller: remarksCtrl,
//             maxLines: 2,
//             decoration: InputDecoration(
//               labelText: 'Remarks (optional)',
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ]),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: color,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10))),
//             onPressed: () => onConfirm(remarksCtrl.text.trim()),
//             child: const Text('Confirm',
//                 style: TextStyle(
//                     fontFamily: 'Poppins', color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   String _monthName(int m) {
//     const n = [
//       '', 'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return n[m.clamp(1, 12)];
//   }
// }

// // ═══════════════════════════════════════════
// //  ADMIN — PROCESS PAYROLL TAB
// // ═══════════════════════════════════════════
// class _AdminProcessTab extends StatefulWidget {
//   const _AdminProcessTab();

//   @override
//   State<_AdminProcessTab> createState() => _AdminProcessTabState();
// }

// class _AdminProcessTabState extends State<_AdminProcessTab> {
//   final _ctrl = Get.find<PayrollController>();
//   final _salaryCtrl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _salaryCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _calculate() async {
//     if (!_formKey.currentState!.validate()) return;
//     _ctrl.basicSalary.value = double.parse(_salaryCtrl.text);
//     final res = await _ctrl.calculatePayroll();
//     if (!res.success) {
//       ResponseHandler.showError(apiMessage: '', fallback: res.message);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//           const SizedBox(height: 4),

//           // ── Employee Dropdown ─────────────────────
//           const _FormLabel('Employee'),
//           const SizedBox(height: 6),
//           Obx(() {
//             if (_ctrl.isLoadingEmployees.value) {
//               return Container(
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppTheme.divider),
//                 ),
//                 child: const Center(
//                     child: SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppTheme.primary))),
//               );
//             }
//             return DropdownButtonFormField<UserModel>(
//               value: _ctrl.selectedEmp.value,
//               isExpanded: true,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 prefixIcon: const Icon(Icons.person_rounded,
//                     color: AppTheme.primary),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         const BorderSide(color: AppTheme.divider)),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         const BorderSide(color: AppTheme.divider)),
//                 hintText: 'Select Employee',
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 14),
//               ),
//               items: _ctrl.employees
//                   .map((u) => DropdownMenuItem<UserModel>(
//                         value: u,
//                         child: Text('${u.userName} (${u.role})',
//                             style: const TextStyle(
//                                 fontFamily: 'Poppins', fontSize: 13)),
//                       ))
//                   .toList(),
//               onChanged: (u) {
//                 _ctrl.selectedEmp.value = u;
//                 _ctrl.calculateResult.value = null;
//               },
//               validator: (v) =>
//                   v == null ? 'Select an employee' : null,
//             );
//           }),
//           const SizedBox(height: 14),

//           // ── Month / Year ──────────────────────────
//           Row(children: [
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const _FormLabel('Month'),
//                     const SizedBox(height: 6),
//                     Obx(() => _MonthDropdown(
//                           value: _ctrl.selectedMonth.value,
//                           onChanged: (v) {
//                             _ctrl.selectedMonth.value = v!;
//                             _ctrl.calculateResult.value = null;
//                           },
//                         )),
//                   ]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const _FormLabel('Year'),
//                     const SizedBox(height: 6),
//                     Obx(() => _YearDropdown(
//                           value: _ctrl.selectedYear.value,
//                           onChanged: (v) {
//                             _ctrl.selectedYear.value = v!;
//                             _ctrl.calculateResult.value = null;
//                           },
//                         )),
//                   ]),
//             ),
//           ]),
//           const SizedBox(height: 14),

//           // ── Basic Salary ──────────────────────────
//           const _FormLabel('Basic Salary (₹)'),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: _salaryCtrl,
//             keyboardType:
//                 const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(
//                   RegExp(r'^\d+\.?\d{0,2}'))
//             ],
//             style: const TextStyle(fontFamily: 'Poppins'),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               prefixIcon: const Icon(Icons.currency_rupee_rounded,
//                   color: AppTheme.primary),
//               hintText: 'e.g. 50000',
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       const BorderSide(color: AppTheme.divider)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       const BorderSide(color: AppTheme.divider)),
//             ),
//             validator: (v) {
//               if (v == null || v.trim().isEmpty)
//                 return 'Enter basic salary';
//               final d = double.tryParse(v);
//               if (d == null || d <= 0) return 'Enter valid amount';
//               return null;
//             },
//           ),
//           const SizedBox(height: 14),

//           // ── Late Cutoff ───────────────────────────
//           const _FormLabel('Late Cutoff Time (Auto)'),
//           const SizedBox(height: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 14, vertical: 16),
//             decoration: BoxDecoration(
//               color: AppTheme.warningLight,
//               borderRadius: BorderRadius.circular(12),
//               border:
//                   Border.all(color: AppTheme.warning.withOpacity(0.3)),
//             ),
//             child: Row(children: [
//               const Icon(Icons.access_time_rounded,
//                   color: AppTheme.warning, size: 20),
//               const SizedBox(width: 10),
//               Obx(() => Text(_ctrl.lateCutoff.value,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.warning))),
//               const Spacer(),
//               const Text(
//                 'Employees arriving after this\ntime are marked Late',
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                     fontSize: 10,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.warning),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 20),

//           // ── Calculate Button ──────────────────────
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   icon: _ctrl.isCalculating.value
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Icon(Icons.calculate_rounded),
//                   label: Text(
//                       _ctrl.isCalculating.value
//                           ? 'Calculating...'
//                           : 'Calculate Payroll',
//                       style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w700)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   onPressed:
//                       _ctrl.isCalculating.value ? null : _calculate,
//                 ),
//               )),
//           const SizedBox(height: 20),

//           // ── Calculate Result ──────────────────────
//           Obx(() {
//             final res = _ctrl.calculateResult.value;
//             if (res == null) return const SizedBox.shrink();
//             return _CalculateResultCard(result: res);
//           }),
//         ]),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Calculate result card
// // ─────────────────────────────────────────────
// class _CalculateResultCard extends StatelessWidget {
//   final PayrollCalculateResult result;
//   const _CalculateResultCard({required this.result});

//   // ✅ 0 present days → net = 0
//   bool get _hasNoAttendance => result.presentDays == 0;
//   double get _netToShow =>
//       _hasNoAttendance ? 0.0 : _effectiveNetResult(result);

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//       // ✅ No attendance warning in process tab
//       if (_hasNoAttendance) ...[
//         _NoAttendanceBanner(employeeName: result.employeeName),
//         const SizedBox(height: 12),
//       ],

//       if (!_hasNoAttendance && result.showLateWarning) ...[
//         _LateWarningBanner(
//             lateDays: result.lateDays, isDeduction: false),
//         const SizedBox(height: 12),
//       ],
//       if (!_hasNoAttendance && result.hasLateDeduction) ...[
//         _LateWarningBanner(
//             lateDays: result.lateDays, isDeduction: true),
//         const SizedBox(height: 12),
//       ],

//       _SectionTitle('Payroll Breakdown'),
//       const SizedBox(height: 8),
//       _BreakdownCard(rows: [
//         _Row('Employee', result.employeeName),
//         _Row('Period', '${_monthName(result.month)} ${result.year}'),
//         _Row('Basic Salary',
//             '₹${result.basicSalary.toStringAsFixed(2)}'),
//         _Row('Present Days', '${result.presentDays} days',
//             valueColor:
//                 result.presentDays == 0 ? AppTheme.error : null),
//         // ✅ 0 present → absent = totalCalendarDays
//         _Row('Absent Days',
//             '${result.presentDays == 0 ? _daysInMonth(result.month, result.year) : result.absentDays} days'),
//         _Row('Late Arrivals', '${result.lateDays} days'),
//         // ✅ Per Day = basicSalary ÷ totalCalendarDays (4 decimal)
//         _Row('Per Day Salary',
//             '₹${result.perDaySalary.toStringAsFixed(4)}'),
//       ]),
//       const SizedBox(height: 12),

//       _SectionTitle('Deductions'),
//       const SizedBox(height: 8),
//       _BreakdownCard(rows: [
//         _Row('Absent Deduction',
//             '- ₹${_displayAbsentResult(result).toStringAsFixed(2)}',
//             valueColor: AppTheme.error),
//         _Row(
//           'Late Deduction',
//           result.hasLateDeduction
//               ? '- ₹${result.lateDeduction.toStringAsFixed(2)}'
//               : '₹0.00 (< 3 late days)',
//           valueColor: result.hasLateDeduction
//               ? AppTheme.error
//               : AppTheme.textSecondary,
//         ),
//         _Row('Total Deductions',
//             '- ₹${_effectiveTotalResult(result).toStringAsFixed(2)}',
//             valueColor: AppTheme.error, isBold: true),
//       ]),
//       const SizedBox(height: 12),

//       // Net Pay
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           gradient: _hasNoAttendance
//               ? const LinearGradient(
//                   colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
//               : const LinearGradient(
//                   colors: [AppTheme.primary, AppTheme.secondary]),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('Net Pay',
//                 style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 13,
//                     fontFamily: 'Poppins')),
//             Text(
//               _hasNoAttendance
//                   ? 'No attendance — ₹0'
//                   : 'After all deductions',
//               style: const TextStyle(
//                   color: Colors.white54,
//                   fontSize: 10,
//                   fontFamily: 'Poppins'),
//             ),
//           ]),
//           const Spacer(),
//           // ✅ Show ₹0 if no attendance
//           Text('₹${_netToShow.toStringAsFixed(2)}',
//               style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   fontFamily: 'Poppins')),
//         ]),
//       ),
//       const SizedBox(height: 20),
//     ]);
//   }

//   String _monthName(int m) {
//     const n = [
//       '', 'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return n[m.clamp(1, 12)];
//   }
// }

// // ═══════════════════════════════════════════
// //  USER — OWN PAYROLL VIEW
// // ═══════════════════════════════════════════
// class _UserPayrollView extends StatelessWidget {
//   const _UserPayrollView();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     final auth = Get.find<AuthController>();

//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Obx(() => Row(children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left_rounded),
//                 onPressed: () {
//                   ctrl.prevMonth();
//                   ctrl.loadMyPayroll(auth.currentUserId);
//                 },
//               ),
//               Expanded(
//                 child: Text(ctrl.periodLabel,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary,
//                     )),
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right_rounded,
//                     color: ctrl.canGoNext
//                         ? AppTheme.textPrimary
//                         : AppTheme.divider),
//                 onPressed: ctrl.canGoNext
//                     ? () {
//                         ctrl.nextMonth();
//                         ctrl.loadMyPayroll(auth.currentUserId);
//                       }
//                     : null,
//               ),
//             ])),
//       ),
//       const Divider(height: 1),

//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingMyPayroll.value) {
//             return const Center(
//                 child: CircularProgressIndicator(
//                     color: AppTheme.primary));
//           }
//           final slip = ctrl.myPayroll.value;
//           if (slip == null) {
//             return Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.receipt_long_rounded,
//                     size: 64, color: AppTheme.textHint),
//                 const SizedBox(height: 12),
//                 Text('No payroll data for ${ctrl.periodLabel}',
//                     style: AppTheme.bodyMedium
//                         .copyWith(color: AppTheme.textSecondary)),
//                 const SizedBox(height: 8),
//                 TextButton.icon(
//                   icon: const Icon(Icons.refresh_rounded),
//                   label: const Text('Refresh'),
//                   onPressed: () =>
//                       ctrl.loadMyPayroll(auth.currentUserId),
//                 ),
//               ]),
//             );
//           }
//           return _UserPayrollDetail(slip: slip);
//         }),
//       ),
//     ]);
//   }
// }

// class _UserPayrollDetail extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _UserPayrollDetail({required this.slip});

//   bool get _hasNoAttendance => slip.presentDays == 0;
//   double get _netToShow =>
//       _hasNoAttendance ? 0.0 : slip.netSalary;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     final color = Color(ctrl.statusColorValue(slip.status));

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         // Status Header card
//         Container(
//           padding: const EdgeInsets.all(18),
//           decoration: AppTheme.cardDecoration(),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [AppTheme.primary, AppTheme.secondary]),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(
//                   Icons.account_balance_wallet_rounded,
//                   color: Colors.white,
//                   size: 28),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Net Salary',
//                         style: TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 12,
//                             color: AppTheme.textSecondary)),
//                     // ✅ Show ₹0 if no attendance
//                     Text('₹${_netToShow.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 22,
//                             fontWeight: FontWeight.w800,
//                             color: AppTheme.textPrimary)),
//                   ]),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(slip.statusLabel,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: color)),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 16),

//         // ✅ No attendance banner for user
//         if (_hasNoAttendance) ...[
//           _NoAttendanceBanner(employeeName: slip.employeeName),
//           const SizedBox(height: 12),
//         ],

//         if (!_hasNoAttendance && slip.lateDays > 0 && slip.lateDays < 3) ...[
//           _LateWarningBanner(
//               lateDays: slip.lateDays, isDeduction: false),
//           const SizedBox(height: 12),
//         ],
//         if (!_hasNoAttendance && slip.lateDays >= 3) ...[
//           _LateWarningBanner(
//               lateDays: slip.lateDays, isDeduction: true),
//           const SizedBox(height: 12),
//         ],

//         _SectionTitle('Salary Breakdown'),
//         const SizedBox(height: 8),
//         _BreakdownCard(rows: [
//           _Row('Basic Salary',
//               '₹${slip.basicSalary.toStringAsFixed(2)}'),
//           _Row('Gross Salary',
//               _hasNoAttendance
//                   ? '₹0.00'
//                   : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//           _Row('Present Days', '${slip.presentDays} days',
//               valueColor:
//                   slip.presentDays == 0 ? AppTheme.error : null),
//           // ✅ 0 present → absent = totalCalendarDays
//           _Row('Absent Days',
//               '${slip.presentDays == 0 ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//           _Row('Late Arrivals', '${slip.lateDays} days'),
//           // ✅ Per Day = basicSalary ÷ totalCalendarDays (4 decimal)
//           _Row('Per Day Salary',
//               '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//         ]),
//         const SizedBox(height: 14),

//         _SectionTitle('Deductions'),
//         const SizedBox(height: 8),
//         _BreakdownCard(rows: [
//           _Row('Absent Deduction',
//               '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
//               valueColor: AppTheme.error),
//           _Row(
//             'Late Deduction',
//             slip.lateDays >= 3
//                 ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
//                 : '₹0.00',
//             valueColor: slip.lateDays >= 3
//                 ? AppTheme.error
//                 : AppTheme.textSecondary,
//           ),
//           _Row(
//               'Other Deductions',
//               slip.manualDeduction > 0
//                   ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
//                   : '₹0.00',
//               valueColor: slip.manualDeduction > 0
//                   ? AppTheme.error
//                   : AppTheme.textSecondary),
//           _Row('Total Deductions',
//               '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
//               valueColor: AppTheme.error, isBold: true),
//         ]),
//         const SizedBox(height: 14),

//         if (slip.isApproved) ...[
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: OutlinedButton.icon(
//               icon: const Icon(Icons.receipt_long_rounded,
//                   color: AppTheme.primary),
//               label: const Text('View Pay Slip',
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w700)),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(
//                     color: AppTheme.primary, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//               ),
//               onPressed: () => _showPaySlipSheet(context, slip),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],

//         if (slip.isPending)
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: AppTheme.warningLight,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                   color: AppTheme.warning.withOpacity(0.3)),
//             ),
//             child: Row(children: [
//               const Icon(Icons.hourglass_top_rounded,
//                   color: AppTheme.warning, size: 20),
//               const SizedBox(width: 10),
//               const Expanded(
//                 child: Text(
//                   'Your payroll is pending admin approval. Pay slip will be available once approved.',
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: AppTheme.warning),
//                 ),
//               ),
//             ]),
//           ),
//         const SizedBox(height: 20),
//       ]),
//     );
//   }

//   void _showPaySlipSheet(BuildContext context, PayrollSlipModel slip) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PaySlipPrintView(slip: slip),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  Pay Slip print-style view
// // ─────────────────────────────────────────────
// class _PaySlipPrintView extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PaySlipPrintView({required this.slip});

//   bool get _hasNoAttendance => slip.presentDays == 0;

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       maxChildSize: 0.95,
//       builder: (_, ctrl) => Container(
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius:
//               BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: ListView(
//           controller: ctrl,
//           padding: const EdgeInsets.all(20),
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                     color: AppTheme.divider,
//                     borderRadius: BorderRadius.circular(10)),
//               ),
//             ),

//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [AppTheme.primary, AppTheme.secondary]),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(children: [
//                 const Text('PAY SLIP',
//                     style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                         letterSpacing: 4,
//                         fontFamily: 'Poppins')),
//                 const SizedBox(height: 4),
//                 Text(slip.employeeName,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins')),
//                 Text(
//                   '${_monthName(slip.month)} ${slip.year}',
//                   style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 13,
//                       fontFamily: 'Poppins'),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(slip.statusLabel.toUpperCase(),
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 2,
//                           fontFamily: 'Poppins')),
//                 ),
//               ]),
//             ),
//             const SizedBox(height: 16),

//             _SlipSection(title: 'EARNINGS', rows: [
//               _SlipRow('Basic Salary',
//                   '₹${slip.basicSalary.toStringAsFixed(2)}'),
//               _SlipRow('Gross Salary',
//                   _hasNoAttendance
//                       ? '₹0.00'
//                       : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//             ]),
//             const SizedBox(height: 10),

//             _SlipSection(title: 'ATTENDANCE', rows: [
//               _SlipRow('Present Days', '${slip.presentDays} days'),
//               // ✅ 0 present → absent = totalCalendarDays
//               _SlipRow('Absent Days',
//                   '${slip.presentDays == 0 ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//               _SlipRow('Late Arrivals', '${slip.lateDays} days'),
//               // ✅ Per Day = basicSalary ÷ totalCalendarDays (4 decimal)
//               _SlipRow('Per Day',
//                   '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//             ]),
//             const SizedBox(height: 10),

//             _SlipSection(title: 'DEDUCTIONS', rows: [
//               _SlipRow('Absent',
//                   '₹${_displayAbsent(slip).toStringAsFixed(2)}',
//                   isDeduction: true),
//               _SlipRow('Late',
//                   '₹${_effectiveLate(slip).toStringAsFixed(2)}',
//                   isDeduction: slip.lateDays >= 3),
//               _SlipRow(
//                   slip.manualDeductionReason != null &&
//                           slip.manualDeductionReason!.isNotEmpty
//                       ? slip.manualDeductionReason!
//                       : 'Manual Deduction',
//                   '₹${slip.manualDeduction.toStringAsFixed(2)}',
//                   isDeduction: slip.manualDeduction > 0),
//             ]),
//             const SizedBox(height: 16),

//             // Net Pay
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _hasNoAttendance
//                     ? const Color(0xFFE2E8F0)
//                     : AppTheme.successLight,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                     color: _hasNoAttendance
//                         ? const Color(0xFF94A3B8).withOpacity(0.3)
//                         : AppTheme.success.withOpacity(0.3)),
//               ),
//               child: Row(children: [
//                 const Text('NET PAY',
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1,
//                         color: AppTheme.success)),
//                 const Spacer(),
//                 // ✅ ₹0 if no attendance
//                 Text(
//                     _hasNoAttendance
//                         ? '₹0.00'
//                         : '₹${slip.netSalary.toStringAsFixed(2)}',
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: _hasNoAttendance
//                             ? const Color(0xFF94A3B8)
//                             : AppTheme.success)),
//               ]),
//             ),

//             if (slip.isPaid && slip.paidAt != null) ...[
//               const SizedBox(height: 12),
//               Text(
//                 'Paid on: ${_fmtDateTime(slip.paidAt)}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 11,
//                     color: AppTheme.textHint),
//               ),
//             ],

//             if (slip.remarks != null && slip.remarks!.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Text('Remarks: ${slip.remarks}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 11,
//                       color: AppTheme.textHint)),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   String _monthName(int m) {
//     const n = [
//       '', 'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return n[m.clamp(1, 12)];
//   }
// }

// // ═══════════════════════════════════════════
// //  SHARED WIDGETS
// // ═══════════════════════════════════════════

// // ✅ NEW: No Attendance Banner
// class _NoAttendanceBanner extends StatelessWidget {
//   final String employeeName;
//   const _NoAttendanceBanner({required this.employeeName});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFEF2F2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.error.withOpacity(0.3)),
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Icon(Icons.person_off_rounded,
//             color: AppTheme.error, size: 20),
//         const SizedBox(width: 10),
//         const Expanded(
//           child: Text(
//             'No attendance recorded this month.\nSalary cannot be processed — Net Pay is ₹0.',
//             style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 12,
//                 color: AppTheme.error,
//                 fontWeight: FontWeight.w500),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ✅ NEW: Blocked button (greyed out — cannot approve)
// class _BlockedBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _BlockedBtn(
//       {required this.icon, required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 48,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 8),
//         Text(label,
//             style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 color: color,
//                 fontSize: 13)),
//       ]),
//     );
//   }
// }

// class _LateWarningBanner extends StatelessWidget {
//   final int lateDays;
//   final bool isDeduction;
//   const _LateWarningBanner(
//       {required this.lateDays, required this.isDeduction});

//   @override
//   Widget build(BuildContext context) {
//     final color = isDeduction ? AppTheme.error : AppTheme.warning;
//     final bg =
//         isDeduction ? AppTheme.errorLight : AppTheme.warningLight;
//     final icon = isDeduction
//         ? Icons.money_off_rounded
//         : Icons.warning_amber_rounded;
//     final text = isDeduction
//         ? '⚠ $lateDays late arrivals — deduction applied (per late hour)'
//         : '⚠ Warning: $lateDays late arrival${lateDays > 1 ? 's' : ''} this month. Deduction applies after 3 late days.';

//     return Container(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(text,
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: color,
//                   fontWeight: FontWeight.w500)),
//         ),
//       ]),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           color: AppTheme.textSecondary,
//           letterSpacing: 0.5));
// }

// class _FormLabel extends StatelessWidget {
//   final String text;
//   const _FormLabel(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textPrimary));
// }

// class _Row {
//   final String label;
//   final String value;
//   final Color? valueColor;
//   final bool isBold;
//   const _Row(this.label, this.value,
//       {this.valueColor, this.isBold = false});
// }

// class _BreakdownCard extends StatelessWidget {
//   final List<_Row> rows;
//   const _BreakdownCard({required this.rows});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: rows.asMap().entries.map((e) {
//           final row = e.value;
//           final isLast = e.key == rows.length - 1;
//           return Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               border: isLast
//                   ? null
//                   : const Border(
//                       bottom: BorderSide(
//                           color: AppTheme.divider, width: 0.8)),
//             ),
//             child: Row(children: [
//               Expanded(
//                 child: Text(row.label,
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 13,
//                         color: AppTheme.textSecondary,
//                         fontWeight: row.isBold
//                             ? FontWeight.w700
//                             : FontWeight.w400)),
//               ),
//               Text(row.value,
//                   style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       fontWeight: row.isBold
//                           ? FontWeight.w800
//                           : FontWeight.w600,
//                       color: row.valueColor ??
//                           AppTheme.textPrimary)),
//             ]),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _DeductionChip extends StatelessWidget {
//   final PayrollDeductionModel d;
//   const _DeductionChip(this.d);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding:
//           const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//           color: AppTheme.errorLight,
//           borderRadius: BorderRadius.circular(10),
//           border:
//               Border.all(color: AppTheme.error.withOpacity(0.2))),
//       child: Row(children: [
//         const Icon(Icons.remove_circle_rounded,
//             color: AppTheme.error, size: 16),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(d.reason,
//               style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 12,
//                   color: AppTheme.error)),
//         ),
//         Text('- ₹${d.amount.toStringAsFixed(2)}',
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.error)),
//       ]),
//     );
//   }
// }

// class _ActionBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final bool loading;
//   final VoidCallback onTap;
//   const _ActionBtn({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.loading,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton.icon(
//         icon: loading
//             ? const SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2))
//             : Icon(icon, size: 18),
//         label: Text(label,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12)),
//           elevation: 0,
//         ),
//         onPressed: loading ? null : onTap,
//       ),
//     );
//   }
// }

// class _SlipSection extends StatelessWidget {
//   final String title;
//   final List<_SlipRow> rows;
//   const _SlipSection({required this.title, required this.rows});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(title,
//           style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 10,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 2,
//               color: AppTheme.textSecondary)),
//       const SizedBox(height: 6),
//       Container(
//         decoration: AppTheme.cardDecoration(),
//         child: Column(
//           children: rows.asMap().entries.map((e) {
//             final r = e.value;
//             final isLast = e.key == rows.length - 1;
//             return Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 14, vertical: 11),
//               decoration: BoxDecoration(
//                 border: isLast
//                     ? null
//                     : const Border(
//                         bottom: BorderSide(
//                             color: AppTheme.divider, width: 0.6)),
//               ),
//               child: Row(children: [
//                 Expanded(
//                     child: Text(r.label,
//                         style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 12,
//                             color: AppTheme.textSecondary))),
//                 Text(r.value,
//                     style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: r.isDeduction
//                             ? AppTheme.error
//                             : AppTheme.textPrimary)),
//               ]),
//             );
//           }).toList(),
//         ),
//       ),
//     ]);
//   }
// }

// class _SlipRow {
//   final String label;
//   final String value;
//   final bool isDeduction;
//   const _SlipRow(this.label, this.value, {this.isDeduction = false});
// }

// // ─────────────────────────────────────────────
// //  Dropdowns
// // ─────────────────────────────────────────────

// class _MonthDropdown extends StatelessWidget {
//   final int value;
//   final ValueChanged<int?> onChanged;
//   const _MonthDropdown({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     const months = [
//       'January', 'February', 'March', 'April',
//       'May', 'June', 'July', 'August',
//       'September', 'October', 'November', 'December'
//     ];
//     return DropdownButtonFormField<int>(
//       value: value,
//       isExpanded: true,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           color: AppTheme.textPrimary),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//       ),
//       items: List.generate(
//           12,
//           (i) => DropdownMenuItem<int>(
//               value: i + 1, child: Text(months[i]))),
//       onChanged: onChanged,
//     );
//   }
// }

// class _YearDropdown extends StatelessWidget {
//   final int value;
//   final ValueChanged<int?> onChanged;
//   const _YearDropdown({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now().year;
//     final years = List.generate(5, (i) => now - i);
//     return DropdownButtonFormField<int>(
//       value: value,
//       isExpanded: true,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 13,
//           color: AppTheme.textPrimary),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//       ),
//       items: years
//           .map((y) =>
//               DropdownMenuItem<int>(value: y, child: Text('$y')))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  GLOBAL HELPER FUNCTIONS
// // ═══════════════════════════════════════════

// /// ✅ UTC → IST + full date & time
// /// Output: "12 Mar 2026, 07:28"
// String _fmtDateTime(String? iso) {
//   if (iso == null || iso.isEmpty) return '';
//   try {
//     var s = iso.trim();
//     if (!s.endsWith('Z') &&
//         !s.contains('+') &&
//         !RegExp(r'-\d{2}:\d{2}$').hasMatch(s)) {
//       s += 'Z';
//     }
//     final dt = DateTime.parse(s).toLocal();
//     const mo = [
//       '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '${dt.day} ${mo[dt.month]} ${dt.year}, $h:$m';
//   } catch (_) {
//     return iso;
//   }
// }

// // ─────────────────────────────────────────────
// //  Deduction helpers
// // ─────────────────────────────────────────────

// // ✅ Absent Deduction display:
// //    present=0  → full basicSalary (100% deduction)
// //    present>0  → backend absentDeduction
// double _displayAbsent(PayrollSlipModel slip) =>
//     slip.presentDays == 0 ? slip.basicSalary : slip.absentDeduction;

// double _displayAbsentResult(PayrollCalculateResult r) =>
//     r.presentDays == 0 ? r.basicSalary : r.absentDeduction;

// double _effectiveLate(PayrollSlipModel slip) =>
//     slip.lateDays >= 3 ? slip.lateDeduction : 0.0;

// // ✅ Total Deductions:
// //    present=0  → basicSalary + manual (no late possible)
// //    present>0  → absentDeduction + late + manual
// double _effectiveTotal(PayrollSlipModel slip) =>
//     _displayAbsent(slip) + _effectiveLate(slip) + slip.manualDeduction;

// double _effectiveLateResult(PayrollCalculateResult r) =>
//     r.lateDays >= 3 ? r.lateDeduction : 0.0;

// double _effectiveTotalResult(PayrollCalculateResult r) =>
//     _displayAbsentResult(r) + _effectiveLateResult(r) + r.manualDeduction;

// double _effectiveNetResult(PayrollCalculateResult r) =>
//     r.presentDays == 0 ? 0.0 : r.basicSalary - _effectiveTotalResult(r);

// /// ✅ Returns total calendar days in a given month/year
// /// March=31, Feb2026=28, Feb2024=29 (leap year)
// int _daysInMonth(int month, int year) =>
//     DateTime(year, month + 1, 0).day;












// // lib/screens/payroll/payroll_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/payroll_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/response_handler.dart';
// import '../../models/models.dart';
// import '../../models/payroll_model.dart';

// class PayrollScreen extends StatefulWidget {
//   const PayrollScreen({super.key});
//   @override
//   State<PayrollScreen> createState() => _PayrollScreenState();
// }

// class _PayrollScreenState extends State<PayrollScreen>
//     with SingleTickerProviderStateMixin {
//   final _ctrl = Get.find<PayrollController>();
//   final _auth = Get.find<AuthController>();
//   late final TabController _tab;

//   bool get _forceUserView =>
//       (Get.arguments as Map?)?['myPayroll'] == true;

//   bool get _showAdminTabs => _auth.isAdmin && !_forceUserView;

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//     if (_showAdminTabs) {
//       _ctrl.getAllPayrolls();
//     } else {
//       _ctrl.loadMyPayroll(_auth.currentUserId);
//     }
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         title: const Text('Payroll'),
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         bottom: _showAdminTabs
//             ? TabBar(
//                 controller: _tab,
//                 indicatorColor: Colors.white,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white70,
//                 labelStyle: const TextStyle(
//                     fontFamily: 'Poppins', fontWeight: FontWeight.w600),
//                 tabs: const [
//                   Tab(text: 'All Payrolls'),
//                   Tab(text: 'Process Payroll'),
//                 ],
//               )
//             : null,
//       ),
//       body: _showAdminTabs
//           ? TabBarView(
//               controller: _tab,
//               children: const [_AdminAllPayrollTab(), _AdminProcessTab()],
//             )
//           : const _UserPayrollView(),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  ADMIN — ALL PAYROLLS TAB
// // ═══════════════════════════════════════════
// class _AdminAllPayrollTab extends StatelessWidget {
//   const _AdminAllPayrollTab();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Obx(() => Row(children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left_rounded),
//                 onPressed: () { ctrl.prevMonth(); ctrl.getAllPayrolls(); },
//               ),
//               Expanded(
//                 child: Text(ctrl.periodLabel,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right_rounded,
//                     color: ctrl.canGoNext ? AppTheme.textPrimary : AppTheme.divider),
//                 onPressed: ctrl.canGoNext
//                     ? () { ctrl.nextMonth(); ctrl.getAllPayrolls(); }
//                     : null,
//               ),
//             ])),
//       ),
//       const Divider(height: 1),
//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingAll.value) {
//             return Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Container(
//                   width: 64, height: 64,
//                   decoration: BoxDecoration(
//                       color: AppTheme.primaryLight,
//                       borderRadius: BorderRadius.circular(20)),
//                   child: const Icon(Icons.account_balance_wallet_rounded,
//                       color: AppTheme.primary, size: 32),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Loading payrolls…',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
//                         fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
//                 const SizedBox(height: 16),
//                 const CircularProgressIndicator(color: AppTheme.primary),
//               ]),
//             );
//           }

//           if (ctrl.allPayrolls.isEmpty) {
//             return Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.receipt_long_rounded, size: 60, color: AppTheme.textHint),
//                 const SizedBox(height: 12),
//                 Text('No payrolls for ${ctrl.periodLabel}',
//                     style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
//                 const SizedBox(height: 8),
//                 TextButton.icon(
//                   icon: const Icon(Icons.refresh_rounded),
//                   label: const Text('Refresh'),
//                   onPressed: ctrl.getAllPayrolls,
//                 ),
//               ]),
//             );
//           }

//           final paid     = ctrl.allPayrolls.where((s) => s.isPaid).length;
//           final approved = ctrl.allPayrolls.where((s) => s.isApproved && !s.isPaid).length;
//           final pending  = ctrl.allPayrolls.where((s) => s.isPending).length;
//           final notDone  = ctrl.allPayrolls.where((s) => s.isNotProcessed).length;

//           return RefreshIndicator(
//             color: AppTheme.primary,
//             onRefresh: ctrl.getAllPayrolls,
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               children: [
//                 Row(children: [
//                   _StatusChip(label: 'Paid',     count: paid,     color: const Color(0xFF22C55E)),
//                   const SizedBox(width: 8),
//                   _StatusChip(label: 'Approved', count: approved, color: const Color(0xFF3B82F6)),
//                   const SizedBox(width: 8),
//                   _StatusChip(label: 'Pending',  count: pending,  color: const Color(0xFFF97316)),
//                   const SizedBox(width: 8),
//                   _StatusChip(label: 'N/A',      count: notDone,  color: const Color(0xFF94A3B8)),
//                 ]),
//                 const SizedBox(height: 12),
//                 ...ctrl.allPayrolls.asMap().entries.map((e) => Padding(
//                       padding: EdgeInsets.only(
//                           bottom: e.key < ctrl.allPayrolls.length - 1 ? 10 : 0),
//                       child: _PayrollListCard(slip: e.value),
//                     )),
//               ],
//             ),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// class _StatusChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//   const _StatusChip({required this.label, required this.count, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//             color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
//         child: Column(children: [
//           Text('$count',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
//                   fontFamily: 'Poppins', color: color)),
//           Text(label,
//               style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
//                   fontFamily: 'Poppins', color: color)),
//         ]),
//       ),
//     );
//   }
// }

// class _PayrollListCard extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PayrollListCard({required this.slip});

//   bool get _isNotProcessed => slip.isNotProcessed;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl     = Get.find<PayrollController>();
//     final color    = Color(ctrl.statusColorValue(slip.status));
//     final initials = slip.employeeName.isNotEmpty
//         ? slip.employeeName.split(' ').map((w) => w[0]).take(2).join()
//         : '?';

//     return GestureDetector(
//       onTap: () {
//         if (_isNotProcessed) {
//           Get.snackbar(
//             'Not Processed',
//             '${slip.employeeName}\'s payroll has not been calculated yet.\nGo to "Process Payroll" tab to calculate.',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: const Color(0xFF94A3B8),
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//             icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
//           );
//           return;
//         }
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (_) => _PayrollDetailSheet(slip: slip),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: AppTheme.cardDecoration().copyWith(
//           color: _isNotProcessed ? AppTheme.background : AppTheme.cardBackground,
//         ),
//         child: Row(children: [
//           Container(
//             width: 46, height: 46,
//             decoration: BoxDecoration(
//               color: _isNotProcessed
//                   ? const Color(0xFF94A3B8).withOpacity(0.12)
//                   : AppTheme.primary.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Center(
//               child: Text(initials.toUpperCase(),
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins',
//                       color: _isNotProcessed ? const Color(0xFF94A3B8) : AppTheme.primary)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(slip.employeeName,
//                   style: TextStyle(
//                       fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
//                       color: _isNotProcessed ? AppTheme.textSecondary : AppTheme.textPrimary)),
//               Text(
//                 _isNotProcessed
//                     ? (slip.designation ?? 'Employee') + ' · Not yet calculated'
//                     : slip.presentDays == 0
//                         ? 'No attendance · ₹0'
//                         : '₹${slip.netSalary.toStringAsFixed(0)}  •  ${slip.presentDays}P / ${slip.absentDays}A / ${slip.lateDays}L',
//                 style: AppTheme.caption,
//               ),
//             ]),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//                 color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
//             child: Text(_isNotProcessed ? 'N/A' : slip.statusLabel,
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins', color: color)),
//           ),
//           const SizedBox(width: 6),
//           Icon(
//             _isNotProcessed ? Icons.add_circle_outline_rounded : Icons.chevron_right_rounded,
//             color: _isNotProcessed ? const Color(0xFF94A3B8) : AppTheme.textHint,
//             size: 18,
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  ADMIN — PAYROLL DETAIL SHEET
// // ═══════════════════════════════════════════
// class _PayrollDetailSheet extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PayrollDetailSheet({required this.slip});

//   bool get _noAtt => slip.presentDays == 0;
//   double get _net => _noAtt ? 0.0 : slip.netSalary;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl  = Get.find<PayrollController>();
//     final color = Color(ctrl.statusColorValue(slip.status));

//     return DraggableScrollableSheet(
//       initialChildSize: 0.88,
//       maxChildSize: 0.95,
//       minChildSize: 0.5,
//       builder: (_, scrollCtrl) => Container(
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         child: Column(children: [
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40, height: 4,
//             decoration: BoxDecoration(
//                 color: AppTheme.divider, borderRadius: BorderRadius.circular(10)),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             child: Row(children: [
//               const Text('Payroll Detail',
//                   style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
//                       fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Get.back(),
//                 child: const Icon(Icons.close_rounded, color: AppTheme.textHint, size: 22),
//               ),
//             ]),
//           ),
//           const Divider(height: 1),
//           Expanded(
//             child: ListView(
//               controller: scrollCtrl,
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: AppTheme.cardDecoration(),
//                   child: Row(children: [
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                             colors: [AppTheme.primary, AppTheme.secondary]),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Icon(Icons.account_balance_wallet_rounded,
//                           color: Colors.white, size: 28),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text(slip.employeeName, style: AppTheme.headline3),
//                         Text('${_monthName(slip.month)} ${slip.year}', style: AppTheme.bodySmall),
//                         const SizedBox(height: 4),
//                         const Text('Net Salary',
//                             style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                                 color: AppTheme.textSecondary)),
//                         Text('₹${_net.toStringAsFixed(2)}',
//                             style: const TextStyle(fontFamily: 'Poppins', fontSize: 22,
//                                 fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
//                       ]),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                           color: color.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(20)),
//                       child: Text(slip.statusLabel,
//                           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins', color: color)),
//                     ),
//                   ]),
//                 ),
//                 const SizedBox(height: 12),

//                 // ✅ FIXED: lateDeduction > 0 use karo
//                 if (_noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
//                 if (!_noAtt && slip.lateDeduction > 0) ...[
//                   _LateWarningBanner(lateDays: slip.lateDays, isDeduction: true),
//                   const SizedBox(height: 12),
//                 ],
//                 if (!_noAtt && slip.lateDays > 0 && slip.lateDeduction == 0) ...[
//                   _LateWarningBanner(lateDays: slip.lateDays, isDeduction: false),
//                   const SizedBox(height: 12),
//                 ],

//                 _SectionTitle('Salary Breakdown'),
//                 const SizedBox(height: 8),
//                 _BreakdownCard(rows: [
//                   _Row('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
//                   _Row('Gross Salary',
//                       _noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//                   _Row('Present Days', '${slip.presentDays} days',
//                       valueColor: slip.presentDays == 0 ? AppTheme.error : null),
//                   _Row('Absent Days',
//                       '${_noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//                   _Row('Late Arrivals', '${slip.lateDays} days'),
//                   _Row('Per Day Salary', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//                 ]),
//                 const SizedBox(height: 14),

//                 _SectionTitle('Deductions'),
//                 const SizedBox(height: 8),
//                 // ✅ FIXED: slip.lateDeduction directly use karo
//                 _BreakdownCard(rows: [
//                   _Row('Absent Deduction',
//                       '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
//                       valueColor: AppTheme.error),
//                   _Row('Late Deduction',
//                       slip.lateDeduction > 0
//                           ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
//                           : '₹0.00',
//                       valueColor: slip.lateDeduction > 0
//                           ? AppTheme.error
//                           : AppTheme.textSecondary),
//                   _Row('Other Deductions',
//                       slip.manualDeduction > 0
//                           ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
//                           : '₹0.00',
//                       valueColor: slip.manualDeduction > 0
//                           ? AppTheme.error
//                           : AppTheme.textSecondary),
//                   _Row('Total Deductions',
//                       '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
//                       valueColor: AppTheme.error, isBold: true),
//                 ]),
//                 const SizedBox(height: 14),

//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: _noAtt
//                         ? const LinearGradient(
//                             colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
//                         : const LinearGradient(
//                             colors: [AppTheme.primary, AppTheme.secondary]),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(children: [
//                     Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       const Text('Net Pay',
//                           style: TextStyle(color: Colors.white70, fontSize: 12,
//                               fontFamily: 'Poppins')),
//                       Text(_noAtt ? '(No attendance this month)' : '(After all deductions)',
//                           style: const TextStyle(color: Colors.white54, fontSize: 10,
//                               fontFamily: 'Poppins')),
//                     ]),
//                     const Spacer(),
//                     Text('₹${_net.toStringAsFixed(2)}',
//                         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
//                             color: Colors.white, fontFamily: 'Poppins')),
//                   ]),
//                 ),
//                 const SizedBox(height: 14),

//                 if (slip.isPaid && slip.paidAt != null) ...[
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                         color: AppTheme.successLight,
//                         borderRadius: BorderRadius.circular(14)),
//                     child: Row(children: [
//                       const Icon(Icons.check_circle_rounded, color: AppTheme.success),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text('Salary Paid\n${_fmtDateTime(slip.paidAt)}',
//                             style: const TextStyle(fontFamily: 'Poppins',
//                                 color: AppTheme.success, fontWeight: FontWeight.w600)),
//                       ),
//                     ]),
//                   ),
//                   const SizedBox(height: 14),
//                 ],

//                 if (slip.deductions.isNotEmpty) ...[
//                   _SectionTitle('Manual Deductions'),
//                   const SizedBox(height: 8),
//                   ...slip.deductions.map((d) => _DeductionChip(d)),
//                   const SizedBox(height: 14),
//                 ],

//                 Obx(() {
//                   final loading = Get.find<PayrollController>().isActionLoading.value;
//                   return Column(children: [
//                     if (!_noAtt) ...[
//                       _ActionBtn(
//                         icon: Icons.remove_circle_outline_rounded,
//                         label: 'Add Deduction',
//                         color: AppTheme.warning,
//                         loading: loading,
//                         onTap: () => _showAddDeductionDialog(context, slip),
//                       ),
//                       const SizedBox(height: 10),
//                     ],
//                     if (slip.isPending)
//                       _noAtt
//                           ? _BlockedBtn(
//                               icon: Icons.block_rounded,
//                               label: 'Cannot Approve — No Attendance',
//                               color: const Color(0xFF94A3B8),
//                             )
//                           : _ActionBtn(
//                               icon: Icons.check_circle_outline_rounded,
//                               label: 'Approve Payroll',
//                               color: AppTheme.info,
//                               loading: loading,
//                               onTap: () => _showActionDialog(
//                                 context: context,
//                                 title: 'Approve Payroll',
//                                 subtitle: 'Approve payroll for ${slip.employeeName}?',
//                                 icon: Icons.check_circle_rounded,
//                                 color: AppTheme.info,
//                                 onConfirm: (remarks) async {
//                                   final res = await Get.find<PayrollController>()
//                                       .approvePayroll(
//                                     employeeId: slip.employeeId,
//                                     remarks: remarks,
//                                     month: slip.month,
//                                     year: slip.year,
//                                   );
//                                   Get.back();
//                                   if (res.success) {
//                                     Get.back();
//                                     ResponseHandler.showSuccess(
//                                         apiMessage: '', fallback: 'Payroll approved');
//                                   } else {
//                                     ResponseHandler.showError(
//                                         apiMessage: '', fallback: res.message);
//                                   }
//                                 },
//                               ),
//                             ),
//                     if (slip.isApproved && !slip.isPaid) ...[
//                       const SizedBox(height: 10),
//                       _ActionBtn(
//                         icon: Icons.payments_rounded,
//                         label: 'Mark as Paid',
//                         color: AppTheme.success,
//                         loading: loading,
//                         onTap: () => _showActionDialog(
//                           context: context,
//                           title: 'Mark as Paid',
//                           subtitle: 'Mark salary as paid for ${slip.employeeName}?',
//                           icon: Icons.payments_rounded,
//                           color: AppTheme.success,
//                           onConfirm: (remarks) async {
//                             final res = await Get.find<PayrollController>().markPaid(
//                               employeeId: slip.employeeId,
//                               remarks: remarks,
//                               month: slip.month,
//                               year: slip.year,
//                             );
//                             Get.back();
//                             if (res.success) {
//                               Get.back();
//                               ResponseHandler.showSuccess(
//                                   apiMessage: '', fallback: 'Marked as Paid!');
//                             } else {
//                               ResponseHandler.showError(
//                                   apiMessage: '', fallback: res.message);
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ]);
//                 }),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _showAddDeductionDialog(BuildContext context, PayrollSlipModel slip) {
//     final amtCtrl    = TextEditingController();
//     final reasonCtrl = TextEditingController();
//     final formKey    = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.warning),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text('Add Deduction for ${slip.employeeName}',
//                 style: const TextStyle(fontFamily: 'Poppins', fontSize: 15)),
//           ),
//         ]),
//         content: Form(
//           key: formKey,
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             TextFormField(
//               controller: amtCtrl,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Amount (₹)',
//                 prefixIcon: const Icon(Icons.currency_rupee_rounded),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               validator: (v) {
//                 if (v == null || v.isEmpty) return 'Enter amount';
//                 if (double.tryParse(v) == null || double.parse(v) <= 0) {
//                   return 'Enter valid amount';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: reasonCtrl,
//               maxLines: 2,
//               decoration: InputDecoration(
//                 labelText: 'Reason',
//                 prefixIcon: const Icon(Icons.edit_note_rounded),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               validator: (v) =>
//                   (v == null || v.trim().isEmpty) ? 'Enter reason' : null,
//             ),
//           ]),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           Obx(() {
//             final loading = Get.find<PayrollController>().isActionLoading.value;
//             return ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.warning,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10))),
//               onPressed: loading
//                   ? null
//                   : () async {
//                       if (!formKey.currentState!.validate()) return;
//                       final res = await Get.find<PayrollController>().addDeduction(
//                         employeeId: slip.employeeId,
//                         amount: double.parse(amtCtrl.text),
//                         reason: reasonCtrl.text.trim(),
//                         month: slip.month,
//                         year: slip.year,
//                       );
//                       Get.back();
//                       if (res.success) {
//                         ResponseHandler.showSuccess(
//                             apiMessage: '', fallback: 'Deduction added successfully');
//                       } else {
//                         ResponseHandler.showError(
//                             apiMessage: '', fallback: res.message);
//                       }
//                     },
//               child: loading
//                   ? const SizedBox(
//                       width: 18, height: 18,
//                       child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                   : const Text('Add',
//                       style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   void _showActionDialog({
//     required BuildContext context,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required Future<void> Function(String remarks) onConfirm,
//   }) {
//     final remarksCtrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(children: [
//           Icon(icon, color: color),
//           const SizedBox(width: 10),
//           Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16)),
//         ]),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           Text(subtitle,
//               style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
//           const SizedBox(height: 12),
//           TextField(
//             controller: remarksCtrl,
//             maxLines: 2,
//             decoration: InputDecoration(
//               labelText: 'Remarks (optional)',
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ]),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel',
//                   style: TextStyle(color: AppTheme.textSecondary))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: color,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10))),
//             onPressed: () => onConfirm(remarksCtrl.text.trim()),
//             child: const Text('Confirm',
//                 style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  ADMIN — PROCESS PAYROLL TAB
// // ═══════════════════════════════════════════
// class _AdminProcessTab extends StatefulWidget {
//   const _AdminProcessTab();
//   @override
//   State<_AdminProcessTab> createState() => _AdminProcessTabState();
// }

// class _AdminProcessTabState extends State<_AdminProcessTab> {
//   final _ctrl       = Get.find<PayrollController>();
//   final _salaryCtrl = TextEditingController();
//   final _formKey    = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _salaryCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _calculate() async {
//     if (!_formKey.currentState!.validate()) return;
//     _ctrl.basicSalary.value = double.parse(_salaryCtrl.text);
//     final res = await _ctrl.calculatePayroll();
//     if (!res.success) {
//       ResponseHandler.showError(apiMessage: '', fallback: res.message);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const SizedBox(height: 4),
//           const _FormLabel('Employee'),
//           const SizedBox(height: 6),
//           Obx(() {
//             if (_ctrl.isLoadingEmployees.value) {
//               return Container(
//                 height: 56,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppTheme.divider)),
//                 child: const Center(
//                     child: SizedBox(
//                         width: 20, height: 20,
//                         child: CircularProgressIndicator(
//                             strokeWidth: 2, color: AppTheme.primary))),
//               );
//             }
//             return DropdownButtonFormField<UserModel>(
//               value: _ctrl.selectedEmp.value,
//               isExpanded: true,
//               decoration: InputDecoration(
//                 filled: true, fillColor: Colors.white,
//                 prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.primary),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: AppTheme.divider)),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: AppTheme.divider)),
//                 hintText: 'Select Employee',
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//               ),
//               items: _ctrl.employees
//                   .map((u) => DropdownMenuItem<UserModel>(
//                         value: u,
//                         child: Text('${u.userName} (${u.role})',
//                             style: const TextStyle(
//                                 fontFamily: 'Poppins', fontSize: 13)),
//                       ))
//                   .toList(),
//               onChanged: (u) {
//                 _ctrl.selectedEmp.value = u;
//                 _ctrl.calculateResult.value = null;
//               },
//               validator: (v) => v == null ? 'Select an employee' : null,
//             );
//           }),
//           const SizedBox(height: 14),
//           Row(children: [
//             Expanded(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const _FormLabel('Month'),
//                 const SizedBox(height: 6),
//                 Obx(() => _MonthDropdown(
//                       value: _ctrl.selectedMonth.value,
//                       onChanged: (v) {
//                         _ctrl.selectedMonth.value = v!;
//                         _ctrl.calculateResult.value = null;
//                       },
//                     )),
//               ]),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const _FormLabel('Year'),
//                 const SizedBox(height: 6),
//                 Obx(() => _YearDropdown(
//                       value: _ctrl.selectedYear.value,
//                       onChanged: (v) {
//                         _ctrl.selectedYear.value = v!;
//                         _ctrl.calculateResult.value = null;
//                       },
//                     )),
//               ]),
//             ),
//           ]),
//           const SizedBox(height: 14),
//           const _FormLabel('Basic Salary (₹)'),
//           const SizedBox(height: 6),
//           TextFormField(
//             controller: _salaryCtrl,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
//             ],
//             style: const TextStyle(fontFamily: 'Poppins'),
//             decoration: InputDecoration(
//               filled: true, fillColor: Colors.white,
//               prefixIcon:
//                   const Icon(Icons.currency_rupee_rounded, color: AppTheme.primary),
//               hintText: 'e.g. 50000',
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppTheme.divider)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppTheme.divider)),
//             ),
//             validator: (v) {
//               if (v == null || v.trim().isEmpty) return 'Enter basic salary';
//               final d = double.tryParse(v);
//               if (d == null || d <= 0) return 'Enter valid amount';
//               return null;
//             },
//           ),
//           const SizedBox(height: 14),
//           const _FormLabel('Late Cutoff Time (Auto)'),
//           const SizedBox(height: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//             decoration: BoxDecoration(
//               color: AppTheme.warningLight,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
//             ),
//             child: Row(children: [
//               const Icon(Icons.access_time_rounded, color: AppTheme.warning, size: 20),
//               const SizedBox(width: 10),
//               Obx(() => Text(_ctrl.lateCutoff.value,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins', fontSize: 14,
//                       fontWeight: FontWeight.w600, color: AppTheme.warning))),
//               const Spacer(),
//               const Text(
//                 'Employees arriving after this\ntime are marked Late',
//                 textAlign: TextAlign.right,
//                 style: TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppTheme.warning),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 20),
//           Obx(() => SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   icon: _ctrl.isCalculating.value
//                       ? const SizedBox(
//                           width: 18, height: 18,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Icon(Icons.calculate_rounded),
//                   label: Text(
//                       _ctrl.isCalculating.value ? 'Calculating...' : 'Calculate Payroll',
//                       style: const TextStyle(
//                           fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primary,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14))),
//                   onPressed: _ctrl.isCalculating.value ? null : _calculate,
//                 ),
//               )),
//           const SizedBox(height: 20),
//           Obx(() {
//             final res = _ctrl.calculateResult.value;
//             if (res == null) return const SizedBox.shrink();
//             return _CalculateResultCard(result: res);
//           }),
//         ]),
//       ),
//     );
//   }
// }

// class _CalculateResultCard extends StatelessWidget {
//   final PayrollCalculateResult result;
//   const _CalculateResultCard({required this.result});

//   bool get _noAtt => result.presentDays == 0;
//   double get _net => _noAtt ? 0.0 : _effectiveNetResult(result);

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       if (_noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
//       // ✅ FIXED: lateDeduction > 0 use karo
//       if (!_noAtt && result.lateDeduction > 0) ...[
//         _LateWarningBanner(lateDays: result.lateDays, isDeduction: true),
//         const SizedBox(height: 12),
//       ],
//       if (!_noAtt && result.lateDays > 0 && result.lateDeduction == 0) ...[
//         _LateWarningBanner(lateDays: result.lateDays, isDeduction: false),
//         const SizedBox(height: 12),
//       ],
//       _SectionTitle('Payroll Breakdown'),
//       const SizedBox(height: 8),
//       _BreakdownCard(rows: [
//         _Row('Employee', result.employeeName),
//         _Row('Period', '${_monthName(result.month)} ${result.year}'),
//         _Row('Basic Salary', '₹${result.basicSalary.toStringAsFixed(2)}'),
//         _Row('Present Days', '${result.presentDays} days',
//             valueColor: result.presentDays == 0 ? AppTheme.error : null),
//         _Row('Absent Days',
//             '${_noAtt ? _daysInMonth(result.month, result.year) : result.absentDays} days'),
//         _Row('Late Arrivals', '${result.lateDays} days'),
//         _Row('Per Day Salary', '₹${result.perDaySalary.toStringAsFixed(4)}'),
//       ]),
//       const SizedBox(height: 12),
//       _SectionTitle('Deductions'),
//       const SizedBox(height: 8),
//       // ✅ FIXED: result.lateDeduction directly use karo
//       _BreakdownCard(rows: [
//         _Row('Absent Deduction',
//             '- ₹${_displayAbsentResult(result).toStringAsFixed(2)}',
//             valueColor: AppTheme.error),
//         _Row('Late Deduction',
//             result.lateDeduction > 0
//                 ? '- ₹${result.lateDeduction.toStringAsFixed(2)}'
//                 : '₹0.00',
//             valueColor: result.lateDeduction > 0
//                 ? AppTheme.error
//                 : AppTheme.textSecondary),
//         _Row('Total Deductions',
//             '- ₹${_effectiveTotalResult(result).toStringAsFixed(2)}',
//             valueColor: AppTheme.error, isBold: true),
//       ]),
//       const SizedBox(height: 12),
//       Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           gradient: _noAtt
//               ? const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
//               : const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('Net Pay',
//                 style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
//             Text(_noAtt ? 'No attendance — ₹0' : 'After all deductions',
//                 style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Poppins')),
//           ]),
//           const Spacer(),
//           Text('₹${_net.toStringAsFixed(2)}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
//                   color: Colors.white, fontFamily: 'Poppins')),
//         ]),
//       ),
//       const SizedBox(height: 20),
//     ]);
//   }
// }

// // ═══════════════════════════════════════════
// //  USER — OWN PAYROLL VIEW
// // ═══════════════════════════════════════════
// class _UserPayrollView extends StatelessWidget {
//   const _UserPayrollView();

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<PayrollController>();
//     final auth = Get.find<AuthController>();

//     return Column(children: [
//       Container(
//         color: AppTheme.cardBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Obx(() => Row(children: [
//               IconButton(
//                 icon: const Icon(Icons.chevron_left_rounded),
//                 onPressed: () {
//                   ctrl.prevMonth();
//                   ctrl.loadMyPayroll(auth.currentUserId);
//                 },
//               ),
//               Expanded(
//                 child: Text(ctrl.periodLabel,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w700,
//                         fontFamily: 'Poppins', color: AppTheme.textPrimary)),
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right_rounded,
//                     color: ctrl.canGoNext ? AppTheme.textPrimary : AppTheme.divider),
//                 onPressed: ctrl.canGoNext
//                     ? () {
//                         ctrl.nextMonth();
//                         ctrl.loadMyPayroll(auth.currentUserId);
//                       }
//                     : null,
//               ),
//             ])),
//       ),
//       const Divider(height: 1),
//       Expanded(
//         child: Obx(() {
//           if (ctrl.isLoadingMyPayroll.value) {
//             return const Center(
//                 child: CircularProgressIndicator(color: AppTheme.primary));
//           }
//           final slip = ctrl.myPayroll.value;
//           if (slip == null) {
//             return Center(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.receipt_long_rounded, size: 64, color: AppTheme.textHint),
//                 const SizedBox(height: 12),
//                 Text('No payroll data for ${ctrl.periodLabel}',
//                     style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
//                 const SizedBox(height: 8),
//                 TextButton.icon(
//                   icon: const Icon(Icons.refresh_rounded),
//                   label: const Text('Refresh'),
//                   onPressed: () => ctrl.loadMyPayroll(auth.currentUserId),
//                 ),
//               ]),
//             );
//           }
//           return _UserPayrollDetail(slip: slip);
//         }),
//       ),
//     ]);
//   }
// }

// class _UserPayrollDetail extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _UserPayrollDetail({required this.slip});

//   bool get _noAtt => slip.presentDays == 0;
//   double get _net => _noAtt ? 0.0 : slip.netSalary;

//   @override
//   Widget build(BuildContext context) {
//     final ctrl  = Get.find<PayrollController>();
//     final color = Color(ctrl.statusColorValue(slip.status));

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(18),
//           decoration: AppTheme.cardDecoration(),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [AppTheme.primary, AppTheme.secondary]),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(Icons.account_balance_wallet_rounded,
//                   color: Colors.white, size: 28),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const Text('Net Salary',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                         color: AppTheme.textSecondary)),
//                 Text('₹${_net.toStringAsFixed(2)}',
//                     style: const TextStyle(fontFamily: 'Poppins', fontSize: 22,
//                         fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
//               ]),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                   color: color.withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(20)),
//               child: Text(slip.statusLabel,
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins', color: color)),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 16),

//         // ✅ FIXED: lateDeduction > 0 use karo
//         if (_noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
//         if (!_noAtt && slip.lateDeduction > 0) ...[
//           _LateWarningBanner(lateDays: slip.lateDays, isDeduction: true),
//           const SizedBox(height: 12),
//         ],
//         if (!_noAtt && slip.lateDays > 0 && slip.lateDeduction == 0) ...[
//           _LateWarningBanner(lateDays: slip.lateDays, isDeduction: false),
//           const SizedBox(height: 12),
//         ],

//         _SectionTitle('Salary Breakdown'),
//         const SizedBox(height: 8),
//         _BreakdownCard(rows: [
//           _Row('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
//           _Row('Gross Salary',
//               _noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//           _Row('Present Days', '${slip.presentDays} days',
//               valueColor: slip.presentDays == 0 ? AppTheme.error : null),
//           _Row('Absent Days',
//               '${_noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//           _Row('Late Arrivals', '${slip.lateDays} days'),
//           _Row('Per Day Salary', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//         ]),
//         const SizedBox(height: 14),

//         _SectionTitle('Deductions'),
//         const SizedBox(height: 8),
//         // ✅ FIXED: slip.lateDeduction directly use karo
//         _BreakdownCard(rows: [
//           _Row('Absent Deduction',
//               '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
//               valueColor: AppTheme.error),
//           _Row('Late Deduction',
//               slip.lateDeduction > 0
//                   ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
//                   : '₹0.00',
//               valueColor: slip.lateDeduction > 0
//                   ? AppTheme.error
//                   : AppTheme.textSecondary),
//           _Row('Other Deductions',
//               slip.manualDeduction > 0
//                   ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
//                   : '₹0.00',
//               valueColor: slip.manualDeduction > 0
//                   ? AppTheme.error
//                   : AppTheme.textSecondary),
//           _Row('Total Deductions',
//               '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
//               valueColor: AppTheme.error, isBold: true),
//         ]),
//         const SizedBox(height: 14),

//         if (slip.isApproved) ...[
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: OutlinedButton.icon(
//               icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
//               label: const Text('View Pay Slip',
//                   style: TextStyle(fontFamily: 'Poppins',
//                       color: AppTheme.primary, fontWeight: FontWeight.w700)),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: AppTheme.primary, width: 1.5),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//               ),
//               onPressed: () => showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => _PaySlipPrintView(slip: slip),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],

//         if (slip.isPending)
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: AppTheme.warningLight,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
//             ),
//             child: const Row(children: [
//               Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 20),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Your payroll is pending admin approval. Pay slip will be available once approved.',
//                   style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.warning),
//                 ),
//               ),
//             ]),
//           ),
//         const SizedBox(height: 20),
//       ]),
//     );
//   }
// }

// class _PaySlipPrintView extends StatelessWidget {
//   final PayrollSlipModel slip;
//   const _PaySlipPrintView({required this.slip});

//   bool get _noAtt => slip.presentDays == 0;

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       maxChildSize: 0.95,
//       builder: (_, ctrl) => Container(
//         decoration: const BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: ListView(
//           controller: ctrl,
//           padding: const EdgeInsets.all(20),
//           children: [
//             Center(
//               child: Container(
//                 width: 40, height: 4,
//                 margin: const EdgeInsets.only(bottom: 16),
//                 decoration: BoxDecoration(
//                     color: AppTheme.divider, borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                     colors: [AppTheme.primary, AppTheme.secondary]),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(children: [
//                 const Text('PAY SLIP',
//                     style: TextStyle(color: Colors.white70, fontSize: 12,
//                         letterSpacing: 4, fontFamily: 'Poppins')),
//                 const SizedBox(height: 4),
//                 Text(slip.employeeName,
//                     style: const TextStyle(color: Colors.white, fontSize: 20,
//                         fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
//                 Text('${_monthName(slip.month)} ${slip.year}',
//                     style: const TextStyle(color: Colors.white70,
//                         fontSize: 13, fontFamily: 'Poppins')),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                   decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(slip.statusLabel.toUpperCase(),
//                       style: const TextStyle(color: Colors.white,
//                           fontSize: 11, fontWeight: FontWeight.w700,
//                           letterSpacing: 2, fontFamily: 'Poppins')),
//                 ),
//               ]),
//             ),
//             const SizedBox(height: 16),

//             _SlipSection(title: 'EARNINGS', rows: [
//               _SlipRow('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
//               _SlipRow('Gross Salary',
//                   _noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
//             ]),
//             const SizedBox(height: 10),

//             _SlipSection(title: 'ATTENDANCE', rows: [
//               _SlipRow('Present Days', '${slip.presentDays} days'),
//               _SlipRow('Absent Days',
//                   '${_noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
//               _SlipRow('Late Arrivals', '${slip.lateDays} days'),
//               _SlipRow('Per Day', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
//             ]),
//             const SizedBox(height: 10),

//             // ✅ FIXED: slip.lateDeduction directly use karo
//             _SlipSection(title: 'DEDUCTIONS', rows: [
//               _SlipRow('Absent',
//                   '₹${_displayAbsent(slip).toStringAsFixed(2)}',
//                   isDeduction: true),
//               _SlipRow('Late',
//                   '₹${slip.lateDeduction.toStringAsFixed(2)}',
//                   isDeduction: slip.lateDeduction > 0),
//               _SlipRow(
//                   slip.manualDeductionReason?.isNotEmpty == true
//                       ? slip.manualDeductionReason!
//                       : 'Manual Deduction',
//                   '₹${slip.manualDeduction.toStringAsFixed(2)}',
//                   isDeduction: slip.manualDeduction > 0),
//             ]),
//             const SizedBox(height: 16),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _noAtt ? const Color(0xFFE2E8F0) : AppTheme.successLight,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                     color: _noAtt
//                         ? const Color(0xFF94A3B8).withOpacity(0.3)
//                         : AppTheme.success.withOpacity(0.3)),
//               ),
//               child: Row(children: [
//                 const Text('NET PAY',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
//                         fontWeight: FontWeight.w700, letterSpacing: 1,
//                         color: AppTheme.success)),
//                 const Spacer(),
//                 Text(_noAtt ? '₹0.00' : '₹${slip.netSalary.toStringAsFixed(2)}',
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: _noAtt ? const Color(0xFF94A3B8) : AppTheme.success)),
//               ]),
//             ),

//             if (slip.isPaid && slip.paidAt != null) ...[
//               const SizedBox(height: 12),
//               Text('Paid on: ${_fmtDateTime(slip.paidAt)}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontFamily: 'Poppins',
//                       fontSize: 11, color: AppTheme.textHint)),
//             ],
//             if (slip.remarks?.isNotEmpty == true) ...[
//               const SizedBox(height: 8),
//               Text('Remarks: ${slip.remarks}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontFamily: 'Poppins',
//                       fontSize: 11, color: AppTheme.textHint)),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  SHARED WIDGETS
// // ═══════════════════════════════════════════

// class _NoAttendanceBanner extends StatelessWidget {
//   const _NoAttendanceBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFEF2F2),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.error.withOpacity(0.3)),
//       ),
//       child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Icon(Icons.person_off_rounded, color: AppTheme.error, size: 20),
//         SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'No attendance recorded this month.\nSalary cannot be processed — Net Pay is ₹0.',
//             style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                 color: AppTheme.error, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _BlockedBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _BlockedBtn({required this.icon, required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 48,
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3))),
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 8),
//         Text(label,
//             style: TextStyle(fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600, color: color, fontSize: 13)),
//       ]),
//     );
//   }
// }

// class _LateWarningBanner extends StatelessWidget {
//   final int lateDays;
//   final bool isDeduction;
//   const _LateWarningBanner({required this.lateDays, required this.isDeduction});

//   @override
//   Widget build(BuildContext context) {
//     final color = isDeduction ? AppTheme.error : AppTheme.warning;
//     final bg    = isDeduction ? AppTheme.errorLight : AppTheme.warningLight;
//     final icon  = isDeduction ? Icons.money_off_rounded : Icons.warning_amber_rounded;
//     // ✅ FIXED: Backend formula mention — 0.5 day per late arrival
//     final text = isDeduction
//         ? '⚠ $lateDays late arrival${lateDays > 1 ? 's' : ''} — 0.5 day deduction applied per late arrival.'
//         : '⚠ Warning: $lateDays late arrival${lateDays > 1 ? 's' : ''} this month.';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.3))),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(text,
//               style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                   color: color, fontWeight: FontWeight.w500)),
//         ),
//       ]),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
//           fontWeight: FontWeight.w700, color: AppTheme.textSecondary,
//           letterSpacing: 0.5));
// }

// class _FormLabel extends StatelessWidget {
//   final String text;
//   const _FormLabel(this.text);
//   @override
//   Widget build(BuildContext context) => Text(text,
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
//           fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
// }

// class _Row {
//   final String label, value;
//   final Color? valueColor;
//   final bool isBold;
//   const _Row(this.label, this.value, {this.valueColor, this.isBold = false});
// }

// class _BreakdownCard extends StatelessWidget {
//   final List<_Row> rows;
//   const _BreakdownCard({required this.rows});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         children: rows.asMap().entries.map((e) {
//           final row    = e.value;
//           final isLast = e.key == rows.length - 1;
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               border: isLast
//                   ? null
//                   : const Border(bottom: BorderSide(color: AppTheme.divider, width: 0.8)),
//             ),
//             child: Row(children: [
//               Expanded(
//                 child: Text(row.label,
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
//                         color: AppTheme.textSecondary,
//                         fontWeight: row.isBold ? FontWeight.w700 : FontWeight.w400)),
//               ),
//               Text(row.value,
//                   style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
//                       fontWeight: row.isBold ? FontWeight.w800 : FontWeight.w600,
//                       color: row.valueColor ?? AppTheme.textPrimary)),
//             ]),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _DeductionChip extends StatelessWidget {
//   final PayrollDeductionModel d;
//   const _DeductionChip(this.d);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//           color: AppTheme.errorLight,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: AppTheme.error.withOpacity(0.2))),
//       child: Row(children: [
//         const Icon(Icons.remove_circle_rounded, color: AppTheme.error, size: 16),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(d.reason,
//               style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppTheme.error)),
//         ),
//         Text('- ₹${d.amount.toStringAsFixed(2)}',
//             style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                 fontWeight: FontWeight.w700, color: AppTheme.error)),
//       ]),
//     );
//   }
// }

// class _ActionBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final bool loading;
//   final VoidCallback onTap;
//   const _ActionBtn({required this.icon, required this.label,
//       required this.color, required this.loading, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton.icon(
//         icon: loading
//             ? const SizedBox(width: 16, height: 16,
//                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//             : Icon(icon, size: 18),
//         label: Text(label,
//             style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
//         style: ElevatedButton.styleFrom(
//             backgroundColor: color,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             elevation: 0),
//         onPressed: loading ? null : onTap,
//       ),
//     );
//   }
// }

// class _SlipSection extends StatelessWidget {
//   final String title;
//   final List<_SlipRow> rows;
//   const _SlipSection({required this.title, required this.rows});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(title,
//           style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
//               fontWeight: FontWeight.w700, letterSpacing: 2,
//               color: AppTheme.textSecondary)),
//       const SizedBox(height: 6),
//       Container(
//         decoration: AppTheme.cardDecoration(),
//         child: Column(
//           children: rows.asMap().entries.map((e) {
//             final r      = e.value;
//             final isLast = e.key == rows.length - 1;
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//               decoration: BoxDecoration(
//                 border: isLast
//                     ? null
//                     : const Border(
//                         bottom: BorderSide(color: AppTheme.divider, width: 0.6)),
//               ),
//               child: Row(children: [
//                 Expanded(child: Text(r.label,
//                     style: const TextStyle(fontFamily: 'Poppins',
//                         fontSize: 12, color: AppTheme.textSecondary))),
//                 Text(r.value,
//                     style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: r.isDeduction ? AppTheme.error : AppTheme.textPrimary)),
//               ]),
//             );
//           }).toList(),
//         ),
//       ),
//     ]);
//   }
// }

// class _SlipRow {
//   final String label, value;
//   final bool isDeduction;
//   const _SlipRow(this.label, this.value, {this.isDeduction = false});
// }

// class _MonthDropdown extends StatelessWidget {
//   final int value;
//   final ValueChanged<int?> onChanged;
//   const _MonthDropdown({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     const months = [
//       'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return DropdownButtonFormField<int>(
//       value: value,
//       isExpanded: true,
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
//           color: AppTheme.textPrimary),
//       decoration: InputDecoration(
//         filled: true, fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//       ),
//       items: List.generate(12,
//           (i) => DropdownMenuItem<int>(value: i + 1, child: Text(months[i]))),
//       onChanged: onChanged,
//     );
//   }
// }

// class _YearDropdown extends StatelessWidget {
//   final int value;
//   final ValueChanged<int?> onChanged;
//   const _YearDropdown({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     final now   = DateTime.now().year;
//     final years = List.generate(5, (i) => now - i);
//     return DropdownButtonFormField<int>(
//       value: value,
//       isExpanded: true,
//       style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
//           color: AppTheme.textPrimary),
//       decoration: InputDecoration(
//         filled: true, fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//       ),
//       items: years
//           .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }
// }

// // ═══════════════════════════════════════════
// //  GLOBAL HELPERS
// // ═══════════════════════════════════════════

// String _monthName(int m) {
//   const n = [
//     '', 'January', 'February', 'March', 'April', 'May', 'June',
//     'July', 'August', 'September', 'October', 'November', 'December'
//   ];
//   return n[m.clamp(1, 12)];
// }

// String _fmtDateTime(String? iso) {
//   if (iso == null || iso.isEmpty) return '';
//   try {
//     var s = iso.trim();
//     if (!s.endsWith('Z') && !s.contains('+') &&
//         !RegExp(r'-\d{2}:\d{2}$').hasMatch(s)) s += 'Z';
//     final dt = DateTime.parse(s).toLocal();
//     const mo = [
//       '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '${dt.day} ${mo[dt.month]} ${dt.year}, $h:$m';
//   } catch (_) {
//     return iso;
//   }
// }

// double _displayAbsent(PayrollSlipModel slip) =>
//     slip.presentDays == 0 ? slip.basicSalary : slip.absentDeduction;

// double _displayAbsentResult(PayrollCalculateResult r) =>
//     r.presentDays == 0 ? r.basicSalary : r.absentDeduction;

// // ✅ FIXED: API ki lateDeduction directly return karo — koi >= 3 threshold nahi
// double _effectiveLate(PayrollSlipModel slip) => slip.lateDeduction;

// double _effectiveTotal(PayrollSlipModel slip) =>
//     _displayAbsent(slip) + slip.lateDeduction + slip.manualDeduction;

// double _effectiveTotalResult(PayrollCalculateResult r) =>
//     _displayAbsentResult(r) + r.lateDeduction + r.manualDeduction;

// double _effectiveNetResult(PayrollCalculateResult r) =>
//     r.presentDays == 0 ? 0.0 : r.basicSalary - _effectiveTotalResult(r);

// int _daysInMonth(int month, int year) => DateTime(year, month + 1, 0).day;














// lib/screens/payroll/payroll_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/payroll_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/response_handler.dart';
import '../../models/models.dart';
import '../../models/payroll_model.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = Get.find<PayrollController>();
  final _auth = Get.find<AuthController>();
  late final TabController _tab;

  bool get _forceUserView =>
      (Get.arguments as Map?)?['myPayroll'] == true;

  bool get _showAdminTabs => _auth.isAdmin && !_forceUserView;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    if (_showAdminTabs) {
      _ctrl.getAllPayrolls();
    } else {
      _ctrl.loadMyPayroll(_auth.currentUserId);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Payroll'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: _showAdminTabs
            ? TabBar(
                controller: _tab,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'All Payrolls'),
                  Tab(text: 'Process Payroll'),
                ],
              )
            : null,
      ),
      body: _showAdminTabs
          ? TabBarView(
              controller: _tab,
              children: const [_AdminAllPayrollTab(), _AdminProcessTab()],
            )
          : const _UserPayrollView(),
    );
  }
}

// ═══════════════════════════════════════════
//  ADMIN — ALL PAYROLLS TAB
// ═══════════════════════════════════════════
class _AdminAllPayrollTab extends StatelessWidget {
  const _AdminAllPayrollTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PayrollController>();
    return Column(children: [
      Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(() => Row(children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () { ctrl.prevMonth(); ctrl.getAllPayrolls(); },
              ),
              Expanded(
                child: Text(ctrl.periodLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins', color: AppTheme.textPrimary)),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: ctrl.canGoNext ? AppTheme.textPrimary : AppTheme.divider),
                onPressed: ctrl.canGoNext
                    ? () { ctrl.nextMonth(); ctrl.getAllPayrolls(); }
                    : null,
              ),
            ])),
      ),
      const Divider(height: 1),
      Expanded(
        child: Obx(() {
          if (ctrl.isLoadingAll.value) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppTheme.primary, size: 32),
                ),
                const SizedBox(height: 20),
                const Text('Loading payrolls…',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: AppTheme.primary),
              ]),
            );
          }

          if (ctrl.allPayrolls.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_rounded, size: 60, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text('No payrolls for ${ctrl.periodLabel}',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                  onPressed: ctrl.getAllPayrolls,
                ),
              ]),
            );
          }

          final paid     = ctrl.allPayrolls.where((s) => s.isPaid).length;
          final approved = ctrl.allPayrolls.where((s) => s.isApproved && !s.isPaid).length;
          final pending  = ctrl.allPayrolls.where((s) => s.isPending).length;
          final notDone  = ctrl.allPayrolls.where((s) => s.isNotProcessed).length;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: ctrl.getAllPayrolls,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                Row(children: [
                  _StatusChip(label: 'Paid',     count: paid,     color: const Color(0xFF22C55E)),
                  const SizedBox(width: 8),
                  _StatusChip(label: 'Approved', count: approved, color: const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _StatusChip(label: 'Pending',  count: pending,  color: const Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  _StatusChip(label: 'N/A',      count: notDone,  color: const Color(0xFF94A3B8)),
                ]),
                const SizedBox(height: 12),
                ...ctrl.allPayrolls.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(
                          bottom: e.key < ctrl.allPayrolls.length - 1 ? 10 : 0),
                      child: _PayrollListCard(slip: e.value),
                    )),
              ],
            ),
          );
        }),
      ),
    ]);
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins', color: color)),
          Text(label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins', color: color)),
        ]),
      ),
    );
  }
}

class _PayrollListCard extends StatelessWidget {
  final PayrollSlipModel slip;
  const _PayrollListCard({required this.slip});

  bool get _isNotProcessed => slip.isNotProcessed;

  @override
  Widget build(BuildContext context) {
    final ctrl     = Get.find<PayrollController>();
    final color    = Color(ctrl.statusColorValue(slip.status));
    final initials = slip.employeeName.isNotEmpty
        ? slip.employeeName.split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return GestureDetector(
      onTap: () {
        if (_isNotProcessed) {
          Get.snackbar(
            'Not Processed',
            '${slip.employeeName}\'s payroll has not been calculated yet.\nGo to "Process Payroll" tab to calculate.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF94A3B8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          );
          return;
        }
        // ✅ Sheet open hone se pehle detailSlip set karo
        ctrl.setDetailSlip(slip);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _PayrollDetailSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration().copyWith(
          color: _isNotProcessed ? AppTheme.background : AppTheme.cardBackground,
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _isNotProcessed
                  ? const Color(0xFF94A3B8).withOpacity(0.12)
                  : AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(initials.toUpperCase(),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Poppins',
                      color: _isNotProcessed ? const Color(0xFF94A3B8) : AppTheme.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(slip.employeeName,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins',
                      color: _isNotProcessed ? AppTheme.textSecondary : AppTheme.textPrimary)),
              Text(
                _isNotProcessed
                    ? (slip.designation ?? 'Employee') + ' · Not yet calculated'
                    : slip.presentDays == 0
                        ? 'No attendance · ₹0'
                        : '₹${slip.netSalary.toStringAsFixed(0)}  •  ${slip.presentDays}P / ${slip.absentDays}A / ${slip.lateDays}L',
                style: AppTheme.caption,
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(_isNotProcessed ? 'N/A' : slip.statusLabel,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', color: color)),
          ),
          const SizedBox(width: 6),
          Icon(
            _isNotProcessed ? Icons.add_circle_outline_rounded : Icons.chevron_right_rounded,
            color: _isNotProcessed ? const Color(0xFF94A3B8) : AppTheme.textHint,
            size: 18,
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  ADMIN — PAYROLL DETAIL SHEET
//
//  ✅ FIX: StatelessWidget se hata ke fully reactive banaya
//  Constructor mein slip nahi leta — ctrl.detailSlip.value se
//  Obx ke through live data read karta hai.
//
//  Flow:
//   1. Card tap → ctrl.setDetailSlip(slip) → sheet open
//   2. addDeduction success → getAllPayrolls() → _refreshDetailSlipFromList()
//   3. detailSlip.value change → Obx rebuild → "Other Deductions" instantly dikhta hai
// ═══════════════════════════════════════════
class _PayrollDetailSheet extends StatelessWidget {
  const _PayrollDetailSheet();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PayrollController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppTheme.divider, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              const Text('Payroll Detail',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                      fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close_rounded, color: AppTheme.textHint, size: 22),
              ),
            ]),
          ),
          const Divider(height: 1),
          // ✅ Pura content Obx mein hai — koi bhi change hone pe instantly rebuild
          Expanded(
            child: Obx(() {
              // detailSlip null check — sheet close ho rahi ho ya data aane se pehle
              final slip = ctrl.detailSlip.value;
              if (slip == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              final bool noAtt  = slip.presentDays == 0;
              final double net  = noAtt ? 0.0 : slip.netSalary;
              final color       = Color(ctrl.statusColorValue(slip.status));

              return ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Header card ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(slip.employeeName, style: AppTheme.headline3),
                          Text('${_monthName(slip.month)} ${slip.year}',
                              style: AppTheme.bodySmall),
                          const SizedBox(height: 4),
                          const Text('Net Salary',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                  color: AppTheme.textSecondary)),
                          Text('₹${net.toStringAsFixed(2)}',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(slip.statusLabel,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins', color: color)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // ── Banners ──────────────────────────────────────────
                  if (noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
                  if (!noAtt && slip.lateDeduction > 0) ...[
                    _LateWarningBanner(lateDays: slip.lateDays, isDeduction: true),
                    const SizedBox(height: 12),
                  ],
                  if (!noAtt && slip.lateDays > 0 && slip.lateDeduction == 0) ...[
                    _LateWarningBanner(lateDays: slip.lateDays, isDeduction: false),
                    const SizedBox(height: 12),
                  ],

                  // ── Salary Breakdown ─────────────────────────────────
                  _SectionTitle('Salary Breakdown'),
                  const SizedBox(height: 8),
                  _BreakdownCard(rows: [
                    _Row('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
                    _Row('Gross Salary',
                        noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
                    _Row('Present Days', '${slip.presentDays} days',
                        valueColor: slip.presentDays == 0 ? AppTheme.error : null),
                    _Row('Absent Days',
                        '${noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
                    _Row('Late Arrivals', '${slip.lateDays} days'),
                    _Row('Per Day Salary', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
                  ]),
                  const SizedBox(height: 14),

                  // ── Deductions ───────────────────────────────────────
                  _SectionTitle('Deductions'),
                  const SizedBox(height: 8),
                  _BreakdownCard(rows: [
                    _Row('Absent Deduction',
                        '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
                        valueColor: AppTheme.error),
                    _Row('Late Deduction',
                        slip.lateDeduction > 0
                            ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
                            : '₹0.00',
                        valueColor: slip.lateDeduction > 0
                            ? AppTheme.error
                            : AppTheme.textSecondary),
                    // ✅ "Other Deductions" ab reactive hai — instantly update hoga
                    _Row('Other Deductions',
                        slip.manualDeduction > 0
                            ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
                            : '₹0.00',
                        valueColor: slip.manualDeduction > 0
                            ? AppTheme.error
                            : AppTheme.textSecondary),
                    _Row('Total Deductions',
                        '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
                        valueColor: AppTheme.error, isBold: true),
                  ]),
                  const SizedBox(height: 14),

                  // ── Net Pay ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: noAtt
                          ? const LinearGradient(
                              colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
                          : const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Net Pay',
                            style: TextStyle(color: Colors.white70, fontSize: 12,
                                fontFamily: 'Poppins')),
                        Text(noAtt ? '(No attendance this month)' : '(After all deductions)',
                            style: const TextStyle(color: Colors.white54,
                                fontSize: 10, fontFamily: 'Poppins')),
                      ]),
                      const Spacer(),
                      Text('₹${net.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                              color: Colors.white, fontFamily: 'Poppins')),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Paid badge ───────────────────────────────────────
                  if (slip.isPaid && slip.paidAt != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Salary Paid\n${_fmtDateTime(slip.paidAt)}',
                              style: const TextStyle(fontFamily: 'Poppins',
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ✅ Manual Deductions section — auto-refreshes via Obx
                  if (slip.deductions.isNotEmpty) ...[
                    _SectionTitle('Manual Deductions'),
                    const SizedBox(height: 8),
                    ...slip.deductions.map((d) => _DeductionChip(d)),
                    const SizedBox(height: 14),
                  ],

                  // ── Action Buttons ───────────────────────────────────
                  Obx(() {
                    final loading = ctrl.isActionLoading.value;
                    // Live slip for action buttons too
                    final liveSlip = ctrl.detailSlip.value ?? slip;
                    return Column(children: [
                      if (!noAtt) ...[
                        _ActionBtn(
                          icon: Icons.remove_circle_outline_rounded,
                          label: 'Add Deduction',
                          color: AppTheme.warning,
                          loading: loading,
                          onTap: () => _showAddDeductionDialog(context, liveSlip),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (liveSlip.isPending)
                        noAtt
                            ? _BlockedBtn(
                                icon: Icons.block_rounded,
                                label: 'Cannot Approve — No Attendance',
                                color: const Color(0xFF94A3B8),
                              )
                            : _ActionBtn(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Approve Payroll',
                                color: AppTheme.info,
                                loading: loading,
                                onTap: () => _showActionDialog(
                                  context: context,
                                  title: 'Approve Payroll',
                                  subtitle:
                                      'Approve payroll for ${liveSlip.employeeName}?',
                                  icon: Icons.check_circle_rounded,
                                  color: AppTheme.info,
                                  onConfirm: (remarks) async {
                                    final res = await ctrl.approvePayroll(
                                      employeeId: liveSlip.employeeId,
                                      remarks: remarks,
                                      month: liveSlip.month,
                                      year: liveSlip.year,
                                    );
                                    Get.back();
                                    if (res.success) {
                                      Get.back();
                                      ResponseHandler.showSuccess(
                                          apiMessage: '',
                                          fallback: 'Payroll approved');
                                    } else {
                                      ResponseHandler.showError(
                                          apiMessage: '',
                                          fallback: res.message);
                                    }
                                  },
                                ),
                              ),
                      if (liveSlip.isApproved && !liveSlip.isPaid) ...[
                        const SizedBox(height: 10),
                        _ActionBtn(
                          icon: Icons.payments_rounded,
                          label: 'Mark as Paid',
                          color: AppTheme.success,
                          loading: loading,
                          onTap: () => _showActionDialog(
                            context: context,
                            title: 'Mark as Paid',
                            subtitle:
                                'Mark salary as paid for ${liveSlip.employeeName}?',
                            icon: Icons.payments_rounded,
                            color: AppTheme.success,
                            onConfirm: (remarks) async {
                              final res = await ctrl.markPaid(
                                employeeId: liveSlip.employeeId,
                                remarks: remarks,
                                month: liveSlip.month,
                                year: liveSlip.year,
                              );
                              Get.back();
                              if (res.success) {
                                Get.back();
                                ResponseHandler.showSuccess(
                                    apiMessage: '',
                                    fallback: 'Marked as Paid!');
                              } else {
                                ResponseHandler.showError(
                                    apiMessage: '',
                                    fallback: res.message);
                              }
                            },
                          ),
                        ),
                      ],
                    ]);
                  }),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ]),
      ),
    );
  }

  void _showAddDeductionDialog(BuildContext context, PayrollSlipModel slip) {
    final amtCtrl    = TextEditingController();
    final reasonCtrl = TextEditingController();
    final formKey    = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Add Deduction for ${slip.employeeName}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15)),
          ),
        ]),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: amtCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Reason',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter reason' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          Obx(() {
            final loading =
                Get.find<PayrollController>().isActionLoading.value;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final res =
                          await Get.find<PayrollController>().addDeduction(
                        employeeId: slip.employeeId,
                        amount: double.parse(amtCtrl.text),
                        reason: reasonCtrl.text.trim(),
                        month: slip.month,
                        year: slip.year,
                      );
                      Get.back(); // dialog close
                      if (res.success) {
                        // ✅ Sheet auto-refresh ho gayi via detailSlip Obx
                        // Alag se kuch karne ki zaroorat nahi
                        ResponseHandler.showSuccess(
                            apiMessage: '',
                            fallback: 'Deduction added successfully');
                      } else {
                        ResponseHandler.showError(
                            apiMessage: '', fallback: res.message);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Add',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: Colors.white)),
            );
          }),
        ],
      ),
    );
  }

  void _showActionDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Future<void> Function(String remarks) onConfirm,
  }) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(subtitle,
              style: const TextStyle(
                  fontFamily: 'Poppins', color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          TextField(
            controller: remarksCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Remarks (optional)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => onConfirm(remarksCtrl.text.trim()),
            child: const Text('Confirm',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  ADMIN — PROCESS PAYROLL TAB
// ═══════════════════════════════════════════
class _AdminProcessTab extends StatefulWidget {
  const _AdminProcessTab();
  @override
  State<_AdminProcessTab> createState() => _AdminProcessTabState();
}

class _AdminProcessTabState extends State<_AdminProcessTab> {
  final _ctrl       = Get.find<PayrollController>();
  final _salaryCtrl = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    _ctrl.basicSalary.value = double.parse(_salaryCtrl.text);
    final res = await _ctrl.calculatePayroll();
    if (!res.success) {
      ResponseHandler.showError(apiMessage: '', fallback: res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          const _FormLabel('Employee'),
          const SizedBox(height: 6),
          Obx(() {
            if (_ctrl.isLoadingEmployees.value) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider)),
                child: const Center(
                    child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary))),
              );
            }
            return DropdownButtonFormField<UserModel>(
              value: _ctrl.selectedEmp.value,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.person_rounded, color: AppTheme.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider)),
                hintText: 'Select Employee',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
              items: _ctrl.employees
                  .map((u) => DropdownMenuItem<UserModel>(
                        value: u,
                        child: Text('${u.userName} (${u.role})',
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (u) {
                _ctrl.selectedEmp.value = u;
                _ctrl.calculateResult.value = null;
              },
              validator: (v) => v == null ? 'Select an employee' : null,
            );
          }),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _FormLabel('Month'),
                const SizedBox(height: 6),
                Obx(() => _MonthDropdown(
                      value: _ctrl.selectedMonth.value,
                      onChanged: (v) {
                        _ctrl.selectedMonth.value = v!;
                        _ctrl.calculateResult.value = null;
                      },
                    )),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _FormLabel('Year'),
                const SizedBox(height: 6),
                Obx(() => _YearDropdown(
                      value: _ctrl.selectedYear.value,
                      onChanged: (v) {
                        _ctrl.selectedYear.value = v!;
                        _ctrl.calculateResult.value = null;
                      },
                    )),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          const _FormLabel('Basic Salary (₹)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _salaryCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            style: const TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              prefixIcon: const Icon(Icons.currency_rupee_rounded,
                  color: AppTheme.primary),
              hintText: 'e.g. 50000',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter basic salary';
              final d = double.tryParse(v);
              if (d == null || d <= 0) return 'Enter valid amount';
              return null;
            },
          ),
          const SizedBox(height: 14),
          const _FormLabel('Late Cutoff Time (Auto)'),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.warningLight,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.warning.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.access_time_rounded,
                  color: AppTheme.warning, size: 20),
              const SizedBox(width: 10),
              Obx(() => Text(_ctrl.lateCutoff.value,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppTheme.warning))),
              const Spacer(),
              const Text(
                'Employees arriving after this\ntime are marked Late',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, fontFamily: 'Poppins',
                    color: AppTheme.warning),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _ctrl.isCalculating.value
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.calculate_rounded),
                  label: Text(
                      _ctrl.isCalculating.value
                          ? 'Calculating...'
                          : 'Calculate Payroll',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  onPressed:
                      _ctrl.isCalculating.value ? null : _calculate,
                ),
              )),
          const SizedBox(height: 20),
          Obx(() {
            final res = _ctrl.calculateResult.value;
            if (res == null) return const SizedBox.shrink();
            return _CalculateResultCard(result: res);
          }),
        ]),
      ),
    );
  }
}

class _CalculateResultCard extends StatelessWidget {
  final PayrollCalculateResult result;
  const _CalculateResultCard({required this.result});

  bool get _noAtt => result.presentDays == 0;
  double get _net => _noAtt ? 0.0 : _effectiveNetResult(result);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
      if (!_noAtt && result.lateDeduction > 0) ...[
        _LateWarningBanner(lateDays: result.lateDays, isDeduction: true),
        const SizedBox(height: 12),
      ],
      if (!_noAtt && result.lateDays > 0 && result.lateDeduction == 0) ...[
        _LateWarningBanner(lateDays: result.lateDays, isDeduction: false),
        const SizedBox(height: 12),
      ],
      _SectionTitle('Payroll Breakdown'),
      const SizedBox(height: 8),
      _BreakdownCard(rows: [
        _Row('Employee', result.employeeName),
        _Row('Period', '${_monthName(result.month)} ${result.year}'),
        _Row('Basic Salary', '₹${result.basicSalary.toStringAsFixed(2)}'),
        _Row('Present Days', '${result.presentDays} days',
            valueColor: result.presentDays == 0 ? AppTheme.error : null),
        _Row('Absent Days',
            '${_noAtt ? _daysInMonth(result.month, result.year) : result.absentDays} days'),
        _Row('Late Arrivals', '${result.lateDays} days'),
        _Row('Per Day Salary', '₹${result.perDaySalary.toStringAsFixed(4)}'),
      ]),
      const SizedBox(height: 12),
      _SectionTitle('Deductions'),
      const SizedBox(height: 8),
      _BreakdownCard(rows: [
        _Row('Absent Deduction',
            '- ₹${_displayAbsentResult(result).toStringAsFixed(2)}',
            valueColor: AppTheme.error),
        _Row('Late Deduction',
            result.lateDeduction > 0
                ? '- ₹${result.lateDeduction.toStringAsFixed(2)}'
                : '₹0.00',
            valueColor: result.lateDeduction > 0
                ? AppTheme.error
                : AppTheme.textSecondary),
        _Row('Total Deductions',
            '- ₹${_effectiveTotalResult(result).toStringAsFixed(2)}',
            valueColor: AppTheme.error, isBold: true),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: _noAtt
              ? const LinearGradient(
                  colors: [Color(0xFF94A3B8), Color(0xFF64748B)])
              : const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Net Pay',
                style: TextStyle(color: Colors.white70, fontSize: 13,
                    fontFamily: 'Poppins')),
            Text(_noAtt ? 'No attendance — ₹0' : 'After all deductions',
                style: const TextStyle(color: Colors.white54,
                    fontSize: 10, fontFamily: 'Poppins')),
          ]),
          const Spacer(),
          Text('₹${_net.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
        ]),
      ),
      const SizedBox(height: 20),
    ]);
  }
}

// ═══════════════════════════════════════════
//  USER — OWN PAYROLL VIEW
// ═══════════════════════════════════════════
class _UserPayrollView extends StatelessWidget {
  const _UserPayrollView();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PayrollController>();
    final auth = Get.find<AuthController>();

    return Column(children: [
      Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(() => Row(children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  ctrl.prevMonth();
                  ctrl.loadMyPayroll(auth.currentUserId);
                },
              ),
              Expanded(
                child: Text(ctrl.periodLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins', color: AppTheme.textPrimary)),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: ctrl.canGoNext
                        ? AppTheme.textPrimary
                        : AppTheme.divider),
                onPressed: ctrl.canGoNext
                    ? () {
                        ctrl.nextMonth();
                        ctrl.loadMyPayroll(auth.currentUserId);
                      }
                    : null,
              ),
            ])),
      ),
      const Divider(height: 1),
      Expanded(
        child: Obx(() {
          if (ctrl.isLoadingMyPayroll.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          final slip = ctrl.myPayroll.value;
          if (slip == null) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_rounded,
                    size: 64, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text('No payroll data for ${ctrl.periodLabel}',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh'),
                  onPressed: () => ctrl.loadMyPayroll(auth.currentUserId),
                ),
              ]),
            );
          }
          return _UserPayrollDetail(slip: slip);
        }),
      ),
    ]);
  }
}

class _UserPayrollDetail extends StatelessWidget {
  final PayrollSlipModel slip;
  const _UserPayrollDetail({required this.slip});

  bool get _noAtt => slip.presentDays == 0;
  double get _net => _noAtt ? 0.0 : slip.netSalary;

  @override
  Widget build(BuildContext context) {
    final ctrl  = Get.find<PayrollController>();
    final color = Color(ctrl.statusColorValue(slip.status));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration(),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Net Salary',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: AppTheme.textSecondary)),
                Text('₹${_net.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(slip.statusLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins', color: color)),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        if (_noAtt) ...[const _NoAttendanceBanner(), const SizedBox(height: 12)],
        if (!_noAtt && slip.lateDeduction > 0) ...[
          _LateWarningBanner(lateDays: slip.lateDays, isDeduction: true),
          const SizedBox(height: 12),
        ],
        if (!_noAtt && slip.lateDays > 0 && slip.lateDeduction == 0) ...[
          _LateWarningBanner(lateDays: slip.lateDays, isDeduction: false),
          const SizedBox(height: 12),
        ],

        _SectionTitle('Salary Breakdown'),
        const SizedBox(height: 8),
        _BreakdownCard(rows: [
          _Row('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
          _Row('Gross Salary',
              _noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
          _Row('Present Days', '${slip.presentDays} days',
              valueColor: slip.presentDays == 0 ? AppTheme.error : null),
          _Row('Absent Days',
              '${_noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
          _Row('Late Arrivals', '${slip.lateDays} days'),
          _Row('Per Day Salary', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
        ]),
        const SizedBox(height: 14),

        _SectionTitle('Deductions'),
        const SizedBox(height: 8),
        _BreakdownCard(rows: [
          _Row('Absent Deduction',
              '- ₹${_displayAbsent(slip).toStringAsFixed(2)}',
              valueColor: AppTheme.error),
          _Row('Late Deduction',
              slip.lateDeduction > 0
                  ? '- ₹${slip.lateDeduction.toStringAsFixed(2)}'
                  : '₹0.00',
              valueColor: slip.lateDeduction > 0
                  ? AppTheme.error
                  : AppTheme.textSecondary),
          _Row('Other Deductions',
              slip.manualDeduction > 0
                  ? '- ₹${slip.manualDeduction.toStringAsFixed(2)}'
                  : '₹0.00',
              valueColor: slip.manualDeduction > 0
                  ? AppTheme.error
                  : AppTheme.textSecondary),
          _Row('Total Deductions',
              '- ₹${_effectiveTotal(slip).toStringAsFixed(2)}',
              valueColor: AppTheme.error, isBold: true),
        ]),
        const SizedBox(height: 14),

        if (slip.isApproved) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
              label: const Text('View Pay Slip',
                  style: TextStyle(fontFamily: 'Poppins',
                      color: AppTheme.primary, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _PaySlipPrintView(slip: slip),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (slip.isPending)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warningLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your payroll is pending admin approval. Pay slip will be available once approved.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                      color: AppTheme.warning),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _PaySlipPrintView extends StatelessWidget {
  final PayrollSlipModel slip;
  const _PaySlipPrintView({required this.slip});

  bool get _noAtt => slip.presentDays == 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('PAY SLIP',
                    style: TextStyle(color: Colors.white70, fontSize: 12,
                        letterSpacing: 4, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text(slip.employeeName,
                    style: const TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                Text('${_monthName(slip.month)} ${slip.year}',
                    style: const TextStyle(color: Colors.white70,
                        fontSize: 13, fontFamily: 'Poppins')),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(slip.statusLabel.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 2,
                          fontFamily: 'Poppins')),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            _SlipSection(title: 'EARNINGS', rows: [
              _SlipRow('Basic Salary', '₹${slip.basicSalary.toStringAsFixed(2)}'),
              _SlipRow('Gross Salary',
                  _noAtt ? '₹0.00' : '₹${slip.grossSalary.toStringAsFixed(2)}'),
            ]),
            const SizedBox(height: 10),

            _SlipSection(title: 'ATTENDANCE', rows: [
              _SlipRow('Present Days', '${slip.presentDays} days'),
              _SlipRow('Absent Days',
                  '${_noAtt ? _daysInMonth(slip.month, slip.year) : slip.absentDays} days'),
              _SlipRow('Late Arrivals', '${slip.lateDays} days'),
              _SlipRow('Per Day', '₹${slip.perDaySalary.toStringAsFixed(4)}'),
            ]),
            const SizedBox(height: 10),

            _SlipSection(title: 'DEDUCTIONS', rows: [
              _SlipRow('Absent',
                  '₹${_displayAbsent(slip).toStringAsFixed(2)}',
                  isDeduction: true),
              _SlipRow('Late',
                  '₹${slip.lateDeduction.toStringAsFixed(2)}',
                  isDeduction: slip.lateDeduction > 0),
              _SlipRow(
                  slip.manualDeductionReason?.isNotEmpty == true
                      ? slip.manualDeductionReason!
                      : 'Manual Deduction',
                  '₹${slip.manualDeduction.toStringAsFixed(2)}',
                  isDeduction: slip.manualDeduction > 0),
            ]),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _noAtt
                    ? const Color(0xFFE2E8F0)
                    : AppTheme.successLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _noAtt
                        ? const Color(0xFF94A3B8).withOpacity(0.3)
                        : AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Text('NET PAY',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.w700, letterSpacing: 1,
                        color: AppTheme.success)),
                const Spacer(),
                Text(_noAtt ? '₹0.00' : '₹${slip.netSalary.toStringAsFixed(2)}',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _noAtt
                            ? const Color(0xFF94A3B8)
                            : AppTheme.success)),
              ]),
            ),

            if (slip.isPaid && slip.paidAt != null) ...[
              const SizedBox(height: 12),
              Text('Paid on: ${_fmtDateTime(slip.paidAt)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, color: AppTheme.textHint)),
            ],
            if (slip.remarks?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Remarks: ${slip.remarks}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, color: AppTheme.textHint)),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════

class _NoAttendanceBanner extends StatelessWidget {
  const _NoAttendanceBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.person_off_rounded, color: AppTheme.error, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'No attendance recorded this month.\nSalary cannot be processed — Net Pay is ₹0.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                color: AppTheme.error, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}

class _BlockedBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _BlockedBtn(
      {required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ]),
    );
  }
}

class _LateWarningBanner extends StatelessWidget {
  final int lateDays;
  final bool isDeduction;
  const _LateWarningBanner(
      {required this.lateDays, required this.isDeduction});
  @override
  Widget build(BuildContext context) {
    final color = isDeduction ? AppTheme.error : AppTheme.warning;
    final bg    = isDeduction ? AppTheme.errorLight : AppTheme.warningLight;
    final icon  = isDeduction
        ? Icons.money_off_rounded
        : Icons.warning_amber_rounded;
    final text = isDeduction
        ? '⚠ $lateDays late arrival${lateDays > 1 ? 's' : ''} — hourly deduction applied (>3 days grace period exceeded).'
        : '⚠ Warning: $lateDays late arrival${lateDays > 1 ? 's' : ''} this month (within 3-day grace period — no deduction).';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: color, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          fontWeight: FontWeight.w700, color: AppTheme.textSecondary,
          letterSpacing: 0.5));
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
}

class _Row {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _Row(this.label, this.value, {this.valueColor, this.isBold = false});
}

class _BreakdownCard extends StatelessWidget {
  final List<_Row> rows;
  const _BreakdownCard({required this.rows});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final row    = e.value;
          final isLast = e.key == rows.length - 1;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppTheme.divider, width: 0.8)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(row.label,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: row.isBold
                            ? FontWeight.w700
                            : FontWeight.w400)),
              ),
              Text(row.value,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: row.isBold
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: row.valueColor ?? AppTheme.textPrimary)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _DeductionChip extends StatelessWidget {
  final PayrollDeductionModel d;
  const _DeductionChip(this.d);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.error.withOpacity(0.2))),
      child: Row(children: [
        const Icon(Icons.remove_circle_rounded, color: AppTheme.error, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(d.reason,
              style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 12, color: AppTheme.error)),
        ),
        Text('- ₹${d.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                fontWeight: FontWeight.w700, color: AppTheme.error)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.color,
      required this.loading, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: loading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0),
        onPressed: loading ? null : onTap,
      ),
    );
  }
}

class _SlipSection extends StatelessWidget {
  final String title;
  final List<_SlipRow> rows;
  const _SlipSection({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 2,
              color: AppTheme.textSecondary)),
      const SizedBox(height: 6),
      Container(
        decoration: AppTheme.cardDecoration(),
        child: Column(
          children: rows.asMap().entries.map((e) {
            final r      = e.value;
            final isLast = e.key == rows.length - 1;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom: BorderSide(
                            color: AppTheme.divider, width: 0.6)),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(r.label,
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 12, color: AppTheme.textSecondary))),
                Text(r.value,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: r.isDeduction
                            ? AppTheme.error
                            : AppTheme.textPrimary)),
              ]),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

class _SlipRow {
  final String label, value;
  final bool isDeduction;
  const _SlipRow(this.label, this.value, {this.isDeduction = false});
}

class _MonthDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;
  const _MonthDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
      ),
      items: List.generate(
          12,
          (i) => DropdownMenuItem<int>(
              value: i + 1, child: Text(months[i]))),
      onChanged: onChanged,
    );
  }
}

class _YearDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;
  const _YearDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now().year;
    final years = List.generate(5, (i) => now - i);
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
      ),
      items: years
          .map((y) => DropdownMenuItem<int>(
              value: y, child: Text('$y')))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ═══════════════════════════════════════════
//  GLOBAL HELPERS
// ═══════════════════════════════════════════

String _monthName(int m) {
  const n = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return n[m.clamp(1, 12)];
}

String _fmtDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    var s = iso.trim();
    if (!s.endsWith('Z') &&
        !s.contains('+') &&
        !RegExp(r'-\d{2}:\d{2}$').hasMatch(s)) s += 'Z';
    final dt = DateTime.parse(s).toLocal();
    const mo = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${mo[dt.month]} ${dt.year}, $h:$m';
  } catch (_) {
    return iso;
  }
}

double _displayAbsent(PayrollSlipModel slip) =>
    slip.presentDays == 0 ? slip.basicSalary : slip.absentDeduction;

double _displayAbsentResult(PayrollCalculateResult r) =>
    r.presentDays == 0 ? r.basicSalary : r.absentDeduction;

double _effectiveTotal(PayrollSlipModel slip) =>
    _displayAbsent(slip) + slip.lateDeduction + slip.manualDeduction;

double _effectiveTotalResult(PayrollCalculateResult r) =>
    _displayAbsentResult(r) + r.lateDeduction + r.manualDeduction;

double _effectiveNetResult(PayrollCalculateResult r) =>
    r.presentDays == 0 ? 0.0 : r.basicSalary - _effectiveTotalResult(r);

int _daysInMonth(int month, int year) =>
    DateTime(year, month + 1, 0).day;