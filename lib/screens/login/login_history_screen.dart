// // // lib/screens/login_history/login_history_screen.dart

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:intl/intl.dart';

// // import '../../controllers/auth_controller.dart';
// // import '../../controllers/login_history_controller.dart';
// // import '../../core/theme/app_theme.dart';
// // import '../../models/login_history_model.dart';

// // class LoginHistoryScreen extends StatefulWidget {
// //   const LoginHistoryScreen({super.key});

// //   @override
// //   State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
// // }

// // class _LoginHistoryScreenState extends State<LoginHistoryScreen>
// //     with SingleTickerProviderStateMixin {
// //   late final LoginHistoryController _ctrl;
// //   late final TabController _tabs;
// //   final AuthController _auth = Get.find();

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (!Get.isRegistered<LoginHistoryController>()) {
// //       Get.put(LoginHistoryController());
// //     }
// //     _ctrl = Get.find<LoginHistoryController>();
// //     // Admin: 2 tabs (My History | User Lookup)
// //     // Non-admin: no tabs at all
// //     _tabs = TabController(
// //       length: _auth.isAdmin ? 2 : 1,
// //       vsync: this,
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _tabs.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _pickDateRange() async {
// //     final range = await showDateRangePicker(
// //       context: context,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       initialDateRange:
// //           _ctrl.fromDate.value != null && _ctrl.toDate.value != null
// //               ? DateTimeRange(
// //                   start: _ctrl.fromDate.value!, end: _ctrl.toDate.value!)
// //               : null,
// //       builder: (context, child) => Theme(
// //         data: Theme.of(context).copyWith(
// //           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (range != null) {
// //       _ctrl.applyDateFilter(range.start, range.end);
// //     }
// //   }

// //   AppBar _buildAppBar({required bool showTabBar}) {
// //     return AppBar(
// //       backgroundColor: AppTheme.primary,
// //       foregroundColor: Colors.white,
// //       elevation: 0,
// //       title: const Text(
// //         'Login History',
// //         style: TextStyle(
// //           fontFamily: 'Poppins',
// //           fontWeight: FontWeight.w700,
// //           fontSize: 18,
// //           color: Colors.white,
// //         ),
// //       ),
// //       systemOverlayStyle: SystemUiOverlayStyle.light,
// //       bottom: showTabBar
// //           ? TabBar(
// //               controller: _tabs,
// //               indicatorColor: Colors.white,
// //               indicatorWeight: 3,
// //               labelStyle: const TextStyle(
// //                   fontFamily: 'Poppins',
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 13),
// //               unselectedLabelStyle: const TextStyle(
// //                   fontFamily: 'Poppins',
// //                   fontWeight: FontWeight.w400,
// //                   fontSize: 13),
// //               labelColor: Colors.white,
// //               unselectedLabelColor: Colors.white60,
// //               tabs: const [
// //                 Tab(text: 'My History'),
// //                 Tab(text: 'User Lookup'),
// //               ],
// //             )
// //           : null,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Non-admin: no TabBar, just the combined screen
// //     if (!_auth.isAdmin) {
// //       return Scaffold(
// //         backgroundColor: AppTheme.background,
// //         appBar: _buildAppBar(showTabBar: false),
// //         body: _MyHistoryCombinedTab(ctrl: _ctrl, onPickDate: _pickDateRange),
// //       );
// //     }

// //     // Admin: 2 tabs
// //     return Scaffold(
// //       backgroundColor: AppTheme.background,
// //       appBar: _buildAppBar(showTabBar: true),
// //       body: TabBarView(
// //         controller: _tabs,
// //         children: [
// //           _MyHistoryCombinedTab(ctrl: _ctrl, onPickDate: _pickDateRange),
// //           _UserLookupTab(ctrl: _ctrl),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  COMBINED: Today's Sessions + Full History
// // // ─────────────────────────────────────────────
// // class _MyHistoryCombinedTab extends StatelessWidget {
// //   final LoginHistoryController ctrl;
// //   final VoidCallback onPickDate;
// //   const _MyHistoryCombinedTab(
// //       {required this.ctrl, required this.onPickDate});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         // ── Date-range filter bar (applies to Full History only) ───────────
// //         Obx(() {
// //           final from = ctrl.fromDate.value;
// //           final to   = ctrl.toDate.value;
// //           final fmt  = DateFormat('dd MMM');
// //           return Container(
// //             color: AppTheme.cardBackground,
// //             padding:
// //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //             child: Row(children: [
// //               Expanded(
// //                 child: GestureDetector(
// //                   onTap: onPickDate,
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 14, vertical: 10),
// //                     decoration: BoxDecoration(
// //                       color: AppTheme.background,
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: AppTheme.divider),
// //                     ),
// //                     child: Row(children: [
// //                       const Icon(Icons.date_range_rounded,
// //                           color: AppTheme.primary, size: 18),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         from != null && to != null
// //                             ? 'History: ${fmt.format(from)} – ${fmt.format(to)}'
// //                             : 'Filter history by date range',
// //                         style: TextStyle(
// //                           fontFamily: 'Poppins',
// //                           fontSize: 13,
// //                           color: from != null
// //                               ? AppTheme.textPrimary
// //                               : AppTheme.textSecondary,
// //                         ),
// //                       ),
// //                     ]),
// //                   ),
// //                 ),
// //               ),
// //               if (from != null) ...[
// //                 const SizedBox(width: 8),
// //                 GestureDetector(
// //                   onTap: ctrl.clearDateFilter,
// //                   child: Container(
// //                     padding: const EdgeInsets.all(9),
// //                     decoration: BoxDecoration(
// //                       color: AppTheme.errorLight,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: const Icon(Icons.close_rounded,
// //                         color: AppTheme.error, size: 17),
// //                   ),
// //                 ),
// //               ],
// //             ]),
// //           );
// //         }),

// //         // ── Scrollable body: both sections ────────────────────────────────
// //         Expanded(
// //           child: Obx(() {
// //             return RefreshIndicator(
// //               color: AppTheme.primary,
// //               onRefresh: () async {
// //                 await Future.wait([
// //                   ctrl.fetchTodayHistory(),
// //                   ctrl.fetchMyHistory(),
// //                 ]);
// //               },
// //               child: CustomScrollView(
// //                 physics: const AlwaysScrollableScrollPhysics(
// //                     parent: BouncingScrollPhysics()),
// //                 slivers: [

// //                   // ════════════════════════════════
// //                   //  TODAY'S SESSIONS
// //                   // ════════════════════════════════
// //                   SliverToBoxAdapter(
// //                     child: _SectionHeader(
// //                       icon: Icons.today_rounded,
// //                       title: "Today's Sessions",
// //                       color: AppTheme.success,
// //                       trailing: ctrl.isLoadingToday.value
// //                           ? const _InlineLoader()
// //                           : Text(
// //                               '${ctrl.todayHistory.length} session${ctrl.todayHistory.length == 1 ? '' : 's'}',
// //                               style: AppTheme.caption,
// //                             ),
// //                     ),
// //                   ),

// //                   if (ctrl.isLoadingToday.value)
// //                     const SliverToBoxAdapter(
// //                         child: Padding(
// //                             padding: EdgeInsets.symmetric(vertical: 24),
// //                             child: _Loader()))
// //                   else if (ctrl.errorToday.value.isNotEmpty)
// //                     SliverToBoxAdapter(
// //                       child: _InlineError(
// //                         message: ctrl.errorToday.value,
// //                         onRetry: ctrl.fetchTodayHistory,
// //                       ),
// //                     )
// //                   else if (ctrl.todayHistory.isEmpty)
// //                     const SliverToBoxAdapter(
// //                       child: _InlineEmpty(
// //                           icon: Icons.login_rounded,
// //                           message: 'No login activity today'),
// //                     )
// //                   else
// //                     SliverPadding(
// //                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
// //                       sliver: SliverList(
// //                         delegate: SliverChildBuilderDelegate(
// //                           (_, i) => Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: _HistoryCard(
// //                                 record: ctrl.todayHistory[i], ctrl: ctrl),
// //                           ),
// //                           childCount: ctrl.todayHistory.length,
// //                         ),
// //                       ),
// //                     ),

// //                   // ── Divider between sections ──────────────────────────
// //                   SliverToBoxAdapter(
// //                     child: Container(
// //                       margin: const EdgeInsets.symmetric(
// //                           horizontal: 16, vertical: 6),
// //                       height: 1,
// //                       color: AppTheme.divider,
// //                     ),
// //                   ),

// //                   // ════════════════════════════════
// //                   //  FULL HISTORY  (/LoginHistory/me)
// //                   // ════════════════════════════════
// //                   SliverToBoxAdapter(
// //                     child: _SectionHeader(
// //                       icon: Icons.history_rounded,
// //                       title: 'Full History',
// //                       color: AppTheme.primary,
// //                       trailing: ctrl.isLoadingMy.value
// //                           ? const _InlineLoader()
// //                           : Text(
// //                               '${ctrl.myHistory.length} record${ctrl.myHistory.length == 1 ? '' : 's'}',
// //                               style: AppTheme.caption,
// //                             ),
// //                     ),
// //                   ),

// //                   if (ctrl.isLoadingMy.value)
// //                     const SliverToBoxAdapter(
// //                         child: Padding(
// //                             padding: EdgeInsets.symmetric(vertical: 24),
// //                             child: _Loader()))
// //                   else if (ctrl.errorMy.value.isNotEmpty)
// //                     SliverToBoxAdapter(
// //                       child: _InlineError(
// //                         message: ctrl.errorMy.value,
// //                         onRetry: ctrl.fetchMyHistory,
// //                       ),
// //                     )
// //                   else if (ctrl.myHistory.isEmpty)
// //                     const SliverToBoxAdapter(
// //                       child: _InlineEmpty(
// //                           icon: Icons.history_rounded,
// //                           message: 'No history records found'),
// //                     )
// //                   else
// //                     SliverPadding(
// //                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
// //                       sliver: SliverList(
// //                         delegate: SliverChildBuilderDelegate(
// //                           (_, i) => Padding(
// //                             padding: const EdgeInsets.only(bottom: 10),
// //                             child: _HistoryCard(
// //                                 record: ctrl.myHistory[i], ctrl: ctrl),
// //                           ),
// //                           childCount: ctrl.myHistory.length,
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             );
// //           }),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  USER LOOKUP TAB (Admin only)
// // // ─────────────────────────────────────────────
// // class _UserLookupTab extends StatefulWidget {
// //   final LoginHistoryController ctrl;
// //   const _UserLookupTab({required this.ctrl});
// //   @override
// //   State<_UserLookupTab> createState() => _UserLookupTabState();
// // }

// // class _UserLookupTabState extends State<_UserLookupTab> {
// //   final _idController = TextEditingController();
// //   final _formKey      = GlobalKey<FormState>();
// //   DateTime? _from, _to;

// //   Future<void> _pickRange() async {
// //     final range = await showDateRangePicker(
// //       context: context,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       initialDateRange: _from != null && _to != null
// //           ? DateTimeRange(start: _from!, end: _to!)
// //           : null,
// //       builder: (context, child) => Theme(
// //         data: Theme.of(context).copyWith(
// //           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (range != null) setState(() { _from = range.start; _to = range.end; });
// //   }

// //   void _search() {
// //     if (!_formKey.currentState!.validate()) return;
// //     final id = int.parse(_idController.text.trim());
// //     widget.ctrl.fetchUserHistory(id, from: _from, to: _to);
// //   }

// //   @override
// //   void dispose() {
// //     _idController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final fmt = DateFormat('dd MMM');
// //     return Column(
// //       children: [
// //         Container(
// //           color: AppTheme.cardBackground,
// //           padding: const EdgeInsets.all(16),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(children: [
// //               TextFormField(
// //                 controller: _idController,
// //                 keyboardType: TextInputType.number,
// //                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                 decoration: InputDecoration(
// //                   labelText: 'User ID',
// //                   hintText: 'e.g. 42',
// //                   prefixIcon: const Icon(Icons.person_search_rounded,
// //                       color: AppTheme.primary),
// //                   border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12)),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide:
// //                         const BorderSide(color: AppTheme.primary, width: 2),
// //                   ),
// //                 ),
// //                 validator: (v) {
// //                   if (v == null || v.trim().isEmpty) return 'User ID required';
// //                   if (int.tryParse(v.trim()) == null) return 'Enter numeric ID';
// //                   return null;
// //                 },
// //               ),
// //               const SizedBox(height: 10),
// //               Row(children: [
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: _pickRange,
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 14, vertical: 12),
// //                       decoration: BoxDecoration(
// //                         border: Border.all(color: AppTheme.divider),
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Row(children: [
// //                         const Icon(Icons.date_range_rounded,
// //                             color: AppTheme.primary, size: 18),
// //                         const SizedBox(width: 8),
// //                         Text(
// //                           _from != null && _to != null
// //                               ? '${fmt.format(_from!)} – ${fmt.format(_to!)}'
// //                               : 'Date range (optional)',
// //                           style: TextStyle(
// //                             fontFamily: 'Poppins',
// //                             fontSize: 13,
// //                             color: _from != null
// //                                 ? AppTheme.textPrimary
// //                                 : AppTheme.textSecondary,
// //                           ),
// //                         ),
// //                       ]),
// //                     ),
// //                   ),
// //                 ),
// //                 if (_from != null) ...[
// //                   const SizedBox(width: 8),
// //                   GestureDetector(
// //                     onTap: () =>
// //                         setState(() { _from = null; _to = null; }),
// //                     child: Container(
// //                       padding: const EdgeInsets.all(9),
// //                       decoration: BoxDecoration(
// //                         color: AppTheme.errorLight,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       child: const Icon(Icons.close_rounded,
// //                           color: AppTheme.error, size: 16),
// //                     ),
// //                   ),
// //                 ],
// //               ]),
// //               const SizedBox(height: 12),
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton.icon(
// //                   icon: const Icon(Icons.search_rounded),
// //                   label: const Text('Search',
// //                       style: TextStyle(fontFamily: 'Poppins')),
// //                   onPressed: _search,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppTheme.primary,
// //                     padding: const EdgeInsets.symmetric(vertical: 13),
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12)),
// //                   ),
// //                 ),
// //               ),
// //             ]),
// //           ),
// //         ),
// //         Expanded(
// //           child: Obx(() {
// //             if (widget.ctrl.isLoadingUser.value) return const _Loader();
// //             if (widget.ctrl.errorUser.value.isNotEmpty) {
// //               return _InlineError(
// //                 message: widget.ctrl.errorUser.value,
// //                 onRetry: () {},
// //               );
// //             }
// //             if (widget.ctrl.userHistory.isEmpty) {
// //               return const _InlineEmpty(
// //                 icon: Icons.manage_search_rounded,
// //                 message: 'Enter a User ID and tap Search',
// //               );
// //             }
// //             return ListView.separated(
// //               padding: const EdgeInsets.all(16),
// //               itemCount: widget.ctrl.userHistory.length,
// //               separatorBuilder: (_, __) => const SizedBox(height: 10),
// //               itemBuilder: (_, i) => _HistoryCard(
// //                   record: widget.ctrl.userHistory[i], ctrl: widget.ctrl),
// //             );
// //           }),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  SECTION HEADER
// // // ─────────────────────────────────────────────
// // class _SectionHeader extends StatelessWidget {
// //   final IconData icon;
// //   final String title;
// //   final Color color;
// //   final Widget trailing;
// //   const _SectionHeader({
// //     required this.icon,
// //     required this.title,
// //     required this.color,
// //     required this.trailing,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
// //       child: Row(children: [
// //         Container(
// //           padding: const EdgeInsets.all(7),
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(icon, color: color, size: 16),
// //         ),
// //         const SizedBox(width: 10),
// //         Text(title,
// //             style: const TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.w700,
// //               fontFamily: 'Poppins',
// //               color: AppTheme.textPrimary,
// //             )),
// //         const Spacer(),
// //         trailing,
// //       ]),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  HISTORY CARD
// // // ─────────────────────────────────────────────
// // class _HistoryCard extends StatelessWidget {
// //   final LoginHistoryModel record;
// //   final LoginHistoryController ctrl;
// //   const _HistoryCard({required this.record, required this.ctrl});

// //   @override
// //   Widget build(BuildContext context) {
// //     final statusColor = ctrl.statusColor(record);
// //     final isActive    = record.isActive;

// //     return Container(
// //       decoration: AppTheme.cardDecoration(),
// //       padding: const EdgeInsets.all(16),
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Row(children: [
// //           Container(
// //             width: 44,
// //             height: 44,
// //             decoration: BoxDecoration(
// //               gradient: AppTheme.primaryGradientDecoration.gradient,
// //               borderRadius: BorderRadius.circular(14),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 record.userName.isNotEmpty
// //                     ? record.userName[0].toUpperCase()
// //                     : 'U',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w800,
// //                   fontSize: 18,
// //                   fontFamily: 'Poppins',
// //                 ),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //               Text(record.userName,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w700,
// //                     fontFamily: 'Poppins',
// //                     color: AppTheme.textPrimary,
// //                   )),
// //               if (record.userEmail != null && record.userEmail!.isNotEmpty)
// //                 Text(record.userEmail!,
// //                     style: AppTheme.caption,
// //                     overflow: TextOverflow.ellipsis),
// //             ]),
// //           ),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
// //             decoration: BoxDecoration(
// //               color: statusColor.withOpacity(0.12),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(mainAxisSize: MainAxisSize.min, children: [
// //               Container(
// //                   width: 7, height: 7,
// //                   decoration: BoxDecoration(
// //                       color: statusColor, shape: BoxShape.circle)),
// //               const SizedBox(width: 5),
// //               Text(isActive ? 'Active' : 'Ended',
// //                   style: TextStyle(
// //                     fontSize: 11, fontWeight: FontWeight.w700,
// //                     fontFamily: 'Poppins', color: statusColor,
// //                   )),
// //             ]),
// //           ),
// //         ]),

// //         const SizedBox(height: 12),
// //         const Divider(height: 1, color: AppTheme.divider),
// //         const SizedBox(height: 12),

// //         _DetailRow(
// //           icon: Icons.login_rounded,
// //           label: 'Login',
// //           value: ctrl.formatLoginTime(record.loginTime),
// //           iconColor: AppTheme.success,
// //         ),
// //         if (record.logoutTime != null && record.logoutTime!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.logout_rounded,
// //             label: 'Logout',
// //             value: ctrl.formatLoginTime(record.logoutTime!),
// //             iconColor: AppTheme.error,
// //           ),
// //         ],
// //         const SizedBox(height: 6),
// //         _DetailRow(
// //           icon: Icons.timer_outlined,
// //           label: 'Duration',
// //           value: record.sessionDuration,
// //           iconColor: AppTheme.info,
// //         ),
// //         if (record.role != null && record.role!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.badge_outlined,
// //             label: 'Role',
// //             value: record.role!,
// //             iconColor: AppTheme.accent,
// //           ),
// //         ],
// //         if (record.platform != null && record.platform!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.phone_android_rounded,
// //             label: 'Platform',
// //             value: record.platform!,
// //             iconColor: AppTheme.chipWFH,
// //           ),
// //         ],
// //         if (record.deviceId != null && record.deviceId!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.fingerprint_rounded,
// //             label: 'Device',
// //             value: record.deviceId!.length > 20
// //                 ? '${record.deviceId!.substring(0, 20)}…'
// //                 : record.deviceId!,
// //             iconColor: AppTheme.textSecondary,
// //           ),
// //         ],
// //       ]),
// //     );
// //   }
// // }

// // class _DetailRow extends StatelessWidget {
// //   final IconData icon;
// //   final Color iconColor;
// //   final String label, value;
// //   const _DetailRow({
// //     required this.icon, required this.iconColor,
// //     required this.label, required this.value,
// //   });
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(children: [
// //       Icon(icon, color: iconColor, size: 15),
// //       const SizedBox(width: 7),
// //       Text('$label: ',
// //           style: const TextStyle(
// //               fontSize: 12, fontFamily: 'Poppins',
// //               color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
// //       Expanded(
// //         child: Text(value,
// //             style: const TextStyle(
// //                 fontSize: 12, fontFamily: 'Poppins',
// //                 color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
// //             overflow: TextOverflow.ellipsis),
// //       ),
// //     ]);
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  UTILITY WIDGETS
// // // ─────────────────────────────────────────────
// // class _Loader extends StatelessWidget {
// //   const _Loader();
// //   @override
// //   Widget build(BuildContext context) =>
// //       const Center(child: CircularProgressIndicator(color: AppTheme.primary));
// // }

// // class _InlineLoader extends StatelessWidget {
// //   const _InlineLoader();
// //   @override
// //   Widget build(BuildContext context) => const SizedBox(
// //         width: 14, height: 14,
// //         child: CircularProgressIndicator(
// //             strokeWidth: 2, color: AppTheme.primary),
// //       );
// // }

// // class _InlineEmpty extends StatelessWidget {
// //   final IconData icon;
// //   final String message;
// //   const _InlineEmpty({required this.icon, required this.message});
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
// //         child: Row(children: [
// //           Icon(icon, size: 20, color: AppTheme.textHint),
// //           const SizedBox(width: 10),
// //           Text(message,
// //               style: const TextStyle(
// //                   fontFamily: 'Poppins', fontSize: 13,
// //                   color: AppTheme.textSecondary)),
// //         ]),
// //       );
// // }

// // class _InlineError extends StatelessWidget {
// //   final String message;
// //   final VoidCallback onRetry;
// //   const _InlineError({required this.message, required this.onRetry});
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //         child: Container(
// //           padding: const EdgeInsets.all(14),
// //           decoration: BoxDecoration(
// //             color: AppTheme.errorLight,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Row(children: [
// //             const Icon(Icons.error_outline_rounded,
// //                 color: AppTheme.error, size: 18),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(message,
// //                   style: const TextStyle(
// //                       fontFamily: 'Poppins', fontSize: 12,
// //                       color: AppTheme.error)),
// //             ),
// //             GestureDetector(
// //               onTap: onRetry,
// //               child: const Padding(
// //                 padding: EdgeInsets.only(left: 8),
// //                 child: Icon(Icons.refresh_rounded,
// //                     color: AppTheme.error, size: 18),
// //               ),
// //             ),
// //           ]),
// //         ),
// //       );
// // }







// // // lib/screens/login/login_history_screen.dart

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:intl/intl.dart';

// // import '../../controllers/auth_controller.dart';
// // import '../../controllers/login_history_controller.dart';
// // import '../../core/theme/app_theme.dart';
// // import '../../core/utils/app_utils.dart';
// // import '../../models/login_history_model.dart';
// // import '../../models/models.dart';
// // import '../../services/api_service.dart';

// // class LoginHistoryScreen extends StatefulWidget {
// //   const LoginHistoryScreen({super.key});

// //   @override
// //   State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
// // }

// // class _LoginHistoryScreenState extends State<LoginHistoryScreen>
// //     with SingleTickerProviderStateMixin {
// //   late final LoginHistoryController _ctrl;
// //   late final TabController _tabs;
// //   final AuthController _auth = Get.find();

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (!Get.isRegistered<LoginHistoryController>()) {
// //       Get.put(LoginHistoryController());
// //     }
// //     _ctrl = Get.find<LoginHistoryController>();
// //     _tabs = TabController(length: _auth.isAdmin ? 2 : 1, vsync: this);
// //   }

// //   @override
// //   void dispose() {
// //     _tabs.dispose();
// //     super.dispose();
// //   }

// //   AppBar _buildAppBar({required bool showTabBar}) {
// //     return AppBar(
// //       backgroundColor: AppTheme.primary,
// //       foregroundColor: Colors.white,
// //       elevation: 0,
// //       title: const Text('Login History',
// //           style: TextStyle(
// //               fontFamily: 'Poppins',
// //               fontWeight: FontWeight.w700,
// //               fontSize: 18,
// //               color: Colors.white)),
// //       systemOverlayStyle: SystemUiOverlayStyle.light,
// //       bottom: showTabBar
// //           ? TabBar(
// //               controller: _tabs,
// //               indicatorColor: Colors.white,
// //               indicatorWeight: 3,
// //               labelStyle: const TextStyle(
// //                   fontFamily: 'Poppins',
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 13),
// //               unselectedLabelStyle: const TextStyle(
// //                   fontFamily: 'Poppins',
// //                   fontWeight: FontWeight.w400,
// //                   fontSize: 13),
// //               labelColor: Colors.white,
// //               unselectedLabelColor: Colors.white60,
// //               tabs: const [
// //                 Tab(text: 'My History'),
// //                 Tab(text: 'User Lookup'),
// //               ],
// //             )
// //           : null,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (!_auth.isAdmin) {
// //       return Scaffold(
// //         backgroundColor: AppTheme.background,
// //         appBar: _buildAppBar(showTabBar: false),
// //         body: _MyHistoryTab(ctrl: _ctrl),
// //       );
// //     }

// //     return Scaffold(
// //       backgroundColor: AppTheme.background,
// //       appBar: _buildAppBar(showTabBar: true),
// //       body: TabBarView(
// //         controller: _tabs,
// //         children: [
// //           _MyHistoryTab(ctrl: _ctrl),
// //           _UserLookupTab(ctrl: _ctrl),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  MY HISTORY TAB — no date filter
// // // ─────────────────────────────────────────────
// // class _MyHistoryTab extends StatelessWidget {
// //   final LoginHistoryController ctrl;
// //   const _MyHistoryTab({required this.ctrl});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Obx(() {
// //       return RefreshIndicator(
// //         color: AppTheme.primary,
// //         onRefresh: () async {
// //           await Future.wait([
// //             ctrl.fetchTodayHistory(),
// //             ctrl.fetchMyHistory(),
// //           ]);
// //         },
// //         child: CustomScrollView(
// //           physics: const AlwaysScrollableScrollPhysics(
// //               parent: BouncingScrollPhysics()),
// //           slivers: [

// //             // ── Today's Sessions ───────────────────────────────────────
// //             SliverToBoxAdapter(
// //               child: _SectionHeader(
// //                 icon: Icons.today_rounded,
// //                 title: "Today's Sessions",
// //                 color: AppTheme.success,
// //                 trailing: ctrl.isLoadingToday.value
// //                     ? const _InlineLoader()
// //                     : Text(
// //                         '${ctrl.todayHistory.length} session${ctrl.todayHistory.length == 1 ? '' : 's'}',
// //                         style: AppTheme.caption),
// //               ),
// //             ),

// //             if (ctrl.isLoadingToday.value)
// //               const SliverToBoxAdapter(
// //                   child: Padding(
// //                       padding: EdgeInsets.symmetric(vertical: 24),
// //                       child: _Loader()))
// //             else if (ctrl.errorToday.value.isNotEmpty)
// //               SliverToBoxAdapter(
// //                 child: _InlineError(
// //                     message: ctrl.errorToday.value,
// //                     onRetry: ctrl.fetchTodayHistory),
// //               )
// //             else if (ctrl.todayHistory.isEmpty)
// //               const SliverToBoxAdapter(
// //                 child: _InlineEmpty(
// //                     icon: Icons.login_rounded,
// //                     message: 'No login activity today'),
// //               )
// //             else
// //               SliverPadding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
// //                 sliver: SliverList(
// //                   delegate: SliverChildBuilderDelegate(
// //                     (_, i) => Padding(
// //                       padding: const EdgeInsets.only(bottom: 10),
// //                       child: _HistoryCard(
// //                           record: ctrl.todayHistory[i], ctrl: ctrl),
// //                     ),
// //                     childCount: ctrl.todayHistory.length,
// //                   ),
// //                 ),
// //               ),

// //             SliverToBoxAdapter(
// //               child: Container(
// //                 margin:
// //                     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //                 height: 1,
// //                 color: AppTheme.divider,
// //               ),
// //             ),

// //             // ── Full History ────────────────────────────────────────────
// //             SliverToBoxAdapter(
// //               child: _SectionHeader(
// //                 icon: Icons.history_rounded,
// //                 title: 'Full History',
// //                 color: AppTheme.primary,
// //                 trailing: ctrl.isLoadingMy.value
// //                     ? const _InlineLoader()
// //                     : Text(
// //                         '${ctrl.myHistory.length} record${ctrl.myHistory.length == 1 ? '' : 's'}',
// //                         style: AppTheme.caption),
// //               ),
// //             ),

// //             if (ctrl.isLoadingMy.value)
// //               const SliverToBoxAdapter(
// //                   child: Padding(
// //                       padding: EdgeInsets.symmetric(vertical: 24),
// //                       child: _Loader()))
// //             else if (ctrl.errorMy.value.isNotEmpty)
// //               SliverToBoxAdapter(
// //                 child: _InlineError(
// //                     message: ctrl.errorMy.value,
// //                     onRetry: ctrl.fetchMyHistory),
// //               )
// //             else if (ctrl.myHistory.isEmpty)
// //               const SliverToBoxAdapter(
// //                 child: _InlineEmpty(
// //                     icon: Icons.history_rounded,
// //                     message: 'No history records found'),
// //               )
// //             else
// //               SliverPadding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
// //                 sliver: SliverList(
// //                   delegate: SliverChildBuilderDelegate(
// //                     (_, i) => Padding(
// //                       padding: const EdgeInsets.only(bottom: 10),
// //                       child: _HistoryCard(
// //                           record: ctrl.myHistory[i], ctrl: ctrl),
// //                     ),
// //                     childCount: ctrl.myHistory.length,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       );
// //     });
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  USER LOOKUP TAB — orange date fields + dropdown
// // // ─────────────────────────────────────────────
// // class _UserLookupTab extends StatefulWidget {
// //   final LoginHistoryController ctrl;
// //   const _UserLookupTab({required this.ctrl});
// //   @override
// //   State<_UserLookupTab> createState() => _UserLookupTabState();
// // }

// // class _UserLookupTabState extends State<_UserLookupTab> {
// //   List<UserModel> _users        = [];
// //   bool            _loadingUsers = true;
// //   UserModel?      _selectedUser;

// //   // ── Rx dates — same as AttendanceController style ─────────────────
// //   final Rx<DateTime> _fromDate = DateTime.now().obs;
// //   final Rx<DateTime> _toDate   = DateTime.now().obs;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUsers();
// //   }

// //   Future<void> _loadUsers() async {
// //     setState(() => _loadingUsers = true);
// //     try {
// //       final list = await ApiService.getAllUsers();
// //       setState(() {
// //         _users        = list;
// //         _loadingUsers = false;
// //       });
// //     } catch (_) {
// //       setState(() => _loadingUsers = false);
// //     }
// //   }

// //   Future<void> _pickFromDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _fromDate.value,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) => Theme(
// //         data: Theme.of(context).copyWith(
// //           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (picked != null) _fromDate.value = picked;
// //   }

// //   Future<void> _pickToDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _toDate.value,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) => Theme(
// //         data: Theme.of(context).copyWith(
// //           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (picked != null) _toDate.value = picked;
// //   }

// //   void _search() {
// //     if (_selectedUser == null) {
// //       Get.snackbar('Select User', 'Please select a user first',
// //           backgroundColor: AppTheme.errorLight,
// //           colorText: AppTheme.error,
// //           snackPosition: SnackPosition.BOTTOM);
// //       return;
// //     }
// //     widget.ctrl.fetchUserHistory(
// //       _selectedUser!.userId,
// //       from: _fromDate.value,
// //       to:   _toDate.value,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(children: [

// //       // ── Date + Search bar — same orange style as UserSummaryScreen ──
// //       Container(
// //         color: AppTheme.primary,
// //         padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //         child: Row(children: [
// //           Expanded(
// //             child: _DateField(
// //               label: 'From',
// //               obs: _fromDate,
// //               onTap: _pickFromDate,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: _DateField(
// //               label: 'To',
// //               obs: _toDate,
// //               onTap: _pickToDate,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Obx(() => ElevatedButton(
// //                 onPressed:
// //                     widget.ctrl.isLoadingUser.value ? null : _search,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.white,
// //                   foregroundColor: AppTheme.primary,
// //                   minimumSize: const Size(0, 44),
// //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 ),
// //                 child: widget.ctrl.isLoadingUser.value
// //                     ? const SizedBox(
// //                         height: 16,
// //                         width: 16,
// //                         child: CircularProgressIndicator(
// //                             strokeWidth: 2, color: AppTheme.primary))
// //                     : const Icon(Icons.search),
// //               )),
// //         ]),
// //       ),

// //       // ── User dropdown ─────────────────────────────────────────────
// //       Container(
// //         color: AppTheme.cardBackground,
// //         padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //         child: _loadingUsers
// //             ? Container(
// //                 height: 52,
// //                 decoration: BoxDecoration(
// //                   border: Border.all(color: AppTheme.divider),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: const Center(
// //                   child: SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                         strokeWidth: 2, color: AppTheme.primary),
// //                   ),
// //                 ),
// //               )
// //             : DropdownButtonFormField<UserModel>(
// //                 value: _selectedUser,
// //                 isExpanded: true,
// //                 decoration: InputDecoration(
// //                   labelText: 'Select User',
// //                   prefixIcon: const Icon(Icons.person_search_rounded,
// //                       color: AppTheme.primary),
// //                   border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12)),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: const BorderSide(
// //                         color: AppTheme.primary, width: 2),
// //                   ),
// //                   contentPadding: const EdgeInsets.symmetric(
// //                       horizontal: 12, vertical: 14),
// //                 ),
// //                 hint: const Text('Choose a user',
// //                     style: TextStyle(
// //                         fontFamily: 'Poppins',
// //                         color: AppTheme.textSecondary)),
// //                 items: _users.map((u) {
// //                   return DropdownMenuItem<UserModel>(
// //                     value: u,
// //                     child: Text(u.userName,
// //                         style: const TextStyle(
// //                             fontFamily: 'Poppins',
// //                             fontSize: 14,
// //                             color: AppTheme.textPrimary),
// //                         overflow: TextOverflow.ellipsis),
// //                   );
// //                 }).toList(),
// //                 onChanged: (val) => setState(() => _selectedUser = val),
// //               ),
// //       ),

// //       // ── Results ───────────────────────────────────────────────────
// //       Expanded(
// //         child: Obx(() {
// //           if (widget.ctrl.isLoadingUser.value) return const _Loader();
// //           if (widget.ctrl.errorUser.value.isNotEmpty) {
// //             return _InlineError(
// //                 message: widget.ctrl.errorUser.value, onRetry: () {});
// //           }
// //           if (widget.ctrl.userHistory.isEmpty) {
// //             return const _InlineEmpty(
// //               icon: Icons.manage_search_rounded,
// //               message: 'Select user, pick dates, then tap 🔍',
// //             );
// //           }
// //           return ListView.separated(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: widget.ctrl.userHistory.length,
// //             separatorBuilder: (_, __) => const SizedBox(height: 10),
// //             itemBuilder: (_, i) => _HistoryCard(
// //                 record: widget.ctrl.userHistory[i],
// //                 ctrl:   widget.ctrl),
// //           );
// //         }),
// //       ),
// //     ]);
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  DATE FIELD — same style as UserSummaryScreen
// // // ─────────────────────────────────────────────
// // class _DateField extends StatelessWidget {
// //   final String label;
// //   final Rx<DateTime> obs;
// //   final VoidCallback onTap;

// //   const _DateField({
// //     required this.label,
// //     required this.obs,
// //     required this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.15),
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.white.withOpacity(0.3)),
// //       ),
// //       child: Row(children: [
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(label,
// //                   style: TextStyle(
// //                       color: Colors.white.withOpacity(0.8),
// //                       fontSize: 10,
// //                       fontFamily: 'Poppins')),
// //               const SizedBox(height: 2),
// //               Obx(() => Text(
// //                     AppUtils.formatDate(obs.value),
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                       fontFamily: 'Poppins',
// //                     ),
// //                   )),
// //             ],
// //           ),
// //         ),
// //         GestureDetector(
// //           onTap: onTap,
// //           child: Icon(Icons.calendar_month_outlined,
// //               size: 18, color: Colors.white.withOpacity(0.85)),
// //         ),
// //       ]),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  SECTION HEADER
// // // ─────────────────────────────────────────────
// // class _SectionHeader extends StatelessWidget {
// //   final IconData icon;
// //   final String title;
// //   final Color color;
// //   final Widget trailing;
// //   const _SectionHeader({
// //     required this.icon,
// //     required this.title,
// //     required this.color,
// //     required this.trailing,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
// //       child: Row(children: [
// //         Container(
// //           padding: const EdgeInsets.all(7),
// //           decoration: BoxDecoration(
// //               color: color.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(10)),
// //           child: Icon(icon, color: color, size: 16),
// //         ),
// //         const SizedBox(width: 10),
// //         Text(title,
// //             style: const TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w700,
// //                 fontFamily: 'Poppins',
// //                 color: AppTheme.textPrimary)),
// //         const Spacer(),
// //         trailing,
// //       ]),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  HISTORY CARD
// // // ─────────────────────────────────────────────
// // class _HistoryCard extends StatelessWidget {
// //   final LoginHistoryModel record;
// //   final LoginHistoryController ctrl;
// //   const _HistoryCard({required this.record, required this.ctrl});

// //   @override
// //   Widget build(BuildContext context) {
// //     final statusColor = ctrl.statusColor(record);
// //     final isActive    = record.isActive;

// //     return Container(
// //       decoration: AppTheme.cardDecoration(),
// //       padding: const EdgeInsets.all(16),
// //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// //         Row(children: [
// //           Container(
// //             width: 44, height: 44,
// //             decoration: BoxDecoration(
// //               gradient: AppTheme.primaryGradientDecoration.gradient,
// //               borderRadius: BorderRadius.circular(14),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 record.userName.isNotEmpty
// //                     ? record.userName[0].toUpperCase()
// //                     : 'U',
// //                 style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w800,
// //                     fontSize: 18,
// //                     fontFamily: 'Poppins'),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //               Text(record.userName,
// //                   style: const TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.w700,
// //                       fontFamily: 'Poppins',
// //                       color: AppTheme.textPrimary)),
// //               if (record.userEmail != null && record.userEmail!.isNotEmpty)
// //                 Text(record.userEmail!,
// //                     style: AppTheme.caption,
// //                     overflow: TextOverflow.ellipsis),
// //             ]),
// //           ),
// //           Container(
// //             padding:
// //                 const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
// //             decoration: BoxDecoration(
// //                 color: statusColor.withOpacity(0.12),
// //                 borderRadius: BorderRadius.circular(8)),
// //             child: Row(mainAxisSize: MainAxisSize.min, children: [
// //               Container(
// //                   width: 7, height: 7,
// //                   decoration: BoxDecoration(
// //                       color: statusColor, shape: BoxShape.circle)),
// //               const SizedBox(width: 5),
// //               Text(isActive ? 'Active' : 'Ended',
// //                   style: TextStyle(
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.w700,
// //                       fontFamily: 'Poppins',
// //                       color: statusColor)),
// //             ]),
// //           ),
// //         ]),

// //         const SizedBox(height: 12),
// //         const Divider(height: 1, color: AppTheme.divider),
// //         const SizedBox(height: 12),

// //         _DetailRow(
// //           icon: Icons.login_rounded,
// //           label: 'Login',
// //           value: ctrl.formatLoginTime(record.loginTime),
// //           iconColor: AppTheme.success,
// //         ),
// //         const SizedBox(height: 6),
// //         _DetailRow(
// //           icon: Icons.logout_rounded,
// //           label: 'Logout',
// //           value: (record.logoutTime != null &&
// //                   record.logoutTime!.isNotEmpty)
// //               ? ctrl.formatLoginTime(record.logoutTime!)
// //               : isActive
// //                   ? 'Session Active'
// //                   : 'Not recorded',
// //           iconColor: (record.logoutTime != null &&
// //                   record.logoutTime!.isNotEmpty)
// //               ? AppTheme.error
// //               : isActive
// //                   ? AppTheme.success
// //                   : AppTheme.textSecondary,
// //         ),
// //         const SizedBox(height: 6),
// //         _DetailRow(
// //           icon: Icons.timer_outlined,
// //           label: 'Duration',
// //           value: record.sessionDuration,
// //           iconColor: AppTheme.info,
// //         ),
// //         if (record.role != null && record.role!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.badge_outlined,
// //             label: 'Role',
// //             value: record.role!,
// //             iconColor: AppTheme.accent,
// //           ),
// //         ],
// //         if (record.platform != null && record.platform!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.phone_android_rounded,
// //             label: 'Platform',
// //             value: record.platform!,
// //             iconColor: AppTheme.chipWFH,
// //           ),
// //         ],
// //         if (record.deviceId != null && record.deviceId!.isNotEmpty) ...[
// //           const SizedBox(height: 6),
// //           _DetailRow(
// //             icon: Icons.fingerprint_rounded,
// //             label: 'Device',
// //             value: record.deviceId!.length > 20
// //                 ? '${record.deviceId!.substring(0, 20)}…'
// //                 : record.deviceId!,
// //             iconColor: AppTheme.textSecondary,
// //           ),
// //         ],
// //       ]),
// //     );
// //   }
// // }

// // class _DetailRow extends StatelessWidget {
// //   final IconData icon;
// //   final Color iconColor;
// //   final String label, value;
// //   const _DetailRow({
// //     required this.icon,
// //     required this.iconColor,
// //     required this.label,
// //     required this.value,
// //   });
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(children: [
// //       Icon(icon, color: iconColor, size: 15),
// //       const SizedBox(width: 7),
// //       Text('$label: ',
// //           style: const TextStyle(
// //               fontSize: 12,
// //               fontFamily: 'Poppins',
// //               color: AppTheme.textSecondary,
// //               fontWeight: FontWeight.w500)),
// //       Expanded(
// //         child: Text(value,
// //             style: const TextStyle(
// //                 fontSize: 12,
// //                 fontFamily: 'Poppins',
// //                 color: AppTheme.textPrimary,
// //                 fontWeight: FontWeight.w600),
// //             overflow: TextOverflow.ellipsis),
// //       ),
// //     ]);
// //   }
// // }

// // // ─────────────────────────────────────────────
// // //  UTILITY WIDGETS
// // // ─────────────────────────────────────────────
// // class _Loader extends StatelessWidget {
// //   const _Loader();
// //   @override
// //   Widget build(BuildContext context) =>
// //       const Center(child: CircularProgressIndicator(color: AppTheme.primary));
// // }

// // class _InlineLoader extends StatelessWidget {
// //   const _InlineLoader();
// //   @override
// //   Widget build(BuildContext context) => const SizedBox(
// //         width: 14, height: 14,
// //         child: CircularProgressIndicator(
// //             strokeWidth: 2, color: AppTheme.primary),
// //       );
// // }

// // class _InlineEmpty extends StatelessWidget {
// //   final IconData icon;
// //   final String message;
// //   const _InlineEmpty({required this.icon, required this.message});
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
// //         child: Row(children: [
// //           Icon(icon, size: 20, color: AppTheme.textHint),
// //           const SizedBox(width: 10),
// //           Text(message,
// //               style: const TextStyle(
// //                   fontFamily: 'Poppins',
// //                   fontSize: 13,
// //                   color: AppTheme.textSecondary)),
// //         ]),
// //       );
// // }

// // class _InlineError extends StatelessWidget {
// //   final String message;
// //   final VoidCallback onRetry;
// //   const _InlineError({required this.message, required this.onRetry});
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //         child: Container(
// //           padding: const EdgeInsets.all(14),
// //           decoration: BoxDecoration(
// //               color: AppTheme.errorLight,
// //               borderRadius: BorderRadius.circular(12)),
// //           child: Row(children: [
// //             const Icon(Icons.error_outline_rounded,
// //                 color: AppTheme.error, size: 18),
// //             const SizedBox(width: 10),
// //             Expanded(
// //               child: Text(message,
// //                   style: const TextStyle(
// //                       fontFamily: 'Poppins',
// //                       fontSize: 12,
// //                       color: AppTheme.error)),
// //             ),
// //             GestureDetector(
// //               onTap: onRetry,
// //               child: const Padding(
// //                 padding: EdgeInsets.only(left: 8),
// //                 child: Icon(Icons.refresh_rounded,
// //                     color: AppTheme.error, size: 18),
// //               ),
// //             ),
// //           ]),
// //         ),
// //       );
// // }









// // lib/screens/login/login_history_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import '../../controllers/auth_controller.dart';
// import '../../controllers/login_history_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';
// import '../../models/login_history_model.dart';
// import '../../models/models.dart';
// import '../../services/api_service.dart';

// class LoginHistoryScreen extends StatefulWidget {
//   const LoginHistoryScreen({super.key});

//   @override
//   State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
// }

// class _LoginHistoryScreenState extends State<LoginHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late final LoginHistoryController _ctrl;
//   late final TabController _tabs;
//   final AuthController _auth = Get.find();

//   @override
//   void initState() {
//     super.initState();
//     if (!Get.isRegistered<LoginHistoryController>()) {
//       Get.put(LoginHistoryController());
//     }
//     _ctrl = Get.find<LoginHistoryController>();
//     _tabs = TabController(length: _auth.isAdmin ? 2 : 1, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabs.dispose();
//     super.dispose();
//   }

//   AppBar _buildAppBar({required bool showTabBar}) {
//     return AppBar(
//       backgroundColor: AppTheme.primary,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       title: const Text(
//         'Login History',
//         style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//             color: Colors.white),
//       ),
//       systemOverlayStyle: SystemUiOverlayStyle.light,
//       bottom: showTabBar
//           ? TabBar(
//               controller: _tabs,
//               indicatorColor: Colors.white,
//               indicatorWeight: 3,
//               labelStyle: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13),
//               unselectedLabelStyle: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w400,
//                   fontSize: 13),
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.white60,
//               tabs: const [
//                 Tab(text: 'My History'),
//                 Tab(text: 'User Lookup'),
//               ],
//             )
//           : null,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_auth.isAdmin) {
//       return Scaffold(
//         backgroundColor: AppTheme.background,
//         appBar: _buildAppBar(showTabBar: false),
//         body: _MyHistoryTab(ctrl: _ctrl),
//       );
//     }
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: _buildAppBar(showTabBar: true),
//       body: TabBarView(
//         controller: _tabs,
//         children: [
//           _MyHistoryTab(ctrl: _ctrl),
//           _UserLookupTab(ctrl: _ctrl),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  MY HISTORY TAB
// // ─────────────────────────────────────────────
// class _MyHistoryTab extends StatelessWidget {
//   final LoginHistoryController ctrl;
//   const _MyHistoryTab({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return RefreshIndicator(
//         color: AppTheme.primary,
//         onRefresh: () async => ctrl.fetchTodayHistory(),
//         child: CustomScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics()),
//           slivers: [
//             SliverToBoxAdapter(
//               child: _SectionHeader(
//                 icon: Icons.today_rounded,
//                 title: "Today's Sessions",
//                 color: AppTheme.success,
//                 trailing: ctrl.isLoadingToday.value
//                     ? const _InlineLoader()
//                     : Text(
//                         '${ctrl.todayHistory.length} session${ctrl.todayHistory.length == 1 ? '' : 's'}',
//                         style: AppTheme.caption),
//               ),
//             ),

//             if (ctrl.isLoadingToday.value)
//               const SliverToBoxAdapter(
//                   child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 40),
//                       child: _Loader()))
//             else if (ctrl.errorToday.value.isNotEmpty)
//               SliverToBoxAdapter(
//                 child: _InlineError(
//                     message: ctrl.errorToday.value,
//                     onRetry: ctrl.fetchTodayHistory),
//               )
//             else if (ctrl.todayHistory.isEmpty)
//               const SliverToBoxAdapter(
//                 child: _InlineEmpty(
//                     icon: Icons.login_rounded,
//                     message: 'No login activity today'),
//               )
//             else
//               SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (_, i) => Padding(
//                       padding: const EdgeInsets.only(bottom: 10),
//                       child: _HistoryCard(
//                           record: ctrl.todayHistory[i], ctrl: ctrl),
//                     ),
//                     childCount: ctrl.todayHistory.length,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }
// }

// // ─────────────────────────────────────────────
// //  USER LOOKUP TAB
// //  ✅ Fix 2: User Dropdown bhi orange background mein
// //  ✅ Summary card added
// // ─────────────────────────────────────────────
// class _UserLookupTab extends StatefulWidget {
//   final LoginHistoryController ctrl;
//   const _UserLookupTab({required this.ctrl});

//   @override
//   State<_UserLookupTab> createState() => _UserLookupTabState();
// }

// class _UserLookupTabState extends State<_UserLookupTab>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<UserModel> _users = [];
//   bool _loadingUsers = true;
//   UserModel? _selectedUser;

//   final Rx<DateTime> _fromDate = DateTime.now().obs;
//   final Rx<DateTime> _toDate = DateTime.now().obs;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   Future<void> _loadUsers() async {
//     setState(() => _loadingUsers = true);
//     try {
//       final list = await ApiService.getAllUsers();
//       setState(() {
//         _users = list;
//         _loadingUsers = false;
//       });
//     } catch (_) {
//       setState(() => _loadingUsers = false);
//     }
//   }

//   Future<void> _pickFromDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _fromDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) _fromDate.value = picked;
//   }

//   Future<void> _pickToDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _toDate.value,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(primary: AppTheme.primary),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) _toDate.value = picked;
//   }

//   void _search() {
//     if (_selectedUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Row(children: [
//             Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
//             SizedBox(width: 10),
//             Text('Please select a user first',
//                 style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
//           ]),
//           backgroundColor: Colors.black87,
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//     widget.ctrl.fetchUserHistory(
//       _selectedUser!.userId,
//       from: _fromDate.value,
//       to: _toDate.value,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Column(children: [
//       // ✅ Fix 2: Pura filter section ek hi orange container mein
//       //    User Dropdown + Date Range + Search — sab orange background
//       Container(
//         color: AppTheme.primary,
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//         child: Column(children: [
//           // ── User Dropdown (orange style) ──────────────────────────
//           _loadingUsers
//               ? Container(
//                   height: 52,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                         color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: const Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white),
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           'Loading users...',
//                           style: TextStyle(
//                               color: Colors.white70,
//                               fontFamily: 'Poppins',
//                               fontSize: 13),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                         color: Colors.white.withOpacity(0.3)),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<UserModel>(
//                       value: _selectedUser,
//                       isExpanded: true,
//                       dropdownColor: AppTheme.primaryDark,
//                       iconEnabledColor: Colors.white,
//                       hint: const Row(children: [
//                         Icon(Icons.person_search_rounded,
//                             color: Colors.white70, size: 18),
//                         SizedBox(width: 8),
//                         Text(
//                           'Select User',
//                           style: TextStyle(
//                               color: Colors.white70,
//                               fontFamily: 'Poppins',
//                               fontSize: 13),
//                         ),
//                       ]),
//                       items: _users.map((u) {
//                         return DropdownMenuItem<UserModel>(
//                           value: u,
//                           child: Text(
//                             u.userName,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'Poppins',
//                                 fontSize: 14),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (val) =>
//                           setState(() => _selectedUser = val),
//                       selectedItemBuilder: (_) => _users.map((u) {
//                         return Row(children: [
//                           const Icon(Icons.person_rounded,
//                               color: Colors.white70, size: 18),
//                           const SizedBox(width: 8),
//                           Text(
//                             u.userName,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'Poppins',
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                         ]);
//                       }).toList(),
//                     ),
//                   ),
//                 ),

//           const SizedBox(height: 10),

//           // ── Date Range + Search ──────────────────────────────────
//           Row(children: [
//             Expanded(
//               child: _DateField(
//                 label: 'From',
//                 obs: _fromDate,
//                 onTap: _pickFromDate,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _DateField(
//                 label: 'To',
//                 obs: _toDate,
//                 onTap: _pickToDate,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Obx(() => ElevatedButton(
//                   onPressed:
//                       widget.ctrl.isLoadingUser.value ? null : _search,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: AppTheme.primary,
//                     minimumSize: const Size(0, 44),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                   child: widget.ctrl.isLoadingUser.value
//                       ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppTheme.primary))
//                       : const Icon(Icons.search),
//                 )),
//           ]),
//         ]),
//       ),

//       // ✅ Fix 2: Summary Card — search ke baad dikhao
//       Obx(() {
//         final records = widget.ctrl.userHistory;
//         if (records.isEmpty) return const SizedBox();
//         final activeCount = records.where((r) => r.isActive).length;
//         final endedCount = records.length - activeCount;
//         final totalMins = records.fold<int>(
//             0, (s, r) => s + _HistoryHelper.calcDurationMins(r));
//         final h = totalMins ~/ 60;
//         final m = totalMins % 60;

//         return Container(
//           margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//           padding: const EdgeInsets.all(12),
//           decoration: AppTheme.cardDecoration(),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _StatItem(
//                   label: 'Total',
//                   value: '${records.length}',
//                   color: AppTheme.primary),
//               _StatItem(
//                   label: 'Active',
//                   value: '$activeCount',
//                   color: AppTheme.success),
//               _StatItem(
//                   label: 'Ended',
//                   value: '$endedCount',
//                   color: AppTheme.error),
//               _StatItem(
//                   label: 'Hours',
//                   value: '${h}h ${m}m',
//                   color: AppTheme.accent),
//             ],
//           ),
//         );
//       }),

//       // ── Results List ──────────────────────────────────────────────
//       Expanded(
//         child: Obx(() {
//           if (widget.ctrl.isLoadingUser.value) return const _Loader();
//           if (widget.ctrl.errorUser.value.isNotEmpty) {
//             return _InlineError(
//                 message: widget.ctrl.errorUser.value,
//                 onRetry: () {});
//           }
//           if (widget.ctrl.userHistory.isEmpty) {
//             return const _InlineEmpty(
//               icon: Icons.manage_search_rounded,
//               message: 'Select user, pick dates, then tap 🔍',
//             );
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
//             itemCount: widget.ctrl.userHistory.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 10),
//             itemBuilder: (_, i) => _HistoryCard(
//                 record: widget.ctrl.userHistory[i],
//                 ctrl: widget.ctrl),
//           );
//         }),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  HELPER — Duration Calculation
// // ─────────────────────────────────────────────
// class _HistoryHelper {
//   /// API se aane wale datetime string ko safely parse karo
//   /// Handles: "2026-03-01T14:30:00", "2026-03-01 14:30:00",
//   ///          "2026-03-01 14:30:00.000", "2026-03-01T14:30:00.000Z"
//   // Handles: "HH:mm:ss", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-ddTHH:mm:ss"
//   static DateTime? _parse(String? raw) {
//     if (raw == null || raw.trim().isEmpty) return null;
//     final s = raw.trim();
//     try {
//       // Case 1: Sirf time "14:20:00" — no date (no dash in string)
//       if (!s.contains('-') && s.contains(':')) {
//         final now   = DateTime.now();
//         final parts = s.split(':');
//         final h     = int.tryParse(parts[0]) ?? 0;
//         final m     = int.tryParse(parts[1]) ?? 0;
//         final sec   = parts.length > 2
//             ? int.tryParse(parts[2].split('.')[0]) ?? 0
//             : 0;
//         return DateTime(now.year, now.month, now.day, h, m, sec);
//       }
//       // Case 2 & 3: Full datetime — space ko T se replace karo
//       return DateTime.parse(s.replaceFirst(' ', 'T'));
//     } catch (_) {
//       return null;
//     }
//   }

//   /// Public wrapper — Fix 2 me use ho raha hai expired session ke liye
//   static DateTime? parsePublic(String? raw) => _parse(raw);

//   /// loginTime se logoutTime (ya now agar active) tak minutes calculate
//   static int calcDurationMins(LoginHistoryModel record) {
//     final login = _parse(record.loginTime);
//     if (login == null) return 0;

//     final DateTime logout;
//     final parsedLogout = _parse(record.logoutTime);
//     if (parsedLogout != null) {
//       // Edge case: midnight cross ho to +1 day
//       logout = parsedLogout.isBefore(login)
//           ? parsedLogout.add(const Duration(days: 1))
//           : parsedLogout;
//     } else if (record.isActive) {
//       logout = DateTime.now();
//     } else {
//       return 0;
//     }

//     return logout.difference(login).inMinutes.clamp(0, 99999);
//   }

//   /// Minutes → "2h 30m" ya "45m"
//   static String fmtDuration(int mins) {
//     if (mins <= 0) return '0h 0m';
//     final h = mins ~/ 60;
//     final m = mins % 60;
//     return h == 0 ? '${m}m' : '${h}h ${m}m';
//   }

//   /// DateTime string → "01 Mar 2026"
//   static String fmtDate(String dtStr) {
//     final dt = _parse(dtStr);
//     if (dt == null) return dtStr;
//     const mo = [
//       'Jan','Feb','Mar','Apr','May','Jun',
//       'Jul','Aug','Sep','Oct','Nov','Dec'
//     ];
//     return '${dt.day.toString().padLeft(2,'0')} ${mo[dt.month-1]} ${dt.year}';
//   }
// }

// // ─────────────────────────────────────────────
// //  HISTORY CARD
// //  ✅ Fix 1: Date top-right
// //  ✅ Fix 3: Active / Ended label
// //  ✅ Fix 4: Calculated duration
// //  ✅ Fix 5: Admin-style In / Out / Duration row
// // ─────────────────────────────────────────────
// class _HistoryCard extends StatelessWidget {
//   final LoginHistoryModel record;
//   final LoginHistoryController ctrl;
//   const _HistoryCard({required this.record, required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     final isActive = record.isActive;
//     // ✅ Fix 3
//     final statusLabel = isActive ? 'Active' : 'Ended';
//     final statusColor = isActive ? AppTheme.success : AppTheme.error;

//     // ✅ Fix 1: Date
//     final dateText = record.loginTime.isNotEmpty
//         ? _HistoryHelper.fmtDate(record.loginTime)
//         : '--';

//     // ✅ Fix 4: Duration
//     final durationMins = _HistoryHelper.calcDurationMins(record);
//     final durationText = _HistoryHelper.fmtDuration(durationMins);

//     // Login / Logout time strings
//     final loginStr = ctrl.formatLoginTime(record.loginTime);
//     // Fix 2: expired session me bhi logout time dikhao —
//     // logoutTime available ho to use karo,
//     // warna login + duration se calculate karo
//     String logoutStr = '--:--';
//     if (record.logoutTime != null && record.logoutTime!.isNotEmpty) {
//       logoutStr = ctrl.formatLoginTime(record.logoutTime!);
//     } else if (!isActive) {
//       // Session ended/expired but no logoutTime — calculate from duration
//       final loginDt = _HistoryHelper.parsePublic(record.loginTime);
//       if (loginDt != null && durationMins > 0) {
//         final calcLogout = loginDt.add(Duration(minutes: durationMins));
//         final h = calcLogout.hour.toString().padLeft(2, '0');
//         final m = calcLogout.minute.toString().padLeft(2, '0');
//         logoutStr = '$h:$m';
//       }
//     }

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── TOP ROW ───────────────────────────────────────────
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Avatar
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     gradient:
//                         AppTheme.primaryGradientDecoration.gradient,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Center(
//                     child: Text(
//                       record.userName.isNotEmpty
//                           ? record.userName[0].toUpperCase()
//                           : 'U',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 18,
//                           fontFamily: 'Poppins'),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // Name + Role
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         record.userName,
//                         style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             fontFamily: 'Poppins',
//                             color: AppTheme.textPrimary),
//                       ),
//                       if (record.role != null &&
//                           record.role!.isNotEmpty)
//                         Text(record.role!, style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 ),

//                 // Status badge only (no time on top)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 9, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: statusColor.withOpacity(0.3)),
//                   ),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     Container(
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                             color: statusColor,
//                             shape: BoxShape.circle)),
//                     const SizedBox(width: 5),
//                     Text(
//                       statusLabel,
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: statusColor),
//                     ),
//                   ]),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),
//             const Divider(height: 1, color: AppTheme.divider),
//             const SizedBox(height: 12),

//             // ✅ Fix 4+5: In / Out / Duration row (Admin screen style)
//             Row(children: [
//               Expanded(
//                 child: _TimeCell(
//                   label: 'In',
//                   value: loginStr,
//                   dotColor: AppTheme.success,
//                 ),
//               ),
//               Expanded(
//                 child: _TimeCell(
//                   label: 'Out',
//                   value: logoutStr,
//                   dotColor:
//                       isActive ? AppTheme.textHint : AppTheme.error,
//                 ),
//               ),
//               Expanded(
//                 child: _TimeCell(
//                   label: 'Duration',
//                   value: durationText,
//                   dotColor: AppTheme.primary,
//                 ),
//               ),
//             ]),

//             // Extra info (Platform / Device)
//             if ((record.platform != null &&
//                     record.platform!.isNotEmpty) ||
//                 (record.deviceId != null &&
//                     record.deviceId!.isNotEmpty)) ...[
//               const SizedBox(height: 10),
//               const Divider(height: 1, color: AppTheme.divider),
//               const SizedBox(height: 10),
//             ],
//             if (record.platform != null && record.platform!.isNotEmpty)
//               _DetailRow(
//                   icon: Icons.phone_android_rounded,
//                   label: 'Platform',
//                   value: record.platform!,
//                   iconColor: AppTheme.chipWFH),
//             if (record.deviceId != null &&
//                 record.deviceId!.isNotEmpty) ...[
//               if (record.platform != null &&
//                   record.platform!.isNotEmpty)
//                 const SizedBox(height: 6),
//               _DetailRow(
//                 icon: Icons.fingerprint_rounded,
//                 label: 'Device',
//                 value: record.deviceId!.length > 24
//                     ? '${record.deviceId!.substring(0, 24)}…'
//                     : record.deviceId!,
//                 iconColor: AppTheme.textSecondary,
//               ),
//             ],
//           ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  TIME CELL — Admin-style dot + label + value
// // ─────────────────────────────────────────────
// class _TimeCell extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color dotColor;

//   const _TimeCell({
//     required this.label,
//     required this.value,
//     required this.dotColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Fix 4: label + value ek saath compact column — dot + text ek line mein
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//               fontSize: 10,
//               color: AppTheme.textSecondary,
//               fontFamily: 'Poppins'),
//         ),
//         const SizedBox(height: 3),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 7,
//               height: 7,
//               decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
//             ),
//             const SizedBox(width: 5),
//             Flexible(
//               child: Text(
//                 value,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: AppTheme.textPrimary,
//                     fontFamily: 'Poppins'),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STAT ITEM
// // ─────────────────────────────────────────────
// class _StatItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatItem(
//       {required this.label, required this.value, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Text(
//         value,
//         style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: color,
//             fontFamily: 'Poppins'),
//       ),
//       Text(label, style: AppTheme.caption),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  DATE FIELD
// // ─────────────────────────────────────────────
// class _DateField extends StatelessWidget {
//   final String label;
//   final Rx<DateTime> obs;
//   final VoidCallback onTap;

//   const _DateField(
//       {required this.label, required this.obs, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.white.withOpacity(0.3)),
//       ),
//       child: Row(children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 10,
//                     fontFamily: 'Poppins'),
//               ),
//               const SizedBox(height: 2),
//               Obx(() => Text(
//                     AppUtils.formatDate(obs.value),
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins'),
//                   )),
//             ],
//           ),
//         ),
//         GestureDetector(
//           onTap: onTap,
//           child: Icon(Icons.calendar_month_outlined,
//               size: 18, color: Colors.white.withOpacity(0.85)),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SECTION HEADER
// // ─────────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Color color;
//   final Widget trailing;

//   const _SectionHeader({
//     required this.icon,
//     required this.title,
//     required this.color,
//     required this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10)),
//           child: Icon(icon, color: color, size: 16),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           title,
//           style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//               color: AppTheme.textPrimary),
//         ),
//         const Spacer(),
//         trailing,
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  DETAIL ROW (Platform / Device)
// // ─────────────────────────────────────────────
// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String label, value;

//   const _DetailRow({
//     required this.icon,
//     required this.iconColor,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Icon(icon, color: iconColor, size: 15),
//       const SizedBox(width: 7),
//       Text(
//         '$label: ',
//         style: const TextStyle(
//             fontSize: 12,
//             fontFamily: 'Poppins',
//             color: AppTheme.textSecondary,
//             fontWeight: FontWeight.w500),
//       ),
//       Expanded(
//         child: Text(
//           value,
//           style: const TextStyle(
//               fontSize: 12,
//               fontFamily: 'Poppins',
//               color: AppTheme.textPrimary,
//               fontWeight: FontWeight.w600),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  UTILITY WIDGETS
// // ─────────────────────────────────────────────
// class _Loader extends StatelessWidget {
//   const _Loader();
//   @override
//   Widget build(BuildContext context) => const Center(
//       child: CircularProgressIndicator(color: AppTheme.primary));
// }

// class _InlineLoader extends StatelessWidget {
//   const _InlineLoader();
//   @override
//   Widget build(BuildContext context) => const SizedBox(
//         width: 14,
//         height: 14,
//         child: CircularProgressIndicator(
//             strokeWidth: 2, color: AppTheme.primary),
//       );
// }

// class _InlineEmpty extends StatelessWidget {
//   final IconData icon;
//   final String message;
//   const _InlineEmpty({required this.icon, required this.message});
//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 56, color: AppTheme.textHint),
//             const SizedBox(height: 14),
//             Text(message,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 13,
//                     color: AppTheme.textSecondary)),
//           ],
//         ),
//       );
// }

// class _InlineError extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _InlineError({required this.message, required this.onRetry});
//   @override
//   Widget build(BuildContext context) => Padding(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//               color: AppTheme.errorLight,
//               borderRadius: BorderRadius.circular(12)),
//           child: Row(children: [
//             const Icon(Icons.error_outline_rounded,
//                 color: AppTheme.error, size: 18),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(message,
//                   style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: AppTheme.error)),
//             ),
//             GestureDetector(
//               onTap: onRetry,
//               child: const Padding(
//                 padding: EdgeInsets.only(left: 8),
//                 child: Icon(Icons.refresh_rounded,
//                     color: AppTheme.error, size: 18),
//               ),
//             ),
//           ]),
//         ),
//       );
// }



















// lib/screens/login/login_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/login_history_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../models/login_history_model.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final LoginHistoryController _ctrl;
  late final TabController _tabs;
  final AuthController _auth = Get.find();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LoginHistoryController>()) {
      Get.put(LoginHistoryController());
    }
    _ctrl = Get.find<LoginHistoryController>();
    _tabs = TabController(length: _auth.isAdmin ? 2 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  AppBar _buildAppBar({required bool showTabBar}) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Login History',
        style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      bottom: showTabBar
          ? TabBar(
              controller: _tabs,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'My History'),
                Tab(text: 'User Lookup'),
              ],
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(showTabBar: false),
        body: _MyHistoryTab(ctrl: _ctrl),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(showTabBar: true),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MyHistoryTab(ctrl: _ctrl),
          _UserLookupTab(ctrl: _ctrl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MY HISTORY TAB  — only today's sessions, no filter
// ─────────────────────────────────────────────
class _MyHistoryTab extends StatelessWidget {
  final LoginHistoryController ctrl;
  const _MyHistoryTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => ctrl.fetchTodayHistory(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            // ── Today's Sessions ──────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: Icons.today_rounded,
                title: "Today's Sessions",
                color: AppTheme.success,
                trailing: ctrl.isLoadingToday.value
                    ? const _InlineLoader()
                    : Text(
                        '${ctrl.todayHistory.length} session${ctrl.todayHistory.length == 1 ? '' : 's'}',
                        style: AppTheme.caption),
              ),
            ),
            if (ctrl.isLoadingToday.value)
              const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: _Loader()))
            else if (ctrl.errorToday.value.isNotEmpty)
              SliverToBoxAdapter(
                child: _InlineError(
                    message: ctrl.errorToday.value,
                    onRetry: ctrl.fetchTodayHistory),
              )
            else if (ctrl.todayHistory.isEmpty)
              const SliverToBoxAdapter(
                child: _InlineEmpty(
                    icon: Icons.login_rounded,
                    message: 'No login activity today'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HistoryCard(
                          record: ctrl.todayHistory[i], ctrl: ctrl),
                    ),
                    childCount: ctrl.todayHistory.length,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
//  USER LOOKUP TAB
// ─────────────────────────────────────────────
class _UserLookupTab extends StatefulWidget {
  final LoginHistoryController ctrl;
  const _UserLookupTab({required this.ctrl});

  @override
  State<_UserLookupTab> createState() => _UserLookupTabState();
}

class _UserLookupTabState extends State<_UserLookupTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<UserModel> _users        = [];
  bool            _loadingUsers = true;
  UserModel?      _selectedUser;

  final Rx<DateTime> _fromDate = DateTime.now().obs;
  final Rx<DateTime> _toDate   = DateTime.now().obs;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final list = await ApiService.getAllUsers();
      setState(() {
        _users        = list;
        _loadingUsers = false;
      });
    } catch (_) {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) _fromDate.value = picked;
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) _toDate.value = picked;
  }

  void _search() {
    if (_selectedUser == null) {
      Get.snackbar(
        'Select a User',
        'Please select a user from the dropdown before searching.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.cardBackground,
        colorText: AppTheme.textPrimary,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.person_search_rounded,
              color: AppTheme.primary, size: 20),
        ),
        margin: const EdgeInsets.all(12),
        borderRadius: 16,
        duration: const Duration(seconds: 3),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        titleText: const Text(
          'Select a User',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.textPrimary),
        ),
        messageText: const Text(
          'Please select a user from the dropdown before searching.',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppTheme.textSecondary),
        ),
      );
      return;
    }
    widget.ctrl.fetchUserHistory(
      _selectedUser!.userId,
      from: _fromDate.value,
      to:   _toDate.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      // ── Filter Header ──────────────────────────────────────
      Container(
        color: AppTheme.primary,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(children: [
          // User Dropdown
          _loadingUsers
              ? Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Loading users...',
                            style: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                                fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserModel>(
                      value: _selectedUser,
                      isExpanded: true,
                      dropdownColor: AppTheme.primaryDark,
                      iconEnabledColor: Colors.white,
                      hint: const Row(children: [
                        Icon(Icons.person_search_rounded,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text('Select User',
                            style: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                                fontSize: 13)),
                      ]),
                      items: _users
                          .map((u) => DropdownMenuItem<UserModel>(
                                value: u,
                                child: Text(u.userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14),
                                    overflow:
                                        TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedUser = val),
                      selectedItemBuilder: (_) => _users
                          .map((u) => Row(children: [
                                const Icon(Icons.person_rounded,
                                    color: Colors.white70,
                                    size: 18),
                                const SizedBox(width: 8),
                                Text(u.userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600)),
                              ]))
                          .toList(),
                    ),
                  ),
                ),

          const SizedBox(height: 10),

          // Date + Search
          Row(children: [
            Expanded(
              child: _DateField(
                  label: 'From',
                  obs: _fromDate,
                  onTap: _pickFromDate),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                  label: 'To',
                  obs: _toDate,
                  onTap: _pickToDate),
            ),
            const SizedBox(width: 12),
            Obx(() => ElevatedButton(
                  onPressed: widget.ctrl.isLoadingUser.value
                      ? null
                      : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                  ),
                  child: widget.ctrl.isLoadingUser.value
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary))
                      : const Icon(Icons.search),
                )),
          ]),
        ]),
      ),

      // ── Summary Card ───────────────────────────────────────
      Obx(() {
        final records = widget.ctrl.userHistory;
        if (records.isEmpty) return const SizedBox();
        final activeCount = records
            .where((r) =>
                r.sessionStatus == 'Active' || r.isActive)
            .length;
        final endedCount = records.length - activeCount;
        final totalMins  = records.fold<int>(
            0, (s, r) => s + _HistoryHelper.calcDurationMins(r));
        final h = totalMins ~/ 60;
        final m = totalMins % 60;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.cardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Total',  value: '${records.length}', color: AppTheme.primary),
              _StatItem(label: 'Active', value: '$activeCount',      color: AppTheme.success),
              _StatItem(label: 'Ended',  value: '$endedCount',       color: AppTheme.error),
              _StatItem(label: 'Hours',  value: '${h}h ${m}m',      color: AppTheme.accent),
            ],
          ),
        );
      }),

      // ── Results ────────────────────────────────────────────
      Expanded(
        child: Obx(() {
          if (widget.ctrl.isLoadingUser.value) return const _Loader();
          if (widget.ctrl.errorUser.value.isNotEmpty) {
            return _InlineError(
                message: widget.ctrl.errorUser.value,
                onRetry: () {});
          }
          if (widget.ctrl.userHistory.isEmpty) {
            return const _InlineEmpty(
              icon: Icons.manage_search_rounded,
              message: 'Select user, pick dates, then tap 🔍',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: widget.ctrl.userHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _HistoryCard(
                record: widget.ctrl.userHistory[i],
                ctrl: widget.ctrl),
          );
        }),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  HELPER
// ─────────────────────────────────────────────
class _HistoryHelper {
  static DateTime? _parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    try {
      if (!s.contains('-') && s.contains(':')) {
        final now   = DateTime.now();
        final parts = s.split(':');
        final h     = int.tryParse(parts[0]) ?? 0;
        final m     = int.tryParse(parts[1]) ?? 0;
        final sec   = parts.length > 2
            ? int.tryParse(parts[2].split('.')[0]) ?? 0
            : 0;
        return DateTime(now.year, now.month, now.day, h, m, sec);
      }
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  static DateTime? parsePublic(String? raw) => _parse(raw);

  static int calcDurationMins(LoginHistoryModel record) {
    if (record.totalMinutes != null && record.totalMinutes! > 0) {
      return record.totalMinutes!;
    }
    final login = _parse(record.loginTime);
    if (login == null) return 0;
    final DateTime logout;
    final parsedLogout = _parse(record.logoutTime);
    if (parsedLogout != null) {
      logout = parsedLogout.isBefore(login)
          ? parsedLogout.add(const Duration(days: 1))
          : parsedLogout;
    } else if (record.sessionStatus == 'Active' || record.isActive) {
      logout = DateTime.now();
    } else {
      return 0;
    }
    return logout.difference(login).inMinutes.clamp(0, 99999);
  }

  static String fmtDuration(int mins) {
    if (mins <= 0) return '--';
    final h = mins ~/ 60;
    final m = mins % 60;
    return h == 0 ? '${m}m' : '${h}h ${m}m';
  }
}

// ─────────────────────────────────────────────
//  HISTORY CARD
// ─────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final LoginHistoryModel      record;
  final LoginHistoryController ctrl;
  const _HistoryCard({required this.record, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final sessionStatus = record.sessionStatus;
    final isActive  = sessionStatus == 'Active'  || record.isActive;
    final isExpired = sessionStatus == 'Expired';

    final statusLabel = isActive  ? 'Active'
                      : isExpired ? 'Expired'
                      : 'Ended';
    final statusColor = isActive  ? AppTheme.success
                      : isExpired ? Colors.orange
                      : AppTheme.error;

    // Duration
    final String durationText;
    if (record.totalDuration != null &&
        record.totalDuration!.isNotEmpty) {
      durationText = record.totalDuration!;
    } else {
      final mins = _HistoryHelper.calcDurationMins(record);
      durationText = _HistoryHelper.fmtDuration(mins);
    }

    // Login
    final loginDate = ctrl.formatDateOnly(record.loginTime);
    final loginTime = ctrl.formatTimeOnly(record.loginTime);

    // Logout
    String logoutDate = '';
    String logoutTime = '';
    if (record.logoutTime != null && record.logoutTime!.isNotEmpty) {
      logoutDate = ctrl.formatDateOnly(record.logoutTime!);
      logoutTime = ctrl.formatTimeOnly(record.logoutTime!);
    } else if (!isActive) {
      final loginDt  = _HistoryHelper.parsePublic(record.loginTime);
      final totalMin = _HistoryHelper.calcDurationMins(record);
      if (loginDt != null && totalMin > 0) {
        final calcLogout = loginDt.add(Duration(minutes: totalMin));
        logoutDate = DateFormat('dd MMM yyyy').format(calcLogout);
        logoutTime = DateFormat('hh:mm a').format(calcLogout);
      }
    }

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top Row ──────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientDecoration.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  record.userName.isNotEmpty
                      ? record.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.userName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary)),
                  if (record.role != null && record.role!.isNotEmpty)
                    Text(record.role!, style: AppTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: statusColor.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: statusColor)),
              ]),
            ),
          ]),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),

          // ── In / Out / Duration ───────────────────────────
          _InOutDurationRow(
            loginDate:  loginDate,
            loginTime:  loginTime,
            logoutDate: logoutDate,
            logoutTime: logoutTime,
            duration:   durationText,
            isActive:   isActive,
          ),

          // ── Logout Reason Badge ───────────────────────────
          if (record.logoutReason != null &&
              record.logoutReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ctrl
                    .reasonColor(record.logoutReason)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: ctrl
                        .reasonColor(record.logoutReason)
                        .withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(ctrl.reasonIcon(record.logoutReason),
                    size: 12,
                    color: ctrl.reasonColor(record.logoutReason)),
                const SizedBox(width: 5),
                Text(
                  ctrl.reasonLabel(record.logoutReason),
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: ctrl.reasonColor(record.logoutReason)),
                ),
              ]),
            ),
          ],

          // ── Platform / Device ─────────────────────────────
          if ((record.platform != null &&
                  record.platform!.isNotEmpty &&
                  record.platform != 'string') ||
              (record.deviceId != null &&
                  record.deviceId!.isNotEmpty)) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 10),
          ],
          if (record.platform != null &&
              record.platform!.isNotEmpty &&
              record.platform != 'string')
            _DetailRow(
                icon: Icons.phone_android_rounded,
                label: 'Platform',
                value: record.platform!,
                iconColor: AppTheme.chipWFH),
          if (record.deviceId != null &&
              record.deviceId!.isNotEmpty) ...[
            if (record.platform != null &&
                record.platform!.isNotEmpty &&
                record.platform != 'string')
              const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.fingerprint_rounded,
              label: 'Device',
              value: record.deviceId!.length > 24
                  ? '${record.deviceId!.substring(0, 24)}…'
                  : record.deviceId!,
              iconColor: AppTheme.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  IN / OUT / DURATION ROW
//  Uses fixed SizedBox heights on every line so all 3 columns
//  are guaranteed to stay pixel-perfectly aligned.
// ─────────────────────────────────────────────
class _InOutDurationRow extends StatelessWidget {
  final String loginDate;
  final String loginTime;
  final String logoutDate;
  final String logoutTime;
  final String duration;
  final bool   isActive;

  const _InOutDurationRow({
    required this.loginDate,
    required this.loginTime,
    required this.logoutDate,
    required this.logoutTime,
    required this.duration,
    required this.isActive,
  });

  static const _labelStyle = TextStyle(
    fontSize: 10,
    color: AppTheme.textSecondary,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );
  static const _dateStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
    fontFamily: 'Poppins',
  );
  static const _timeStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
    fontFamily: 'Poppins',
  );
  static const _timeHintStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppTheme.textHint,
    fontFamily: 'Poppins',
  );

  Widget _cell({
    required String label,
    required String date,
    required String time,
    required Color  dotColor,
    Color? timeColor,
  }) {
    final hasDate = date.isNotEmpty;
    final hasTime = time.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Row A: label ──
        SizedBox(height: 14, child: Text(label, style: _labelStyle)),
        const SizedBox(height: 3),
        // ── Row B: dot + date ──
        SizedBox(
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  hasDate ? date : '--',
                  style: _dateStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // ── Row C: time ──
        SizedBox(
          height: 17,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              hasTime ? time : '--:--',
              style: (hasDate || hasTime)
                  ? (timeColor != null
                      ? _timeStyle.copyWith(color: timeColor)
                      : _timeStyle)
                  : _timeHintStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _durationCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Row A: label ──
        const SizedBox(height: 14, child: Text('Duration', style: _labelStyle)),
        const SizedBox(height: 3),
        // ── Row B: dot + empty (same height as date row) ──
        SizedBox(
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: AppTheme.primary, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // ── Row C: duration value ──
        SizedBox(
          height: 17,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              duration,
              style: _timeStyle.copyWith(
                  color: isActive ? AppTheme.primary : AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _cell(
            label:    'In',
            date:     loginDate,
            time:     loginTime,
            dotColor: AppTheme.success,
          ),
        ),
        Container(
          width: 1, height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AppTheme.divider,
        ),
        Expanded(
          child: _cell(
            label:    'Out',
            date:     logoutDate,
            time:     logoutTime,
            dotColor: isActive ? AppTheme.textHint : AppTheme.error,
          ),
        ),
        Container(
          width: 1, height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AppTheme.divider,
        ),
        Expanded(child: _durationCell()),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  STAT ITEM
// ─────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatItem(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Poppins')),
      Text(label, style: AppTheme.caption),
    ]);
  }
}

// ─────────────────────────────────────────────
//  DATE FIELD
// ─────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String       label;
  final Rx<DateTime> obs;
  final VoidCallback onTap;
  const _DateField(
      {required this.label,
      required this.obs,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Obx(() => Text(AppUtils.formatDate(obs.value),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'))),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Icon(Icons.calendar_month_outlined,
              size: 18,
              color: Colors.white.withOpacity(0.85)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Color    color;
  final Widget   trailing;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary)),
        const Spacer(),
        trailing,
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  DETAIL ROW
// ─────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label, value;
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: iconColor, size: 15),
      const SizedBox(width: 7),
      Text('$label: ',
          style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500)),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  UTILITY WIDGETS
// ─────────────────────────────────────────────
class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(color: AppTheme.primary));
}

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 14, height: 14,
      child: CircularProgressIndicator(
          strokeWidth: 2, color: AppTheme.primary));
}

class _InlineEmpty extends StatelessWidget {
  final IconData icon;
  final String   message;
  const _InlineEmpty({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: AppTheme.textHint),
              const SizedBox(height: 14),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
}

class _InlineError extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.errorLight,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppTheme.error)),
            ),
            GestureDetector(
              onTap: onRetry,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.refresh_rounded,
                    color: AppTheme.error, size: 18),
              ),
            ),
          ]),
        ),
      );
}