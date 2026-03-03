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
  final int      id;
  final String   assetName;
  final String   assetType;
  final String?  assetCode;
  final String?  serialNumber;
  final String?  brand;
  final String?  model;
  final String?  description;
  final String   status;
  final String?  assignedToUserName;
  final int?     assignedToUserId;
  final DateTime?  assignedDate;
  final DateTime?  expectedReturnDate;
  final String?  assignmentNote;
  final DateTime?  returnedDate;
  final String?  returnNote;
  final String?  returnCondition;
  final DateTime createdOn;

  AssetModel({
    required this.id,
    required this.assetName,
    required this.assetType,
    this.assetCode,
    this.serialNumber,
    this.brand,
    this.model,
    this.description,
    required this.status,
    this.assignedToUserName,
    this.assignedToUserId,
    this.assignedDate,
    this.expectedReturnDate,
    this.assignmentNote,
    this.returnedDate,
    this.returnNote,
    this.returnCondition,
    required this.createdOn,
  });

  // ── Backward-compat getters so existing screens compile without changes ──
  // asset_admin_screen & asset_model_screen still use old names
  String? get assignedToName  => assignedToUserName;

  // Null-safe helpers used by screens that expect non-nullable String
  String get assetCodeSafe     => assetCode     ?? '';
  String get serialNumberSafe  => serialNumber  ?? '';
  String get brandSafe         => brand         ?? '';
  String get modelSafe         => model         ?? '';
  String get descriptionSafe   => description   ?? '';

  factory AssetModel.fromJson(Map<String, dynamic> j) => AssetModel(
        id:                 j['assetId']           ?? 0,
        assetName:          j['assetName']          ?? '',
        assetType:          j['assetType']          ?? '',
        assetCode:          j['assetCode'],
        serialNumber:       j['serialNumber'],
        brand:              j['brand'],
        model:              j['model'],
        description:        j['description'],
        status:             j['status']             ?? 'available',
        assignedToUserName: j['assignedToUserName'],
        assignedToUserId:   j['assignedToUserId'],
        assignedDate: j['assignedDate'] != null
            ? DateTime.tryParse(j['assignedDate'])
            : null,
        expectedReturnDate: j['expectedReturnDate'] != null
            ? DateTime.tryParse(j['expectedReturnDate'])
            : null,
        assignmentNote: j['assignmentNote'],
        returnedDate: j['returnedDate'] != null
            ? DateTime.tryParse(j['returnedDate'])
            : null,
        returnNote:      j['returnNote'],
        returnCondition: j['returnCondition'],
        createdOn: j['createdOn'] != null
            ? DateTime.tryParse(j['createdOn']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AssetHistoryModel {
  final int      historyId;
  final int      assetId;
  final String?  assetName;
  final String?  assetType;
  final int?     userId;
  final String?  userName;
  final String   action;
  final String?  note;
  final String?  condition;
  final DateTime actionDate;
  final String?  actionByUserName;

  AssetHistoryModel({
    required this.historyId,
    required this.assetId,
    this.assetName,
    this.assetType,
    this.userId,
    this.userName,
    required this.action,
    this.note,
    this.condition,
    required this.actionDate,
    this.actionByUserName,
  });

  // ── Backward-compat getters so existing screens compile without changes ──
  String? get targetUserName   => userName;
  String? get performedByName  => actionByUserName;
  DateTime get createdAt       => actionDate;

  // assetName is nullable but _HistoryCard passes it as non-nullable String
  String get assetNameSafe => assetName ?? '';

  factory AssetHistoryModel.fromJson(Map<String, dynamic> j) =>
      AssetHistoryModel(
        historyId:        j['historyId']        ?? 0,
        assetId:          j['assetId']           ?? 0,
        assetName:        j['assetName'],
        assetType:        j['assetType'],
        userId:           j['userId'],
        userName:         j['userName'],
        action:           j['action']            ?? '',
        note:             j['note'],
        condition:        j['condition'],
        actionDate: j['actionDate'] != null
            ? DateTime.tryParse(j['actionDate']) ?? DateTime.now()
            : DateTime.now(),
        actionByUserName: j['actionByUserName'],
      );
}

class AssetSummaryModel {
  final int    total;
  final int    available;
  final int    assigned;
  final int    underMaintenance;   // calculated: total - available - assigned
  final List<AssetTypeCount> byType;

  AssetSummaryModel({
    required this.total,
    required this.available,
    required this.assigned,
    required this.underMaintenance,
    required this.byType,
  });

  factory AssetSummaryModel.fromJson(Map<String, dynamic> j) {
    final total     = j['total']     ?? 0;
    final available = j['available'] ?? 0;
    final assigned  = j['assigned']  ?? 0;

    // Backend mein 'underMaintenance' field nahi hai
    // total - available - assigned = maintenance + retired assets
    final underMaintenance = (total - available - assigned).clamp(0, total);

    final byTypeList = (j['byType'] as List? ?? [])
        .map((e) => AssetTypeCount.fromJson(e))
        .toList();

    return AssetSummaryModel(
      total:            total,
      available:        available,
      assigned:         assigned,
      underMaintenance: underMaintenance,
      byType:           byTypeList,
    );
  }
}

class AssetTypeCount {
  final String assetType;
  final int    count;
  AssetTypeCount({required this.assetType, required this.count});
  factory AssetTypeCount.fromJson(Map<String, dynamic> j) => AssetTypeCount(
        assetType: j['assetType'] ?? '',
        count:     j['count']     ?? 0,
      );
}

class MaintenanceModel {
  final int      maintenanceId;
  final int      assetId;
  final String?  assetName;
  final String?  assetType;
  final String   maintenanceType;
  final String?  vendorName;
  final String?  ticketNo;
  final String?  issueDescription;
  final DateTime startDate;
  final DateTime? endDate;
  final String   status;
  final double?  cost;
  final String?  resolutionNote;

  MaintenanceModel({
    required this.maintenanceId,
    required this.assetId,
    this.assetName,
    this.assetType,
    required this.maintenanceType,
    this.vendorName,
    this.ticketNo,
    this.issueDescription,
    required this.startDate,
    this.endDate,
    required this.status,
    this.cost,
    this.resolutionNote,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> j) => MaintenanceModel(
        maintenanceId:    j['maintenanceId']   ?? j['assetId'] ?? 0,
        assetId:          j['assetId']          ?? 0,
        assetName:        j['assetName'],
        assetType:        j['assetType'],
        maintenanceType:  j['maintenanceType']  ?? '',
        vendorName:       j['vendorName'],
        ticketNo:         j['ticketNo'],
        issueDescription: j['issueDescription'],
        startDate: j['startDate'] != null
            ? DateTime.tryParse(j['startDate']) ?? DateTime.now()
            : DateTime.now(),
        endDate: j['endDate'] != null
            ? DateTime.tryParse(j['endDate'])
            : null,
        status:         j['status']         ?? 'open',
        cost:           (j['cost'] as num?)?.toDouble(),
        resolutionNote: j['resolutionNote'],
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
  final isLoading            = false.obs;
  final isHistoryLoading     = false.obs;
  final isSummaryLoading     = false.obs;
  final isMaintenanceLoading = false.obs;
  final isSubmitting         = false.obs;

  final assets      = <AssetModel>[].obs;
  final myAssets    = <AssetModel>[].obs;
  final history     = <AssetHistoryModel>[].obs;
  final maintenance = <MaintenanceModel>[].obs;
  final summary     = Rxn<AssetSummaryModel>();

  // ── Fetch: My Assets ─────────────────────────────────────────────────
  Future<void> fetchMyAssets(int userId) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_base${AppConstants.assetListEndpoint}')
          .replace(queryParameters: {'userId': userId.toString()});
      debugPrint('fetchMyAssets URI: $uri');
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchMyAssets status: ${res.statusCode}');
      debugPrint('fetchMyAssets body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? []) as List;
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
  Future<void> fetchAssets({
    String? status,
    String? assetType,
    int?    userId,
  }) async {
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
        final list = (data['data'] ?? []) as List;
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

  // ── Fetch: History ────────────────────────────────────────────────────
  Future<void> fetchHistory({
    int?    assetId,
    int?    userId,
    String? action,
    int     page     = 1,
    int     pageSize = 20,
  }) async {
    isHistoryLoading.value = true;
    try {
      final params = <String, String>{
        'page':     page.toString(),
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
        final data    = jsonDecode(res.body);
        final list    = (data['data'] ?? []) as List;
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

  // ── Fetch: Summary ────────────────────────────────────────────────────
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

  // ── Fetch: Maintenance List ───────────────────────────────────────────
  Future<void> fetchMaintenanceList({
    int?    assetId,
    String? status,
    int     page     = 1,
    int     pageSize = 20,
  }) async {
    isMaintenanceLoading.value = true;
    try {
      final params = <String, String>{
        'page':     page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (assetId != null) params['assetId'] = assetId.toString();
      if (status  != null) params['status']  = status;
      final uri = Uri.parse(
              '$_base${AppConstants.assetMaintenanceListEndpoint}')
          .replace(queryParameters: params);
      debugPrint('fetchMaintenanceList URI: $uri');
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('fetchMaintenanceList status: ${res.statusCode}');
      debugPrint('fetchMaintenanceList body  : ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] ?? []) as List;
        maintenance
            .assignAll(list.map((e) => MaintenanceModel.fromJson(e)));
      }
    } catch (e) {
      debugPrint('fetchMaintenanceList error: $e');
      ResponseHandler.showError(
          apiMessage: '', fallback: 'Failed to load maintenance list');
    } finally {
      isMaintenanceLoading.value = false;
    }
  }

  // ── Add Asset ─────────────────────────────────────────────────────────
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
          apiMessage: data['message'] ?? '',
          fallback: 'Failed to add asset');
      return false;
    } catch (e) {
      debugPrint('addAsset error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Assign Asset ──────────────────────────────────────────────────────
  Future<bool> assignAsset({
    required int      assetId,
    required int      assignedToUserId,
    DateTime?         expectedReturnDate,
    String?           assignmentNote,
  }) async {
    isSubmitting.value = true;
    try {
      final bodyMap = <String, dynamic>{
        'assetId':          assetId,
        'assignedToUserId': assignedToUserId,
      };
      if (expectedReturnDate != null) {
        bodyMap['expectedReturnDate'] =
            expectedReturnDate.toIso8601String();
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

  // ── Return Asset ──────────────────────────────────────────────────────
  Future<bool> returnAsset({
    required int    assetId,
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

  // ── Start Maintenance ─────────────────────────────────────────────────
  Future<bool> startMaintenance({
    required int    assetId,
    required String maintenanceType,
    String?         vendorName,
    String?         ticketNo,
    String?         issueDescription,
  }) async {
    isSubmitting.value = true;
    try {
      final body = jsonEncode({
        'assetId':         assetId,
        'maintenanceType': maintenanceType,
        if (vendorName       != null) 'vendorName':       vendorName,
        if (ticketNo         != null) 'ticketNo':         ticketNo,
        if (issueDescription != null) 'issueDescription': issueDescription,
      });
      debugPrint('startMaintenance body: $body');
      final res = await http
          .post(
            Uri.parse(
                '$_base${AppConstants.assetMaintenanceStartEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('startMaintenance status: ${res.statusCode}');
      debugPrint('startMaintenance body  : ${res.body}');
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        ResponseHandler.showSuccess(
            apiMessage: data['message'] ?? '',
            fallback: 'Maintenance started!');
        await fetchAssets();
        await fetchSummary();
        await fetchMaintenanceList();
        return true;
      }
      ResponseHandler.showError(
          apiMessage: data['message'] ?? '',
          fallback: 'Failed to start maintenance');
      return false;
    } catch (e) {
      debugPrint('startMaintenance error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Complete Maintenance ──────────────────────────────────────────────
  Future<bool> completeMaintenance({
    required int   assetId,
    double?        cost,
    String?        resolutionNote,
  }) async {
    isSubmitting.value = true;
    try {
      final body = jsonEncode({
        'assetId': assetId,
        if (cost           != null) 'cost':           cost,
        if (resolutionNote != null) 'resolutionNote': resolutionNote,
      });
      debugPrint('completeMaintenance body: $body');
      final res = await http
          .put(
            Uri.parse(
                '$_base${AppConstants.assetMaintenanceCompleteEndpoint}'),
            headers: _authHeaders,
            body: body,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
      debugPrint('completeMaintenance status: ${res.statusCode}');
      debugPrint('completeMaintenance body  : ${res.body}');
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        ResponseHandler.showSuccess(
            apiMessage: data['message'] ?? '',
            fallback: 'Maintenance completed!');
        await fetchAssets();
        await fetchSummary();
        await fetchMaintenanceList();
        return true;
      }
      ResponseHandler.showError(
          apiMessage: data['message'] ?? '',
          fallback: 'Failed to complete maintenance');
      return false;
    } catch (e) {
      debugPrint('completeMaintenance error: $e');
      ResponseHandler.showError(apiMessage: '', fallback: 'Error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}