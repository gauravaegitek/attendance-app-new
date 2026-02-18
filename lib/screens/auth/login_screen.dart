// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AuthController>();

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppTheme.primary, AppTheme.primaryDark],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // =================== HEADER ===================
//               Expanded(
//                 flex: 2,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 90,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                         child: const Icon(
//                           Icons.fingerprint,
//                           size: 50,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Attendance App',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Sign in to continue',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white.withOpacity(0.8),
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // =================== FORM ===================
//               Expanded(
//                 flex: 3,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(28),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(32),
//                     ),
//                   ),
//                   child: Form(
//                     key: controller.loginFormKey,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Welcome Back!',
//                             style: AppTheme.headline2,
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Enter your credentials to login',
//                             style: AppTheme.bodySmall,
//                           ),
//                           const SizedBox(height: 28),

//                           // Email
//                           _buildLabel('Email Address'),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: controller.loginEmailController,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: AppUtils.validateEmail,
//                             decoration: const InputDecoration(
//                               hintText: 'Enter your email',
//                               prefixIcon: Icon(Icons.email_outlined,
//                                   color: AppTheme.primary),
//                             ),
//                           ),
//                           const SizedBox(height: 20),

//                           // Password
//                           _buildLabel('Password'),
//                           const SizedBox(height: 8),
//                           Obx(() => TextFormField(
//                             controller: controller.loginPasswordController,
//                             obscureText: !controller.isPasswordVisible.value,
//                             validator: AppUtils.validatePassword,
//                             decoration: InputDecoration(
//                               hintText: 'Enter your password',
//                               prefixIcon: const Icon(Icons.lock_outline,
//                                   color: AppTheme.primary),
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   controller.isPasswordVisible.value
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
//                                   color: AppTheme.textSecondary,
//                                 ),
//                                 onPressed: controller.togglePasswordVisibility,
//                               ),
//                             ),
//                           )),
//                           const SizedBox(height: 32),

//                           // Login Button
//                           Obx(() => ElevatedButton(
//                             onPressed: controller.isLoading.value
//                                 ? null
//                                 : controller.login,
//                             child: controller.isLoading.value
//                                 ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Text('Login'),
//                           )),
//                           const SizedBox(height: 20),

//                           // Register Link
//                           Center(
//                             child: GestureDetector(
//                               onTap: () => Get.toNamed('/register'),
//                               child: RichText(
//                                 text: const TextSpan(
//                                   text: "Don't have an account? ",
//                                   style: TextStyle(
//                                     color: AppTheme.textSecondary,
//                                     fontFamily: 'Poppins',
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text: 'Register',
//                                       style: TextStyle(
//                                         color: AppTheme.primary,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Poppins',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) => Text(
//     text,
//     style: const TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w600,
//       color: AppTheme.textPrimary,
//       fontFamily: 'Poppins',
//     ),
//   );
// }









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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // ─── DECORATIVE BLOBS ───────────────────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: _blob(260, const Color(0xFF1565C0).withOpacity(0.25)),
          ),
          Positioned(
            top: size.height * 0.18,
            left: -110,
            child: _blob(200, const Color(0xFF0D47A1).withOpacity(0.18)),
          ),
          Positioned(
            bottom: size.height * 0.38,
            right: -60,
            child: _blob(150, AppTheme.primary.withOpacity(0.12)),
          ),

          // ─── MAIN CONTENT ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // HEADER SECTION
                Expanded(
                  flex: 45,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fingerprint_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Attendance App',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'SECURE  ·  SMART  ·  SEAMLESS',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.45),
                                fontFamily: 'Poppins',
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // FORM CARD
                Expanded(
                  flex: 55,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(38)),
                      ),
                      child: Form(
                        key: controller.loginFormKey,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag Handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const Text(
                                'Welcome Back 👋',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0A1628),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Enter your credentials to sign in',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ─── EMAIL ─────────────────────────────
                              _FieldLabel(label: 'Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller.loginEmailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: AppUtils.validateEmail,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Color(0xFF0A1628),
                                ),
                                decoration: _fieldDecor(
                                  hint: 'Enter your email',
                                  icon: Icons.email_outlined,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // ─── PASSWORD ──────────────────────────
                              _FieldLabel(label: 'Password'),
                              const SizedBox(height: 8),
                              Obx(() => TextFormField(
                                    controller:
                                        controller.loginPasswordController,
                                    obscureText:
                                        !controller.isPasswordVisible.value,
                                    validator: AppUtils.validatePassword,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Color(0xFF0A1628),
                                    ),
                                    decoration: _fieldDecor(
                                      hint: 'Enter your password',
                                      icon: Icons.lock_outline_rounded,
                                      suffix: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible.value
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed:
                                            controller.togglePasswordVisibility,
                                      ),
                                    ),
                                  )),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(top: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ─── LOGIN BUTTON ──────────────────────
                              Obx(() => SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        disabledBackgroundColor:
                                            AppTheme.primary.withOpacity(0.55),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  )),
                              const SizedBox(height: 20),

                              // Divider
                              Row(children: [
                                Expanded(
                                    child: Divider(color: Colors.grey[200])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(color: Colors.grey[200])),
                              ]),
                              const SizedBox(height: 20),

                              // ─── REGISTER LINK ─────────────────────
                              Center(
                                child: GestureDetector(
                                  onTap: () => Get.toNamed('/register'),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account?  ",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Register Now',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Security Badge
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.grey[200]!, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield_outlined,
                                          size: 13,
                                          color: AppTheme.primary
                                              .withOpacity(0.7)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Single-device secure session',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  InputDecoration _fieldDecor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFEEEFF3), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 1.6),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
          fontFamily: 'Poppins',
        ),
      );
}