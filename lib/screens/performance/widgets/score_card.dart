// // lib/screens/performance/widgets/score_card.dart

// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class ScoreCard extends StatelessWidget {
//   final double score;
//   final String? grade;
//   final double? autoScore;
//   final double? manualScore;
//   final String? comments;

//   const ScoreCard({
//     super.key,
//     required this.score,
//     this.grade,
//     this.autoScore,
//     this.manualScore,
//     this.comments,
//   });

//   Color get _gradeColor {
//     final g = grade?.toUpperCase() ?? '';
//     if (g == 'A+' || g == 'A') return Colors.green;
//     if (g == 'B') return Colors.blue;
//     if (g == 'C') return Colors.orange;
//     return Colors.red;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).primaryColor,
//             Theme.of(context).primaryColor.withBlue(200),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).primaryColor.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Score Arc ────────────────────────────────────────────────────
//           SizedBox(
//             height: 120,
//             child: CustomPaint(
//               painter: ScoreArcPainter(score: score),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       score.toStringAsFixed(1),
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const Text(
//                       'Performance Score',
//                       style: TextStyle(color: Colors.white70, fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // ── Grade Badge ──────────────────────────────────────────────────
//           if (grade != null) ...[
//             const SizedBox(height: 8),
//             Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _gradeColor,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 'Grade: $grade',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],

//           // ── Auto vs Manual Score ─────────────────────────────────────────
//           if (autoScore != null || manualScore != null) ...[
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 if (autoScore != null)
//                   Expanded(
//                     child: _ScoreBreakdown(
//                       label: 'Auto Score',
//                       value: autoScore!.toStringAsFixed(1),
//                     ),
//                   ),
//                 if (autoScore != null && manualScore != null)
//                   Container(width: 1, height: 30, color: Colors.white30),
//                 if (manualScore != null)
//                   Expanded(
//                     child: _ScoreBreakdown(
//                       label: 'Manual Score',
//                       value: manualScore!.toStringAsFixed(1),
//                     ),
//                   ),
//               ],
//             ),
//           ],

//           // ── Comments ─────────────────────────────────────────────────────
//           if (comments != null && comments!.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.comment_outlined,
//                       size: 14, color: Colors.white70),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       comments!,
//                       style: const TextStyle(
//                           color: Colors.white70, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // ─── Score Breakdown Row Item ─────────────────────────────────────────────────
// class _ScoreBreakdown extends StatelessWidget {
//   final String label;
//   final String value;
//   const _ScoreBreakdown({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white60, fontSize: 11),
//         ),
//       ],
//     );
//   }
// }

// // ─── Arc Painter ──────────────────────────────────────────────────────────────
// class ScoreArcPainter extends CustomPainter {
//   final double score;
//   const ScoreArcPainter({required this.score});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx     = size.width / 2;
//     final cy     = size.height * 0.75;
//     final radius = size.width * 0.42;

//     const startAngle = math.pi;
//     const sweepMax   = math.pi;

//     final bgPaint = Paint()
//       ..color      = Colors.white.withOpacity(0.2)
//       ..strokeWidth = 8
//       ..style      = PaintingStyle.stroke
//       ..strokeCap  = StrokeCap.round;

//     final fgPaint = Paint()
//       ..color      = Colors.white
//       ..strokeWidth = 8
//       ..style      = PaintingStyle.stroke
//       ..strokeCap  = StrokeCap.round;

//     final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

//     // Background arc
//     canvas.drawArc(rect, startAngle, sweepMax, false, bgPaint);

//     // Foreground arc (score progress)
//     final sweep = sweepMax * (score.clamp(0, 100) / 100);
//     canvas.drawArc(rect, startAngle, sweep, false, fgPaint);
//   }

//   @override
//   bool shouldRepaint(ScoreArcPainter old) => old.score != score;
// }






// // lib/screens/performance/widgets/score_card.dart

// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ScoreCard extends StatelessWidget {
//   final double score;
//   final String? grade;
//   final double? autoScore;
//   final double? manualScore;
//   final String? comments;
//   final int month;
//   final int year;

//   // Attendance stats (all inside same card)
//   final double? attendancePercentage;
//   final double? averageWorkingHours;
//   final double? performanceScore;
//   final int? presentDays;
//   final int? absentDays;
//   final int? wfhDays;
//   final int? totalWorkingDays;

//   const ScoreCard({
//     super.key,
//     required this.score,
//     required this.month,
//     required this.year,
//     this.grade,
//     this.autoScore,
//     this.manualScore,
//     this.comments,
//     this.attendancePercentage,
//     this.averageWorkingHours,
//     this.performanceScore,
//     this.presentDays,
//     this.absentDays,
//     this.wfhDays,
//     this.totalWorkingDays,
//   });

//   Color get _gradeColor {
//     switch (grade?.toUpperCase() ?? '') {
//       case 'A+':
//       case 'A':  return const Color(0xFF22C55E);
//       case 'B':  return const Color(0xFF3B82F6);
//       case 'C':  return const Color(0xFFF97316);
//       default:   return const Color(0xFFEF4444);
//     }
//   }

//   Color get _bgColor {
//     switch (grade?.toUpperCase() ?? '') {
//       case 'A+':
//       case 'A':  return const Color(0xFFDCFCE7);
//       case 'B':  return const Color(0xFFDBEAFE);
//       case 'C':  return const Color(0xFFFFF7ED);
//       default:   return const Color(0xFFFEF2F2);
//     }
//   }

//   String get _monthLabel {
//     try {
//       return DateFormat('MMMM yyyy').format(DateTime(year, month));
//     } catch (_) {
//       return '';
//     }
//   }

//   // ✅ Month ke actual working days (Mon–Sat)
//   int get _calculatedWorkingDays {
//     if (totalWorkingDays != null) return totalWorkingDays!;
//     final daysInMonth = DateTime(year, month + 1, 0).day;
//     int count = 0;
//     for (int d = 1; d <= daysInMonth; d++) {
//       if (DateTime(year, month, d).weekday != DateTime.sunday) {
//         count++;
//       }
//     }
//     return count;
//   }

//   // ✅ Month ke Sundays
//   int get _sundaysInMonth {
//     final daysInMonth = DateTime(year, month + 1, 0).day;
//     int count = 0;
//     for (int d = 1; d <= daysInMonth; d++) {
//       if (DateTime(year, month, d).weekday == DateTime.sunday) {
//         count++;
//       }
//     }
//     return count;
//   }

//   // ✅ Month ke total calendar days
//   int get _totalCalendarDays => DateTime(year, month + 1, 0).day;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [

//           // ── Header: Star + Title ─────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
//             child: Row(
//               children: const [
//                 Icon(Icons.star_rounded,
//                     color: Color(0xFFFACC15), size: 26),
//                 SizedBox(width: 8),
//                 Text(
//                   'Performance Score',
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Divider ──────────────────────────────────────────────────────
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             child: Divider(height: 1, color: Color(0xFFE5E7EB)),
//           ),

//           // ── Circle Score ─────────────────────────────────────────────────
//           SizedBox(
//             width: 175,
//             height: 175,
//             child: CustomPaint(
//               painter: _CircleScorePainter(
//                 score:     score,
//                 ringColor: _gradeColor,
//                 bgColor:   _bgColor,
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       score.toStringAsFixed(1),
//                       style: TextStyle(
//                         fontSize: 44,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: _gradeColor,
//                         height: 1.1,
//                       ),
//                     ),
//                     if (grade != null)
//                       Text(
//                         grade!,
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Poppins',
//                           color: _gradeColor,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 10),

//           // ── Month Label ──────────────────────────────────────────────────
//           Text(
//             _monthLabel,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF9CA3AF),
//               fontFamily: 'Poppins',
//             ),
//           ),

//           const SizedBox(height: 20),

//           // ── Row 1: Attendance | Avg Hours | Perf Score ───────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _StatBox(
//                   value: attendancePercentage != null
//                       ? '${attendancePercentage!.toStringAsFixed(1)}%'
//                       : '-',
//                   label: 'Attendance',
//                   valueColor: const Color(0xFF3B82F6),
//                   bgColor:    const Color(0xFFEFF6FF),
//                 ),
//                 const SizedBox(width: 10),
//                 _StatBox(
//                   value: averageWorkingHours != null
//                       ? '${averageWorkingHours!.toStringAsFixed(1)}h'
//                       : '-',
//                   label: 'Avg Hours',
//                   valueColor: const Color(0xFF8B5CF6),
//                   bgColor:    const Color(0xFFF5F3FF),
//                 ),
//                 const SizedBox(width: 10),
//                 _StatBox(
//                   value: (performanceScore ?? score).toStringAsFixed(1),
//                   label: 'Perf Score',
//                   valueColor: const Color(0xFF22C55E),
//                   bgColor:    const Color(0xFFF0FDF4),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 10),

//           // ── Row 2: Total | Sunday | Present | Absent | WFH ──────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _StatBox(
//                   value: '$_totalCalendarDays',
//                   label: 'Total Days',
//                   valueColor: const Color(0xFF64748B),
//                   bgColor:    const Color(0xFFF1F5F9),
//                 ),
//                 const SizedBox(width: 8),
//                 _StatBox(
//                   value: '$_sundaysInMonth',
//                   label: 'Sunday',
//                   valueColor: const Color(0xFFEC4899),
//                   bgColor:    const Color(0xFFFDF2F8),
//                 ),
//                 const SizedBox(width: 8),
//                 _StatBox(
//                   value: '${presentDays ?? '-'}',
//                   label: 'Present',
//                   valueColor: const Color(0xFF22C55E),
//                   bgColor:    const Color(0xFFF0FDF4),
//                 ),
//                 const SizedBox(width: 8),
//                 _StatBox(
//                   value: '${absentDays ?? '-'}',
//                   label: 'Absent',
//                   valueColor: const Color(0xFFEF4444),
//                   bgColor:    const Color(0xFFFEF2F2),
//                 ),
//                 const SizedBox(width: 8),
//                 _StatBox(
//                   value: '${wfhDays ?? '-'}',
//                   label: 'WFH',
//                   valueColor: const Color(0xFFF97316),
//                   bgColor:    const Color(0xFFFFF7ED),
//                 ),
//               ],
//             ),
//           ),

//           // ── Comments ──────────────────────────────────────────────────────
//           if (comments != null && comments!.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF9FAFB),
//                   borderRadius: BorderRadius.circular(10),
//                   border:
//                       Border.all(color: const Color(0xFFE5E7EB)),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Icon(Icons.format_quote_rounded,
//                         size: 16, color: Color(0xFF9CA3AF)),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         comments!,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF6B7280),
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// // ─── Stat Box ─────────────────────────────────────────────────────────────────
// class _StatBox extends StatelessWidget {
//   final String value;
//   final String label;
//   final Color valueColor;
//   final Color bgColor;

//   const _StatBox({
//     required this.value,
//     required this.label,
//     required this.valueColor,
//     required this.bgColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 13),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: valueColor,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Color(0xFF9CA3AF),
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Circle Painter ───────────────────────────────────────────────────────────
// class _CircleScorePainter extends CustomPainter {
//   final double score;
//   final Color ringColor;
//   final Color bgColor;

//   const _CircleScorePainter({
//     required this.score,
//     required this.ringColor,
//     required this.bgColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width / 2;
//     final cy = size.height / 2;
//     final radius = size.width / 2 - 8;

//     // Fill circle
//     canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = bgColor);

//     // Track ring
//     canvas.drawCircle(
//       Offset(cx, cy),
//       radius,
//       Paint()
//         ..color = ringColor.withOpacity(0.15)
//         ..strokeWidth = 12
//         ..style = PaintingStyle.stroke,
//     );

//     // Progress ring
//     canvas.drawArc(
//       Rect.fromCircle(center: Offset(cx, cy), radius: radius),
//       -math.pi / 2,
//       2 * math.pi * (score.clamp(0, 100) / 100),
//       false,
//       Paint()
//         ..color = ringColor
//         ..strokeWidth = 12
//         ..style = PaintingStyle.stroke
//         ..strokeCap = StrokeCap.round,
//     );
//   }

//   @override
//   bool shouldRepaint(_CircleScorePainter old) =>
//       old.score != score || old.ringColor != ringColor;
// }











// lib/screens/performance/widgets/score_card.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreCard extends StatelessWidget {
  final double score;
  final String? grade;
  final double? autoScore;
  final double? manualScore;
  final String? comments;
  final int month;
  final int year;

  // Attendance stats (all inside same card)
  final double? attendancePercentage;
  final double? averageWorkingHours;
  final double? performanceScore;
  final int? presentDays;
  final int? absentDays;
  final int? wfhDays;
  final int? totalWorkingDays;

  const ScoreCard({
    super.key,
    required this.score,
    required this.month,
    required this.year,
    this.grade,
    this.autoScore,
    this.manualScore,
    this.comments,
    this.attendancePercentage,
    this.averageWorkingHours,
    this.performanceScore,
    this.presentDays,
    this.absentDays,
    this.wfhDays,
    this.totalWorkingDays,
  });

  Color get _gradeColor {
    switch (grade?.toUpperCase() ?? '') {
      case 'A+':
      case 'A':  return const Color(0xFF22C55E);
      case 'B':  return const Color(0xFF3B82F6);
      case 'C':  return const Color(0xFFF97316);
      default:   return const Color(0xFFEF4444);
    }
  }

  Color get _bgColor {
    switch (grade?.toUpperCase() ?? '') {
      case 'A+':
      case 'A':  return const Color(0xFFDCFCE7);
      case 'B':  return const Color(0xFFDBEAFE);
      case 'C':  return const Color(0xFFFFF7ED);
      default:   return const Color(0xFFFEF2F2);
    }
  }

  String get _monthLabel {
    try {
      return DateFormat('MMMM yyyy').format(DateTime(year, month));
    } catch (_) {
      return '';
    }
  }

  // ✅ Month ke actual working days (Mon–Sat)
  int get _calculatedWorkingDays {
    if (totalWorkingDays != null) return totalWorkingDays!;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (DateTime(year, month, d).weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  // ✅ Month ke Sundays
  int get _sundaysInMonth {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (DateTime(year, month, d).weekday == DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  // ✅ Month ke Saturdays
  int get _saturdaysInMonth {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (DateTime(year, month, d).weekday == DateTime.saturday) count++;
    }
    return count;
  }

  // ✅ Month ke total calendar days
  int get _totalCalendarDays => DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Header: Star + Title ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: const [
                Icon(Icons.star_rounded,
                    color: Color(0xFFFACC15), size: 26),
                SizedBox(width: 8),
                Text(
                  'Performance Score',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),

          // ── Circle Score ─────────────────────────────────────────────────
          SizedBox(
            width: 175,
            height: 175,
            child: CustomPaint(
              painter: _CircleScorePainter(
                score:     score,
                ringColor: _gradeColor,
                bgColor:   _bgColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: _gradeColor,
                        height: 1.1,
                      ),
                    ),
                    if (grade != null)
                      Text(
                        grade!,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: _gradeColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Month Label ──────────────────────────────────────────────────
          Text(
            _monthLabel,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 20),

          // ── Row 1: Attendance | Avg Hours | Perf Score ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatBox(
                  value: attendancePercentage != null
                      ? '${attendancePercentage!.toStringAsFixed(1)}%'
                      : '-',
                  label: 'Attendance',
                  valueColor: const Color(0xFF3B82F6),
                  bgColor:    const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 10),
                _StatBox(
                  value: averageWorkingHours != null
                      ? '${averageWorkingHours!.toStringAsFixed(1)}h'
                      : '-',
                  label: 'Avg Hours',
                  valueColor: const Color(0xFF8B5CF6),
                  bgColor:    const Color(0xFFF5F3FF),
                ),
                const SizedBox(width: 10),
                _StatBox(
                  value: (performanceScore ?? score).toStringAsFixed(1),
                  label: 'Perf Score',
                  valueColor: const Color(0xFF22C55E),
                  bgColor:    const Color(0xFFF0FDF4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Row 2: Total | Sunday | Saturday | Present | Absent | WFH ────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatBoxFixed(
                  value: '$_totalCalendarDays',
                  label: 'Total Days',
                  valueColor: const Color(0xFF64748B),
                  bgColor:    const Color(0xFFF1F5F9),
                ),
                _StatBoxFixed(
                  value: '$_sundaysInMonth',
                  label: 'Sunday',
                  valueColor: const Color(0xFFEC4899),
                  bgColor:    const Color(0xFFFDF2F8),
                ),
                _StatBoxFixed(
                  value: '$_saturdaysInMonth',
                  label: 'Saturday',
                  valueColor: const Color(0xFF6366F1),
                  bgColor:    const Color(0xFFEEF2FF),
                ),
                _StatBoxFixed(
                  value: '${presentDays ?? '-'}',
                  label: 'Present',
                  valueColor: const Color(0xFF22C55E),
                  bgColor:    const Color(0xFFF0FDF4),
                ),
                _StatBoxFixed(
                  value: '${absentDays ?? '-'}',
                  label: 'Absent',
                  valueColor: const Color(0xFFEF4444),
                  bgColor:    const Color(0xFFFEF2F2),
                ),
                _StatBoxFixed(
                  value: '${wfhDays ?? '-'}',
                  label: 'WFH',
                  valueColor: const Color(0xFFF97316),
                  bgColor:    const Color(0xFFFFF7ED),
                ),
              ],
            ),
          ),

          // ── Comments ──────────────────────────────────────────────────────
          if (comments != null && comments!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        comments!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Stat Box ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color bgColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Box Fixed (for Wrap layout) ────────────────────────────────────────
class _StatBoxFixed extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final Color bgColor;

  const _StatBoxFixed({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 32 - 40) / 3;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Circle Painter ───────────────────────────────────────────────────────────
class _CircleScorePainter extends CustomPainter {
  final double score;
  final Color ringColor;
  final Color bgColor;

  const _CircleScorePainter({
    required this.score,
    required this.ringColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 8;

    // Fill circle
    canvas.drawCircle(Offset(cx, cy), radius, Paint()..color = bgColor);

    // Track ring
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = ringColor.withOpacity(0.15)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke,
    );

    // Progress ring
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * (score.clamp(0, 100) / 100),
      false,
      Paint()
        ..color = ringColor
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircleScorePainter old) =>
      old.score != score || old.ringColor != ringColor;
}