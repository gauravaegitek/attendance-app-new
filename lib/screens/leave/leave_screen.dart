// lib/screens/leave/leave_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/leave_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leave_model.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    // Ensure controller is registered
    if (!Get.isRegistered<LeaveController>()) {
      Get.put(LeaveController());
    }

    // Admin gets 2 tabs, user gets 1 tab (Apply + My Leaves only)
    return Obx(() {
      final isAdmin = auth.isAdmin;

      if (isAdmin) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.cardBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimary, size: 20),
                onPressed: () => Get.back(),
              ),
              title: const Text('Leave Management',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.textPrimary)),
              bottom: const TabBar(
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primary,
                labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                tabs: [
                  Tab(text: 'Apply'),
                  Tab(text: 'My Leaves'),
                  Tab(text: 'All Leaves'), // Admin only
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                _ApplyLeaveTab(),
                _MyLeavesTab(),
                _AdminAllLeavesTab(), // Admin only tab
              ],
            ),
          ),
        );
      }

      // Non-admin: 2 tabs only
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.cardBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppTheme.textPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
            title: const Text('My Leaves',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            bottom: const TabBar(
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              tabs: [
                Tab(text: 'Apply'),
                Tab(text: 'My Leaves'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _ApplyLeaveTab(),
              _MyLeavesTab(),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
//  APPLY LEAVE TAB
// ─────────────────────────────────────────────────────────────
class _ApplyLeaveTab extends StatelessWidget {
  const _ApplyLeaveTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeaveController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        _sectionLabel('Leave Type'),
        const SizedBox(height: 8),
        Obx(() => Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: ctrl.selectedLeaveType.value.isEmpty
                      ? null
                      : ctrl.selectedLeaveType.value,
                  hint: const Text('Select Leave Type',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.textHint,
                          fontSize: 14)),
                  items: ctrl.leaveTypeOptions
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => ctrl.selectedLeaveType.value = v ?? '',
                ),
              ),
            )),

        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _sectionLabel('From Date'),
              const SizedBox(height: 8),
              Obx(() => _DatePickerField(
                    label: ctrl.fromDate.value == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy')
                            .format(ctrl.fromDate.value!),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) ctrl.fromDate.value = picked;
                    },
                  )),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _sectionLabel('To Date'),
              const SizedBox(height: 8),
              Obx(() => _DatePickerField(
                    label: ctrl.toDate.value == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(ctrl.toDate.value!),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            ctrl.fromDate.value ?? DateTime.now(),
                        firstDate: ctrl.fromDate.value ?? DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) ctrl.toDate.value = picked;
                    },
                  )),
            ]),
          ),
        ]),

        // Show total days
        Obx(() {
          if (ctrl.fromDate.value != null && ctrl.toDate.value != null) {
            final days =
                ctrl.toDate.value!.difference(ctrl.fromDate.value!).inDays + 1;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.primary, size: 16),
                const SizedBox(width: 6),
                Text('Total: $days day${days > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
              ]),
            );
          }
          return const SizedBox.shrink();
        }),

        const SizedBox(height: 20),
        _sectionLabel('Reason'),
        const SizedBox(height: 8),
        Container(
          decoration: AppTheme.cardDecoration(),
          child: TextField(
            controller: ctrl.reasonController,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Enter reason for leave...',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTheme.textHint,
                  fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 28),
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isApplying.value
                    ? null
                    : () => ctrl.applyLeave(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: ctrl.isApplying.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Apply Leave',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white)),
              ),
            )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MY LEAVES TAB (User)
// ─────────────────────────────────────────────────────────────
class _MyLeavesTab extends StatelessWidget {
  const _MyLeavesTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeaveController>();

    return Column(children: [
      // Filter row
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Row(children: [
          Expanded(
            child: Obx(() => _StatusFilter(
                  selected: ctrl.selectedStatus.value,
                  onChanged: (v) {
                    ctrl.selectedStatus.value = v;
                    ctrl.fetchMyLeaves();
                  },
                )),
          ),
          const SizedBox(width: 10),
          // Refresh
          GestureDetector(
            onTap: ctrl.fetchMyLeaves,
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
          if (ctrl.myLeaves.isEmpty) {
            return _EmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No leaves found',
              sub: 'Apply for a leave to see it here',
            );
          }
          return RefreshIndicator(
            onRefresh: ctrl.fetchMyLeaves,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              itemCount: ctrl.myLeaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LeaveCard(
                leave: ctrl.myLeaves[i],
                isAdmin: false,
                onCancel: (id) => _confirmCancel(context, ctrl, id),
              ),
            ),
          );
        }),
      ),
    ]);
  }

  void _confirmCancel(
      BuildContext context, LeaveController ctrl, int leaveId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Leave?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to cancel this leave?',
            style: TextStyle(fontFamily: 'Poppins', color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('No',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.cancelLeave(leaveId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADMIN: ALL LEAVES TAB  ← Only shown to admin
// ─────────────────────────────────────────────────────────────
class _AdminAllLeavesTab extends StatefulWidget {
  const _AdminAllLeavesTab();

  @override
  State<_AdminAllLeavesTab> createState() => _AdminAllLeavesTabState();
}

class _AdminAllLeavesTabState extends State<_AdminAllLeavesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LeaveController>().fetchAllLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ctrl = Get.find<LeaveController>();

    return Column(children: [
      // Filter row
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Row(children: [
          Expanded(
            child: Obx(() => _StatusFilter(
                  selected: ctrl.selectedStatus.value,
                  onChanged: (v) {
                    ctrl.selectedStatus.value = v;
                    ctrl.fetchAllLeaves();
                  },
                )),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: ctrl.fetchAllLeaves,
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
          if (ctrl.allLeaves.isEmpty) {
            return _EmptyState(
              icon: Icons.inbox_rounded,
              title: 'No leave requests',
              sub: 'No leaves found for selected filter',
            );
          }
          return RefreshIndicator(
            onRefresh: ctrl.fetchAllLeaves,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              itemCount: ctrl.allLeaves.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LeaveCard(
                leave: ctrl.allLeaves[i],
                isAdmin: true,
                onApprove: (id) => _showActionDialog(context, ctrl, id, 'Approved'),
                onReject: (id) => _showActionDialog(context, ctrl, id, 'Rejected'),
              ),
            ),
          );
        }),
      ),
    ]);
  }

  void _showActionDialog(
    BuildContext context,
    LeaveController ctrl,
    int leaveId,
    String action,
  ) {
    final remarkCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(
            action == 'Approved'
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: action == 'Approved' ? AppTheme.success : AppTheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text('$action Leave',
              style: const TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
              'Are you sure you want to ${action.toLowerCase()} this leave request?',
              style: const TextStyle(
                  fontFamily: 'Poppins', color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          TextField(
            controller: remarkCtrl,
            decoration: InputDecoration(
              labelText: 'Admin Remark (optional)',
              hintText: 'Add a note...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: action == 'Approved'
                        ? AppTheme.success
                        : AppTheme.error,
                    width: 2),
              ),
            ),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            maxLines: 2,
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.takeLeaveAction(
                leaveId:     leaveId,
                status:      action,
                adminRemark: remarkCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'Approved'
                  ? AppTheme.success
                  : AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(action,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED: LEAVE CARD
// ─────────────────────────────────────────────────────────────
class _LeaveCard extends StatelessWidget {
  final LeaveModel leave;
  final bool       isAdmin;
  final void Function(int id)? onCancel;
  final void Function(int id)? onApprove;
  final void Function(int id)? onReject;

  const _LeaveCard({
    required this.leave,
    required this.isAdmin,
    this.onCancel,
    this.onApprove,
    this.onReject,
  });

  Color get _statusColor {
    switch (leave.status.toLowerCase()) {
      case 'approved': return AppTheme.success;
      case 'rejected': return AppTheme.error;
      default:         return AppTheme.warning;
    }
  }

  IconData get _statusIcon {
    switch (leave.status.toLowerCase()) {
      case 'approved': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default:         return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(leave.leaveType,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
          ),
          const Spacer(),
          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_statusIcon, color: _statusColor, size: 14),
              const SizedBox(width: 4),
              Text(leave.status,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor)),
            ]),
          ),
        ]),

        // Admin sees employee name
        if (isAdmin) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.person_outline_rounded,
                size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(leave.userName,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ]),
        ],

        const SizedBox(height: 10),
        // Date range
        Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text('${fmt.format(leave.fromDate)}  →  ${fmt.format(leave.toDate)}',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6)),
            child: Text('${leave.totalDays}d',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ),
        ]),

        // Reason
        const SizedBox(height: 8),
        Text(leave.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.textSecondary)),

        // Admin Remark
        if (leave.adminRemark != null && leave.adminRemark!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.comment_outlined,
                size: 14, color: AppTheme.info),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Remark: ${leave.adminRemark}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppTheme.info,
                      fontStyle: FontStyle.italic)),
            ),
          ]),
        ],

        // User: cancel button (only for Pending)
        if (!isAdmin && leave.status.toLowerCase() == 'pending') ...[
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => onCancel?.call(leave.id),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.close_rounded,
                  color: AppTheme.error, size: 16),
              const SizedBox(width: 6),
              const Text('Cancel Leave',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],

        // Admin: approve/reject buttons (only for Pending)
        if (isAdmin && leave.status.toLowerCase() == 'pending') ...[
          const SizedBox(height: 12),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onApprove?.call(leave.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded,
                            color: AppTheme.success, size: 18),
                        SizedBox(width: 6),
                        Text('Approve',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppTheme.success,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => onReject?.call(leave.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded,
                            color: AppTheme.error, size: 18),
                        SizedBox(width: 6),
                        Text('Reject',
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
//  SHARED: SMALL WIDGETS
// ─────────────────────────────────────────────────────────────

class _StatusFilter extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _StatusFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = ['All', 'Pending', 'Approved', 'Rejected'];
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.cardBackground,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary)),
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
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: label == 'Select date'
                        ? AppTheme.textHint
                        : AppTheme.textPrimary)),
          ),
        ]),
      ),
    );
  }
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

Widget _sectionLabel(String text) => Text(text,
    style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary));