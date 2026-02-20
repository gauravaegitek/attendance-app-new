// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';
// import '../../core/constants/app_constants.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AuthController>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: controller.registerFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 const Text('Create Account', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Fill in your details to register',
//                   style: AppTheme.bodySmall,
//                 ),
//                 const SizedBox(height: 32),

//                 // Full Name
//                 _buildLabel('Full Name'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: controller.registerNameController,
//                   validator: (v) => AppUtils.validateRequired(v, 'Full name'),
//                   textCapitalization: TextCapitalization.words,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your full name',
//                     prefixIcon: Icon(Icons.person_outline,
//                         color: AppTheme.primary),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Email
//                 _buildLabel('Email Address'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: controller.registerEmailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: AppUtils.validateEmail,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your email',
//                     prefixIcon: Icon(Icons.email_outlined,
//                         color: AppTheme.primary),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Password
//                 _buildLabel('Password'),
//                 const SizedBox(height: 8),
//                 Obx(() => TextFormField(
//                   controller: controller.registerPasswordController,
//                   obscureText: !controller.isPasswordVisible.value,
//                   validator: AppUtils.validatePassword,
//                   decoration: InputDecoration(
//                     hintText: 'Minimum 6 characters',
//                     prefixIcon: const Icon(Icons.lock_outline,
//                         color: AppTheme.primary),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         controller.isPasswordVisible.value
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: AppTheme.textSecondary,
//                       ),
//                       onPressed: controller.togglePasswordVisibility,
//                     ),
//                   ),
//                 )),
//                 const SizedBox(height: 20),

//                 // Role
//                 _buildLabel('Role'),
//                 const SizedBox(height: 8),
//                 Obx(() => Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppTheme.divider),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: controller.selectedRole.value,
//                       isExpanded: true,
//                       icon: const Icon(Icons.keyboard_arrow_down,
//                           color: AppTheme.primary),
//                       items: AppConstants.allRoles
//                           .map((role) => DropdownMenuItem(
//                                 value: role,
//                                 child: Text(
//                                   role[0].toUpperCase() + role.substring(1),
//                                   style: AppTheme.bodyMedium,
//                                 ),
//                               ))
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) controller.selectedRole.value = val;
//                       },
//                     ),
//                   ),
//                 )),
//                 const SizedBox(height: 36),

//                 // Register Button
//                 Obx(() => ElevatedButton(
//                   onPressed: controller.isLoading.value
//                       ? null
//                       : controller.register,
//                   child: controller.isLoading.value
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text('Create Account'),
//                 )),
//                 const SizedBox(height: 20),

//                 // Login Link
//                 Center(
//                   child: GestureDetector(
//                     onTap: () => Get.back(),
//                     child: RichText(
//                       text: const TextSpan(
//                         text: 'Already have an account? ',
//                         style: TextStyle(
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins',
//                         ),
//                         children: [
//                           TextSpan(
//                             text: 'Login',
//                             style: TextStyle(
//                               color: AppTheme.primary,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'Poppins',
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
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








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';
// import '../../core/constants/app_constants.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<AuthController>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: controller.registerFormKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ─── HEADER ───────────────────────────────────
//                 const Text('Create Account', style: AppTheme.headline2),
//                 const SizedBox(height: 6),
//                 const Text(
//                   'Fill in your details to register',
//                   style: AppTheme.bodySmall,
//                 ),
//                 const SizedBox(height: 32),

//                 // ─── FULL NAME ────────────────────────────────
//                 _buildLabel('Full Name'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: controller.registerNameController,
//                   validator: (v) => AppUtils.validateRequired(v, 'Full name'),
//                   textCapitalization: TextCapitalization.words,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your full name',
//                     prefixIcon:
//                         Icon(Icons.person_outline, color: AppTheme.primary),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ─── EMAIL ────────────────────────────────────
//                 _buildLabel('Email Address'),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: controller.registerEmailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: AppUtils.validateEmail,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your email',
//                     prefixIcon:
//                         Icon(Icons.email_outlined, color: AppTheme.primary),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ─── PASSWORD ─────────────────────────────────
//                 _buildLabel('Password'),
//                 const SizedBox(height: 8),
//                 Obx(() => TextFormField(
//                       controller: controller.registerPasswordController,
//                       obscureText: !controller.isPasswordVisible.value,
//                       validator: AppUtils.validatePassword,
//                       decoration: InputDecoration(
//                         hintText: 'Minimum 6 characters',
//                         prefixIcon: const Icon(Icons.lock_outline,
//                             color: AppTheme.primary),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             controller.isPasswordVisible.value
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: AppTheme.textSecondary,
//                           ),
//                           onPressed: controller.togglePasswordVisibility,
//                         ),
//                       ),
//                     )),
//                 const SizedBox(height: 20),

//                 // ─── CONFIRM PASSWORD ─────────────────────────
//                 _buildLabel('Confirm Password'),
//                 const SizedBox(height: 8),
//                 Obx(() => TextFormField(
//                       controller:
//                           controller.registerConfirmPasswordController,
//                       obscureText:
//                           !controller.isConfirmPasswordVisible.value,
//                       validator: (v) {
//                         if (v == null || v.isEmpty) {
//                           return 'Please confirm your password';
//                         }
//                         if (v !=
//                             controller.registerPasswordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Re-enter your password',
//                         prefixIcon: const Icon(Icons.lock_outline,
//                             color: AppTheme.primary),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             controller.isConfirmPasswordVisible.value
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color: AppTheme.textSecondary,
//                           ),
//                           onPressed:
//                               controller.toggleConfirmPasswordVisibility,
//                         ),
//                       ),
//                     )),
//                 const SizedBox(height: 20),

//                 // ─── ROLE ─────────────────────────────────────
//                 _buildLabel('Role'),
//                 const SizedBox(height: 8),
//                 Obx(() {
//                   if (controller.isRolesLoading.value) {
//                     return Container(
//                       height: 54,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppTheme.divider),
//                       ),
//                       child: const Row(
//                         children: [
//                           SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppTheme.primary,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Text(
//                             'Loading roles...',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontFamily: 'Poppins',
//                               color: AppTheme.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   final roles = controller.rolesList.isNotEmpty
//                       ? controller.rolesList
//                       : AppConstants.allRoles;

//                   final selectedValue =
//                       roles.contains(controller.selectedRole.value)
//                           ? controller.selectedRole.value
//                           : roles.first;

//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppTheme.divider),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: selectedValue,
//                         isExpanded: true,
//                         icon: const Icon(Icons.keyboard_arrow_down,
//                             color: AppTheme.primary),
//                         items: roles
//                             .map((role) => DropdownMenuItem(
//                                   value: role,
//                                   child: Text(
//                                     role[0].toUpperCase() + role.substring(1),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontFamily: 'Poppins',
//                                       color: AppTheme.textPrimary,
//                                     ),
//                                   ),
//                                 ))
//                             .toList(),
//                         onChanged: (val) {
//                           if (val != null) {
//                             // ✅ onRoleSelected — roleId bhi update hoga
//                             controller.onRoleSelected(val);
//                           }
//                         },
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 36),

//                 // ─── REGISTER BUTTON ──────────────────────────
//                 Obx(() => SizedBox(
//                       width: double.infinity,
//                       height: 54,
//                       child: ElevatedButton(
//                         onPressed: controller.isLoading.value
//                             ? null
//                             : controller.register,
//                         child: controller.isLoading.value
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Create Account'),
//                       ),
//                     )),
//                 const SizedBox(height: 20),

//                 // ─── LOGIN LINK ───────────────────────────────
//                 Center(
//                   child: GestureDetector(
//                     onTap: () => Get.back(),
//                     child: RichText(
//                       text: const TextSpan(
//                         text: 'Already have an account? ',
//                         style: TextStyle(
//                           color: AppTheme.textSecondary,
//                           fontFamily: 'Poppins',
//                           fontSize: 13,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: 'Login',
//                             style: TextStyle(
//                               color: AppTheme.primary,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'Poppins',
//                               fontSize: 13,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) => Text(
//         text,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: AppTheme.textPrimary,
//           fontFamily: 'Poppins',
//         ),
//       );
// }






import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    // Roles sirf yahan fetch hogi — login screen pe nahi
    _controller.fetchRoles();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── HEADER ───────────────────────────────────
                const Text('Create Account', style: AppTheme.headline2),
                const SizedBox(height: 6),
                const Text(
                  'Fill in your details to register',
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 32),

                // ─── FULL NAME ────────────────────────────────
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.registerNameController,
                  validator: (v) => AppUtils.validateRequired(v, 'Full name'),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── EMAIL ────────────────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.registerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppUtils.validateEmail,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── PASSWORD ─────────────────────────────────
                _buildLabel('Password'),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                      controller: controller.registerPasswordController,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: AppUtils.validatePassword,
                      decoration: InputDecoration(
                        hintText: 'Minimum 6 characters',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),

                // ─── CONFIRM PASSWORD ─────────────────────────
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                      controller: controller.registerConfirmPasswordController,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != controller.registerPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed:
                              controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),

                // ─── ROLE ─────────────────────────────────────
                _buildLabel('Role'),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.isRolesLoading.value) {
                    return Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Loading roles...',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final roles = controller.rolesList.isNotEmpty
                      ? controller.rolesList
                      : AppConstants.allRoles;

                  final selectedValue =
                      roles.contains(controller.selectedRole.value)
                          ? controller.selectedRole.value
                          : roles.first;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.primary),
                        items: roles
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role[0].toUpperCase() + role.substring(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.onRoleSelected(val);
                          }
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 36),

                // ─── REGISTER BUTTON ──────────────────────────
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.register,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    )),
                const SizedBox(height: 20),

                // ─── LOGIN LINK ───────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontFamily: 'Poppins',
        ),
      );
}