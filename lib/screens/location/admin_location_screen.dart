// lib/screens/location/admin_location_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/location_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location_model.dart';

class AdminLocationScreen extends StatefulWidget {
  const AdminLocationScreen({super.key});

  @override
  State<AdminLocationScreen> createState() => _AdminLocationScreenState();
}

class _AdminLocationScreenState extends State<AdminLocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final ctrl  = Get.find<LocationController>();
  final auth  = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    // Guard: non-admin should not reach here
    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar('Access Denied', 'Admin access required',
            backgroundColor: AppTheme.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      });
      return;
    }

    ctrl.fetchAllToday();
    ctrl.fetchAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        title: const Text(
          'Location Tracking',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded,
                color: AppTheme.primary),
            onPressed: () => _showFilterSheet(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13),
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "All History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TodayTab(ctrl: ctrl),
          _AllHistoryTab(ctrl: ctrl),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminFilterSheet(ctrl: ctrl),
    );
  }
}

// ─────────────────────────────────────────────
//  TODAY TAB
// ─────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final LocationController ctrl;
  const _TodayTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: ctrl.fetchAllToday,
      child: Obx(() {
        if (ctrl.isLoadingAllToday.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final entries = ctrl.allTodayEntries;

        return Column(
          children: [
            // ── Summary strip ─────────────────────────────────────
            Container(
              color: AppTheme.cardBackground,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                _SummaryChip(
                  label: 'Total',
                  count: entries.length,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Checked In',
                  count:
                      entries.where((e) => !e.isCheckedOut).length,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Checked Out',
                  count: entries.where((e) => e.isCheckedOut).length,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Client',
                  count:
                      entries.where((e) => e.isClientVisit).length,
                  color: const Color(0xFF0D9488),
                ),
              ]),
            ),

            // ── List ──────────────────────────────────────────────
            Expanded(
              child: entries.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 80),
                      const Center(
                        child: Column(children: [
                          Icon(Icons.location_off_rounded,
                              size: 56, color: AppTheme.textHint),
                          SizedBox(height: 12),
                          Text('No tracking data today',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _AdminEntryCard(entry: entries[i]),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  ALL HISTORY TAB
// ─────────────────────────────────────────────
class _AllHistoryTab extends StatelessWidget {
  final LocationController ctrl;
  const _AllHistoryTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: ctrl.fetchAll,
      child: Obx(() {
        if (ctrl.isLoadingAll.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final entries = ctrl.allEntries;

        if (entries.isEmpty) {
          return ListView(children: [
            const SizedBox(height: 80),
            const Center(
              child: Column(children: [
                Icon(Icons.history_rounded,
                    size: 56, color: AppTheme.textHint),
                SizedBox(height: 12),
                Text('No history found',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Try adjusting filters',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppTheme.textHint)),
              ]),
            ),
          ]);
        }

        // Group by date
        final grouped = <String, List<LocationTrackingModel>>{};
        for (final e in entries) {
          final key = _dateKey(e.checkInTime);
          grouped.putIfAbsent(key, () => []).add(e);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grouped.length,
          itemBuilder: (_, i) {
            final dateKey = grouped.keys.elementAt(i);
            final dayEntries = grouped[dateKey]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(dateKey, style: AppTheme.labelBold),
                ),
                ...dayEntries
                    .map((e) => _AdminEntryCard(entry: e)),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      }),
    );
  }

  String _dateKey(String raw) {
    if (raw.isEmpty) return 'Unknown';
    try {
      return DateFormat('EEEE, dd MMM yyyy')
          .format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────
//  ADMIN ENTRY CARD
// ─────────────────────────────────────────────
class _AdminEntryCard extends StatelessWidget {
  final LocationTrackingModel entry;
  const _AdminEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── User row ───────────────────────────────────────────
          Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  entry.userName.isNotEmpty
                      ? entry.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      fontFamily: 'Poppins'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.userName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary)),
                  Text(entry.role,
                      style: AppTheme.caption),
                ],
              ),
            ),
            _StatusBadge(entry: entry),
          ]),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),

          // ── Time row ───────────────────────────────────────────
          Row(children: [
            _TimeChip(
              icon: Icons.login_rounded,
              label: _fmt(entry.checkInTime),
              color: AppTheme.success,
            ),
            if (entry.isCheckedOut) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppTheme.textHint),
              ),
              _TimeChip(
                icon: Icons.logout_rounded,
                label: _fmt(entry.checkOutTime ?? ''),
                color: AppTheme.error,
              ),
            ],
            const Spacer(),
            if (entry.totalHours != null && entry.totalHours!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(entry.totalHours!,
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: AppTheme.info)),
              ),
          ]),

          // ── Work type ──────────────────────────────────────────
          if (entry.workType.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.work_outline_rounded,
                  size: 12, color: AppTheme.textHint),
              const SizedBox(width: 5),
              Text(entry.workType, style: AppTheme.caption),
            ]),
          ],

          // ── Address ────────────────────────────────────────────
          if (entry.checkInAddress.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.pin_drop_rounded,
                  size: 12, color: AppTheme.textHint),
              const SizedBox(width: 5),
              Expanded(
                child: Text(entry.checkInAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption),
              ),
            ]),
          ],

          // ── Client visit ───────────────────────────────────────
          if (entry.isClientVisit) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:
                        const Color(0xFF0D9488).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.business_center_rounded,
                        size: 13, color: Color(0xFF0D9488)),
                    const SizedBox(width: 5),
                    Text(
                        entry.clientName != null
                            ? 'Client: ${entry.clientName}'
                            : 'Client Visit',
                        style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D9488))),
                  ]),
                  if (entry.visitPurpose != null &&
                      entry.visitPurpose!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text('Purpose: ${entry.visitPurpose}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            color: AppTheme.textSecondary)),
                  ],
                  if (entry.outcome != null &&
                      entry.outcome!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text('Outcome: ${entry.outcome}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(String raw) {
    if (raw.isEmpty) return '—';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────
//  ADMIN FILTER SHEET
// ─────────────────────────────────────────────
class _AdminFilterSheet extends StatelessWidget {
  final LocationController ctrl;
  const _AdminFilterSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final userIdCtrl = TextEditingController(
        text: ctrl.filterUserId.value?.toString() ?? '');

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Filter Tracking Data',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            // User ID
            TextField(
              controller: userIdCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                labelText: 'User ID (optional)',
                labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.person_search_rounded,
                    color: AppTheme.textSecondary, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Date range
            Row(children: [
              Expanded(
                child: Obx(() => _DateBtn(
                      label: 'From Date',
                      date: ctrl.filterFromDate.value,
                      onPick: (dt) =>
                          ctrl.filterFromDate.value = dt,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _DateBtn(
                      label: 'To Date',
                      date: ctrl.filterToDate.value,
                      onPick: (dt) =>
                          ctrl.filterToDate.value = dt,
                    )),
              ),
            ]),
            const SizedBox(height: 14),

            // Client visit filter
            const Text('Visit Type',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Obx(() => Wrap(spacing: 8, children: [
                  _VisitChip(
                    label: 'All',
                    selected: ctrl.filterClientVisit.value == null,
                    onTap: () =>
                        ctrl.filterClientVisit.value = null,
                  ),
                  _VisitChip(
                    label: 'Client Visit',
                    selected:
                        ctrl.filterClientVisit.value == true,
                    onTap: () =>
                        ctrl.filterClientVisit.value = true,
                  ),
                  _VisitChip(
                    label: 'Regular',
                    selected:
                        ctrl.filterClientVisit.value == false,
                    onTap: () =>
                        ctrl.filterClientVisit.value = false,
                  ),
                ])),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ctrl.resetFilters();
                    ctrl.fetchAll();
                    ctrl.fetchAllToday();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side:
                        const BorderSide(color: AppTheme.divider),
                  ),
                  child: const Text('Reset',
                      style: TextStyle(fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final uid = int.tryParse(
                        userIdCtrl.text.trim());
                    ctrl.filterUserId.value = uid;
                    ctrl.fetchAll();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFamily: 'Poppins')),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontFamily: 'Poppins',
                    color: AppTheme.textSecondary)),
          ]),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final LocationTrackingModel entry;
  const _StatusBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.isCheckedOut
        ? AppTheme.textSecondary
        : AppTheme.success;
    final label = entry.isCheckedOut ? 'Checked Out' : 'Active';

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: color)),
      ]),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TimeChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      );
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DateBtn(
      {required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          final dt = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(
                    primary: AppTheme.primary),
              ),
              child: child!,
            ),
          );
          if (dt != null) onPick(dt);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color: date != null
                    ? AppTheme.primary
                    : AppTheme.divider),
            borderRadius: BorderRadius.circular(12),
            color: date != null
                ? AppTheme.primary.withOpacity(0.06)
                : null,
          ),
          child: Row(children: [
            Icon(Icons.calendar_today_rounded,
                size: 14,
                color: date != null
                    ? AppTheme.primary
                    : AppTheme.textHint),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd MMM yy').format(date!)
                    : label,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    color: date != null
                        ? AppTheme.primary
                        : AppTheme.textHint,
                    fontWeight: date != null
                        ? FontWeight.w600
                        : FontWeight.normal),
              ),
            ),
          ]),
        ),
      );
}

class _VisitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _VisitChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary
                : AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.primary)),
        ),
      );
}



// Home Screen
//     │
//     ▼
// [Location Chip] → /my-location
//     │
//     ├─── अगर कोई Active Session नहीं है
//     │         │
//     │         ▼
//     │    [Check In Card]
//     │    Work Type select करो: Office / WFH / Field / Client Site
//     │    [Check In Now] button press करो
//     │         │
//     │         ▼
//     │    GPS location लेता है automatically
//     │    POST /api/Location/checkin
//     │    { latitude, longitude, address, workType }
//     │         │
//     │         ▼
//     │    ✅ Active Session Card दिखता है (Green, Live badge)
//     │    Check-in time, Work Type, Address show होता है
//     │
//     └─── अगर Active Session है
//               │
//               ▼
//          [Check Out] button press करो
//               │
//               ▼
//          Bottom Sheet खुलता है:
//          ┌─────────────────────────┐
//          │  Client Visit? (Toggle) │
//          │  ├── OFF: सिर्फ checkout │
//          │  └── ON: extra fields   │
//          │      • Client Name      │
//          │      • Client Address   │
//          │      • Visit Purpose    │
//          │      • Meeting Notes    │
//          │      • Outcome         │
//          └─────────────────────────┘
//               │
//               ▼
//          PUT /api/Location/checkout
//          { trackingId, latitude, longitude,
//            isClientVisit, clientName, ... }
//               │
//               ▼
//          ✅ Session end, Today's list refresh

//          /my-location → [History icon] → /location-history
//     │
//     ▼
// GET /api/Location/my/history
//     │
//     ▼
// Date-wise grouped list दिखता है:
//   Thursday, 26 Feb 2025
//   ├── Office  In: 09:30 AM  Out: 06:15 PM  [8.75h]
//   └── Client Visit  In: 02:00 PM  Out: 04:00 PM  🏢 Client Name
//     │
//     ▼
// [Filter icon] → Date range filter
//   From Date ── To Date
//   [Apply] → GET /api/Location/my/history?fromDate=&toDate=

//   Home Screen (Admin)
//     │
//     ▼
// Admin Panel → [Location Tracking] → /admin-location
//     │
//     ▼
// ┌──────────────────────────────────┐
// │  TabBar                          │
// │  [Today]  |  [All History]       │
// └──────────────────────────────────┘

// TODAY TAB:
//     │
//     ▼
// GET /api/Location/all/today
//     │
//     ▼
// Summary Strip:
// ┌────────┬───────────┬─────────────┬────────┐
// │ Total  │ Checked In│ Checked Out │ Client │
// │   12   │     8     │      4      │   2    │
// └────────┴───────────┴─────────────┴────────┘
//     │
//     ▼
// Employee Cards:
// ┌─────────────────────────────┐
// │ [A]  Amit Kumar             │
// │      Developer        🟢 Active │
// │  ─────────────────────────  │
// │  ▶ 09:30 AM                 │
// │  📍 Sector 62, Noida        │
// │  💼 Office                  │
// └─────────────────────────────┘

// ALL HISTORY TAB:
//     │
//     ▼
// [Filter icon] → Admin Filter Sheet
// ┌──────────────────────────────┐
// │ User ID: [____]              │
// │ From Date: [  ] To: [  ]     │
// │ Visit Type: All/Client/Regular│
// │ [Reset]        [Apply]       │
// └──────────────────────────────┘
//     │
//     ▼
// GET /api/Location/all?userId=&fromDate=&toDate=&isClientVisit=
//     │
//     ▼
// Date-wise grouped employee list