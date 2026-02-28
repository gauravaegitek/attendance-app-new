// lib/screens/performance/my_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/performance_controller.dart';
import '../../models/performance_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final _ctrl = Get.find<PerformanceController>();

  // "Search abhi nahi hua" state — user pehle filter set kare phir search kare
  final _hasSearched = false.obs;

  @override
  void initState() {
    super.initState();
    // Default: current month
    _ctrl.setDateRange(
      from: DateTime(DateTime.now().year, DateTime.now().month, 1),
      to:   DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ctrl.fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _ctrl.fromDate.value = picked;
      // toDate fromDate se pehle nahi honi chahiye
      if (_ctrl.toDate.value.isBefore(picked)) {
        _ctrl.toDate.value = picked;
      }
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ctrl.toDate.value,
      firstDate: _ctrl.fromDate.value,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _ctrl.toDate.value = picked;
    }
  }

  void _search() {
    _hasSearched.value = true;
    _ctrl.fetchMyReviews(
      fromDate: _ctrl.fromDate.value,
      toDate:   _ctrl.toDate.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Reviews'),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // =================== FILTER ===================
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'From',
                    obs:   _ctrl.fromDate,
                    onTap: _pickFromDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'To',
                    obs:   _ctrl.toDate,
                    onTap: _pickToDate,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                      onPressed: _ctrl.isLoadingMyReviews.value
                          ? null
                          : _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _ctrl.isLoadingMyReviews.value
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
              ],
            ),
          ),

          // =================== SUMMARY CARD ===================
          Obx(() {
            final reviews = _ctrl.myReviews;
            if (reviews.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews Summary',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: reviews.length.toString(),
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Avg Score',
                        value: _avgScore(reviews).toStringAsFixed(1),
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'High Score',
                        value: reviews
                            .where((r) =>
                                r.manualScore != null && r.manualScore! >= 80)
                            .length
                            .toString(),
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // =================== LIST ===================
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingMyReviews.value) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary));
              }

              // Search abhi tak nahi hua
              if (!_hasSearched.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_search_rounded,
                          size: 64, color: AppTheme.textHint),
                      SizedBox(height: 16),
                      Text('Search Reviews', style: AppTheme.headline3),
                      Text('Select date range, then tap 🔍',
                          style: AppTheme.bodySmall),
                    ],
                  ),
                );
              }

              if (_ctrl.errorMyReviews.value.isNotEmpty &&
                  _ctrl.myReviews.isEmpty) {
                return _ErrorView(
                  message: _ctrl.errorMyReviews.value,
                  onRetry: _search,
                );
              }

              if (_ctrl.myReviews.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 60, color: AppTheme.textHint),
                      SizedBox(height: 16),
                      Text('No reviews found', style: AppTheme.headline3),
                      SizedBox(height: 8),
                      Text('Try a different date range',
                          style: AppTheme.bodySmall),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _search(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ctrl.myReviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _MyReviewCard(review: _ctrl.myReviews[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _avgScore(List<ReviewModel> reviews) {
    final scores = reviews
        .where((r) => r.manualScore != null)
        .map((r) => r.manualScore!)
        .toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

// =================== DATE FIELD ===================
class _DateField extends StatelessWidget {
  final String label;
  final Rx<DateTime> obs;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.obs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
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
                const SizedBox(height: 2),
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
          GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// =================== STAT CHIP ===================
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =================== REVIEW CARD ===================
class _MyReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _MyReviewCard({required this.review});

  Color get _scoreColor {
    final s = review.manualScore ?? 0;
    if (s >= 90) return const Color(0xFF22C55E);
    if (s >= 75) return const Color(0xFF3B82F6);
    if (s >= 60) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  String get _monthLabel {
    try {
      return DateFormat('MMMM yyyy')
          .format(DateTime(review.year, review.month));
    } catch (_) {
      return '${review.month}/${review.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header: Month chip + Score badge ──────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 12, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        _monthLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Circular score badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _scoreColor.withOpacity(0.12),
                    border: Border.all(color: _scoreColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      review.manualScore?.toStringAsFixed(1) ?? '-',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: _scoreColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 12),

            // ── Comments ──────────────────────────────────────────────────
            if (review.comments != null && review.comments!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      size: 16, color: AppTheme.textHint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.comments!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ] else ...[
              const Text(
                'No comments provided.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textHint,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Footer: Reviewed by / at ──────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (review.reviewedBy != null) ...[
                    const Icon(Icons.verified_user_outlined,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'By ${review.reviewedBy}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (review.reviewedAt != null) ...[
                    const Icon(Icons.access_time,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(review.reviewedAt!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== ERROR VIEW ===================
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
                size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.error, fontFamily: 'Poppins')),
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