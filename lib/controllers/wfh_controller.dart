// lib/controllers/wfh_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/wfh_model.dart';
import '../services/storage_service.dart';
import '../core/utils/response_handler.dart';

class WfhController extends GetxController {
  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  Map<String, String> get _authHeaders => {
        'Content-Type':  'application/json',
        'Accept':        'application/json',
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // =================== STATE ===================
  final RxList<WfhModel> myRequests  = <WfhModel>[].obs;
  final RxList<WfhModel> allRequests = <WfhModel>[].obs;
  final RxBool isLoading             = false.obs;
  final RxString statusFilter        = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  // =================== EMPLOYEE ===================

  Future<void> loadMyRequests({String status = 'all'}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_base${AppConstants.wfhMyRequestsEndpoint}')
          .replace(queryParameters: {'status': status});

      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('WFH myRequests: ${res.statusCode} | ${res.body}');

      final data   = jsonDecode(res.body);
      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data['success'] == true && data['data'] != null) {
        list = data['data'] as List;
      }

      myRequests.value = list.map((e) => WfhModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadMyRequests error: $e');
      ResponseHandler.handleException(
        e,
        context: 'loadMyRequests',
        fallback: 'Unable to load WFH requests. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestWFH({
    required String wfhDate,
    required String reason,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base${AppConstants.wfhRequestEndpoint}'),
            headers: _authHeaders,
            body:    jsonEncode({'wfhDate': wfhDate, 'reason': reason}),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('WFH request: ${res.statusCode} | ${res.body}');

      final data = jsonDecode(res.body);
      final ok   = res.statusCode == 200 && data['success'] == true;

      if (ok) {
        final apiMsg = (data['message'] ?? '').toString();
        ResponseHandler.showSuccess(
          apiMessage: apiMsg,
          fallback:   'WFH request submitted successfully!',
        );
        loadMyRequests();
      } else {
        final apiMsg = (data['message'] ?? '').toString();
        ResponseHandler.showError(
          apiMessage: apiMsg,
          fallback:   'Unable to submit WFH request. Please try again.',
        );
      }
      return ok;
    } catch (e) {
      debugPrint('requestWFH error: $e');
      ResponseHandler.handleException(
        e,
        context: 'requestWFH',
        fallback: 'Unable to submit WFH request. Please try again.',
      );
      return false;
    }
  }

  // =================== ADMIN/MANAGER ===================

  Future<void> loadAllRequests({
    String status = 'all',
    int?   month,
    int?   year,
  }) async {
    isLoading.value = true;
    try {
      final params = <String, String>{'status': status};
      if (month != null) params['month'] = month.toString();
      if (year  != null) params['year']  = year.toString();

      final uri = Uri.parse('$_base${AppConstants.wfhAllEndpoint}')
          .replace(queryParameters: params);

      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('WFH all: ${res.statusCode} | ${res.body}');

      final data        = jsonDecode(res.body);
      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data['success'] == true && data['data'] != null) {
        list = data['data'] as List;
      }

      allRequests.value = list.map((e) => WfhModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadAllRequests error: $e');
      ResponseHandler.handleException(
        e,
        context: 'loadAllRequests',
        fallback: 'Unable to load WFH requests. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveWFH({
    required int    wfhId,
    required String action, // 'Approved' or 'Rejected'
    String?         rejectionReason,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base${AppConstants.wfhApproveEndpoint}'),
            headers: _authHeaders,
            body: jsonEncode({
              'wfhId':           wfhId,
              'action':          action,
              'rejectionReason': rejectionReason ?? '',
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      debugPrint('WFH approve: ${res.statusCode} | ${res.body}');

      final data = jsonDecode(res.body);
      final ok   = res.statusCode == 200 && data['success'] == true;

      if (ok) {
        final apiMsg = (data['message'] ?? '').toString();
        ResponseHandler.showSuccess(
          apiMessage: apiMsg,
          fallback:   'WFH request $action successfully!',
        );
        loadAllRequests(status: statusFilter.value);
      } else {
        final apiMsg = (data['message'] ?? '').toString();
        ResponseHandler.showError(
          apiMessage: apiMsg,
          fallback:   'Unable to process WFH request. Please try again.',
        );
      }
      return ok;
    } catch (e) {
      debugPrint('approveWFH error: $e');
      ResponseHandler.handleException(
        e,
        context: 'approveWFH',
        fallback: 'Unable to process WFH request. Please try again.',
      );
      return false;
    }
  }
}
