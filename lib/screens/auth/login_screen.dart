// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// // ══════════════════════════════════════════════════════════════════════════════
// //  NEON ORBITAL ATTENDANCE LOGIN
// //  — Completely new design language: neon glow + orbital rings + waveform
// // ══════════════════════════════════════════════════════════════════════════════
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
//   late final AnimationController _formCtrl;
//   late final AnimationController _orbitCtrl;
//   late final AnimationController _waveCtrl;
//   late final AnimationController _glowCtrl;
//   late final AnimationController _radarCtrl;
//   late final AnimationController _progressCtrl;
//   late final AnimationController _floatCtrl;

//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset>  _slideAnim;
//   late final Animation<double>  _progressAnim;

//   final _rng = Random(13);

//   @override
//   void initState() {
//     super.initState();

//     _formCtrl = AnimationController(vsync: this, duration: 1100.ms)..forward();
//     _fadeAnim  = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));

//     _orbitCtrl    = AnimationController(vsync: this, duration: 8000.ms)..repeat();
//     _waveCtrl     = AnimationController(vsync: this, duration: 2400.ms)..repeat();
//     _glowCtrl     = AnimationController(vsync: this, duration: 2800.ms)..repeat(reverse: true);
//     _radarCtrl    = AnimationController(vsync: this, duration: 3000.ms)..repeat();
//     _floatCtrl    = AnimationController(vsync: this, duration: 3400.ms)..repeat(reverse: true);

//     _progressCtrl = AnimationController(vsync: this, duration: 2200.ms);
//     _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic);
//     Future.delayed(600.ms, () { if (mounted) _progressCtrl.forward(); });
//   }

//   @override
//   void dispose() {
//     for (final c in [_formCtrl, _orbitCtrl, _waveCtrl, _glowCtrl,
//       _radarCtrl, _progressCtrl, _floatCtrl]) c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<AuthController>();
//     final size = MediaQuery.of(context).size;
//     final bgH  = size.height * 0.58;

//     return Scaffold(
//       backgroundColor: const Color(0xFF050B14),
//       body: Stack(children: [

//         // ── Base gradient ──────────────────────────────────────────
//         Positioned.fill(
//           child: DecoratedBox(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter, end: Alignment.bottomCenter,
//                 colors: [Color(0xFF070F1C), Color(0xFF050B14), Color(0xFF0A0600)],
//                 stops: [0.0, 0.6, 1.0],
//               ),
//             ),
//           ),
//         ),

//         // ── Radar sweep + orbital rings + fingerprint ──────────────
//         Positioned(top: 0, left: 0, right: 0, height: bgH,
//           child: AnimatedBuilder(
//             animation: Listenable.merge(
//                 [_orbitCtrl, _radarCtrl, _glowCtrl, _progressAnim]),
//             builder: (_, __) => CustomPaint(
//               painter: _OrbitalPainter(
//                 primary:      AppTheme.primary,
//                 orbitT:       _orbitCtrl.value,
//                 radarT:       _radarCtrl.value,
//                 glowT:        _glowCtrl.value,
//                 progressT:    _progressAnim.value,
//                 size:         Size(size.width, bgH),
//               ),
//             ),
//           ),
//         ),

//         // ── Animated waveform strip ────────────────────────────────
//         Positioned(
//           top: bgH * 0.74, left: 0, right: 0, height: 56,
//           child: AnimatedBuilder(
//             animation: _waveCtrl,
//             builder: (_, __) => CustomPaint(
//               painter: _WavePainter(t: _waveCtrl.value, primary: AppTheme.primary),
//             ),
//           ),
//         ),

//         // ── Bottom fade ────────────────────────────────────────────
//         Positioned(top: bgH * 0.60, left: 0, right: 0, height: bgH * 0.42,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter, end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   const Color(0xFF050B14).withOpacity(0.78),
//                   const Color(0xFF050B14),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // ── Neon glow stat pill — top center ──────────────────────
//         AnimatedBuilder(
//           animation: Listenable.merge([_glowCtrl, _floatCtrl]),
//           builder: (_, __) {
//             final glow = 0.4 + _glowCtrl.value * 0.4;
//             final dy   = sin(_floatCtrl.value * pi) * 6;
//             return Positioned(
//               top: size.height * 0.025 + dy,
//               left: 0, right: 0,
//               child: Center(child: _NeonPill(
//                 label: 'LIVE TRACKING',
//                 icon: Icons.radio_button_checked_rounded,
//                 primary: AppTheme.primary,
//                 glowOpacity: glow,
//               )),
//             );
//           },
//         ),

//         // ── Left neon card: check-ins today ───────────────────────
//         AnimatedBuilder(
//           animation: _floatCtrl,
//           builder: (_, __) {
//             final dy = sin(_floatCtrl.value * pi) * 7;
//             return Positioned(
//               top: size.height * 0.085 + dy,
//               left: 14,
//               child: _NeonCard(
//                 topLabel: 'Check-ins',
//                 value: '24',
//                 bottomLabel: 'Today',
//                 icon: Icons.login_rounded,
//                 primary: AppTheme.primary,
//                 accent: const Color(0xFF22C55E),
//               ),
//             );
//           },
//         ),

//         // ── Right neon card: on-time % ─────────────────────────────
//         AnimatedBuilder(
//           animation: _floatCtrl,
//           builder: (_, __) {
//             final dy = sin(_floatCtrl.value * pi + 1.2) * 7;
//             return Positioned(
//               top: size.height * 0.085 + dy,
//               right: 14,
//               child: _NeonCard(
//                 topLabel: 'On Time',
//                 value: '96%',
//                 bottomLabel: 'Rate',
//                 icon: Icons.timer_rounded,
//                 primary: AppTheme.primary,
//                 accent: AppTheme.primary,
//               ),
//             );
//           },
//         ),

//         // ── Employee orbit labels (outside the canvas) ────────────
//         AnimatedBuilder(
//           animation: _orbitCtrl,
//           builder: (_, __) {
//             final cx   = size.width / 2;
//             final cy   = bgH * 0.50;
//             return Stack(children: [
//               ..._buildOrbitBadges(cx, cy, size, bgH),
//             ]);
//           },
//         ),

//         // ── MAIN CONTENT ───────────────────────────────────────────
//         SafeArea(
//           child: Column(children: [
//             Expanded(
//               flex: 44,
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: SlideTransition(
//                   position: _slideAnim,
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [

//                         // Neon glow icon
//                         AnimatedBuilder(
//                           animation: _glowCtrl,
//                           builder: (_, child) {
//                             final g = 0.55 + _glowCtrl.value * 0.30;
//                             return Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: AppTheme.primary.withOpacity(g * 0.55),
//                                     blurRadius: 50 + _glowCtrl.value * 25,
//                                     spreadRadius: 6,
//                                   ),
//                                 ],
//                               ),
//                               child: child,
//                             );
//                           },
//                           child: Container(
//                             width: 86, height: 86,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [AppTheme.primary, AppTheme.primaryDark],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(26),
//                               border: Border.all(
//                                 color: AppTheme.primary.withOpacity(0.60), width: 1.5),
//                             ),
//                             child: const Icon(Icons.fingerprint_rounded,
//                                 size: 48, color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Neon title
//                         AnimatedBuilder(
//                           animation: _glowCtrl,
//                           builder: (_, child) => Text('Attendance App',
//                             style: TextStyle(
//                               fontSize: 27, fontWeight: FontWeight.w700,
//                               color: Colors.white, fontFamily: 'Poppins',
//                               letterSpacing: 0.4,
//                               shadows: [
//                                 Shadow(color: AppTheme.primary.withOpacity(
//                                     0.20 + _glowCtrl.value * 0.25),
//                                   blurRadius: 20),
//                                 const Shadow(color: Colors.black54, blurRadius: 12),
//                               ],
//                             )),
//                         ),
//                         const SizedBox(height: 10),

//                         // Subtitle
//                         Text('Biometric • Location • Real-time',
//                           style: TextStyle(
//                             fontSize: 11, color: Colors.white.withOpacity(0.40),
//                             fontFamily: 'Poppins', letterSpacing: 1.5,
//                           )),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // FORM CARD
//             Expanded(
//               flex: 56,
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
//                   ),
//                   child: Form(
//                     key: ctrl.loginFormKey,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(child: Container(
//                             width: 40, height: 4,
//                             margin: const EdgeInsets.symmetric(vertical: 14),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           )),
//                           const Text('Welcome Back 👋',
//                             style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
//                                 color: Color(0xFF050B14), fontFamily: 'Poppins')),
//                           const SizedBox(height: 5),
//                           Text('Sign in to track your attendance',
//                             style: TextStyle(fontSize: 13, color: Colors.grey[500],
//                                 fontFamily: 'Poppins')),
//                           const SizedBox(height: 28),

//                           _FL('Email Address'),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: ctrl.loginEmailController,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: AppUtils.validateEmail,
//                             style: const TextStyle(fontFamily: 'Poppins',
//                                 fontSize: 14, color: Color(0xFF050B14)),
//                             decoration: _fd(hint: 'Enter your email',
//                                 icon: Icons.email_outlined),
//                           ),
//                           const SizedBox(height: 18),

//                           _FL('Password'),
//                           const SizedBox(height: 8),
//                           Obx(() => TextFormField(
//                             controller: ctrl.loginPasswordController,
//                             obscureText: !ctrl.isPasswordVisible.value,
//                             validator: AppUtils.validatePassword,
//                             style: const TextStyle(fontFamily: 'Poppins',
//                                 fontSize: 14, color: Color(0xFF050B14)),
//                             decoration: _fd(
//                               hint: 'Enter your password',
//                               icon: Icons.lock_outline_rounded,
//                               suffix: IconButton(
//                                 icon: Icon(
//                                   ctrl.isPasswordVisible.value
//                                       ? Icons.visibility_off_rounded
//                                       : Icons.visibility_rounded,
//                                   color: Colors.grey[400], size: 20,
//                                 ),
//                                 onPressed: ctrl.togglePasswordVisibility,
//                               ),
//                             ),
//                           )),

//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: TextButton(
//                               onPressed: () {},
//                               style: TextButton.styleFrom(
//                                   padding: const EdgeInsets.only(top: 6),
//                                   minimumSize: Size.zero,
//                                   tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                               child: Text('Forgot Password?',
//                                 style: TextStyle(fontSize: 12,
//                                     color: AppTheme.primary,
//                                     fontFamily: 'Poppins',
//                                     fontWeight: FontWeight.w600)),
//                             ),
//                           ),
//                           const SizedBox(height: 24),

//                           Obx(() => SizedBox(
//                             width: double.infinity, height: 54,
//                             child: ElevatedButton(
//                               onPressed: ctrl.isLoading.value ? null : ctrl.login,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppTheme.primary,
//                                 disabledBackgroundColor:
//                                     AppTheme.primary.withOpacity(0.55),
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14)),
//                               ),
//                               child: ctrl.isLoading.value
//                                   ? const SizedBox(width: 22, height: 22,
//                                   child: CircularProgressIndicator(
//                                       color: Colors.white, strokeWidth: 2.5))
//                                   : const Text('Sign In',
//                                   style: TextStyle(fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       fontFamily: 'Poppins', color: Colors.white,
//                                       letterSpacing: 0.5)),
//                             ),
//                           )),
//                           const SizedBox(height: 20),

//                           Row(children: [
//                             Expanded(child: Divider(color: Colors.grey[200])),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               child: Text('OR',
//                                 style: TextStyle(fontSize: 11, color: Colors.grey[400],
//                                     fontFamily: 'Poppins',
//                                     fontWeight: FontWeight.w500)),
//                             ),
//                             Expanded(child: Divider(color: Colors.grey[200])),
//                           ]),
//                           const SizedBox(height: 20),

//                           Center(child: GestureDetector(
//                             onTap: () => Get.toNamed('/register'),
//                             child: RichText(text: TextSpan(
//                               text: "Don't have an account?  ",
//                               style: TextStyle(color: Colors.grey[500],
//                                   fontFamily: 'Poppins', fontSize: 13),
//                               children: [TextSpan(
//                                 text: 'Register Now',
//                                 style: TextStyle(color: AppTheme.primary,
//                                     fontWeight: FontWeight.w700,
//                                     fontFamily: 'Poppins', fontSize: 13),
//                               )],
//                             )),
//                           )),
//                           const SizedBox(height: 18),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }

//   List<Widget> _buildOrbitBadges(
//       double cx, double cy, Size size, double bgH) {
//     final badges = [
//       _OrbitBadge('Rahul', '✓', const Color(0xFF22C55E), 0.0),
//       _OrbitBadge('Priya', '✓', const Color(0xFF22C55E), 0.20),
//       _OrbitBadge('Amit',  '✗', const Color(0xFFEF4444), 0.42),
//       _OrbitBadge('Meera', '⏱', const Color(0xFFF59E0B), 0.63),
//       _OrbitBadge('Suraj', '✓', const Color(0xFF22C55E), 0.82),
//     ];

//     return badges.map((b) {
//       const orbitR = 165.0;
//       final angle  = (_orbitCtrl.value + b.phase) * pi * 2;
//       final x = cx + orbitR * cos(angle);
//       final y = cy + orbitR * sin(angle) * 0.35;

//       if (y < 14 || y > bgH - 14) return const SizedBox.shrink();

//       return Positioned(
//         left: x - 22, top: y - 10,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//           decoration: BoxDecoration(
//             color: b.color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: b.color.withOpacity(0.40), width: 1),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             Text(b.mark,
//               style: TextStyle(fontSize: 8, color: b.color,
//                   fontWeight: FontWeight.w700)),
//             const SizedBox(width: 3),
//             Text(b.name,
//               style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(0.65),
//                   fontFamily: 'Poppins')),
//           ]),
//         ),
//       );
//     }).toList();
//   }

//   InputDecoration _fd({required String hint, required IconData icon, Widget? suffix}) =>
//       InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
//         prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
//         suffixIcon: suffix,
//         filled: true, fillColor: const Color(0xFFF7F8FA),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
//             borderSide: BorderSide.none),
//         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: Color(0xFFEEEFF3), width: 1.2)),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
//             borderSide: BorderSide(color: AppTheme.primary, width: 1.6)),
//         errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: Colors.red, width: 1.2)),
//         focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
//             borderSide: const BorderSide(color: Colors.red, width: 1.6)),
//       );
// }

// class _OrbitBadge {
//   final String name, mark;
//   final Color color;
//   final double phase;
//   _OrbitBadge(this.name, this.mark, this.color, this.phase);
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  PAINTER: ORBITAL RINGS + RADAR + FINGERPRINT + PROGRESS ARC
// // ══════════════════════════════════════════════════════════════════════════════
// class _OrbitalPainter extends CustomPainter {
//   final Color  primary;
//   final double orbitT, radarT, glowT, progressT;
//   final Size   size;

//   _OrbitalPainter({
//     required this.primary, required this.orbitT, required this.radarT,
//     required this.glowT,  required this.progressT, required this.size,
//   });

//   @override
//   void paint(Canvas canvas, Size s) {
//     final cx = s.width / 2;
//     final cy = size.height * 0.50;

//     final gridP = Paint()..color = Colors.white.withOpacity(0.025)..strokeWidth = 0.8;
//     for (double y = 0; y < s.height; y += 28) {
//       canvas.drawLine(Offset(0, y), Offset(s.width, y), gridP);
//     }
//     for (double x = 0; x < s.width; x += 28) {
//       canvas.drawLine(Offset(x, 0), Offset(x, s.height), gridP);
//     }

//     for (final r in [130.0, 90.0, 55.0]) {
//       canvas.drawCircle(Offset(cx, cy), r,
//           Paint()
//             ..color = primary.withOpacity(0.04 + (0.08 - r / 130 * 0.06) * glowT)
//             ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4));
//     }

//     final trackP = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0;
//     for (final rd in [165.0, 125.0, 88.0]) {
//       trackP.color = primary.withOpacity(0.10);
//       canvas.drawOval(
//         Rect.fromCenter(center: Offset(cx, cy),
//             width: rd * 2, height: rd * 0.70),
//         trackP,
//       );
//     }

//     final radarAngle = radarT * pi * 2;
//     const radarR = 125.0;
//     final radarRect = Rect.fromCircle(center: Offset(cx, cy), radius: radarR);
//     final radarPaint = Paint();
//     if (radarAngle > 0.8) {
//       radarPaint.shader = SweepGradient(
//         startAngle: radarAngle - 0.8,
//         endAngle: radarAngle,
//         colors: [Colors.transparent, primary.withOpacity(0.30)],
//         center: Alignment.center,
//       ).createShader(radarRect);
//     } else {
//       radarPaint.color = primary.withOpacity(0.20);
//     }
//     canvas.drawArc(radarRect, radarAngle - 0.8, 0.8, true, radarPaint);

//     canvas.drawLine(
//       Offset(cx, cy),
//       Offset(cx + radarR * cos(radarAngle), cy + radarR * sin(radarAngle) * 0.35),
//       Paint()
//         ..color = primary.withOpacity(0.55)
//         ..strokeWidth = 1.5,
//     );

//     const arcR = 88.0;
//     canvas.drawCircle(Offset(cx, cy), arcR,
//         Paint()
//           ..color = Colors.white.withOpacity(0.06)
//           ..style = PaintingStyle.stroke..strokeWidth = 6);

//     final sweepColors = [primary, primary.withOpacity(0.70), const Color(0xFF22C55E)];
//     final sweepAngle = progressT * 0.93 * pi * 2;
//     if (sweepAngle > 0.01) {
//       canvas.drawArc(
//         Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
//         -pi / 2, sweepAngle, false,
//         Paint()
//           ..shader = SweepGradient(
//             colors: sweepColors,
//             startAngle: -pi / 2,
//             endAngle: -pi / 2 + sweepAngle,
//           ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: arcR))
//           ..style = PaintingStyle.stroke..strokeWidth = 6
//           ..strokeCap = StrokeCap.round,
//       );
//     }

//     if (progressT > 0.02) {
//       final tipAngle = -pi / 2 + progressT * 0.93 * pi * 2;
//       final tipX = cx + arcR * cos(tipAngle);
//       final tipY = cy + arcR * sin(tipAngle);
//       canvas.drawCircle(Offset(tipX, tipY), 5,
//           Paint()..color = const Color(0xFF22C55E));
//       canvas.drawCircle(Offset(tipX, tipY), 10,
//           Paint()
//             ..color = const Color(0xFF22C55E).withOpacity(0.25)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
//     }

//     canvas.drawCircle(Offset(cx, cy), 54,
//         Paint()..color = Colors.white.withOpacity(0.05));
//     canvas.drawCircle(Offset(cx, cy), 54,
//         Paint()
//           ..color = primary.withOpacity(0.12)
//           ..style = PaintingStyle.stroke..strokeWidth = 1.0);

//     final fpP = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
//     final fpRadii = [14.0, 24.0, 34.0, 44.0, 54.0];
//     for (int i = 0; i < fpRadii.length; i++) {
//       final op = (0.38 - i * 0.05).clamp(0.05, 0.38);
//       fpP..color = primary.withOpacity(op)..strokeWidth = 1.8;
//       canvas.drawArc(
//         Rect.fromCircle(center: Offset(cx, cy), radius: fpRadii[i]),
//         pi * 0.18, pi * 0.75, false, fpP);
//       canvas.drawArc(
//         Rect.fromCircle(center: Offset(cx, cy), radius: fpRadii[i]),
//         pi * 1.10, pi * 0.62, false, fpP);
//     }
//     canvas.drawCircle(Offset(cx, cy), 4.5,
//         Paint()..color = primary.withOpacity(0.70));

//     final employeeColors = [
//       const Color(0xFF22C55E), const Color(0xFF22C55E),
//       const Color(0xFFEF4444), const Color(0xFFF59E0B),
//       const Color(0xFF22C55E),
//     ];
//     const orbitRad = 165.0;
//     const phases   = [0.0, 0.20, 0.42, 0.63, 0.82];

//     for (int i = 0; i < 5; i++) {
//       final angle = (orbitT + phases[i]) * pi * 2;
//       final ox = cx + orbitRad * cos(angle);
//       final oy = cy + orbitRad * sin(angle) * 0.35;
//       final ec = employeeColors[i];

//       canvas.drawLine(Offset(cx, cy), Offset(ox, oy),
//           Paint()
//             ..color = ec.withOpacity(0.08)
//             ..strokeWidth = 0.8);

//       canvas.drawCircle(Offset(ox, oy), 7,
//           Paint()..color = ec.withOpacity(0.85));
//       canvas.drawCircle(Offset(ox, oy), 13,
//           Paint()..color = ec.withOpacity(0.18)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
//       canvas.drawCircle(Offset(ox, oy), 10,
//           Paint()
//             ..color = ec.withOpacity(0.45)
//             ..style = PaintingStyle.stroke..strokeWidth = 1.2);
//     }

//     for (int i = 0; i < 48; i++) {
//       final angle = i * pi * 2 / 48;
//       final r1 = 175.0;
//       final r2 = i % 4 == 0 ? 180.0 : 177.0;
//       canvas.drawLine(
//         Offset(cx + r1 * cos(angle), cy + r1 * sin(angle) * 0.35),
//         Offset(cx + r2 * cos(angle), cy + r2 * sin(angle) * 0.35),
//         Paint()
//           ..color = primary.withOpacity(i % 4 == 0 ? 0.30 : 0.12)
//           ..strokeWidth = i % 4 == 0 ? 1.5 : 0.8,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _OrbitalPainter o) =>
//       o.orbitT != orbitT || o.radarT != radarT ||
//       o.glowT  != glowT  || o.progressT != progressT;
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  PAINTER: WAVEFORM
// // ══════════════════════════════════════════════════════════════════════════════
// class _WavePainter extends CustomPainter {
//   final double t;
//   final Color primary;
//   _WavePainter({required this.t, required this.primary});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final path1 = Path();
//     final path2 = Path();
//     final midY  = size.height / 2;

//     for (double x = 0; x <= size.width; x++) {
//       final y1 = midY + sin((x / size.width * pi * 8) - t * pi * 2) *
//           (14 + sin(x / size.width * pi * 3) * 8);
//       final y2 = midY + sin((x / size.width * pi * 6) - t * pi * 2 + 1.2) *
//           (10 + cos(x / size.width * pi * 4) * 6);
//       x == 0 ? path1.moveTo(x, y1) : path1.lineTo(x, y1);
//       x == 0 ? path2.moveTo(x, y2) : path2.lineTo(x, y2);
//     }

//     canvas.drawPath(path1,
//         Paint()
//           ..color = primary.withOpacity(0.40)
//           ..strokeWidth = 1.8
//           ..style = PaintingStyle.stroke
//           ..strokeCap = StrokeCap.round);

//     canvas.drawPath(path2,
//         Paint()
//           ..color = Colors.white.withOpacity(0.12)
//           ..strokeWidth = 1.2
//           ..style = PaintingStyle.stroke);

//     canvas.drawPath(path1,
//         Paint()
//           ..color = primary.withOpacity(0.10)
//           ..strokeWidth = 8
//           ..style = PaintingStyle.stroke
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
//   }

//   @override
//   bool shouldRepaint(covariant _WavePainter o) => o.t != t;
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  WIDGET: NEON PILL
// // ══════════════════════════════════════════════════════════════════════════════
// class _NeonPill extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color primary;
//   final double glowOpacity;
//   const _NeonPill({
//     required this.label, required this.icon,
//     required this.primary, required this.glowOpacity,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//     decoration: BoxDecoration(
//       color: primary.withOpacity(0.12),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: primary.withOpacity(glowOpacity * 0.55), width: 1.2),
//       boxShadow: [
//         BoxShadow(
//           color: primary.withOpacity(glowOpacity * 0.25),
//           blurRadius: 14, spreadRadius: 1,
//         ),
//       ],
//     ),
//     child: Row(mainAxisSize: MainAxisSize.min, children: [
//       Icon(icon, size: 10, color: primary),
//       const SizedBox(width: 6),
//       Text(label, style: TextStyle(
//         fontSize: 10, color: primary,
//         fontFamily: 'Poppins', fontWeight: FontWeight.w700,
//         letterSpacing: 1.8,
//       )),
//     ]),
//   );
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  WIDGET: NEON CARD
// // ══════════════════════════════════════════════════════════════════════════════
// class _NeonCard extends StatelessWidget {
//   final String topLabel, value, bottomLabel;
//   final IconData icon;
//   final Color primary, accent;
//   const _NeonCard({
//     required this.topLabel, required this.value,
//     required this.bottomLabel, required this.icon,
//     required this.primary,    required this.accent,
//   });

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.06),
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
//       boxShadow: [
//         BoxShadow(color: accent.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4)),
//       ],
//     ),
//     child: Column(mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon, size: 10, color: accent.withOpacity(0.75)),
//           const SizedBox(width: 4),
//           Text(topLabel, style: TextStyle(
//             fontSize: 9, color: Colors.white.withOpacity(0.50),
//             fontFamily: 'Poppins', height: 1.2,
//           )),
//         ]),
//         const SizedBox(height: 2),
//         Text(value, style: TextStyle(
//           fontSize: 20, fontWeight: FontWeight.w800,
//           color: Colors.white.withOpacity(0.95),
//           fontFamily: 'Poppins', height: 1.1,
//         )),
//         Text(bottomLabel, style: TextStyle(
//           fontSize: 8, color: accent.withOpacity(0.60),
//           fontFamily: 'Poppins', fontWeight: FontWeight.w500,
//         )),
//       ],
//     ),
//   );
// }

// // ─── HELPERS ─────────────────────────────────────────────────────────────────
// class _FL extends StatelessWidget {
//   final String label;
//   const _FL(this.label);
//   @override
//   Widget build(BuildContext context) => Text(label,
//     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
//         color: Color(0xFF2D3748), fontFamily: 'Poppins'));
// }

// extension on int {
//   Duration get ms => Duration(milliseconds: this);
// }








import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late final AnimationController _formCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _radarCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _floatCtrl;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset>  _slideAnim;
  late final Animation<double>  _progressAnim;

  final _rng = Random(13);

  @override
  void initState() {
    super.initState();

    _formCtrl = AnimationController(vsync: this, duration: 1100.ms)..forward();
    _fadeAnim  = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));

    _orbitCtrl    = AnimationController(vsync: this, duration: 8000.ms)..repeat();
    _waveCtrl     = AnimationController(vsync: this, duration: 2400.ms)..repeat();
    _glowCtrl     = AnimationController(vsync: this, duration: 2800.ms)..repeat(reverse: true);
    _radarCtrl    = AnimationController(vsync: this, duration: 3000.ms)..repeat();
    _floatCtrl    = AnimationController(vsync: this, duration: 3400.ms)..repeat(reverse: true);

    _progressCtrl = AnimationController(vsync: this, duration: 2200.ms);
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic);
    Future.delayed(600.ms, () { if (mounted) _progressCtrl.forward(); });
  }

  @override
  void dispose() {
    for (final c in [_formCtrl, _orbitCtrl, _waveCtrl, _glowCtrl,
      _radarCtrl, _progressCtrl, _floatCtrl]) c.dispose();
    super.dispose();
  }

  // ── Coming Soon Snackbar ──────────────────────────────────────── ✅
  void _showComingSoon() {
    Get.snackbar(
      '🚧 Coming Soon',
      'Forgot Password feature will be available soon!',
      backgroundColor: const Color(0xFF050B14),
      colorText: Colors.white,
      icon: const Icon(Icons.construction_rounded, color: Color(0xFFF59E0B)),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final bgH  = size.height * 0.58;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Stack(children: [

        // ── Base gradient ──────────────────────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF070F1C), Color(0xFF050B14), Color(0xFF0A0600)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // ── Radar sweep + orbital rings + fingerprint ──────────────
        Positioned(top: 0, left: 0, right: 0, height: bgH,
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_orbitCtrl, _radarCtrl, _glowCtrl, _progressAnim]),
            builder: (_, __) => CustomPaint(
              painter: _OrbitalPainter(
                primary:   AppTheme.primary,
                orbitT:    _orbitCtrl.value,
                radarT:    _radarCtrl.value,
                glowT:     _glowCtrl.value,
                progressT: _progressAnim.value,
                size:      Size(size.width, bgH),
              ),
            ),
          ),
        ),

        // ── Animated waveform strip ────────────────────────────────
        Positioned(
          top: bgH * 0.74, left: 0, right: 0, height: 56,
          child: AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => CustomPaint(
              painter: _WavePainter(t: _waveCtrl.value, primary: AppTheme.primary),
            ),
          ),
        ),

        // ── Bottom fade ────────────────────────────────────────────
        Positioned(top: bgH * 0.60, left: 0, right: 0, height: bgH * 0.42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF050B14).withOpacity(0.78),
                  const Color(0xFF050B14),
                ],
              ),
            ),
          ),
        ),

        // ── Neon glow stat pill — top center ──────────────────────
        AnimatedBuilder(
          animation: Listenable.merge([_glowCtrl, _floatCtrl]),
          builder: (_, __) {
            final glow = 0.4 + _glowCtrl.value * 0.4;
            final dy   = sin(_floatCtrl.value * pi) * 6;
            return Positioned(
              top: size.height * 0.025 + dy,
              left: 0, right: 0,
              child: Center(child: _NeonPill(
                label: 'LIVE TRACKING',
                icon: Icons.radio_button_checked_rounded,
                primary: AppTheme.primary,
                glowOpacity: glow,
              )),
            );
          },
        ),

        // ── Left neon card: check-ins today ───────────────────────
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final dy = sin(_floatCtrl.value * pi) * 7;
            return Positioned(
              top: size.height * 0.085 + dy,
              left: 14,
              child: _NeonCard(
                topLabel: 'Check-ins',
                value: '24',
                bottomLabel: 'Today',
                icon: Icons.login_rounded,
                primary: AppTheme.primary,
                accent: const Color(0xFF22C55E),
              ),
            );
          },
        ),

        // ── Right neon card: on-time % ─────────────────────────────
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final dy = sin(_floatCtrl.value * pi + 1.2) * 7;
            return Positioned(
              top: size.height * 0.085 + dy,
              right: 14,
              child: _NeonCard(
                topLabel: 'On Time',
                value: '96%',
                bottomLabel: 'Rate',
                icon: Icons.timer_rounded,
                primary: AppTheme.primary,
                accent: AppTheme.primary,
              ),
            );
          },
        ),

        // ── Employee orbit labels ──────────────────────────────────
        AnimatedBuilder(
          animation: _orbitCtrl,
          builder: (_, __) {
            final cx = size.width / 2;
            final cy = bgH * 0.50;
            return Stack(children: [
              ..._buildOrbitBadges(cx, cy, size, bgH),
            ]);
          },
        ),

        // ── MAIN CONTENT ───────────────────────────────────────────
        SafeArea(
          child: Column(children: [
            Expanded(
              flex: 44,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Neon glow icon
                        AnimatedBuilder(
                          animation: _glowCtrl,
                          builder: (_, child) {
                            final g = 0.55 + _glowCtrl.value * 0.30;
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(g * 0.55),
                                    blurRadius: 50 + _glowCtrl.value * 25,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 86, height: 86,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.60), width: 1.5),
                            ),
                            child: const Icon(Icons.fingerprint_rounded,
                                size: 48, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Neon title
                        AnimatedBuilder(
                          animation: _glowCtrl,
                          builder: (_, child) => Text('Attendance App',
                              style: TextStyle(
                                fontSize: 27, fontWeight: FontWeight.w700,
                                color: Colors.white, fontFamily: 'Poppins',
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(color: AppTheme.primary.withOpacity(
                                      0.20 + _glowCtrl.value * 0.25),
                                      blurRadius: 20),
                                  const Shadow(color: Colors.black54, blurRadius: 12),
                                ],
                              )),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        Text('Biometric • Location • Real-time',
                            style: TextStyle(
                              fontSize: 11, color: Colors.white.withOpacity(0.40),
                              fontFamily: 'Poppins', letterSpacing: 1.5,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── FORM CARD ──────────────────────────────────────────
            Expanded(
              flex: 56,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
                  ),
                  child: Form(
                    key: ctrl.loginFormKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(
                            width: 40, height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )),
                          const Text('Welcome Back 👋',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                                  color: Color(0xFF050B14), fontFamily: 'Poppins')),
                          const SizedBox(height: 5),
                          Text('Sign in to track your attendance',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500],
                                  fontFamily: 'Poppins')),
                          const SizedBox(height: 28),

                          _FL('Email Address'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: ctrl.loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: AppUtils.validateEmail,
                            style: const TextStyle(fontFamily: 'Poppins',
                                fontSize: 14, color: Color(0xFF050B14)),
                            decoration: _fd(hint: 'Enter your email',
                                icon: Icons.email_outlined),
                          ),
                          const SizedBox(height: 18),

                          _FL('Password'),
                          const SizedBox(height: 8),
                          Obx(() => TextFormField(
                            controller: ctrl.loginPasswordController,
                            obscureText: !ctrl.isPasswordVisible.value,
                            validator: AppUtils.validatePassword,
                            style: const TextStyle(fontFamily: 'Poppins',
                                fontSize: 14, color: Color(0xFF050B14)),
                            decoration: _fd(
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  ctrl.isPasswordVisible.value
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.grey[400], size: 20,
                                ),
                                onPressed: ctrl.togglePasswordVisibility,
                              ),
                            ),
                          )),

                          // ── Forgot Password ✅ ───────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showComingSoon, // ✅ UPDATED
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(top: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: Text('Forgot Password?',
                                  style: TextStyle(fontSize: 12,
                                      color: AppTheme.primary,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Obx(() => SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              onPressed: ctrl.isLoading.value ? null : ctrl.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                disabledBackgroundColor:
                                AppTheme.primary.withOpacity(0.55),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: ctrl.isLoading.value
                                  ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                                  : const Text('Sign In',
                                  style: TextStyle(fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins', color: Colors.white,
                                      letterSpacing: 0.5)),
                            ),
                          )),
                          const SizedBox(height: 20),

                          Row(children: [
                            Expanded(child: Divider(color: Colors.grey[200])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400],
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500)),
                            ),
                            Expanded(child: Divider(color: Colors.grey[200])),
                          ]),
                          const SizedBox(height: 20),

                          Center(child: GestureDetector(
                            onTap: () => Get.toNamed('/register'),
                            child: RichText(text: TextSpan(
                              text: "Don't have an account?  ",
                              style: TextStyle(color: Colors.grey[500],
                                  fontFamily: 'Poppins', fontSize: 13),
                              children: [TextSpan(
                                text: 'Register Now',
                                style: TextStyle(color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins', fontSize: 13),
                              )],
                            )),
                          )),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  List<Widget> _buildOrbitBadges(
      double cx, double cy, Size size, double bgH) {
    final badges = [
      _OrbitBadge('Rahul', '✓', const Color(0xFF22C55E), 0.0),
      _OrbitBadge('Priya', '✓', const Color(0xFF22C55E), 0.20),
      _OrbitBadge('Amit',  '✗', const Color(0xFFEF4444), 0.42),
      _OrbitBadge('Meera', '⏱', const Color(0xFFF59E0B), 0.63),
      _OrbitBadge('Suraj', '✓', const Color(0xFF22C55E), 0.82),
    ];

    return badges.map((b) {
      const orbitR = 165.0;
      final angle  = (_orbitCtrl.value + b.phase) * pi * 2;
      final x = cx + orbitR * cos(angle);
      final y = cy + orbitR * sin(angle) * 0.35;

      if (y < 14 || y > bgH - 14) return const SizedBox.shrink();

      return Positioned(
        left: x - 22, top: y - 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: b.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: b.color.withOpacity(0.40), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(b.mark,
                style: TextStyle(fontSize: 8, color: b.color,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            Text(b.name,
                style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(0.65),
                    fontFamily: 'Poppins')),
          ]),
        ),
      );
    }).toList();
  }

  InputDecoration _fd({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        suffixIcon: suffix,
        filled: true, fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFEEEFF3), width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppTheme.primary, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.red, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.red, width: 1.6)),
      );
}

class _OrbitBadge {
  final String name, mark;
  final Color color;
  final double phase;
  _OrbitBadge(this.name, this.mark, this.color, this.phase);
}

// ══════════════════════════════════════════════════════════════════════════════
//  PAINTER: ORBITAL RINGS + RADAR + FINGERPRINT + PROGRESS ARC
// ══════════════════════════════════════════════════════════════════════════════
class _OrbitalPainter extends CustomPainter {
  final Color  primary;
  final double orbitT, radarT, glowT, progressT;
  final Size   size;

  _OrbitalPainter({
    required this.primary, required this.orbitT, required this.radarT,
    required this.glowT,  required this.progressT, required this.size,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = size.height * 0.50;

    final gridP = Paint()..color = Colors.white.withOpacity(0.025)..strokeWidth = 0.8;
    for (double y = 0; y < s.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), gridP);
    }
    for (double x = 0; x < s.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), gridP);
    }

    for (final r in [130.0, 90.0, 55.0]) {
      canvas.drawCircle(Offset(cx, cy), r,
          Paint()
            ..color = primary.withOpacity(0.04 + (0.08 - r / 130 * 0.06) * glowT)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4));
    }

    final trackP = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (final rd in [165.0, 125.0, 88.0]) {
      trackP.color = primary.withOpacity(0.10);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy),
            width: rd * 2, height: rd * 0.70),
        trackP,
      );
    }

    final radarAngle = radarT * pi * 2;
    const radarR = 125.0;
    final radarRect = Rect.fromCircle(center: Offset(cx, cy), radius: radarR);
    final radarPaint = Paint();
    if (radarAngle > 0.8) {
      radarPaint.shader = SweepGradient(
        startAngle: radarAngle - 0.8,
        endAngle: radarAngle,
        colors: [Colors.transparent, primary.withOpacity(0.30)],
        center: Alignment.center,
      ).createShader(radarRect);
    } else {
      radarPaint.color = primary.withOpacity(0.20);
    }
    canvas.drawArc(radarRect, radarAngle - 0.8, 0.8, true, radarPaint);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + radarR * cos(radarAngle), cy + radarR * sin(radarAngle) * 0.35),
      Paint()
        ..color = primary.withOpacity(0.55)
        ..strokeWidth = 1.5,
    );

    const arcR = 88.0;
    canvas.drawCircle(Offset(cx, cy), arcR,
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..style = PaintingStyle.stroke..strokeWidth = 6);

    final sweepColors = [primary, primary.withOpacity(0.70), const Color(0xFF22C55E)];
    final sweepAngle = progressT * 0.93 * pi * 2;
    if (sweepAngle > 0.01) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        -pi / 2, sweepAngle, false,
        Paint()
          ..shader = SweepGradient(
            colors: sweepColors,
            startAngle: -pi / 2,
            endAngle: -pi / 2 + sweepAngle,
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: arcR))
          ..style = PaintingStyle.stroke..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    if (progressT > 0.02) {
      final tipAngle = -pi / 2 + progressT * 0.93 * pi * 2;
      final tipX = cx + arcR * cos(tipAngle);
      final tipY = cy + arcR * sin(tipAngle);
      canvas.drawCircle(Offset(tipX, tipY), 5,
          Paint()..color = const Color(0xFF22C55E));
      canvas.drawCircle(Offset(tipX, tipY), 10,
          Paint()
            ..color = const Color(0xFF22C55E).withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }

    canvas.drawCircle(Offset(cx, cy), 54,
        Paint()..color = Colors.white.withOpacity(0.05));
    canvas.drawCircle(Offset(cx, cy), 54,
        Paint()
          ..color = primary.withOpacity(0.12)
          ..style = PaintingStyle.stroke..strokeWidth = 1.0);

    final fpP = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fpRadii = [14.0, 24.0, 34.0, 44.0, 54.0];
    for (int i = 0; i < fpRadii.length; i++) {
      final op = (0.38 - i * 0.05).clamp(0.05, 0.38);
      fpP..color = primary.withOpacity(op)..strokeWidth = 1.8;
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: fpRadii[i]),
          pi * 0.18, pi * 0.75, false, fpP);
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: fpRadii[i]),
          pi * 1.10, pi * 0.62, false, fpP);
    }
    canvas.drawCircle(Offset(cx, cy), 4.5,
        Paint()..color = primary.withOpacity(0.70));

    final employeeColors = [
      const Color(0xFF22C55E), const Color(0xFF22C55E),
      const Color(0xFFEF4444), const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
    ];
    const orbitRad = 165.0;
    const phases   = [0.0, 0.20, 0.42, 0.63, 0.82];

    for (int i = 0; i < 5; i++) {
      final angle = (orbitT + phases[i]) * pi * 2;
      final ox = cx + orbitRad * cos(angle);
      final oy = cy + orbitRad * sin(angle) * 0.35;
      final ec = employeeColors[i];

      canvas.drawLine(Offset(cx, cy), Offset(ox, oy),
          Paint()
            ..color = ec.withOpacity(0.08)
            ..strokeWidth = 0.8);

      canvas.drawCircle(Offset(ox, oy), 7,
          Paint()..color = ec.withOpacity(0.85));
      canvas.drawCircle(Offset(ox, oy), 13,
          Paint()..color = ec.withOpacity(0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(Offset(ox, oy), 10,
          Paint()
            ..color = ec.withOpacity(0.45)
            ..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }

    for (int i = 0; i < 48; i++) {
      final angle = i * pi * 2 / 48;
      const r1 = 175.0;
      final r2 = i % 4 == 0 ? 180.0 : 177.0;
      canvas.drawLine(
        Offset(cx + r1 * cos(angle), cy + r1 * sin(angle) * 0.35),
        Offset(cx + r2 * cos(angle), cy + r2 * sin(angle) * 0.35),
        Paint()
          ..color = primary.withOpacity(i % 4 == 0 ? 0.30 : 0.12)
          ..strokeWidth = i % 4 == 0 ? 1.5 : 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter o) =>
      o.orbitT != orbitT || o.radarT != radarT ||
      o.glowT  != glowT  || o.progressT != progressT;
}

// ══════════════════════════════════════════════════════════════════════════════
//  PAINTER: WAVEFORM
// ══════════════════════════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  final double t;
  final Color primary;
  _WavePainter({required this.t, required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path();
    final path2 = Path();
    final midY  = size.height / 2;

    for (double x = 0; x <= size.width; x++) {
      final y1 = midY + sin((x / size.width * pi * 8) - t * pi * 2) *
          (14 + sin(x / size.width * pi * 3) * 8);
      final y2 = midY + sin((x / size.width * pi * 6) - t * pi * 2 + 1.2) *
          (10 + cos(x / size.width * pi * 4) * 6);
      x == 0 ? path1.moveTo(x, y1) : path1.lineTo(x, y1);
      x == 0 ? path2.moveTo(x, y2) : path2.lineTo(x, y2);
    }

    canvas.drawPath(path1,
        Paint()
          ..color = primary.withOpacity(0.40)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    canvas.drawPath(path2,
        Paint()
          ..color = Colors.white.withOpacity(0.12)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke);

    canvas.drawPath(path1,
        Paint()
          ..color = primary.withOpacity(0.10)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  @override
  bool shouldRepaint(covariant _WavePainter o) => o.t != t;
}

// ══════════════════════════════════════════════════════════════════════════════
//  WIDGET: NEON PILL
// ══════════════════════════════════════════════════════════════════════════════
class _NeonPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color primary;
  final double glowOpacity;
  const _NeonPill({
    required this.label, required this.icon,
    required this.primary, required this.glowOpacity,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: primary.withOpacity(glowOpacity * 0.55), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(glowOpacity * 0.25),
          blurRadius: 14, spreadRadius: 1,
        ),
      ],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: primary),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(
        fontSize: 10, color: primary,
        fontFamily: 'Poppins', fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      )),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  WIDGET: NEON CARD
// ══════════════════════════════════════════════════════════════════════════════
class _NeonCard extends StatelessWidget {
  final String topLabel, value, bottomLabel;
  final IconData icon;
  final Color primary, accent;
  const _NeonCard({
    required this.topLabel, required this.value,
    required this.bottomLabel, required this.icon,
    required this.primary,    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
      boxShadow: [
        BoxShadow(color: accent.withOpacity(0.15), blurRadius: 16,
            offset: const Offset(0, 4)),
      ],
    ),
    child: Column(mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: accent.withOpacity(0.75)),
          const SizedBox(width: 4),
          Text(topLabel, style: TextStyle(
            fontSize: 9, color: Colors.white.withOpacity(0.50),
            fontFamily: 'Poppins', height: 1.2,
          )),
        ]),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: Colors.white.withOpacity(0.95),
          fontFamily: 'Poppins', height: 1.1,
        )),
        Text(bottomLabel, style: TextStyle(
          fontSize: 8, color: accent.withOpacity(0.60),
          fontFamily: 'Poppins', fontWeight: FontWeight.w500,
        )),
      ],
    ),
  );
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────
class _FL extends StatelessWidget {
  final String label;
  const _FL(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748), fontFamily: 'Poppins'));
}

extension on int {
  Duration get ms => Duration(milliseconds: this);
}