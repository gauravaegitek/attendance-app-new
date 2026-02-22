// lib/controllers/performance_controller.dart

import 'package:get/get.dart';

import '../models/performance_model.dart';
import '../services/performance_api_service.dart';

class PerformanceController extends GetxController {
  // ─── Loading ───────────────────────────────────────────────────────────────
  final isLoadingScore     = false.obs;
  final isLoadingRanking   = false.obs;
  final isLoadingReviews   = false.obs;
  final isSubmittingReview = false.obs;
  final isLoadingRoles     = false.obs;

  // ─── Data ──────────────────────────────────────────────────────────────────
  final employeeScore = Rxn<EmployeeScoreModel>();
  final rankings      = <RankingModel>[].obs;
  final reviews       = <ReviewModel>[].obs;

  // ✅ Roles from /api/Role — department filter ke liye
  final rolesList = <String>[].obs;

  // ─── Filter state ──────────────────────────────────────────────────────────
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear  = DateTime.now().year.obs;
  final selectedDept  = ''.obs;

  // ─── Error ─────────────────────────────────────────────────────────────────
  final errorScore   = ''.obs;
  final errorRanking = ''.obs;
  final errorReviews = ''.obs;

  // ===========================================================================
  // Fetch: Roles from /api/Role
  // ===========================================================================
  Future<void> fetchRoles() async {
    if (rolesList.isNotEmpty) return; // already loaded
    isLoadingRoles.value = true;
    try {
      final result = await PerformanceApiService.getRoles();
      rolesList.value = result;
    } catch (e) {
      // silent fail — chips nahi dikhenge
    } finally {
      isLoadingRoles.value = false;
    }
  }

  // ===========================================================================
  // Fetch: Employee Score
  // ===========================================================================
  Future<void> fetchEmployeeScore({
    required int month,
    required int year,
    required int userId,
  }) async {
    isLoadingScore.value = true;
    errorScore.value     = '';
    try {
      final result = await PerformanceApiService.getEmployeeScore(
        month:  month,
        year:   year,
        userId: userId,
      );
      employeeScore.value = result;
      if (result == null) errorScore.value = 'No score data found.';
    } catch (e) {
      errorScore.value = 'Failed to load score: $e';
    } finally {
      isLoadingScore.value = false;
    }
  }

  // ===========================================================================
  // Fetch: Rankings
  // ===========================================================================
  Future<void> fetchRanking({
    required int month,
    required int year,
    String? department,
  }) async {
    isLoadingRanking.value = true;
    errorRanking.value     = '';
    try {
      final result = await PerformanceApiService.getRanking(
        month:      month,
        year:       year,
        department: department ?? selectedDept.value,
      );
      rankings.value = result;
      if (result.isEmpty) errorRanking.value = 'No ranking data found.';
    } catch (e) {
      errorRanking.value = 'Failed to load rankings: $e';
    } finally {
      isLoadingRanking.value = false;
    }
  }

  // ===========================================================================
  // Fetch: Reviews
  // ===========================================================================
  Future<void> fetchReviews({
    required int month,
    required int year,
  }) async {
    isLoadingReviews.value = true;
    errorReviews.value     = '';
    try {
      final result = await PerformanceApiService.getReviews(
        month: month,
        year:  year,
      );
      reviews.value = result;
    } catch (e) {
      errorReviews.value = 'Failed to load reviews: $e';
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // ===========================================================================
  // Submit: Review (Admin only)
  // ===========================================================================
  Future<bool> submitReview(ReviewRequestModel request) async {
    isSubmittingReview.value = true;
    try {
      final success = await PerformanceApiService.submitReview(request);
      if (success) {
        Get.snackbar(
          'Success',
          'Review submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchReviews(month: request.month, year: request.year);
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit review. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  void setMonthYear(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value  = year;
  }

  void updateDepartment(String dept) {
    selectedDept.value = dept;
  }

  RankingModel? rankOf(int userId) =>
      rankings.firstWhereOrNull((r) => r.userId == userId);

  ReviewModel? reviewOf(int userId) =>
      reviews.firstWhereOrNull((r) => r.userId == userId);
}