// lib/controllers/asset_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/utils/response_handler.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class AssetModel {
  final int id;
  final String assetName;
  final String assetType;
  final String assetCode;
  final String serialNumber;
  final String brand;
  final String model;
  final String description;
  final String status;
  final String? assignedToName;
  final int? assignedToUserId;
  final DateTime? expectedReturnDate;
  final String? assignmentNote;

  AssetModel({
    required this.id,
    required this.assetName,
    required this.assetType,
    required this.assetCode,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.description,
    required this.status,
    this.assignedToName,
    this.assignedToUserId,
    this.expectedReturnDate,
    this.assignmentNote,
  });

  factory AssetModel.fromJson(Map<String, dynamic> j) => AssetModel(
        id: j['id'] ?? 0,
        assetName: j['assetName'] ?? '',
        assetType: j['assetType'] ?? '',
        assetCode: j['assetCode'] ?? '',
        serialNumber: j['serialNumber'] ?? '',
        brand: j['brand'] ?? '',
        model: j['model'] ?? '',
        description: j['description'] ?? '',
        status: j['status'] ?? 'Available',
        assignedToName: j['assignedToName'],
        assignedToUserId: j['assignedToUserId'],
        expectedReturnDate: j['expectedReturnDate'] != null
            ? DateTime.tryParse(j['expectedReturnDate'])
            : null,
        assignmentNote: j['assignmentNote'],
      );
}

class AssetHistoryModel {
  final int id;
  final int assetId;
  final String assetName;
  final String action;
  final String? performedByName;
  final String? targetUserName;
  final String? note;
  final DateTime createdAt;

  AssetHistoryModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.action,
    this.performedByName,
    this.targetUserName,
    this.note,
    required this.createdAt,
  });

  factory AssetHistoryModel.fromJson(Map<String, dynamic> j) =>
      AssetHistoryModel(
        id: j['id'] ?? 0,
        assetId: j['assetId'] ?? 0,
        assetName: j['assetName'] ?? '',
        action: j['action'] ?? '',
        performedByName: j['performedByName'],
        targetUserName: j['targetUserName'],
        note: j['note'],
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AssetSummaryModel {
  final int total;
  final int available;
  final int assigned;
  final int underMaintenance;

  AssetSummaryModel({
    required this.total,
    required this.available,
    required this.assigned,
    required this.underMaintenance,
  });

  factory AssetSummaryModel.fromJson(Map<String, dynamic> j) =>
      AssetSummaryModel(
        total: j['total'] ?? 0,
        available: j['available'] ?? 0,
        assigned: j['assigned'] ?? 0,
        underMaintenance: j['underMaintenance'] ?? 0,
      );
}

// ─────────────────────────────────────────────
//  CONTROLLER
// ─────────────────────────────────────────────
class AssetController extends GetxController {
  static String get _base =>
      AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${StorageService.getToken()}',
      };

  // ── Observable State ──────────────────────────────────────────────────
  final isLoading        = false.obs;
  final isHistoryLoading = false.obs;
  final isSummaryLoading = false.obs;
  final isSubmitting     = false.obs;

  final assets   = <AssetModel>[].obs;
  final myAssets = <AssetModel>[].obs;
  final history  = <AssetHistoryModel>[].obs;
  final summary  = Rxn<AssetSummaryModel>();

  // ── Fetch: My Assets (User + Admin personal view) ─────────────────────
  Future<void> fetchMyAssets(int userId) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_base${AppConstants.assetListEndpoint}')
          .replace(queryParameters: {
        'userId': userId.toString(),
        'status': 'Assigned',
      });
      debugPrint('fetchMyAssets URI: $uri');
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchMyAssets status: ${res.statusCode}');
      debugPrint('fetchMyAssets body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? data) as List;
        myAssets.assignAll(list.map((e) => AssetModel.fromJson(e)));
      }
    } catch (e) {
      debugPrint('fetchMyAssets error: $e');
      ResponseHandler.showError(
          apiMessage: '', fallback: 'Failed to load your assets');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fetch: All Assets (Admin) ─────────────────────────────────────────
  Future<void> fetchAssets({String? status, String? assetType, int? userId}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (status    != null) params['status']    = status;
      if (assetType != null) params['assetType'] = assetType;
      if (userId    != null) params['userId']    = userId.toString();
      final uri = Uri.parse('$_base${AppConstants.assetListEndpoint}')
          .replace(queryParameters: params.isNotEmpty ? params : null);
      debugPrint('fetchAssets URI: $uri');
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchAssets status: ${res.statusCode}');
      debugPrint('fetchAssets body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? data) as List;
        assets.assignAll(list.map((e) => AssetModel.fromJson(e)));
      }
    } catch (e) {
      debugPrint('fetchAssets error: $e');
      ResponseHandler.showError(
          apiMessage: '', fallback: 'Failed to load assets');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Fetch: History (Admin) ────────────────────────────────────────────
  Future<void> fetchHistory({
    int? assetId,
    int? userId,
    String? action,
    int page = 1,
    int pageSize = 20,
  }) async {
    isHistoryLoading.value = true;
    try {
      final params = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (assetId != null) params['assetId'] = assetId.toString();
      if (userId  != null) params['userId']  = userId.toString();
      if (action  != null) params['action']  = action;
      final uri = Uri.parse('$_base${AppConstants.assetHistoryEndpoint}')
          .replace(queryParameters: params);
      debugPrint('fetchHistory URI: $uri');
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchHistory status: ${res.statusCode}');
      debugPrint('fetchHistory body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? data) as List;
        final fetched = list.map((e) => AssetHistoryModel.fromJson(e)).toList();
        if (page == 1) {
          history.assignAll(fetched);
        } else {
          history.addAll(fetched);
        }
      }
    } catch (e) {
      debugPrint('fetchHistory error: $e');
      ResponseHandler.showError(
          apiMessage: '', fallback: 'Failed to load history');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  // ── Fetch: Summary (Admin) ────────────────────────────────────────────
  Future<void> fetchSummary() async {
    isSummaryLoading.value = true;
    try {
      final res = await http
          .get(
            Uri.parse('$_base${AppConstants.assetSummaryEndpoint}'),
            headers: _authHeaders,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchSummary status: ${res.statusCode}');
      debugPrint('fetchSummary body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        summary.value = AssetSummaryModel.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      debugPrint('fetchSummary error: $e');
      ResponseHandler.showError(
          apiMessage: '', fallback: 'Failed to load summary');
    } finally {
      isSummaryLoading.value = false;
    }
  }

  // ── Add Asset (Admin) ─────────────────────────────────────────────────
  Future<bool> addAsset({
    required String assetName,
    required String assetType,
    required String assetCode,
    required String serialNumber,
    required String brand,
    required String model,
    required String description,
  }) async {
    isSubmitting.value = true;
    try {
      final body = jsonEncode({
        'assetName':    assetName,
        'assetType':    assetType,
        'assetCode':    assetCode,
        'serialNumber': serialNumber,
        'brand':        brand,
        'model':        model,
        'description':  description,
      });
      debugPrint('addAsset body: $body');
      final res = await http
          .post(
            Uri.parse('$_base${AppConstants.assetAddEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('addAsset status: ${res.statusCode}');
      debugPrint('addAsset body  : ${res.body}');
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ResponseHandler.showSuccess(
            apiMessage: data['message'] ?? '', fallback: 'Asset added!');
        await fetchAssets();
        await fetchSummary();
        return true;
      }
      ResponseHandler.showError(
          apiMessage: data['message'] ?? '', fallback: 'Failed to add asset');
      return false;
    } catch (e) {
      debugPrint('addAsset error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Assign Asset (Admin) ──────────────────────────────────────────────
  Future<bool> assignAsset({
    required int assetId,
    required int assignedToUserId,
    DateTime? expectedReturnDate,
    String? assignmentNote,
  }) async {
    isSubmitting.value = true;
    try {
      final bodyMap = <String, dynamic>{
        'assetId':          assetId,
        'assignedToUserId': assignedToUserId,
      };
      if (expectedReturnDate != null) {
        bodyMap['expectedReturnDate'] = expectedReturnDate.toIso8601String();
      }
      if (assignmentNote != null && assignmentNote.isNotEmpty) {
        bodyMap['assignmentNote'] = assignmentNote;
      }
      debugPrint('assignAsset body: ${jsonEncode(bodyMap)}');
      final res = await http
          .post(
            Uri.parse('$_base${AppConstants.assetAssignEndpoint}'),
            headers: _authHeaders,
            body: jsonEncode(bodyMap),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('assignAsset status: ${res.statusCode}');
      debugPrint('assignAsset body  : ${res.body}');
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        ResponseHandler.showSuccess(
            apiMessage: data['message'] ?? '', fallback: 'Asset assigned!');
        await fetchAssets();
        await fetchSummary();
        return true;
      }
      ResponseHandler.showError(
          apiMessage: data['message'] ?? '', fallback: 'Failed to assign');
      return false;
    } catch (e) {
      debugPrint('assignAsset error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Return Asset (Admin) ──────────────────────────────────────────────
  Future<bool> returnAsset({
    required int assetId,
    required String returnNote,
    required String returnCondition,
  }) async {
    isSubmitting.value = true;
    try {
      final body = jsonEncode({
        'assetId':         assetId,
        'returnNote':      returnNote,
        'returnCondition': returnCondition,
      });
      debugPrint('returnAsset body: $body');
      final res = await http
          .put(
            Uri.parse('$_base${AppConstants.assetReturnEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('returnAsset status: ${res.statusCode}');
      debugPrint('returnAsset body  : ${res.body}');
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        ResponseHandler.showSuccess(
            apiMessage: data['message'] ?? '', fallback: 'Asset returned!');
        await fetchAssets();
        await fetchSummary();
        return true;
      }
      ResponseHandler.showError(
          apiMessage: data['message'] ?? '', fallback: 'Failed to return');
      return false;
    } catch (e) {
      debugPrint('returnAsset error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
