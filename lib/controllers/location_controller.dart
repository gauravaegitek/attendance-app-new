// lib/controllers/location_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/location_model.dart';
import '../services/storage_service.dart';

class LocationController extends GetxController {
  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // ── State ─────────────────────────────────────────────────────────────
  final todayEntries    = <LocationTrackingModel>[].obs;
  final historyEntries  = <LocationTrackingModel>[].obs;
  final allEntries      = <LocationTrackingModel>[].obs;
  final allTodayEntries = <LocationTrackingModel>[].obs;

  final isLoadingToday    = false.obs;
  final isLoadingHistory  = false.obs;
  final isLoadingAll      = false.obs;
  final isLoadingAllToday = false.obs;
  final isSubmitting      = false.obs;

  // Active tracking (current session)
  final activeTracking = Rx<LocationTrackingModel?>(null);

  // ── Filters ───────────────────────────────────────────────────────────
  final filterFromDate    = Rx<DateTime?>(null);
  final filterToDate      = Rx<DateTime?>(null);
  final filterUserId      = Rx<int?>(null);
  final filterClientVisit = Rx<bool?>(null);

  // ── Checkout form ─────────────────────────────────────────────────────
  final isClientVisit     = false.obs;
  final clientNameCtrl    = TextEditingController();
  final clientAddressCtrl = TextEditingController();
  final visitPurposeCtrl  = TextEditingController();
  final meetingNotesCtrl  = TextEditingController();
  final outcomeCtrl       = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTodayMy();
  }

  @override
  void onClose() {
    clientNameCtrl.dispose();
    clientAddressCtrl.dispose();
    visitPurposeCtrl.dispose();
    meetingNotesCtrl.dispose();
    outcomeCtrl.dispose();
    super.onClose();
  }

  // ── Helper: parse list ────────────────────────────────────────────────
  List<LocationTrackingModel> _parseList(dynamic data) {
    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data['data'] is List) {
      list = data['data'] as List;
    } else if (data['data'] is Map) {
      final obj = data['data'] as Map<String, dynamic>;
      list = (obj['entries'] ?? obj['data'] ?? obj['items'] ?? []) as List;
    }
    return list.map((e) => LocationTrackingModel.fromJson(e)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────
  //  USER: Check-in
  // ─────────────────────────────────────────────────────────────────────
  Future<bool> checkIn({required String workType}) async {
    isSubmitting.value = true;
    try {
      final pos = await _getLocation();
      if (pos == null) return false;

      final body = jsonEncode({
        'latitude':  pos.latitude,
        'longitude': pos.longitude,
        'address':   '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
        'workType':  workType,
      });

      debugPrint('checkIn body: $body');

      final response = await http
          .post(
            Uri.parse('$_base/Location/checkin'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('checkIn status: ${response.statusCode}');
      debugPrint('checkIn body  : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('Checked in successfully!');
        await fetchTodayMy();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _showSnack(
          (data['message'] ?? data['msg'] ?? 'Check-in failed').toString(),
          isError: true,
        );
        return false;
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  USER: Check-out
  // ─────────────────────────────────────────────────────────────────────
  Future<bool> checkOut(int trackingId) async {
    isSubmitting.value = true;
    try {
      final pos = await _getLocation();
      if (pos == null) return false;

      double? clientLat;
      double? clientLng;
      if (isClientVisit.value) {
        final clientPos = await _getLocation();
        clientLat = clientPos?.latitude;
        clientLng = clientPos?.longitude;
      }

      final body = jsonEncode({
        'trackingId':      trackingId,
        'latitude':        pos.latitude,
        'longitude':       pos.longitude,
        'address':         '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
        'isClientVisit':   isClientVisit.value,
        'clientName':      clientNameCtrl.text.trim(),
        'clientAddress':   clientAddressCtrl.text.trim(),
        'clientLatitude':  clientLat ?? 0,
        'clientLongitude': clientLng ?? 0,
        'visitPurpose':    visitPurposeCtrl.text.trim(),
        'meetingNotes':    meetingNotesCtrl.text.trim(),
        'outcome':         outcomeCtrl.text.trim(),
      });

      debugPrint('checkOut body: $body');

      final response = await http
          .put(
            Uri.parse('$_base/Location/checkout'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('checkOut status: ${response.statusCode}');
      debugPrint('checkOut body  : ${response.body}');

      if (response.statusCode == 200) {
        _showSnack('Checked out successfully!');
        _clearCheckoutForm();
        await fetchTodayMy();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _showSnack(
          (data['message'] ?? data['msg'] ?? 'Check-out failed').toString(),
          isError: true,
        );
        return false;
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  USER: Today's entries
  // ─────────────────────────────────────────────────────────────────────
  Future<void> fetchTodayMy() async {
    isLoadingToday.value = true;
    try {
      final response = await http
          .get(
            Uri.parse('$_base/Location/my/today'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('fetchTodayMy status: ${response.statusCode}');
      debugPrint('fetchTodayMy body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = _parseList(data);
        todayEntries.assignAll(entries);

        // Set active tracking (latest unchecked-out entry)
        activeTracking.value = entries
            .where((e) => !e.isCheckedOut)
            .isNotEmpty
            ? entries.firstWhere((e) => !e.isCheckedOut)
            : null;
      }
    } catch (e) {
      debugPrint('fetchTodayMy error: $e');
    } finally {
      isLoadingToday.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  USER: History
  // ─────────────────────────────────────────────────────────────────────
  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final params = <String, String>{};
      if (filterFromDate.value != null) {
        params['fromDate'] = DateFormat('yyyy-MM-dd').format(filterFromDate.value!);
      }
      if (filterToDate.value != null) {
        params['toDate'] = DateFormat('yyyy-MM-dd').format(filterToDate.value!);
      }

      final uri = Uri.parse('$_base/Location/my/history')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('fetchHistory URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('fetchHistory status: ${response.statusCode}');
      debugPrint('fetchHistory body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        historyEntries.assignAll(_parseList(data));
      }
    } catch (e) {
      debugPrint('fetchHistory error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ADMIN: All entries
  // ─────────────────────────────────────────────────────────────────────
  Future<void> fetchAll() async {
    isLoadingAll.value = true;
    try {
      final params = <String, String>{};
      if (filterUserId.value != null)
        params['userId'] = filterUserId.value.toString();
      if (filterFromDate.value != null)
        params['fromDate'] = DateFormat('yyyy-MM-dd').format(filterFromDate.value!);
      if (filterToDate.value != null)
        params['toDate'] = DateFormat('yyyy-MM-dd').format(filterToDate.value!);
      if (filterClientVisit.value != null)
        params['isClientVisit'] = filterClientVisit.value.toString();

      final uri = Uri.parse('$_base/Location/all')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      debugPrint('fetchAll URI: $uri');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('fetchAll status: ${response.statusCode}');
      debugPrint('fetchAll body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        allEntries.assignAll(_parseList(data));
      }
    } catch (e) {
      debugPrint('fetchAll error: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ADMIN: All today
  // ─────────────────────────────────────────────────────────────────────
  Future<void> fetchAllToday() async {
    isLoadingAllToday.value = true;
    try {
      final response = await http
          .get(
            Uri.parse('$_base/Location/all/today'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('fetchAllToday status: ${response.statusCode}');
      debugPrint('fetchAllToday body  : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        allTodayEntries.assignAll(_parseList(data));
      }
    } catch (e) {
      debugPrint('fetchAllToday error: $e');
    } finally {
      isLoadingAllToday.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────────────
  Future<Position?> _getLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnack('Location permission denied', isError: true);
          return null;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied', isError: true);
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _showSnack('Could not get location: $e', isError: true);
      return null;
    }
  }

  void _clearCheckoutForm() {
    isClientVisit.value = false;
    clientNameCtrl.clear();
    clientAddressCtrl.clear();
    visitPurposeCtrl.clear();
    meetingNotesCtrl.clear();
    outcomeCtrl.clear();
  }

  void _showSnack(String msg, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      msg,
      snackPosition:   SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFFEF4444)
          : const Color(0xFF22C55E),
      colorText:    const Color(0xFFFFFFFF),
      margin:       const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  void resetFilters() {
    filterFromDate.value    = null;
    filterToDate.value      = null;
    filterUserId.value      = null;
    filterClientVisit.value = null;
  }
}