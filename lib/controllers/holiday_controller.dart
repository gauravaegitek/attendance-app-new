import 'package:get/get.dart';
import '../models/holiday_model.dart';
import '../services/api_service.dart';

class HolidayController extends GetxController {
  final RxList<HolidayModel> holidays = <HolidayModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString filter = 'upcoming'.obs;

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
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}