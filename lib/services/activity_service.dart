// ============================================================
// lib/services/activity_service.dart
//
// SMART AUTO-LOGOUT ON INACTIVITY
// ────────────────────────────────
// • Tracks user interactions via ActivityDetector widget
// • Auto-logout after configurable idle duration (default 10 min)
// • Resets timer on any touch/tap/scroll/key event
// • Shows 60-second countdown warning dialog before logout
// • Timer only runs when user is logged in
//
// HOW TO USE:
// Wrap your home scaffold or navigator child with ActivityDetector:
//
//   ActivityDetector(child: HomeScreen())
//
// Or in GetMaterialApp:
//   builder: (context, child) => ActivityDetector(child: child!)
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class ActivityService extends GetxService {
  static ActivityService get to => Get.find();

  // ─── CONFIG ────────────────────────────────────────────────
  static const Duration _idleTimeout = Duration(minutes: 10);
  static const Duration _warningBefore = Duration(seconds: 60);
  static const Duration _warningCountdown = Duration(seconds: 60);

  Timer? _idleTimer;
  Timer? _countdownTimer;
  final _countdownSeconds = 60.obs;
  bool _warningShowing = false;
  bool _isActive = false;

  // ─── START (call after login) ──────────────────────────────
  void start() {
    _isActive = true;
    _resetTimer();
  }

  // ─── STOP (call after logout) ─────────────────────────────
  void stop() {
    _isActive = false;
    _idleTimer?.cancel();
    _countdownTimer?.cancel();
    _idleTimer = null;
    _countdownTimer = null;
    if (_warningShowing) {
      _warningShowing = false;
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  // ─── RECORD USER ACTIVITY ─────────────────────────────────
  void recordActivity() {
    if (!_isActive) return;

    // If warning is showing, dismiss and reset
    if (_warningShowing) {
      _warningShowing = false;
      _countdownTimer?.cancel();
      if (Get.isDialogOpen ?? false) Get.back();
    }
    _resetTimer();
  }

  // ─── RESET IDLE TIMER ─────────────────────────────────────
  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(
      _idleTimeout - _warningBefore,
      _showWarningDialog,
    );
  }

  // ─── SHOW 60-SECOND WARNING ───────────────────────────────
  void _showWarningDialog() {
    if (!_isActive) return;
    if (_warningShowing) return;
    _warningShowing = true;
    _countdownSeconds.value = _warningCountdown.inSeconds;

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _countdownSeconds.value--;
      if (_countdownSeconds.value <= 0) {
        t.cancel();
        _executeLogout();
      }
    });

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated countdown ring
                Obx(() => SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: _countdownSeconds.value /
                                  _warningCountdown.inSeconds,
                              strokeWidth: 5,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _countdownSeconds.value > 30
                                    ? const Color(0xFF1565C0)
                                    : Colors.red,
                              ),
                            ),
                          ),
                          Text(
                            '${_countdownSeconds.value}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: Color(0xFF0A1628),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                const Text(
                  'Still There?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: Color(0xFF0A1628),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You have been inactive for a while. You will be automatically logged out.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Stay Logged In button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _warningShowing = false;
                      _countdownTimer?.cancel();
                      if (Get.isDialogOpen ?? false) Get.back();
                      _resetTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "I'm Still Here",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Logout now button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _countdownTimer?.cancel();
                      _executeLogout();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Logout Now',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─── EXECUTE LOGOUT ───────────────────────────────────────
  Future<void> _executeLogout() async {
    _warningShowing = false;
    stop();
    if (Get.isDialogOpen ?? false) Get.back();
    await StorageService.clearAll();
    Get.offAllNamed('/login');
    Get.snackbar(
      'Auto Logout',
      'You were logged out due to inactivity.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0A1628),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}

// ============================================================
// ACTIVITY DETECTOR WIDGET
// Wrap your home content with this.
// Captures all pointer events → records user activity.
//
// Usage in main.dart / GetMaterialApp:
//   builder: (context, child) => ActivityDetector(child: child!)
// ============================================================

class ActivityDetector extends StatelessWidget {
  final Widget child;
  const ActivityDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _record(),
      onPointerMove: (_) => _record(),
      onPointerUp: (_) => _record(),
      child: child,
    );
  }

  void _record() {
    try {
      ActivityService.to.recordActivity();
    } catch (_) {
      // Service not yet initialized — ignore
    }
  }
}