// // lib/screens/performance/ranking_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/performance_controller.dart';
// import '../../models/performance_model.dart';
// import '../../core/theme/app_theme.dart';
// import 'widgets/month_year_picker.dart';

// class RankingScreen extends StatefulWidget {
//   const RankingScreen({super.key});

//   @override
//   State<RankingScreen> createState() => _RankingScreenState();
// }

// class _RankingScreenState extends State<RankingScreen> {
//   final _ctrl = Get.find<PerformanceController>();
//   final _auth = Get.find<AuthController>();

//   @override
//   void initState() {
//     super.initState();
//     _load();
//     // ✅ Roles /api/Role se fetch karo — department chips ke liye
//     _ctrl.fetchRoles();
//   }

//   void _load() {
//     _ctrl.fetchRanking(
//       month: _ctrl.selectedMonth.value,
//       year:  _ctrl.selectedYear.value,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         title: const Text('Employee Rankings'),
//         centerTitle: true,
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

//           // ── Department Filter Chips — /api/Role se ───────────────────────
//           Obx(() {
//             // ✅ Chips roles API se aate hain, ranking data se nahi
//             final roles = _ctrl.rolesList;
//             if (roles.isEmpty) return const SizedBox.shrink();

//             return Container(
//               height: 44,
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   // "All" chip
//                   _DeptChip(
//                     label: 'All',
//                     selected: _ctrl.selectedDept.value.isEmpty,
//                     onTap: () {
//                       _ctrl.updateDepartment('');
//                       _load();
//                     },
//                   ),
//                   // Role chips from API
//                   ...roles.map((role) => _DeptChip(
//                         label: role,
//                         selected: _ctrl.selectedDept.value.toLowerCase() ==
//                             role.toLowerCase(),
//                         onTap: () {
//                           _ctrl.updateDepartment(role);
//                           _ctrl.fetchRanking(
//                             month:      _ctrl.selectedMonth.value,
//                             year:       _ctrl.selectedYear.value,
//                             department: role,
//                           );
//                         },
//                       )),
//                 ],
//               ),
//             );
//           }),

//           // ── Rankings List ────────────────────────────────────────────────
//           Expanded(
//             child: Obx(() {
//               if (_ctrl.isLoadingRanking.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (_ctrl.errorRanking.value.isNotEmpty &&
//                   _ctrl.rankings.isEmpty) {
//                 return _ErrorView(
//                   message: _ctrl.errorRanking.value,
//                   onRetry: _load,
//                 );
//               }

//               if (_ctrl.rankings.isEmpty) {
//                 return const _EmptyView(
//                     message: 'No rankings available.');
//               }

//               return RefreshIndicator(
//                 onRefresh: () async => _load(),
//                 child: ListView.separated(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 8),
//                   itemCount: _ctrl.rankings.length,
//                   separatorBuilder: (_, __) =>
//                       const SizedBox(height: 8),
//                   itemBuilder: (context, i) {
//                     final item = _ctrl.rankings[i];
//                     final isMe = item.userId == _auth.currentUserId;
//                     return _RankCard(item: item, isMe: isMe);
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Rank Card ────────────────────────────────────────────────────────────────
// class _RankCard extends StatelessWidget {
//   final RankingModel item;
//   final bool isMe;
//   const _RankCard({required this.item, required this.isMe});

//   @override
//   Widget build(BuildContext context) {
//     final rank = item.rank;
//     Widget rankBadge;

//     if (rank == 1) {
//       rankBadge = const Icon(Icons.emoji_events,
//           color: Color(0xFFFFD700), size: 28);
//     } else if (rank == 2) {
//       rankBadge = const Icon(Icons.emoji_events,
//           color: Color(0xFFC0C0C0), size: 26);
//     } else if (rank == 3) {
//       rankBadge = const Icon(Icons.emoji_events,
//           color: Color(0xFFCD7F32), size: 24);
//     } else {
//       rankBadge = Text(
//         '#$rank',
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//           fontFamily: 'Poppins',
//           color: Colors.grey.shade600,
//         ),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: isMe ? const Color(0xFFE8F5E9) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isMe ? Colors.green.shade300 : Colors.grey.shade200,
//           width: isMe ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         leading:
//             SizedBox(width: 36, child: Center(child: rankBadge)),
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 item.userName,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   fontFamily: 'Poppins',
//                   color: isMe
//                       ? Colors.green.shade800
//                       : Colors.black87,
//                 ),
//               ),
//             ),
//             if (isMe)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'You',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Poppins'),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Row(
//           children: [
//             if (item.department != null &&
//                 item.department!.isNotEmpty) ...[
//               Icon(Icons.business_outlined,
//                   size: 12, color: Colors.grey.shade500),
//               const SizedBox(width: 3),
//               Text(item.department!,
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade500,
//                       fontFamily: 'Poppins')),
//               const SizedBox(width: 10),
//             ],
//             if (item.attendancePercentage != null) ...[
//               Icon(Icons.check_circle_outline,
//                   size: 12, color: Colors.grey.shade500),
//               const SizedBox(width: 3),
//               Text(
//                 '${item.attendancePercentage!.toStringAsFixed(0)}%',
//                 style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'Poppins'),
//               ),
//             ],
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               item.finalScore.toStringAsFixed(1),
//               style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Poppins'),
//             ),
//             if (item.grade != null)
//               _GradeBadge(grade: item.grade!),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Grade Badge ──────────────────────────────────────────────────────────────
// class _GradeBadge extends StatelessWidget {
//   final String grade;
//   const _GradeBadge({required this.grade});

//   Color get _color {
//     switch (grade.toUpperCase()) {
//       case 'A+':
//       case 'A':  return Colors.green;
//       case 'B':  return Colors.blue;
//       case 'C':  return Colors.orange;
//       default:   return Colors.red;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//       decoration: BoxDecoration(
//         color: _color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         grade,
//         style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Poppins',
//             color: _color),
//       ),
//     );
//   }
// }

// // ─── Dept Chip ────────────────────────────────────────────────────────────────
// class _DeptChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//   const _DeptChip(
//       {required this.label,
//       required this.selected,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(
//             horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? AppTheme.primary : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected
//                 ? AppTheme.primary
//                 : Colors.grey.shade300,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Poppins',
//             color: selected
//                 ? Colors.white
//                 : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Empty ────────────────────────────────────────────────────────────────────
// class _EmptyView extends StatelessWidget {
//   final String message;
//   const _EmptyView({required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.leaderboard_outlined,
//                 size: 64, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(message,
//                 style: TextStyle(
//                     color: Colors.grey.shade500,
//                     fontSize: 14,
//                     fontFamily: 'Poppins')),
//           ],
//         ),
//       );
// }

// // ─── Error ────────────────────────────────────────────────────────────────────
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline,
//                 size: 48, color: Colors.red),
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
//       );
// }





// // lib/screens/performance/ranking_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/performance_controller.dart';
// import '../../models/performance_model.dart';
// import '../../core/theme/app_theme.dart';
// import 'widgets/month_year_picker.dart';

// class RankingScreen extends StatefulWidget {
//   const RankingScreen({super.key});

//   @override
//   State<RankingScreen> createState() => _RankingScreenState();
// }

// class _RankingScreenState extends State<RankingScreen> {
//   final _ctrl = Get.find<PerformanceController>();
//   final _auth = Get.find<AuthController>();

//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _ctrl.fetchRoles();
//   }

//   void _load() {
//     _ctrl.fetchRanking(
//       month: _ctrl.selectedMonth.value,
//       year:  _ctrl.selectedYear.value,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFEEF2F7),
//       appBar: AppBar(
//         title: const Text('Employee Rankings'),
//         centerTitle: true,
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

//           // ── Department Filter Chips ──────────────────────────────────────
//           Obx(() {
//             final roles = _ctrl.rolesList;
//             if (roles.isEmpty) return const SizedBox.shrink();

//             return Container(
//               color: Colors.white,
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//               child: SizedBox(
//                 height: 36,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _DeptChip(
//                       label: 'All',
//                       selected: _ctrl.selectedDept.value.isEmpty,
//                       onTap: () {
//                         _ctrl.updateDepartment('');
//                         _load();
//                       },
//                     ),
//                     ...roles.map((role) => _DeptChip(
//                           label: role,
//                           selected: _ctrl.selectedDept.value
//                                   .toLowerCase() ==
//                               role.toLowerCase(),
//                           onTap: () {
//                             _ctrl.updateDepartment(role);
//                             _ctrl.fetchRanking(
//                               month:      _ctrl.selectedMonth.value,
//                               year:       _ctrl.selectedYear.value,
//                               department: role,
//                             );
//                           },
//                         )),
//                   ],
//                 ),
//               ),
//             );
//           }),

//           // ── Rankings List ────────────────────────────────────────────────
//           Expanded(
//             child: Obx(() {
//               if (_ctrl.isLoadingRanking.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (_ctrl.errorRanking.value.isNotEmpty &&
//                   _ctrl.rankings.isEmpty) {
//                 return _ErrorView(
//                     message: _ctrl.errorRanking.value,
//                     onRetry: _load);
//               }

//               if (_ctrl.rankings.isEmpty) {
//                 return const _EmptyView(
//                     message: 'No rankings available.');
//               }

//               final top3     = _ctrl.rankings.take(3).toList();
//               final rest     = _ctrl.rankings.skip(3).toList();
//               final myUserId = _auth.currentUserId;

//               return RefreshIndicator(
//                 onRefresh: () async => _load(),
//                 child: ListView(
//                   padding:
//                       const EdgeInsets.fromLTRB(16, 16, 16, 24),
//                   children: [
//                     // ── Podium ─────────────────────────────────────────────
//                     if (top3.isNotEmpty)
//                       _PodiumSection(
//                         rankings:  top3,
//                         myUserId:  myUserId,
//                       ),

//                     if (rest.isNotEmpty) ...[
//                       const SizedBox(height: 16),
//                       ...rest.map((item) => Padding(
//                             padding:
//                                 const EdgeInsets.only(bottom: 8),
//                             child: _RankCard(
//                               item: item,
//                               isMe: item.userId == myUserId,
//                             ),
//                           )),
//                     ],
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Podium Section ───────────────────────────────────────────────────────────
// class _PodiumSection extends StatelessWidget {
//   final List<RankingModel> rankings;
//   final int myUserId;
//   const _PodiumSection(
//       {required this.rankings, required this.myUserId});

//   @override
//   Widget build(BuildContext context) {
//     final first  = rankings.isNotEmpty ? rankings[0] : null;
//     final second = rankings.length > 1  ? rankings[1] : null;
//     final third  = rankings.length > 2  ? rankings[2] : null;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFF8C00), Color(0xFFFF5722)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             '🏆  Top Performers',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Expanded(
//                 child: second != null
//                     ? _PodiumItem(
//                         item:       second,
//                         podHeight:  90,
//                         medal:      '🥈',
//                         medalColor: const Color(0xFFC0C0C0),
//                         isMe:       second.userId == myUserId,
//                       )
//                     : const SizedBox(),
//               ),
//               Expanded(
//                 child: first != null
//                     ? _PodiumItem(
//                         item:       first,
//                         podHeight:  120,
//                         medal:      '🥇',
//                         medalColor: const Color(0xFFFFD700),
//                         isMe:       first.userId == myUserId,
//                       )
//                     : const SizedBox(),
//               ),
//               Expanded(
//                 child: third != null
//                     ? _PodiumItem(
//                         item:       third,
//                         podHeight:  70,
//                         medal:      '🥉',
//                         medalColor: const Color(0xFFCD7F32),
//                         isMe:       third.userId == myUserId,
//                       )
//                     : const SizedBox(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Podium Item ──────────────────────────────────────────────────────────────
// class _PodiumItem extends StatelessWidget {
//   final RankingModel item;
//   final double podHeight;
//   final String medal;
//   final Color medalColor;
//   final bool isMe;

//   const _PodiumItem({
//     required this.item,
//     required this.podHeight,
//     required this.medal,
//     required this.medalColor,
//     required this.isMe,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Avatar
//         Container(
//           width: 52,
//           height: 52,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white,
//             border: Border.all(
//               color: isMe ? Colors.greenAccent : medalColor,
//               width: 2.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 8,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               item.userName.isNotEmpty
//                   ? item.userName[0].toUpperCase()
//                   : '?',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Poppins',
//                 color: medalColor,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(medal, style: const TextStyle(fontSize: 20)),
//         const SizedBox(height: 4),
//         Text(
//           item.userName.split(' ').first,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Poppins',
//             color: isMe ? Colors.greenAccent : Colors.white,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           item.finalScore.toStringAsFixed(1),
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Poppins',
//             color: Colors.white70,
//           ),
//         ),
//         const SizedBox(height: 6),
//         // Podium bar
//         Container(
//           width: double.infinity,
//           height: podHeight,
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: const BorderRadius.only(
//               topLeft:  Radius.circular(8),
//               topRight: Radius.circular(8),
//             ),
//           ),
//           child: Center(
//             child: Text(
//               '#${item.rank}',
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'Poppins',
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─── Rank Card (rank 4+) ──────────────────────────────────────────────────────
// class _RankCard extends StatelessWidget {
//   final RankingModel item;
//   final bool isMe;
//   const _RankCard({required this.item, required this.isMe});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isMe ? const Color(0xFFE8F5E9) : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isMe
//               ? Colors.green.shade300
//               : Colors.grey.shade200,
//           width: isMe ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//             horizontal: 14, vertical: 12),
//         child: Row(
//           children: [
//             // Rank number
//             SizedBox(
//               width: 36,
//               child: Text(
//                 '#${item.rank}',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//             ),
//             // Avatar
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isMe
//                     ? Colors.green.shade100
//                     : const Color(0xFFF3F4F6),
//               ),
//               child: Center(
//                 child: Text(
//                   item.userName.isNotEmpty
//                       ? item.userName[0].toUpperCase()
//                       : '?',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Poppins',
//                     color: isMe
//                         ? Colors.green.shade700
//                         : Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Name + info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           item.userName,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'Poppins',
//                             color: isMe
//                                 ? Colors.green.shade800
//                                 : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       if (isMe)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius:
//                                 BorderRadius.circular(20),
//                           ),
//                           child: const Text(
//                             'You',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 3),
//                   Row(
//                     children: [
//                       if (item.department != null &&
//                           item.department!.isNotEmpty) ...[
//                         Icon(Icons.business_outlined,
//                             size: 11,
//                             color: Colors.grey.shade400),
//                         const SizedBox(width: 3),
//                         Text(
//                           item.department!,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                       ],
//                       if (item.attendancePercentage != null) ...[
//                         Icon(Icons.access_time_outlined,
//                             size: 11,
//                             color: Colors.grey.shade400),
//                         const SizedBox(width: 3),
//                         Text(
//                           '${item.attendancePercentage!.toStringAsFixed(0)}% attendance',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Score + Grade
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   item.finalScore.toStringAsFixed(1),
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//                 if (item.grade != null)
//                   _GradeBadge(grade: item.grade!),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Grade Badge ──────────────────────────────────────────────────────────────
// class _GradeBadge extends StatelessWidget {
//   final String grade;
//   const _GradeBadge({required this.grade});

//   Color get _color {
//     switch (grade.toUpperCase()) {
//       case 'A+':
//       case 'A':  return Colors.green;
//       case 'B':  return Colors.blue;
//       case 'C':  return Colors.orange;
//       default:   return Colors.red;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//       decoration: BoxDecoration(
//         color: _color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         grade,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Poppins',
//           color: _color,
//         ),
//       ),
//     );
//   }
// }

// // ─── Dept Chip ────────────────────────────────────────────────────────────────
// class _DeptChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//   const _DeptChip(
//       {required this.label,
//       required this.selected,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(
//             horizontal: 16, vertical: 7),
//         decoration: BoxDecoration(
//           color: selected ? AppTheme.primary : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected
//                 ? AppTheme.primary
//                 : Colors.grey.shade300,
//           ),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: AppTheme.primary.withOpacity(0.3),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   )
//                 ]
//               : [],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Poppins',
//             color: selected
//                 ? Colors.white
//                 : Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Empty ────────────────────────────────────────────────────────────────────
// class _EmptyView extends StatelessWidget {
//   final String message;
//   const _EmptyView({required this.message});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.leaderboard_outlined,
//                 size: 64, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(message,
//                 style: TextStyle(
//                     color: Colors.grey.shade500,
//                     fontSize: 14,
//                     fontFamily: 'Poppins')),
//           ],
//         ),
//       );
// }

// // ─── Error ────────────────────────────────────────────────────────────────────
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline,
//                 size: 48, color: Colors.red),
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
//       );
// }












// lib/screens/performance/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/performance_controller.dart';
import '../../models/performance_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import 'widgets/month_year_picker.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _ctrl = Get.find<PerformanceController>();
  final _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    // ✅ Admin-only guard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_auth.isAdmin) {
        Get.back();
        AppUtils.showError('Access denied. Admin only.');
        return;
      }
      _load();
      _ctrl.fetchRoles();
    });
  }

  void _load() {
    _ctrl.fetchRanking(
      month: _ctrl.selectedMonth.value,
      year:  _ctrl.selectedYear.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Employee Rankings'),
        centerTitle: true,
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

          // ── Department Filter Chips ──────────────────────────────────────
          Obx(() {
            final roles = _ctrl.rolesList;
            if (roles.isEmpty) return const SizedBox.shrink();

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _DeptChip(
                      label: 'All',
                      selected: _ctrl.selectedDept.value.isEmpty,
                      onTap: () {
                        _ctrl.updateDepartment('');
                        _load();
                      },
                    ),
                    ...roles.map((role) => _DeptChip(
                          label: role,
                          selected: _ctrl.selectedDept.value
                                  .toLowerCase() ==
                              role.toLowerCase(),
                          onTap: () {
                            _ctrl.updateDepartment(role);
                            _ctrl.fetchRanking(
                              month:      _ctrl.selectedMonth.value,
                              year:       _ctrl.selectedYear.value,
                              department: role,
                            );
                          },
                        )),
                  ],
                ),
              ),
            );
          }),

          // ── Rankings List ────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingRanking.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_ctrl.errorRanking.value.isNotEmpty &&
                  _ctrl.rankings.isEmpty) {
                return _ErrorView(
                    message: _ctrl.errorRanking.value,
                    onRetry: _load);
              }

              if (_ctrl.rankings.isEmpty) {
                return const _EmptyView(
                    message: 'No rankings available.');
              }

              final top3     = _ctrl.rankings.take(3).toList();
              final rest     = _ctrl.rankings.skip(3).toList();
              final myUserId = _auth.currentUserId;

              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // ── Podium ─────────────────────────────────────────────
                    if (top3.isNotEmpty)
                      _PodiumSection(
                        rankings:  top3,
                        myUserId:  myUserId,
                      ),

                    if (rest.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...rest.map((item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8),
                            child: _RankCard(
                              item: item,
                              isMe: item.userId == myUserId,
                            ),
                          )),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Podium Section ───────────────────────────────────────────────────────────
class _PodiumSection extends StatelessWidget {
  final List<RankingModel> rankings;
  final int myUserId;
  const _PodiumSection(
      {required this.rankings, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    final first  = rankings.isNotEmpty ? rankings[0] : null;
    final second = rankings.length > 1  ? rankings[1] : null;
    final third  = rankings.length > 2  ? rankings[2] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '🏆  Top Performers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: second != null
                    ? _PodiumItem(
                        item:       second,
                        podHeight:  90,
                        medal:      '🥈',
                        medalColor: const Color(0xFFC0C0C0),
                        isMe:       second.userId == myUserId,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: first != null
                    ? _PodiumItem(
                        item:       first,
                        podHeight:  120,
                        medal:      '🥇',
                        medalColor: const Color(0xFFFFD700),
                        isMe:       first.userId == myUserId,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: third != null
                    ? _PodiumItem(
                        item:       third,
                        podHeight:  70,
                        medal:      '🥉',
                        medalColor: const Color(0xFFCD7F32),
                        isMe:       third.userId == myUserId,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Podium Item ──────────────────────────────────────────────────────────────
class _PodiumItem extends StatelessWidget {
  final RankingModel item;
  final double podHeight;
  final String medal;
  final Color medalColor;
  final bool isMe;

  const _PodiumItem({
    required this.item,
    required this.podHeight,
    required this.medal,
    required this.medalColor,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isMe ? Colors.greenAccent : medalColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              item.userName.isNotEmpty
                  ? item.userName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: medalColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(medal, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          item.userName.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: isMe ? Colors.greenAccent : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.finalScore.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        // Podium bar
        Container(
          width: double.infinity,
          height: podHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft:  Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '#${item.rank}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Rank Card (rank 4+) ──────────────────────────────────────────────────────
class _RankCard extends StatelessWidget {
  final RankingModel item;
  final bool isMe;
  const _RankCard({required this.item, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? Colors.green.shade300
              : Colors.grey.shade200,
          width: isMe ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 36,
              child: Text(
                '#${item.rank}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMe
                    ? Colors.green.shade100
                    : const Color(0xFFF3F4F6),
              ),
              child: Center(
                child: Text(
                  item.userName.isNotEmpty
                      ? item.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isMe
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.userName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: isMe
                                ? Colors.green.shade800
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isMe)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (item.department != null &&
                          item.department!.isNotEmpty) ...[
                        Icon(Icons.business_outlined,
                            size: 11,
                            color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          item.department!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (item.attendancePercentage != null) ...[
                        Icon(Icons.access_time_outlined,
                            size: 11,
                            color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          '${item.attendancePercentage!.toStringAsFixed(0)}% attendance',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Score + Grade
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.finalScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: Color(0xFF111827),
                  ),
                ),
                if (item.grade != null)
                  _GradeBadge(grade: item.grade!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grade Badge ──────────────────────────────────────────────────────────────
class _GradeBadge extends StatelessWidget {
  final String grade;
  const _GradeBadge({required this.grade});

  Color get _color {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':  return Colors.green;
      case 'B':  return Colors.blue;
      case 'C':  return Colors.orange;
      default:   return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: _color,
        ),
      ),
    );
  }
}

// ─── Dept Chip ────────────────────────────────────────────────────────────────
class _DeptChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DeptChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: selected
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard_outlined,
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

// ─── Error ────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.red),
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
      );
}