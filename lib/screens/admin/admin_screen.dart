// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/admin_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';
// import '../../core/constants/app_constants.dart';

// class AdminScreen extends StatefulWidget {
//   const AdminScreen({super.key});

//   @override
//   State<AdminScreen> createState() => _AdminScreenState();
// }

// class _AdminScreenState extends State<AdminScreen>
//     with SingleTickerProviderStateMixin {
//   final controller = Get.put(AdminController());
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.fetchAdminSummary();
//       controller.fetchAllUsers();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Panel'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'Attendance Summary'),
//             Tab(text: 'All Users'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _AttendanceSummaryTab(controller: controller),
//           _AllUsersTab(controller: controller),
//         ],
//       ),
//     );
//   }
// }

// // =================== ATTENDANCE TAB ===================
// class _AttendanceSummaryTab extends StatelessWidget {
//   final AdminController controller;

//   const _AttendanceSummaryTab({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Filter
//         Container(
//           color: AppTheme.primary,
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//           child: Column(
//             children: [
//               // Role Dropdown
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(10),
//                   border:
//                       Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Obx(() => DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: controller.selectedRole.value,
//                     isExpanded: true,
//                     dropdownColor: AppTheme.primaryDark,
//                     iconEnabledColor: Colors.white,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Poppins',
//                     ),
//                     items: AppConstants.allRoles
//                         .map((r) => DropdownMenuItem(
//                               value: r,
//                               child: Text(
//                                 r[0].toUpperCase() + r.substring(1),
//                               ),
//                             ))
//                         .toList(),
//                     onChanged: (val) {
//                       if (val != null)
//                         controller.selectedRole.value = val;
//                     },
//                   ),
//                 )),
//               ),
//               const SizedBox(height: 10),

//               // Date Range
//               Row(
//                 children: [
//                   Expanded(
//                     child: _DateChip(
//                       label: 'From',
//                       obs: controller.fromDate,
//                       onTap: () => controller.pickFromDate(context),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _DateChip(
//                       label: 'To',
//                       obs: controller.toDate,
//                       onTap: () => controller.pickToDate(context),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Obx(() => ElevatedButton(
//                     onPressed: controller.isLoadingSummary.value
//                         ? null
//                         : controller.fetchAdminSummary,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: AppTheme.primary,
//                       minimumSize: const Size(44, 44),
//                       padding: EdgeInsets.zero,
//                     ),
//                     child: controller.isLoadingSummary.value
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppTheme.primary,
//                             ),
//                           )
//                         : const Icon(Icons.search),
//                   )),
//                   const SizedBox(width: 8),
//                   // Export Button
//                   Obx(() => ElevatedButton(
//                     onPressed: controller.isExporting.value
//                         ? null
//                         : controller.exportPdf,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.accent,
//                       minimumSize: const Size(44, 44),
//                       padding: EdgeInsets.zero,
//                     ),
//                     child: controller.isExporting.value
//                         ? const SizedBox(
//                             height: 16,
//                             width: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.picture_as_pdf,
//                             color: Colors.white, size: 20),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // Stats
//         Obx(() => controller.adminRecords.isEmpty
//             ? const SizedBox()
//             : Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                 decoration: AppTheme.cardDecoration(),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _StatItem(
//                       label: 'Total',
//                       value: controller.adminRecords.length.toString(),
//                       color: AppTheme.primary,
//                     ),
//                     _StatItem(
//                       label: 'Complete',
//                       value: controller.totalPresent.toString(),
//                       color: AppTheme.success,
//                     ),
//                     _StatItem(
//                       label: 'Incomplete',
//                       value: controller.totalIncomplete.toString(),
//                       color: AppTheme.warning,
//                     ),
//                     _StatItem(
//                       label: 'Hours',
//                       value: AppUtils.formatHours(
//                           controller.totalWorkHours),
//                       color: AppTheme.accent,
//                     ),
//                   ],
//                 ),
//               )),

//         // List
//         Expanded(
//           child: Obx(() {
//             if (controller.isLoadingSummary.value) {
//               return const Center(
//                   child:
//                       CircularProgressIndicator(color: AppTheme.primary));
//             }
//             if (controller.adminRecords.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.people_outline,
//                         size: 60, color: AppTheme.textHint),
//                     SizedBox(height: 16),
//                     Text('No records found', style: AppTheme.headline3),
//                     Text('Select role & date range',
//                         style: AppTheme.bodySmall),
//                   ],
//                 ),
//               );
//             }
//             return ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: controller.adminRecords.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (_, i) {
//                 final record = controller.adminRecords[i];
//                 return _AdminAttendanceCard(record: record);
//               },
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

// // =================== USERS TAB ===================
// class _AllUsersTab extends StatelessWidget {
//   final AdminController controller;

//   const _AllUsersTab({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoadingUsers.value) {
//         return const Center(
//             child: CircularProgressIndicator(color: AppTheme.primary));
//       }
//       if (controller.allUsers.isEmpty) {
//         return const Center(child: Text('No users found'));
//       }
//       return ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: controller.allUsers.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 12),
//         itemBuilder: (_, i) {
//           final user = controller.allUsers[i];
//           return Container(
//             padding: const EdgeInsets.all(16),
//             decoration: AppTheme.cardDecoration(),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: AppTheme.primaryLight,
//                   child: Text(
//                     user.userName.isNotEmpty
//                         ? user.userName[0].toUpperCase()
//                         : 'U',
//                     style: const TextStyle(
//                       color: AppTheme.primary,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(user.userName, style: AppTheme.headline3),
//                       const SizedBox(height: 2),
//                       Text(user.email, style: AppTheme.bodySmall),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryLight,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         user.role[0].toUpperCase() +
//                             user.role.substring(1),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.primary,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: user.isActive
//                             ? AppTheme.success
//                             : AppTheme.error,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     });
//   }
// }

// // =================== WIDGETS ===================
// class _DateChip extends StatelessWidget {
//   final String label;
//   final Rx<DateTime> obs;
//   final VoidCallback onTap;

//   const _DateChip({
//     required this.label,
//     required this.obs,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

// class _StatItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _StatItem({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: color,
//             fontFamily: 'Poppins',
//           ),
//         ),
//         Text(label, style: AppTheme.caption),
//       ],
//     );
//   }
// }

// class _AdminAttendanceCard extends StatelessWidget {
//   final dynamic record;

//   const _AdminAttendanceCard({required this.record});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppTheme.cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(record.userName, style: AppTheme.headline3),
//                   Text(
//                     '${record.role[0].toUpperCase()}${record.role.substring(1)}',
//                     style: AppTheme.bodySmall,
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     AppUtils.formatDateDisplay(record.attendanceDate),
//                     style: AppTheme.bodySmall,
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: AppUtils.getStatusBgColor(record.status),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       record.status,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color:
//                             AppUtils.getStatusColor(record.status),
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const Divider(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _TimeRow(
//                   label: 'In',
//                   time: AppUtils.formatTime(record.inTime),
//                   color: AppTheme.success,
//                 ),
//               ),
//               Expanded(
//                 child: _TimeRow(
//                   label: 'Out',
//                   time: AppUtils.formatTime(record.outTime),
//                   color: AppTheme.error,
//                 ),
//               ),
//               Expanded(
//                 child: _TimeRow(
//                   label: 'Hours',
//                   time: AppUtils.formatHours(record.totalHours),
//                   color: AppTheme.primary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeRow extends StatelessWidget {
//   final String label;
//   final String time;
//   final Color color;

//   const _TimeRow({
//     required this.label,
//     required this.time,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                   fontSize: 10,
//                   color: AppTheme.textSecondary,
//                   fontFamily: 'Poppins'),
//             ),
//             Text(
//               time,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textPrimary,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(AdminController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // fetchRoles() onInit mein ho raha hai AdminController mein
      controller.fetchAllUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Attendance Summary'),
            Tab(text: 'All Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AttendanceSummaryTab(controller: controller),
          _AllUsersTab(controller: controller),
        ],
      ),
    );
  }
}

// =================== ATTENDANCE TAB ===================
class _AttendanceSummaryTab extends StatelessWidget {
  final AdminController controller;

  const _AttendanceSummaryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter
        Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // ✅ Role Dropdown — API se roles
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Obx(() {
                  // Loading state
                  if (controller.isLoadingRoles.value) {
                    return const SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Loading roles...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Roles loaded
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedRole.value.isEmpty
                          ? null
                          : controller.selectedRole.value,
                      isExpanded: true,
                      dropdownColor: AppTheme.primaryDark,
                      iconEnabledColor: Colors.white,
                      hint: const Text(
                        'Select Role',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                      items: controller.roles
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(
                                  r == 'all'
                                      ? 'All Roles'
                                      : r[0].toUpperCase() + r.substring(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: r == 'all'
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.selectedRole.value = val;
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: _DateChip(
                      label: 'From',
                      obs: controller.fromDate,
                      onTap: () => controller.pickFromDate(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateChip(
                      label: 'To',
                      obs: controller.toDate,
                      onTap: () => controller.pickToDate(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Search Button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoadingSummary.value
                            ? null
                            : controller.fetchAdminSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: controller.isLoadingSummary.value
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
                  const SizedBox(width: 8),
                  // Export PDF Button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isExporting.value
                            ? null
                            : controller.exportPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                        ),
                        child: controller.isExporting.value
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf,
                                color: Colors.white, size: 20),
                      )),
                ],
              ),
            ],
          ),
        ),

        // Stats Cards
        Obx(() => controller.adminRecords.isEmpty
            ? const SizedBox()
            : Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: AppTheme.cardDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total',
                      value: controller.adminRecords.length.toString(),
                      color: AppTheme.primary,
                    ),
                    _StatItem(
                      label: 'Complete',
                      value: controller.totalPresent.toString(),
                      color: AppTheme.success,
                    ),
                    _StatItem(
                      label: 'Incomplete',
                      value: controller.totalIncomplete.toString(),
                      color: AppTheme.warning,
                    ),
                    _StatItem(
                      label: 'Hours',
                      value: AppUtils.formatHours(controller.totalWorkHours),
                      color: AppTheme.accent,
                    ),
                  ],
                ),
              )),

        // Records List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingSummary.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary));
            }
            if (controller.adminRecords.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 60, color: AppTheme.textHint),
                    SizedBox(height: 16),
                    Text('No records found', style: AppTheme.headline3),
                    Text('Select role & date range',
                        style: AppTheme.bodySmall),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.adminRecords.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final record = controller.adminRecords[i];
                return _AdminAttendanceCard(record: record);
              },
            );
          }),
        ),
      ],
    );
  }
}

// =================== USERS TAB ===================
class _AllUsersTab extends StatelessWidget {
  final AdminController controller;

  const _AllUsersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary));
      }
      if (controller.allUsers.isEmpty) {
        return const Center(child: Text('No users found'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.allUsers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final user = controller.allUsers[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    user.userName.isNotEmpty
                        ? user.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.userName, style: AppTheme.headline3),
                      const SizedBox(height: 2),
                      Text(user.email, style: AppTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role[0].toUpperCase() + user.role.substring(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? AppTheme.success
                            : AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

// =================== WIDGETS ===================
class _DateChip extends StatelessWidget {
  final String label;
  final Rx<DateTime> obs;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.obs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
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
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
        Text(label, style: AppTheme.caption),
      ],
    );
  }
}

class _AdminAttendanceCard extends StatelessWidget {
  final dynamic record;

  const _AdminAttendanceCard({required this.record});

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.userName, style: AppTheme.headline3),
                  Text(
                    '${record.role[0].toUpperCase()}${record.role.substring(1)}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatDateDisplay(record.attendanceDate),
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppUtils.getStatusBgColor(record.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppUtils.getStatusColor(record.status),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeRow(
                  label: 'In',
                  time: AppUtils.formatTime(record.inTime),
                  color: AppTheme.success,
                ),
              ),
              Expanded(
                child: _TimeRow(
                  label: 'Out',
                  time: AppUtils.formatTime(record.outTime),
                  color: AppTheme.error,
                ),
              ),
              Expanded(
                child: _TimeRow(
                  label: 'Hours',
                  time: AppUtils.formatHours(record.totalHours),
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _TimeRow({
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }
}