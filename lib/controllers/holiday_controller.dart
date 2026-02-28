// lib/controllers/holiday_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/holiday_model.dart';
import '../services/api_service.dart';
import '../core/utils/response_handler.dart'; // ✅ centralized handler

class HolidayController extends GetxController {
  final RxList<HolidayModel> holidays = <HolidayModel>[].obs;
  final RxBool isLoading              = true.obs;
  final RxString errorMessage         = ''.obs;
  final RxString filter               = 'upcoming'.obs;

  // ─── FILTERED LIST ───────────────────────────────────────────────────────
  List<HolidayModel> get filtered {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
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

  // ─── LIFECYCLE ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchHolidays();
  }

  // ─── FETCH ───────────────────────────────────────────────────────────────
  Future<void> fetchHolidays() async {
    isLoading.value    = true;
    errorMessage.value = '';
    try {
      final list = await ApiService.getHolidays();
      holidays.value = list;
      holidays.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      debugPrint('fetchHolidays error: $e');
      // ✅ Actual exception message + friendly network fallback
      errorMessage.value = 'Unable to load holidays. Please try again.';
      ResponseHandler.handleException(
        e,
        context: 'fetchHolidays',
        fallback: 'Unable to load holidays. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
