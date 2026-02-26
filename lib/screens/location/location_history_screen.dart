// lib/screens/location/location_history_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/location_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location_model.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() =>
      _LocationHistoryScreenState();
}

class _LocationHistoryScreenState
    extends State<LocationHistoryScreen> {
  final ctrl = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        title: const Text(
          'Location History',
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
          Obx(() {
            final hasFilters = ctrl.filterFromDate.value != null ||
                ctrl.filterToDate.value != null;
            return IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: hasFilters ? AppTheme.primary : AppTheme.textSecondary,
              ),
              onPressed: () => _showFilterSheet(),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Active filter chips ─────────────────────────────────
          Obx(() {
            final hasFilters = ctrl.filterFromDate.value != null ||
                ctrl.filterToDate.value != null;
            if (!hasFilters) return const SizedBox.shrink();
            return Container(
              color: AppTheme.cardBackground,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                if (ctrl.filterFromDate.value != null)
                  _FilterChip(
                    label:
                        'From: ${DateFormat('dd MMM').format(ctrl.filterFromDate.value!)}',
                    onRemove: () {
                      ctrl.filterFromDate.value = null;
                      ctrl.fetchHistory();
                    },
                  ),
                const SizedBox(width: 8),
                if (ctrl.filterToDate.value != null)
                  _FilterChip(
                    label:
                        'To: ${DateFormat('dd MMM').format(ctrl.filterToDate.value!)}',
                    onRemove: () {
                      ctrl.filterToDate.value = null;
                      ctrl.fetchHistory();
                    },
                  ),
              ]),
            );
          }),

          // ── History list ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: ctrl.fetchHistory,
              child: Obx(() {
                if (ctrl.isLoadingHistory.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary),
                  );
                }
                if (ctrl.historyEntries.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(children: [
                          const Icon(Icons.history_rounded,
                              size: 56, color: AppTheme.textHint),
                          const SizedBox(height: 16),
                          const Text('No history found',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('Try adjusting the date filters',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textHint,
                                  fontFamily: 'Poppins')),
                        ]),
                      ),
                    ],
                  );
                }

                // Group by date
                final grouped = <String, List<LocationTrackingModel>>{};
                for (final e in ctrl.historyEntries) {
                  final key = _dateKey(e.checkInTime);
                  grouped.putIfAbsent(key, () => []).add(e);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (_, i) {
                    final dateKey = grouped.keys.elementAt(i);
                    final entries = grouped[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10, top: 4),
                          child: Text(dateKey,
                              style: AppTheme.labelBold),
                        ),
                        ...entries.map(
                            (e) => _HistoryEntryCard(entry: e)),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryFilterSheet(ctrl: ctrl),
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
//  HISTORY ENTRY CARD
// ─────────────────────────────────────────────
class _HistoryEntryCard extends StatelessWidget {
  final LocationTrackingModel entry;
  const _HistoryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final checkinTime  = _fmt(entry.checkInTime);
    final checkoutTime = entry.checkOutTime != null
        ? _fmt(entry.checkOutTime!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Timeline dot
        Column(children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: entry.isCheckedOut
                  ? AppTheme.success
                  : AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          if (checkoutTime != null) ...[
            Container(width: 2, height: 30, color: AppTheme.divider),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ]),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                      entry.workType.isEmpty ? 'Office' : entry.workType,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary)),
                ),
                if (entry.totalHours != null)
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
              const SizedBox(height: 4),
              Text('In: $checkinTime',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.success,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500)),
              if (checkoutTime != null) ...[
                const SizedBox(height: 2),
                Text('Out: $checkoutTime',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.error,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500)),
              ],
              if (entry.checkInAddress.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.pin_drop_rounded,
                      size: 11, color: AppTheme.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(entry.checkInAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.caption),
                  ),
                ]),
              ],
              if (entry.isClientVisit) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.clientName != null
                        ? '🏢 ${entry.clientName}'
                        : '🏢 Client Visit',
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  String _fmt(String raw) {
    if (raw.isEmpty) return '';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────
//  FILTER SHEET
// ─────────────────────────────────────────────
class _HistoryFilterSheet extends StatelessWidget {
  final LocationController ctrl;
  const _HistoryFilterSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
          const Text('Filter History',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: _DatePickerBtn(
                label: 'From Date',
                date: ctrl.filterFromDate.value,
                onPick: (dt) => ctrl.filterFromDate.value = dt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePickerBtn(
                label: 'To Date',
                date: ctrl.filterToDate.value,
                onPick: (dt) => ctrl.filterToDate.value = dt,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ctrl.filterFromDate.value = null;
                  ctrl.filterToDate.value   = null;
                  ctrl.fetchHistory();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: const Text('Reset',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ctrl.fetchHistory();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
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
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppTheme.primary),
          ),
        ]),
      );
}

class _DatePickerBtn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DatePickerBtn(
      {required this.label,
      required this.date,
      required this.onPick});

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
                    fontSize: 12,
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