// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'storage_service.dart';

// class ActivityService extends GetxService {
//   static ActivityService get to => Get.find();

//   // ─── CONFIG ────────────────────────────────────────────────
//   static const Duration _idleTimeout = Duration(minutes: 10);
//   static const Duration _warningBefore = Duration(seconds: 60);
//   static const Duration _warningCountdown = Duration(seconds: 60);

//   Timer? _idleTimer;
//   Timer? _countdownTimer;
//   final _countdownSeconds = 60.obs;
//   bool _warningShowing = false;
//   bool _isActive = false;

//   // ─── START (call after login) ──────────────────────────────
//   void start() {
//     _isActive = true;
//     _resetTimer();
//   }

//   // ─── STOP (call after logout) ─────────────────────────────
//   void stop() {
//     _isActive = false;
//     _idleTimer?.cancel();
//     _countdownTimer?.cancel();
//     _idleTimer = null;
//     _countdownTimer = null;
//     if (_warningShowing) {
//       _warningShowing = false;
//       if (Get.isDialogOpen ?? false) Get.back();
//     }
//   }

//   // ─── RECORD USER ACTIVITY ─────────────────────────────────
//   void recordActivity() {
//     if (!_isActive) return;

//     // If warning is showing, dismiss and reset
//     if (_warningShowing) {
//       _warningShowing = false;
//       _countdownTimer?.cancel();
//       if (Get.isDialogOpen ?? false) Get.back();
//     }
//     _resetTimer();
//   }

//   // ─── RESET IDLE TIMER ─────────────────────────────────────
//   void _resetTimer() {
//     _idleTimer?.cancel();
//     _idleTimer = Timer(
//       _idleTimeout - _warningBefore,
//       _showWarningDialog,
//     );
//   }

//   // ─── SHOW 60-SECOND WARNING ───────────────────────────────
//   void _showWarningDialog() {
//     if (!_isActive) return;
//     if (_warningShowing) return;
//     _warningShowing = true;
//     _countdownSeconds.value = _warningCountdown.inSeconds;

//     // Start countdown
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       _countdownSeconds.value--;
//       if (_countdownSeconds.value <= 0) {
//         t.cancel();
//         _executeLogout();
//       }
//     });

//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           backgroundColor: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Animated countdown ring
//                 Obx(() => SizedBox(
//                       width: 80,
//                       height: 80,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 80,
//                             height: 80,
//                             child: CircularProgressIndicator(
//                               value: _countdownSeconds.value /
//                                   _warningCountdown.inSeconds,
//                               strokeWidth: 5,
//                               backgroundColor: Colors.grey[200],
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 _countdownSeconds.value > 30
//                                     ? const Color(0xFF1565C0)
//                                     : Colors.red,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '${_countdownSeconds.value}',
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: Color(0xFF0A1628),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//                 const SizedBox(height: 20),

//                 const Text(
//                   'Still There?',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF0A1628),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'You have been inactive for a while. You will be automatically logged out.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[500],
//                     fontFamily: 'Poppins',
//                     height: 1.6,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Stay Logged In button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _warningShowing = false;
//                       _countdownTimer?.cancel();
//                       if (Get.isDialogOpen ?? false) Get.back();
//                       _resetTimer();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1565C0),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text(
//                       "I'm Still Here",
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // Logout now button
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       _countdownTimer?.cancel();
//                       _executeLogout();
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: BorderSide(color: Colors.grey[300]!),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: Text(
//                       'Logout Now',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // ─── EXECUTE LOGOUT ───────────────────────────────────────
//   Future<void> _executeLogout() async {
//     _warningShowing = false;
//     stop();
//     if (Get.isDialogOpen ?? false) Get.back();
//     await StorageService.clearAll();
//     Get.offAllNamed('/login');
//     Get.snackbar(
//       'Auto Logout',
//       'You were logged out due to inactivity.',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: const Color(0xFF0A1628),
//       colorText: Colors.white,
//       borderRadius: 12,
//       margin: const EdgeInsets.all(16),
//       icon: const Icon(Icons.logout_rounded, color: Colors.white),
//       duration: const Duration(seconds: 4),
//     );
//   }
// }

// // ============================================================
// // ACTIVITY DETECTOR WIDGET
// // Wrap your home content with this.
// // Captures all pointer events → records user activity.
// //
// // Usage in main.dart / GetMaterialApp:
// //   builder: (context, child) => ActivityDetector(child: child!)
// // ============================================================

// class ActivityDetector extends StatelessWidget {
//   final Widget child;
//   const ActivityDetector({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       behavior: HitTestBehavior.translucent,
//       onPointerDown: (_) => _record(),
//       onPointerMove: (_) => _record(),
//       onPointerUp: (_) => _record(),
//       child: child,
//     );
//   }

//   void _record() {
//     try {
//       ActivityService.to.recordActivity();
//     } catch (_) {
//       // Service not yet initialized — ignore
//     }
//   }
// }







// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'storage_service.dart';

// class ActivityService extends GetxService {
//   static ActivityService get to => Get.find();

//   // ─── CONFIG ─────────────────────────────────────────────────
//   static const Duration _idleTimeout      = Duration(minutes: 10);
//   static const Duration _warningBefore    = Duration(seconds: 60);
//   static const Duration _warningCountdown = Duration(seconds: 60);

//   // ─── STATE ──────────────────────────────────────────────────
//   Timer? _idleTimer;
//   Timer? _countdownTimer;
//   final _countdownSeconds = 60.obs;
//   bool _warningShowing = false;
//   bool _isActive = false;

//   // ─── START (login ke baad call karo) ────────────────────────
//   void start() {
//     _isActive = true;
//     _resetTimer();
//     debugPrint('[Activity] Started — timeout: ${_idleTimeout.inMinutes}min');
//   }

//   // ─── STOP (manual logout pe call karo) ──────────────────────
//   void stop() {
//     _isActive = false;
//     _idleTimer?.cancel();
//     _countdownTimer?.cancel();
//     _idleTimer = null;
//     _countdownTimer = null;
//     if (_warningShowing) {
//       _warningShowing = false;
//       _safeCloseDialog();
//     }
//     debugPrint('[Activity] Stopped');
//   }

//   // ─── USER ACTIVITY RECORD ───────────────────────────────────
//   void recordActivity() {
//     if (!_isActive) return;
//     if (_warningShowing) {
//       _warningShowing = false;
//       _countdownTimer?.cancel();
//       _safeCloseDialog();
//     }
//     _resetTimer();
//   }

//   // ─── RESET IDLE TIMER ───────────────────────────────────────
//   void _resetTimer() {
//     _idleTimer?.cancel();
//     _idleTimer = Timer(
//       _idleTimeout - _warningBefore,
//       _showWarningDialog,
//     );
//   }

//   // ─── SAFE DIALOG CLOSE ──────────────────────────────────────
//   void _safeCloseDialog() {
//     try {
//       if (Get.isDialogOpen ?? false) Get.back();
//     } catch (_) {}
//   }

//   // ─── WARNING DIALOG ─────────────────────────────────────────
//   void _showWarningDialog() {
//     if (!_isActive) return;
//     if (_warningShowing) return;

//     // Login/Splash pe mat dikhao
//     final route = Get.currentRoute;
//     if (route == '/login' || route == '/splash' || route == '/') return;

//     _warningShowing = true;
//     _countdownSeconds.value = _warningCountdown.inSeconds;

//     // Countdown start
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       _countdownSeconds.value--;
//       if (_countdownSeconds.value <= 0) {
//         t.cancel();
//         _executeLogout();
//       }
//     });

//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(28),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // ── Animated Countdown Ring ──────────────────
//                 Obx(() => SizedBox(
//                       width: 88,
//                       height: 88,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 88,
//                             height: 88,
//                             child: CircularProgressIndicator(
//                               value: _countdownSeconds.value /
//                                   _warningCountdown.inSeconds,
//                               strokeWidth: 5,
//                               backgroundColor: Colors.grey[200],
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 _countdownSeconds.value > 30
//                                     ? const Color(0xFF1565C0)
//                                     : Colors.red,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '${_countdownSeconds.value}',
//                             style: const TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.w700,
//                               fontFamily: 'Poppins',
//                               color: Color(0xFF0A1628),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//                 const SizedBox(height: 20),

//                 // ── Title ────────────────────────────────────
//                 const Text(
//                   'Still There?',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: Color(0xFF0A1628),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 Text(
//                   'You have been inactive for a while.\nYou will be automatically logged out.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[500],
//                     fontFamily: 'Poppins',
//                     height: 1.6,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // ── Stay Logged In Button ────────────────────
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _warningShowing = false;
//                       _countdownTimer?.cancel();
//                       _safeCloseDialog();
//                       _resetTimer();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1565C0),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "I'm Still Here",
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // ── Logout Now Button ────────────────────────
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       _countdownTimer?.cancel();
//                       _executeLogout();
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: BorderSide(color: Colors.grey[300]!),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       'Logout Now',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // ─── EXECUTE AUTO LOGOUT ─────────────────────────────────────
//   // NOTE: AuthController ko import nahi karenge — circular dependency hoga.
//   //       (AuthController already ActivityService import karta hai)
//   //       Isliye: storage clear karo + navigate karo.
//   //       AuthController ka state reset next login pe hoga — safe hai.
//   Future<void> _executeLogout() async {
//     debugPrint('[Activity] Auto-logout triggered');

//     // 1. Timers cancel
//     _warningShowing = false;
//     _isActive = false;
//     _idleTimer?.cancel();
//     _countdownTimer?.cancel();
//     _idleTimer = null;
//     _countdownTimer = null;

//     // 2. Dialog band karo + thoda wait
//     _safeCloseDialog();
//     await Future.delayed(const Duration(milliseconds: 200));

//     // 3. Storage clear
//     await StorageService.clearAll();

//     // 4. ✅ Login screen pe navigate karo
//     Get.offAllNamed('/login');

//     // 5. Snackbar — navigate ke baad
//     await Future.delayed(const Duration(milliseconds: 300));
//     Get.snackbar(
//       'Session Expired',
//       'You were logged out due to inactivity.',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: const Color(0xFF0A1628),
//       colorText: Colors.white,
//       borderRadius: 12,
//       margin: const EdgeInsets.all(16),
//       icon: const Icon(Icons.logout_rounded, color: Colors.white),
//       duration: const Duration(seconds: 4),
//     );
//   }

//   @override
//   void onClose() {
//     stop();
//     super.onClose();
//   }
// }

// // ============================================================
// // ACTIVITY DETECTOR WIDGET
// // main.dart builder mein already hai:
// //   builder: (context, child) => ActivityDetector(child: child!)
// // ============================================================
// class ActivityDetector extends StatelessWidget {
//   final Widget child;
//   const ActivityDetector({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       behavior: HitTestBehavior.translucent,
//       onPointerDown: (_) => _record(),
//       onPointerMove: (_) => _record(),
//       onPointerUp: (_) => _record(),
//       child: child,
//     );
//   }

//   void _record() {
//     try {
//       ActivityService.to.recordActivity();
//     } catch (_) {
//       // Service not yet initialized — ignore
//     }
//   }
// }











import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/response_handler.dart';
import 'storage_service.dart';

class ActivityService extends GetxService with WidgetsBindingObserver {
  static ActivityService get to => Get.find();

  // ─── CONFIG ─────────────────────────────────────────────────
  static const Duration idleTimeout = Duration(minutes: 10);
  static const Duration warningBefore = Duration(seconds: 60);
  static const Duration warningCountdown = Duration(seconds: 60);

  // ─── STATE ──────────────────────────────────────────────────
  Timer? _idleTimer;
  Timer? _countdownTimer;
  final countdownSeconds = warningCountdown.inSeconds.obs;

  bool _warningShowing = false;
  bool _isActive = false;
  bool _loggingOut = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  // ─── START (login success ke baad call) ─────────────────────
  void start() {
    _loggingOut = false;
    _isActive = true;
    _warningShowing = false;
    _resetTimer();
    debugPrint('[Activity] Started');
  }

  // ─── STOP (logout / app close / force logout) ───────────────
  void stop() {
    _isActive = false;
    _idleTimer?.cancel();
    _countdownTimer?.cancel();
    _idleTimer = null;
    _countdownTimer = null;

    if (_warningShowing) {
      _warningShowing = false;
      _safeCloseDialog();
    }

    debugPrint('[Activity] Stopped');
  }

  // ─── RECORD ACTIVITY (tap/scroll/typing etc.) ────────────────
  void recordActivity() {
    if (!_isActive) return;
    if (_loggingOut) return;

    // if warning dialog open, close it and continue session
    if (_warningShowing) {
      _warningShowing = false;
      _countdownTimer?.cancel();
      _safeCloseDialog();
    }

    _resetTimer();
  }

  // ─── RESET IDLE TIMER ───────────────────────────────────────
  void _resetTimer() {
    if (!_isActive || _loggingOut) return;

    _idleTimer?.cancel();

    final delay =
        idleTimeout > warningBefore ? (idleTimeout - warningBefore) : Duration.zero;

    _idleTimer = Timer(delay, _showWarningDialog);
  }

  // ─── SAFE DIALOG CLOSE ──────────────────────────────────────
  void _safeCloseDialog() {
    try {
      if (Get.isDialogOpen ?? false) Get.back();
    } catch (_) {}
  }

  // ─── WARNING DIALOG ─────────────────────────────────────────
  void _showWarningDialog() {
    if (!_isActive || _loggingOut) return;
    if (_warningShowing) return;

    // login/splash pe mat dikhao
    final route = Get.currentRoute;
    if (route == '/login' || route == '/splash' || route == '/') return;

    _warningShowing = true;
    countdownSeconds.value = warningCountdown.inSeconds;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!_isActive || _loggingOut) {
        t.cancel();
        return;
      }

      countdownSeconds.value--;
      if (countdownSeconds.value <= 0) {
        t.cancel();
        await _executeLogout(reason: 'inactivity');
      }
    });

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => SizedBox(
                      width: 88,
                      height: 88,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: countdownSeconds.value / warningCountdown.inSeconds,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey[200],
                          ),
                          Text(
                            '${countdownSeconds.value}',
                            style: const TextStyle(
                              fontSize: 26,
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
                  'You have been inactive for a while.\nYou will be automatically logged out.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ stay logged in
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_loggingOut) return;
                      _warningShowing = false;
                      _countdownTimer?.cancel();
                      _safeCloseDialog();
                      _resetTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

                // ✅ logout now
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      _countdownTimer?.cancel();
                      await _executeLogout(reason: 'manual');
                    },
                    child: const Text('Logout Now'),
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

  // ─── EXECUTE LOGOUT ──────────────────────────────────────────
  Future<void> _executeLogout({required String reason}) async {
    if (_loggingOut) return;
    _loggingOut = true;

    debugPrint('[Activity] Logout triggered: $reason');

    // stop timers & close dialog
    stop();
    await Future.delayed(const Duration(milliseconds: 200));

    // clear storage + navigate
    await StorageService.clearAll();
    Get.offAllNamed('/login');

    await Future.delayed(const Duration(milliseconds: 300));
    ResponseHandler.showInfo(
      'You were logged out due to inactivity.',
    );
  }

  // ─── IMPORTANT: Background / Resume handling ────────────────
  // ✅ Jab app background me jaye to timer pause (taaki false logout na ho)
  // ✅ Jab resume ho, activity record + timer restart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isActive) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // pause timers while in background
      _idleTimer?.cancel();
      _countdownTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // resume -> consider as activity
      recordActivity();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stop();
    super.onClose();
  }
}

// ============================================================
// ACTIVITY DETECTOR (wrap whole app in main.dart builder)
// ============================================================
class ActivityDetector extends StatelessWidget {
  final Widget child;
  const ActivityDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _record();
        return false;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _record(),
        onPointerMove: (_) => _record(),
        onPointerUp: (_) => _record(),
        child: child,
      ),
    );
  }

  void _record() {
    try {
      ActivityService.to.recordActivity();
    } catch (_) {}
  }
}