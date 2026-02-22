// lib/screens/performance/reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/performance_controller.dart';
import '../../models/performance_model.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/month_year_picker.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _ctrl = Get.find<PerformanceController>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _ctrl.fetchReviews(
      month: _ctrl.selectedMonth.value,
      year:  _ctrl.selectedYear.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // ✅ FIXED
      appBar: AppBar(
        title: const Text('Performance Reviews'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Review',
            onPressed: () => _showReviewDialog(context),
          ),
        ],
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

          // ── Reviews List ─────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingReviews.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_ctrl.reviews.isEmpty) {
                return _EmptyView(
                  onAdd: () => _showReviewDialog(context),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ctrl.reviews.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ReviewCard(
                    review: _ctrl.reviews[i],
                    onEdit: () => _showReviewDialog(context,
                        existing: _ctrl.reviews[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewDialog(context),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Add Review',
            style: TextStyle(fontFamily: 'Poppins')),
      ),
    );
  }

  // ── Review Bottom Sheet Dialog ──────────────────────────────────────────────
  void _showReviewDialog(BuildContext context, {ReviewModel? existing}) {
    final formKey      = GlobalKey<FormState>();
    final userIdCtrl   = TextEditingController(
        text: existing?.userId.toString() ?? '');
    final scoreCtrl    = TextEditingController(
        text: existing?.manualScore?.toStringAsFixed(1) ?? '');
    final commentsCtrl =
        TextEditingController(text: existing?.comments ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  existing != null ? 'Edit Review' : 'Submit Review',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      'Month: ${_ctrl.selectedMonth.value} / ${_ctrl.selectedYear.value}',
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontFamily: 'Poppins'),
                    )),
                const SizedBox(height: 20),

                // ── Employee ID ──────────────────────────────────────────
                TextFormField(
                  controller: userIdCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: _inputDecoration(
                    label: 'Employee ID',
                    hint: 'Enter user ID',
                    icon: Icons.person_outline,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // ── Manual Score ─────────────────────────────────────────
                TextFormField(
                  controller: scoreCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: _inputDecoration(
                    label: 'Manual Score (0–100)',
                    hint: 'e.g. 85.5',
                    icon: Icons.score_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final val = double.tryParse(v);
                    if (val == null) return 'Enter a valid number';
                    if (val < 0 || val > 100)
                      return 'Score must be 0–100';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Comments ─────────────────────────────────────────────
                TextFormField(
                  controller: commentsCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    label: 'Comments',
                    hint: 'Optional feedback...',
                    icon: Icons.comment_outlined,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Submit Button ─────────────────────────────────────────
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _ctrl.isSubmittingReview.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate())
                                  return;

                                final request = ReviewRequestModel(
                                  userId: int.parse(userIdCtrl.text),
                                  month:  _ctrl.selectedMonth.value,
                                  year:   _ctrl.selectedYear.value,
                                  manualScore:
                                      double.parse(scoreCtrl.text),
                                  comments:
                                      commentsCtrl.text.trim(),
                                );

                                final success =
                                    await _ctrl.submitReview(request);
                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _ctrl.isSubmittingReview.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text(
                                'Submit Review',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins'),
                              ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;
  const _ReviewCard({required this.review, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.indigo.shade50,
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Poppins')),
                      Text('ID: ${review.userId}',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                // Score chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    review.manualScore?.toStringAsFixed(1) ?? '-',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.indigo.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            // Comments
            if (review.comments != null &&
                review.comments!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_outlined,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.comments!,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ],

            // Reviewed by / at
            if (review.reviewedBy != null ||
                review.reviewedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (review.reviewedBy != null) ...[
                    Icon(Icons.verified_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('By ${review.reviewedBy}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontFamily: 'Poppins')),
                    const SizedBox(width: 10),
                  ],
                  if (review.reviewedAt != null) ...[
                    Icon(Icons.access_time,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(review.reviewedAt!),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─── Empty ────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No reviews found for this month.',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add First Review',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}