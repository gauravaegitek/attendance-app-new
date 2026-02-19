import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/holiday_controller.dart';
import '../../models/holiday_model.dart';

class HolidayScreen extends StatelessWidget {
  const HolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HolidayController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(controller: controller),
            _FilterTabs(controller: controller),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2.5,
                    ),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorView(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchHolidays,
                  );
                }
                final list = controller.filtered;
                if (list.isEmpty) {
                  return _EmptyView(filter: controller.filter.value);
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: controller.fetchHolidays,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _HolidayTile(holiday: list[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final HolidayController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Holidays',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  ),
                ),
                Obx(() => Text(
                      '${DateFormat('yyyy').format(DateTime.now())} · ${controller.totalCount} holidays',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.beach_access_rounded,
                color: Color(0xFFFF9800), size: 22),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final HolidayController controller;
  const _FilterTabs({required this.controller});

  static const _tabs = [
    {'key': 'all', 'label': 'All'},
    {'key': 'upcoming', 'label': 'Upcoming'},
    {'key': 'past', 'label': 'Past'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: _tabs.map((tab) {
              final isActive = controller.filter.value == tab['key'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.filter.value = tab['key']!,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary
                          : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      tab['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color:
                            isActive ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

class _HolidayTile extends StatelessWidget {
  final HolidayModel holiday;
  const _HolidayTile({required this.holiday});

  bool get _isToday {
    final now = DateTime.now();
    return holiday.date.year == now.year &&
        holiday.date.month == now.month &&
        holiday.date.day == now.day;
  }

  bool get _isUpcoming {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return DateTime(holiday.date.year, holiday.date.month, holiday.date.day)
        .isAfter(today);
  }

  Color get _dotColor {
    if (_isToday) return const Color(0xFFFF9800);
    if (_isUpcoming) return const Color(0xFF4CAF50);
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _isToday
                    ? const Color(0xFFFFF3E0)
                    : _isUpcoming
                        ? AppTheme.primaryLight
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(holiday.date),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: _isToday
                          ? const Color(0xFFFF9800)
                          : _isUpcoming
                              ? AppTheme.primary
                              : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(holiday.date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: _isToday
                          ? const Color(0xFFFF9800)
                          : _isUpcoming
                              ? AppTheme.primary
                              : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          holiday.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: _isToday
                                ? const Color(0xFFFF9800)
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFF9800)
                                    .withOpacity(0.4)),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('EEEE').format(holiday.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (holiday.description != null &&
                          holiday.description!.isNotEmpty) ...[
                        const Text(' · ',
                            style: TextStyle(
                                color: AppTheme.textHint, fontSize: 12)),
                        Expanded(
                          child: Text(
                            holiday.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textHint,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: AppTheme.errorLight, shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppTheme.error, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry',
                  style: TextStyle(fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final msg = filter == 'upcoming'
        ? 'No upcoming holidays'
        : filter == 'past'
            ? 'No past holidays'
            : 'No holidays found';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.beach_access_rounded,
                color: Color(0xFFFF9800), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}