// lib/core/utils/response_handler.dart
//
// ✅ Centralized response handler — saare controllers yahan se snackbar dikhate hain
// ✅ Actual API message show hota hai (hardcoded nahi)
// ✅ Sab snackbars TOP pe dikhte hain (consistent)
// ✅ Network errors ke liye friendly fallback

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponseHandler {
  // ─── PRIVATE CONSTANTS ────────────────────────────────────────────────────
  static const _margin       = EdgeInsets.all(16);
  static const _borderRadius = 14.0;
  static const _duration     = Duration(seconds: 3);

  static const _colorSuccess = Color(0xFF22C55E);
  static const _colorError   = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorInfo    = Color(0xFF3B82F6);

  // ─── SUCCESS ──────────────────────────────────────────────────────────────
  /// API success response message show karta hai.
  /// [apiMessage] — response.message from API (prefer karo)
  /// [fallback]   — agar apiMessage empty ho to yeh dikhega
  static void showSuccess({
    required String apiMessage,
    String fallback = 'Done successfully.',
  }) {
    final msg = apiMessage.trim().isNotEmpty ? apiMessage.trim() : fallback;
    _show(
      title: 'Success',
      message: msg,
      color: _colorSuccess,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  // ─── ERROR ────────────────────────────────────────────────────────────────
  /// API error response message show karta hai.
  /// [apiMessage] — response.message from API (prefer karo)
  /// [context]    — which operation failed (for network error messages)
  /// [fallback]   — agar apiMessage empty ho to yeh dikhega
  static void showError({
    required String apiMessage,
    String context = '',
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final resolved = _resolveErrorMessage(
      apiMessage: apiMessage,
      context: context,
      fallback: fallback,
    );
    _show(
      title: 'Error',
      message: resolved,
      color: _colorError,
      icon: Icons.error_outline_rounded,
    );
  }

  // ─── WARNING ──────────────────────────────────────────────────────────────
  static void showWarning(String message) {
    _show(
      title: 'Warning',
      message: message,
      color: _colorWarning,
      icon: Icons.warning_amber_rounded,
    );
  }

  // ─── INFO ─────────────────────────────────────────────────────────────────
  static void showInfo(String message) {
    _show(
      title: 'Info',
      message: message,
      color: _colorInfo,
      icon: Icons.info_outline_rounded,
    );
  }

  // ─── HANDLE EXCEPTION ─────────────────────────────────────────────────────
  /// catch (e) block ke andar directly call karo.
  /// Network errors ko automatically friendly message mein convert karta hai.
  static void handleException(dynamic e, {String context = '', String fallback = ''}) {
    debugPrint('[$context] Exception: $e');
    final msg = _resolveErrorMessage(
      apiMessage: e.toString(),
      context: context,
      fallback: fallback.isNotEmpty ? fallback : 'Unable to process request. Please try again.',
    );
    _show(
      title: 'Error',
      message: msg,
      color: _colorError,
      icon: Icons.error_outline_rounded,
    );
  }

  // ─── PRIVATE: CORE SNACKBAR ───────────────────────────────────────────────
  static void _show({
    required String title,
    required String message,
    required Color  color,
    required IconData icon,
  }) {
    // Agar pehle se koi snackbar open hai to pehle band karo
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition:   SnackPosition.TOP,
      backgroundColor: color,
      colorText:       Colors.white,
      icon:            Icon(icon, color: Colors.white, size: 22),
      margin:          _margin,
      borderRadius:    _borderRadius,
      duration:        _duration,
      isDismissible:   true,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  // ─── PRIVATE: ERROR MESSAGE RESOLVER ─────────────────────────────────────
  /// Priority order:
  /// 1. Network errors → friendly "Unable to connect..." message
  /// 2. apiMessage non-empty → API ka actual message
  /// 3. fallback
  static String _resolveErrorMessage({
    required String apiMessage,
    required String context,
    required String fallback,
  }) {
    final raw = apiMessage.trim();

    // Network-level errors
    if (raw.contains('SocketException') ||
        raw.contains('Connection refused') ||
        raw.contains('Network is unreachable')) {
      return 'Unable to connect. Please check your internet and try again.';
    }
    if (raw.contains('TimeoutException') || raw.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }
    if (raw.contains('HandshakeException') ||
        raw.contains('CERTIFICATE_VERIFY_FAILED')) {
      return 'Secure connection failed. Please try again.';
    }

    // API ka actual message (non-empty, non-exception string)
    if (raw.isNotEmpty && !raw.startsWith('Exception:') && !raw.startsWith('type \'')) {
      return raw;
    }

    // Exception wrapper ke andar ka message nikalo
    final exMatch = RegExp(r"Exception:\s*(.+)$").firstMatch(raw);
    if (exMatch != null) {
      final inner = exMatch.group(1)?.trim() ?? '';
      if (inner.isNotEmpty) return inner;
    }

    return fallback;
  }
}
