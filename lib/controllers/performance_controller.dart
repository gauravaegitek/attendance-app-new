// // lib/controllers/performance_controller.dart

// import 'package:get/get.dart';
// import '../models/performance_model.dart';
// import '../services/performance_api_service.dart';
// import '../core/utils/response_handler.dart';

// class PerformanceController extends GetxController {
//   // ─── Loading ───────────────────────────────────────────────────────────────
//   final isLoadingScore       = false.obs;
//   final isLoadingRanking     = false.obs;
//   final isLoadingReviews     = false.obs;
//   final isSubmittingReview   = false.obs;
//   final isLoadingRoles       = false.obs;
//   final isLoadingMyReviews   = false.obs;

//   // ─── Data ──────────────────────────────────────────────────────────────────
//   final employeeScore = Rxn<EmployeeScoreModel>();
//   final rankings      = <RankingModel>[].obs;
//   final reviews       = <ReviewModel>[].obs;
//   final myReviews     = <ReviewModel>[].obs;

//   final rolesList = <String>[].obs;

//   // ─── Filter state ──────────────────────────────────────────────────────────
//   final selectedMonth = DateTime.now().month.obs;
//   final selectedYear  = DateTime.now().year.obs;
//   final selectedDept  = ''.obs;

//   final fromDate = Rx<DateTime>(
//     DateTime(DateTime.now().year, DateTime.now().month, 1),
//   );
//   final toDate = Rx<DateTime>(
//     DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
//   );

//   // ─── Error ─────────────────────────────────────────────────────────────────
//   final errorScore     = ''.obs;
//   final errorRanking   = ''.obs;
//   final errorReviews   = ''.obs;
//   final errorMyReviews = ''.obs;

//   // ===========================================================================

//   void setDateRange({required DateTime from, required DateTime to}) {
//     fromDate.value = from;
//     toDate.value   = to;
//   }

//   Future<void> fetchMyReviews({
//     required DateTime fromDate,
//     required DateTime toDate,
//   }) async {
//     isLoadingMyReviews.value = true;
//     errorMyReviews.value     = '';
//     myReviews.clear();

//     try {
//       final months = <({int month, int year})>[];
//       var cursor   = DateTime(fromDate.year, fromDate.month, 1);
//       final end    = DateTime(toDate.year, toDate.month, 1);

//       while (!cursor.isAfter(end)) {
//         months.add((month: cursor.month, year: cursor.year));
//         cursor = DateTime(cursor.year, cursor.month + 1, 1);
//       }

//       final results = await Future.wait<List<ReviewModel>>(
//         months.map(
//           (m) => PerformanceApiService.getMyReviews(
//             month: m.month,
//             year:  m.year,
//           ),
//         ),
//       );

//       final combined = results.expand<ReviewModel>((r) => r).toList()
//         ..sort((a, b) {
//           final cmpYear = b.year.compareTo(a.year);
//           if (cmpYear != 0) return cmpYear;
//           return b.month.compareTo(a.month);
//         });

//       myReviews.assignAll(combined);

//       if (combined.isEmpty) {
//         errorMyReviews.value = 'No reviews found for selected period.';
//       }
//     } catch (e) {
//       errorMyReviews.value = 'Unable to load reviews. Please try again.';
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchMyReviews',
//         fallback: 'Unable to load reviews. Please try again.',
//       );
//     } finally {
//       isLoadingMyReviews.value = false;
//     }
//   }

//   Future<void> fetchRoles() async {
//     if (rolesList.isNotEmpty) return;
//     isLoadingRoles.value = true;
//     try {
//       final result = await PerformanceApiService.getRoles();
//       rolesList.value = result;
//     } catch (_) {
//       // silent
//     } finally {
//       isLoadingRoles.value = false;
//     }
//   }

//   Future<void> fetchEmployeeScore({
//     required int month,
//     required int year,
//     required int userId,
//   }) async {
//     isLoadingScore.value = true;
//     errorScore.value     = '';
//     try {
//       final result = await PerformanceApiService.getEmployeeScore(
//         month:  month,
//         year:   year,
//         userId: userId,
//       );
//       employeeScore.value = result;
//       if (result == null) errorScore.value = 'No score data found.';
//     } catch (e) {
//       errorScore.value = 'Unable to load score. Please try again.';
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchEmployeeScore',
//         fallback: 'Unable to load score. Please try again.',
//       );
//     } finally {
//       isLoadingScore.value = false;
//     }
//   }

//   Future<void> fetchRanking({
//     required int month,
//     required int year,
//     String?      department,
//   }) async {
//     isLoadingRanking.value = true;
//     errorRanking.value     = '';
//     try {
//       final result = await PerformanceApiService.getRanking(
//         month:      month,
//         year:       year,
//         department: department ?? selectedDept.value,
//       );
//       rankings.value = result;
//       if (result.isEmpty) errorRanking.value = 'No ranking data found.';
//     } catch (e) {
//       errorRanking.value = 'Unable to load rankings. Please try again.';
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchRanking',
//         fallback: 'Unable to load rankings. Please try again.',
//       );
//     } finally {
//       isLoadingRanking.value = false;
//     }
//   }

//   Future<void> fetchReviews({
//     required int month,
//     required int year,
//   }) async {
//     isLoadingReviews.value = true;
//     errorReviews.value     = '';
//     try {
//       final result = await PerformanceApiService.getReviews(
//         month: month,
//         year:  year,
//       );
//       reviews.value = result;
//     } catch (e) {
//       errorReviews.value = 'Unable to load reviews. Please try again.';
//       ResponseHandler.handleException(
//         e,
//         context: 'fetchReviews',
//         fallback: 'Unable to load reviews. Please try again.',
//       );
//     } finally {
//       isLoadingReviews.value = false;
//     }
//   }

//   // ─── Submit Review (Admin) ─────────────────────────────────────────────────
//   Future<bool> submitReview(ReviewRequestModel request) async {
//     isSubmittingReview.value = true;
//     try {
//       final res = await PerformanceApiService.submitReview(request);

//       if (res.success) {
//         ResponseHandler.showSuccess(
//           apiMessage: res.message,
//           fallback:   'Saved successfully.',
//         );
//         await fetchReviews(month: request.month, year: request.year);
//         return true;
//       } else {
//         ResponseHandler.showError(
//           apiMessage: res.message,
//           fallback:   'Unable to submit review. Please try again.',
//         );
//         return false;
//       }
//     } catch (e) {
//       ResponseHandler.handleException(
//         e,
//         context: 'submitReview',
//         fallback: 'Unable to submit review. Please try again.',
//       );
//       return false;
//     } finally {
//       isSubmittingReview.value = false;
//     }
//   }

//   // ─── Helpers ──────────────────────────────────────────────────────────────
//   void setMonthYear(int month, int year) {
//     selectedMonth.value = month;
//     selectedYear.value  = year;
//   }

//   void updateDepartment(String dept) {
//     selectedDept.value = dept;
//   }

//   RankingModel? rankOf(int userId) =>
//       rankings.firstWhereOrNull((r) => r.userId == userId);

//   ReviewModel? reviewOf(int userId) =>
//       reviews.firstWhereOrNull((r) => r.userId == userId);
// }












// lib/controllers/performance_controller.dart

import 'package:get/get.dart';
import '../models/performance_model.dart';
import '../services/performance_api_service.dart';
import '../core/utils/response_handler.dart';

class PerformanceController extends GetxController {
  // ─── Loading ───────────────────────────────────────────────────────────────
  final isLoadingScore     = false.obs;
  final isLoadingRanking   = false.obs;
  final isLoadingReviews   = false.obs;
  final isSubmittingReview = false.obs;
  final isLoadingRoles     = false.obs;
  final isLoadingMyReviews = false.obs;

  // ─── Data ──────────────────────────────────────────────────────────────────
  final employeeScore = Rxn<EmployeeScoreModel>();
  final rankings      = <RankingModel>[].obs;
  final reviews       = <ReviewModel>[].obs;
  final myReviews     = <ReviewModel>[].obs;
  final rolesList     = <String>[].obs;

  // ─── Filter state ──────────────────────────────────────────────────────────
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear  = DateTime.now().year.obs;
  final selectedDept  = ''.obs;

  final fromDate = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month, 1),
  );
  final toDate = Rx<DateTime>(
    DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  // ─── Error ─────────────────────────────────────────────────────────────────
  final errorScore     = ''.obs;
  final errorRanking   = ''.obs;
  final errorReviews   = ''.obs;
  final errorMyReviews = ''.obs;

  // ===========================================================================

  void setDateRange({required DateTime from, required DateTime to}) {
    fromDate.value = from;
    toDate.value   = to;
  }

  Future<void> fetchMyReviews({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    isLoadingMyReviews.value = true;
    errorMyReviews.value     = '';
    myReviews.clear();

    try {
      final months = <({int month, int year})>[];
      var cursor   = DateTime(fromDate.year, fromDate.month, 1);
      final end    = DateTime(toDate.year, toDate.month, 1);

      while (!cursor.isAfter(end)) {
        months.add((month: cursor.month, year: cursor.year));
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }

      final results = await Future.wait<List<ReviewModel>>(
        months.map(
          (m) => PerformanceApiService.getMyReviews(
            month: m.month,
            year:  m.year,
          ),
        ),
      );

      final combined = results.expand<ReviewModel>((r) => r).toList()
        ..sort((a, b) {
          final cmpYear = b.year.compareTo(a.year);
          if (cmpYear != 0) return cmpYear;
          return b.month.compareTo(a.month);
        });

      myReviews.assignAll(combined);
      if (combined.isEmpty) {
        errorMyReviews.value = 'No reviews found for selected period.';
      }
    } catch (e) {
      errorMyReviews.value = 'Unable to load reviews. Please try again.';
      ResponseHandler.handleException(
        e,
        context: 'fetchMyReviews',
        fallback: 'Unable to load reviews. Please try again.',
      );
    } finally {
      isLoadingMyReviews.value = false;
    }
  }

  Future<void> fetchRoles() async {
    if (rolesList.isNotEmpty) return;
    isLoadingRoles.value = true;
    try {
      final result = await PerformanceApiService.getRoles();
      rolesList.value = result;
    } catch (_) {
      // silent
    } finally {
      isLoadingRoles.value = false;
    }
  }

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
      errorScore.value = 'Unable to load score. Please try again.';
      ResponseHandler.handleException(
        e,
        context: 'fetchEmployeeScore',
        fallback: 'Unable to load score. Please try again.',
      );
    } finally {
      isLoadingScore.value = false;
    }
  }

  Future<void> fetchRanking({
    required int month,
    required int year,
    String?      department,
  }) async {
    isLoadingRanking.value = true;
    errorRanking.value     = '';
    rankings.clear();
    try {
      // ✅ Service ab properly nested structure handle karta hai
      final result = await PerformanceApiService.getRanking(
        month:      month,
        year:       year,
        department: department ?? selectedDept.value,
      );
      rankings.value = result;
      if (result.isEmpty) errorRanking.value = 'No ranking data found.';
    } catch (e) {
      errorRanking.value = 'Unable to load rankings. Please try again.';
      ResponseHandler.handleException(
        e,
        context: 'fetchRanking',
        fallback: 'Unable to load rankings. Please try again.',
      );
    } finally {
      isLoadingRanking.value = false;
    }
  }

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
      errorReviews.value = 'Unable to load reviews. Please try again.';
      ResponseHandler.handleException(
        e,
        context: 'fetchReviews',
        fallback: 'Unable to load reviews. Please try again.',
      );
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // ─── Submit Review (Admin) ─────────────────────────────────────────────────
  Future<bool> submitReview(ReviewRequestModel request) async {
    isSubmittingReview.value = true;
    try {
      final res = await PerformanceApiService.submitReview(request);
      if (res.success) {
        ResponseHandler.showSuccess(
          apiMessage: res.message,
          fallback:   'Saved successfully.',
        );
        await fetchReviews(month: request.month, year: request.year);
        return true;
      } else {
        ResponseHandler.showError(
          apiMessage: res.message,
          fallback:   'Unable to submit review. Please try again.',
        );
        return false;
      }
    } catch (e) {
      ResponseHandler.handleException(
        e,
        context: 'submitReview',
        fallback: 'Unable to submit review. Please try again.',
      );
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
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