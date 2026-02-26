// lib/screens/location/my_location_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/location_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/location_model.dart';

class MyLocationScreen extends StatefulWidget {
  const MyLocationScreen({super.key});

  @override
  State<MyLocationScreen> createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends State<MyLocationScreen> {
  final ctrl = Get.find<LocationController>();
  String _selectedWorkType = 'Office';
  final _workTypes = ['Office', 'WFH', 'Field', 'Client Site'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        title: const Text(
          'My Location',
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
            icon: const Icon(Icons.history_rounded, color: AppTheme.primary),
            tooltip: 'View History',
            onPressed: () => Get.toNamed('/location-history'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: ctrl.fetchTodayMy,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Active session card ───────────────────────────────
                  _ActiveSessionCard(
                    ctrl: ctrl,
                    onCheckOut: () => _showCheckoutSheet(),
                  ),
                  const SizedBox(height: 20),

                  // ── Check-in card ─────────────────────────────────────
                  Obx(() {
                    final hasActive = ctrl.activeTracking.value != null;
                    if (hasActive) return const SizedBox.shrink();
                    return _CheckInCard(
                      selectedWorkType: _selectedWorkType,
                      workTypes: _workTypes,
                      onWorkTypeChanged: (v) =>
                          setState(() => _selectedWorkType = v!),
                      onCheckIn: () async {
                        await ctrl.checkIn(workType: _selectedWorkType);
                      },
                      ctrl: ctrl,
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Today's entries ───────────────────────────────────
                  const _SectionLabel("Today's Entries"),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (ctrl.isLoadingToday.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: AppTheme.primary),
                        ),
                      );
                    }
                    if (ctrl.todayEntries.isEmpty) {
                      return _EmptyState(
                        icon: Icons.location_off_rounded,
                        message: 'No check-ins today',
                        sub: 'Check in to start tracking your location',
                      );
                    }
                    return Column(
                      children: ctrl.todayEntries
                          .map((e) => _LocationEntryCard(entry: e))
                          .toList(),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(ctrl: ctrl),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTIVE SESSION CARD
// ─────────────────────────────────────────────
class _ActiveSessionCard extends StatelessWidget {
  final LocationController ctrl;
  final VoidCallback onCheckOut;
  const _ActiveSessionCard({required this.ctrl, required this.onCheckOut});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entry = ctrl.activeTracking.value;
      if (entry == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.success.withOpacity(0.9),
              const Color(0xFF059669),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.success.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Active Session',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text('Live',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            _InfoRow(
                icon: Icons.work_outline_rounded,
                label: entry.workType.isEmpty ? 'Office' : entry.workType),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.login_rounded,
                label: 'Checked in: ${_formatTime(entry.checkInTime)}'),
            const SizedBox(height: 6),
            _InfoRow(
                icon: Icons.pin_drop_rounded,
                label: entry.checkInAddress.isEmpty
                    ? '${entry.checkInLatitude.toStringAsFixed(4)}, '
                        '${entry.checkInLongitude.toStringAsFixed(4)}'
                    : entry.checkInAddress),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    icon: ctrl.isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: AppTheme.success, strokeWidth: 2))
                        : const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                        ctrl.isSubmitting.value ? 'Processing...' : 'Check Out',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed:
                        ctrl.isSubmitting.value ? null : onCheckOut,
                  )),
            ),
          ],
        ),
      );
    });
  }

  Widget _InfoRow({required IconData icon, required String label}) {
    return Row(children: [
      Icon(icon, color: Colors.white.withOpacity(0.8), size: 15),
      const SizedBox(width: 8),
      Expanded(
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Poppins')),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  CHECK-IN CARD
// ─────────────────────────────────────────────
class _CheckInCard extends StatelessWidget {
  final String selectedWorkType;
  final List<String> workTypes;
  final ValueChanged<String?> onWorkTypeChanged;
  final VoidCallback onCheckIn;
  final LocationController ctrl;

  const _CheckInCard({
    required this.selectedWorkType,
    required this.workTypes,
    required this.onWorkTypeChanged,
    required this.onCheckIn,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_location_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check In',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: AppTheme.textPrimary)),
                Text('Start your location session',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins')),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          const Text('Work Type',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: workTypes.map((type) {
              final selected = selectedWorkType == type;
              return GestureDetector(
                onTap: () => onWorkTypeChanged(type),
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
                  child: Text(type,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppTheme.primary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
                  icon: ctrl.isSubmitting.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.login_rounded,
                          color: Colors.white, size: 18),
                  label: Text(
                      ctrl.isSubmitting.value
                          ? 'Getting location...'
                          : 'Check In Now',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: ctrl.isSubmitting.value ? null : onCheckIn,
                )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CHECKOUT BOTTOM SHEET
// ─────────────────────────────────────────────
class _CheckoutSheet extends StatelessWidget {
  final LocationController ctrl;
  const _CheckoutSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final trackingId = ctrl.activeTracking.value?.trackingId ?? 0;

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
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppTheme.error, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check Out',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary)),
                  Text('End your location session',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins')),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // Client visit toggle
            Obx(() => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ctrl.isClientVisit.value
                        ? const Color(0xFF0D9488).withOpacity(0.08)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ctrl.isClientVisit.value
                          ? const Color(0xFF0D9488)
                          : AppTheme.divider,
                    ),
                  ),
                  child: Row(children: [
                    const Icon(Icons.business_center_rounded,
                        color: Color(0xFF0D9488), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client Visit',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textPrimary)),
                          Text('Was this a client visit?',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                    Switch(
                      value: ctrl.isClientVisit.value,
                      onChanged: (v) => ctrl.isClientVisit.value = v,
                      activeColor: const Color(0xFF0D9488),
                    ),
                  ]),
                )),
            const SizedBox(height: 14),

            // Client fields (conditional)
            Obx(() => ctrl.isClientVisit.value
                ? Column(
                    children: [
                      _InputField(
                          controller: ctrl.clientNameCtrl,
                          label: 'Client Name',
                          icon: Icons.person_outline_rounded),
                      const SizedBox(height: 10),
                      _InputField(
                          controller: ctrl.clientAddressCtrl,
                          label: 'Client Address',
                          icon: Icons.location_on_outlined),
                      const SizedBox(height: 10),
                      _InputField(
                          controller: ctrl.visitPurposeCtrl,
                          label: 'Visit Purpose',
                          icon: Icons.flag_outlined),
                      const SizedBox(height: 10),
                      _InputField(
                          controller: ctrl.meetingNotesCtrl,
                          label: 'Meeting Notes',
                          icon: Icons.notes_rounded,
                          maxLines: 3),
                      const SizedBox(height: 10),
                      _InputField(
                          controller: ctrl.outcomeCtrl,
                          label: 'Outcome',
                          icon: Icons.check_circle_outline),
                      const SizedBox(height: 14),
                    ],
                  )
                : const SizedBox.shrink()),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    icon: ctrl.isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.logout_rounded,
                            color: Colors.white, size: 18),
                    label: Text(
                        ctrl.isSubmitting.value
                            ? 'Processing...'
                            : 'Confirm Check Out',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: ctrl.isSubmitting.value
                        ? null
                        : () async {
                            final ok =
                                await ctrl.checkOut(trackingId);
                            if (ok) Get.back();
                          },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOCATION ENTRY CARD
// ─────────────────────────────────────────────
class _LocationEntryCard extends StatelessWidget {
  final LocationTrackingModel entry;
  const _LocationEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: entry.isCheckedOut
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                entry.isCheckedOut
                    ? Icons.check_circle_rounded
                    : Icons.adjust_rounded,
                color: entry.isCheckedOut
                    ? AppTheme.success
                    : AppTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.workType.isEmpty ? 'Office' : entry.workType,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: AppTheme.textPrimary)),
                  Text(_formatTime(entry.checkInTime),
                      style: AppTheme.caption),
                ],
              ),
            ),
            if (entry.totalHours != null && entry.totalHours!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          if (entry.checkOutTime != null && entry.checkOutTime!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.logout_rounded,
                    size: 13, color: AppTheme.textHint),
                const SizedBox(width: 6),
                Text('Checked out: ${_formatTime(entry.checkOutTime!)}',
                    style: AppTheme.caption),
              ]),
            ),
          if (entry.isClientVisit) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.business_center_rounded,
                    size: 12, color: Color(0xFF0D9488)),
                const SizedBox(width: 4),
                Text(
                    entry.clientName != null
                        ? 'Client: ${entry.clientName}'
                        : 'Client Visit',
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488))),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.labelBold);
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.cardDecoration(),
        child: Column(children: [
          Icon(icon, color: AppTheme.textHint, size: 44),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(sub,
              textAlign: TextAlign.center,
              style: AppTheme.caption),
        ]),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppTheme.textSecondary),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      );
}

String _formatTime(String raw) {
  if (raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('hh:mm a').format(dt);
  } catch (_) {
    return raw;
  }
}