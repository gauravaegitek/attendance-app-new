import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'storage_service.dart';
import 'activity_service.dart';

class DeviceSessionService extends GetxService {
  static DeviceSessionService get to => Get.find();

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 30);

  static String get _base => AppConstants.baseUrl + AppConstants.apiVersion;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${StorageService.getToken() ?? ''}',
      };

  // ─── START POLLING AFTER LOGIN ─────────────────────────────
  void startSessionPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkSession());
    debugPrint('[Session] Polling started — every ${_pollInterval.inSeconds}s');
  }

  // ─── STOP POLLING ON LOGOUT ────────────────────────────────
  void stopSessionPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('[Session] Polling stopped');
  }

  // ─── GENERATE STABLE DEVICE ID ─────────────────────────────
  Future<String> getDeviceId() async {
    String? stored = StorageService.getDeviceId();
    if (stored != null && stored.isNotEmpty) return stored;

    final info = DeviceInfoPlugin();
    String id;
    try {
      if (GetPlatform.isAndroid) {
        final d = await info.androidInfo;
        id = d.id;
      } else if (GetPlatform.isIOS) {
        final d = await info.iosInfo;
        id = d.identifierForVendor ?? DateTime.now().toString();
      } else {
        id = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (_) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await StorageService.saveDeviceId(id);
    return id;
  }

  // ─── REGISTER SESSION ON SERVER ────────────────────────────
  Future<bool> registerSession({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base/auth/session/register'),
            headers: _authHeaders,
            body: jsonEncode({
              'userId': userId,
              'deviceId': deviceId,
              'loginTime': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false; // Non-critical — do not block login
    }
  }

  // ─── VALIDATE CURRENT DEVICE SESSION ──────────────────────
  Future<bool> validateSession() async {
    try {
      final int userId       = StorageService.getUserId();
      final String? deviceId = StorageService.getDeviceId();
      final String? token    = StorageService.getToken();

      // ✅ Cache cleared or already logged out — stop polling, do not show session expired
      if (userId == 0 ||
          deviceId == null ||
          deviceId.isEmpty ||
          token == null ||
          token.isEmpty) {
        stopSessionPolling();
        return true;
      }

      final response = await http
          .post(
            Uri.parse('$_base/auth/session/validate'),
            headers: _authHeaders,
            body: jsonEncode({
              'userId': userId.toString(),
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));

      final data = jsonDecode(response.body);
      return data['success'] == true && data['data']?['valid'] == true;
    } catch (_) {
      // Network error — do not force logout, retry on next cycle
      return true;
    }
  }

  // ─── REMOVE SESSION (LOGOUT) ───────────────────────────────
  Future<void> removeSession(String userId) async {
    try {
      await http
          .post(
            Uri.parse('$_base/auth/session/remove'),
            headers: _authHeaders,
            body: jsonEncode({'userId': userId}),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectTimeout));
    } catch (_) {}
  }

  // ─── INTERNAL POLL ─────────────────────────────────────────
  // ✅ Polling only logs — session expired triggers only on API call
  Future<void> _checkSession() async {
    final valid = await validateSession();
    debugPrint('[Session] Poll — valid: $valid');
    // Do not navigate here — api_service._checkSession() handles it
  }
}
// ```

// **`api_service.dart`** same रहेगा — कोई change नहीं।

// ---

// ## Flow अब ऐसा है
// ```
// Admin clears device
//         ↓
// Poll चलता रहे — सिर्फ log करे ✅
//         ↓
// User कोई API hit करे (markIn / markOut / etc.)
//         ↓
// Backend → 401 या SESSION_EXPIRED
//         ↓
// api_service._checkSession() → /session-expired ✅