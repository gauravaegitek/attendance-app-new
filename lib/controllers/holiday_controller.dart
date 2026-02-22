// import 'package:get/get.dart';
// import '../models/holiday_model.dart';
// import '../services/api_service.dart';

// class HolidayController extends GetxController {
//   final RxList<HolidayModel> holidays = <HolidayModel>[].obs;
//   final RxBool isLoading = true.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString filter = 'upcoming'.obs;

//   List<HolidayModel> get filtered {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     switch (filter.value) {
//       case 'upcoming':
//         return holidays
//             .where((h) =>
//                 !DateTime(h.date.year, h.date.month, h.date.day)
//                     .isBefore(today))
//             .toList();
//       case 'past':
//         return holidays
//             .where((h) =>
//                 DateTime(h.date.year, h.date.month, h.date.day)
//                     .isBefore(today))
//             .toList()
//             .reversed
//             .toList();
//       default:
//         return holidays.toList();
//     }
//   }

//   int get totalCount => holidays.length;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchHolidays();
//   }

//   Future<void> fetchHolidays() async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       final list = await ApiService.getHolidays();
//       holidays.value = list;
//       holidays.sort((a, b) => a.date.compareTo(b.date));
//     } catch (e) {
//       errorMessage.value = 'Network error. Please try again.';
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }









import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/holiday_model.dart';
import '../services/api_service.dart';
import '../core/utils/app_utils.dart';

class HolidayController extends GetxController {
  final RxList<HolidayModel> holidays = <HolidayModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString filter = 'upcoming'.obs;

  // ✅ "Unable..." style error handler
  void _showUnableError(String context, dynamic e) {
    debugPrint('$context error: $e');

    final msg = e.toString();
    if (msg.contains('SocketException')) {
      AppUtils.showError('Unable to connect. Please check your internet and try again.');
      return;
    }
    if (msg.contains('TimeoutException')) {
      AppUtils.showError('Unable to complete request. Please try again.');
      return;
    }

    switch (context) {
      case 'fetchHolidays':
        AppUtils.showError('Unable to load holidays. Please try again.');
        break;
      default:
        AppUtils.showError('Unable to process request. Please try again.');
    }
  }

  List<HolidayModel> get filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filter.value) {
      case 'upcoming':
        return holidays
            .where((h) =>
                !DateTime(h.date.year, h.date.month, h.date.day)
                    .isBefore(today))
            .toList();
      case 'past':
        return holidays
            .where((h) =>
                DateTime(h.date.year, h.date.month, h.date.day)
                    .isBefore(today))
            .toList()
            .reversed
            .toList();
      default:
        return holidays.toList();
    }
  }

  int get totalCount => holidays.length;

  @override
  void onInit() {
    super.onInit();
    fetchHolidays();
  }

  Future<void> fetchHolidays() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await ApiService.getHolidays();
      holidays.value = list;
      holidays.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      // ✅ user-friendly "Unable..." message + log
      errorMessage.value = 'Unable to load holidays. Please try again.';
      _showUnableError('fetchHolidays', e);
    } finally {
      isLoading.value = false;
    }
  }
}