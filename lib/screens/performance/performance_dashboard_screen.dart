// // lib/screens/performance/performance_dashboard_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/performance_controller.dart';
// import 'widgets/month_year_picker.dart';
// import 'widgets/score_card.dart';

// class PerformanceDashboardScreen extends StatefulWidget {
//   const PerformanceDashboardScreen({super.key});

//   @override
//   State<PerformanceDashboardScreen> createState() =>
//       _PerformanceDashboardScreenState();
// }

// class _PerformanceDashboardScreenState
//     extends State<PerformanceDashboardScreen> {
//   final _ctrl = Get.find<PerformanceController>();
//   final _auth = Get.find<AuthController>();

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   void _load() {
//     _ctrl.fetchEmployeeScore(
//       month:  _ctrl.selectedMonth.value,
//       year:   _ctrl.selectedYear.value,
//       userId: _auth.currentUserId,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEEF2F7),
//       appBar: AppBar(
//         title: const Text('My Performance'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.leaderboard_outlined),
//             tooltip: 'Rankings',
//             onPressed: () => Get.toNamed('/performance/ranking'),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // ── Month / Year Picker ──────────────────────────────────────────
//           Obx(() => MonthYearPicker(
//                 month: _ctrl.selectedMonth.value,
//                 year:  _ctrl.selectedYear.value,
//                 onChanged: (m, y) {
//                   _ctrl.setMonthYear(m, y);
//                   _load();
//                 },
//               )),

//           // ── Body ────────────────────────────────────────────────────────
//           Expanded(
//             child: Obx(() {
//               if (_ctrl.isLoadingScore.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (_ctrl.errorScore.value.isNotEmpty) {
//                 return _ErrorView(
//                   message: _ctrl.errorScore.value,
//                   onRetry: _load,
//                 );
//               }

//               final score = _ctrl.employeeScore.value;
//               if (score == null) {
//                 return const _EmptyView(
//                   message: 'No performance data for this month.',
//                 );
//               }

//               return RefreshIndicator(
//                 onRefresh: () async => _load(),
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.all(16),
//                   child: ScoreCard(
//                     score:                score.finalScore,
//                     grade:                score.grade,
//                     month:                _ctrl.selectedMonth.value,
//                     year:                 _ctrl.selectedYear.value,
//                     autoScore:            score.autoScore,
//                     manualScore:          score.manualScore,
//                     comments:             score.comments,
//                     attendancePercentage: score.attendancePercentage,
//                     averageWorkingHours:  score.averageWorkingHours,
//                     performanceScore:     score.performanceScore,
//                     presentDays:          score.presentDays,
//                     absentDays:           score.absentDays,
//                     wfhDays:              score.wfhDays,
//                     totalWorkingDays:     score.totalWorkingDays,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Empty ────────────────────────────────────────────────────────────────────
// class _EmptyView extends StatelessWidget {
//   final String message;
//   const _EmptyView({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.bar_chart_outlined,
//               size: 64, color: Colors.grey.shade300),
//           const SizedBox(height: 12),
//           Text(message,
//               style: TextStyle(
//                   color: Colors.grey.shade500,
//                   fontSize: 14,
//                   fontFamily: 'Poppins')),
//         ],
//       ),
//     );
//   }
// }

// // ─── Error ────────────────────────────────────────────────────────────────────
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 12),
//             Text(message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 16),
//             OutlinedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }












// lib/screens/performance/performance_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/performance_controller.dart';
import 'widgets/month_year_picker.dart';
import 'widgets/score_card.dart';

class PerformanceDashboardScreen extends StatefulWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  State<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState
    extends State<PerformanceDashboardScreen> {
  final _ctrl = Get.find<PerformanceController>();
  final _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _ctrl.fetchEmployeeScore(
      month:  _ctrl.selectedMonth.value,
      year:   _ctrl.selectedYear.value,
      userId: _auth.currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('My Performance'),
        centerTitle: true,

        // ✅ Rankings icon sirf Admin ko dikhega
        actions: [
          Obx(() => _auth.isAdmin
              ? IconButton(
                  icon: const Icon(Icons.leaderboard_outlined),
                  tooltip: 'Rankings',
                  onPressed: () => Get.toNamed('/performance/ranking'),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // ── Month / Year Picker ──────────────────────────────────────────
          Obx(() => MonthYearPicker(
                month: _ctrl.selectedMonth.value,
                year:  _ctrl.selectedYear.value,
                onChanged: (m, y) {
                  _ctrl.setMonthYear(m, y);
                  _load();
                },
              )),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingScore.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_ctrl.errorScore.value.isNotEmpty) {
                return _ErrorView(
                  message: _ctrl.errorScore.value,
                  onRetry: _load,
                );
              }

              final score = _ctrl.employeeScore.value;
              if (score == null) {
                return const _EmptyView(
                  message: 'No performance data for this month.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: ScoreCard(
                    score:                score.finalScore,
                    grade:                score.grade,
                    month:                _ctrl.selectedMonth.value,
                    year:                 _ctrl.selectedYear.value,
                    autoScore:            score.autoScore,
                    manualScore:          score.manualScore,
                    comments:             score.comments,
                    attendancePercentage: score.attendancePercentage,
                    averageWorkingHours:  score.averageWorkingHours,
                    performanceScore:     score.performanceScore,
                    presentDays:          score.presentDays,
                    absentDays:           score.absentDays,
                    wfhDays:              score.wfhDays,
                    totalWorkingDays:     score.totalWorkingDays,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}