// import 'dart:io';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import '../../controllers/profile_controller.dart';
// import '../../core/theme/app_theme.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     if (!Get.isRegistered<ProfileController>()) {
//       Get.put(ProfileController());
//     }
//     final ctrl = Get.find<ProfileController>();

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: AppTheme.background,
//         body: Obx(() {
//           if (ctrl.isLoading.value) return const _LoadingState();
//           if (ctrl.profile.value == null) {
//             return _ErrorState(onRetry: ctrl.fetchProfile);
//           }
//           return NestedScrollView(
//             headerSliverBuilder: (context, innerBoxIsScrolled) => [
//               _ProfileSliverAppBar(
//                 ctrl: ctrl,
//                 innerBoxIsScrolled: innerBoxIsScrolled,
//               ),
//             ],
//             body: TabBarView(
//               children: [
//                 _ProfileTab(ctrl: ctrl),
//                 _ChangePasswordTab(ctrl: ctrl),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  SLIVER APP BAR
// // ═══════════════════════════════════════════════
// class _ProfileSliverAppBar extends StatelessWidget {
//   final ProfileController ctrl;
//   final bool innerBoxIsScrolled;
//   const _ProfileSliverAppBar(
//       {required this.ctrl, required this.innerBoxIsScrolled});

//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 220,
//       pinned: true,
//       stretch: true,
//       backgroundColor: AppTheme.cardBackground,
//       elevation: 0,
//       leading: Container(
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           shape: BoxShape.circle,
//         ),
//         child: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: Colors.white, size: 18),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       title: AnimatedOpacity(
//         opacity: innerBoxIsScrolled ? 1 : 0,
//         duration: const Duration(milliseconds: 200),
//         child: Obx(() => Text(
//               ctrl.profile.value?.name ?? 'My Profile',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textPrimary,
//               ),
//             )),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         stretchModes: const [StretchMode.zoomBackground],
//         collapseMode: CollapseMode.parallax,
//         background: _ProfileHeader(ctrl: ctrl),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(48),
//         child: Container(
//           color: AppTheme.cardBackground,
//           child: const TabBar(
//             labelStyle: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13),
//             unselectedLabelStyle:
//                 TextStyle(fontFamily: 'Poppins', fontSize: 13),
//             indicatorColor: AppTheme.primary,
//             indicatorWeight: 3,
//             indicatorSize: TabBarIndicatorSize.label,
//             labelColor: AppTheme.primary,
//             unselectedLabelColor: AppTheme.textSecondary,
//             tabs: [
//               Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'Profile'),
//               Tab(icon: Icon(Icons.lock_rounded, size: 18), text: 'Password'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  PROFILE HEADER
// // ═══════════════════════════════════════════════
// class _ProfileHeader extends StatelessWidget {
//   final ProfileController ctrl;
//   const _ProfileHeader({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final p = ctrl.profile.value;
//       final hasPhoto = p?.photoUrl != null && p!.photoUrl!.isNotEmpty;

//       return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppTheme.primary, AppTheme.secondary, AppTheme.accent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Positioned(
//               top: -30,
//               right: -30,
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.06),
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               child: SafeArea(
//                 bottom: false,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     _CompactAvatar(ctrl: ctrl, hasPhoto: hasPhoto, p: p),
//                     const SizedBox(height: 6),
//                     Text(
//                       p?.name ?? '',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                         fontFamily: 'Poppins',
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       p?.email ?? '',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontFamily: 'Poppins',
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _RoleBadge(role: p?.role ?? ''),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// // ═══════════════════════════════════════════════
// //  COMPACT AVATAR
// // ═══════════════════════════════════════════════
// class _CompactAvatar extends StatelessWidget {
//   final ProfileController ctrl;
//   final bool hasPhoto;
//   final dynamic p;

//   const _CompactAvatar(
//       {required this.ctrl, required this.hasPhoto, required this.p});

//   bool _isLocalPath(String url) => !url.startsWith('http');

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showPhotoOptions(context),
//       child: Stack(alignment: Alignment.bottomRight, children: [
//         Container(
//           width: 78,
//           height: 78,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(22),
//             color: Colors.white,
//             border: Border.all(color: Colors.white, width: 2.5),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 14,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(19.5),
//             child: hasPhoto
//                 ? _isLocalPath(p!.photoUrl!)
//                     ? Image.file(
//                         File(p!.photoUrl!),
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             _AvatarInitial(name: p?.name ?? ''),
//                       )
//                     : Image.network(
//                         p!.photoUrl!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             _AvatarInitial(name: p?.name ?? ''),
//                         loadingBuilder: (_, child, progress) {
//                           if (progress == null) return child;
//                           return const Center(
//                             child: CircularProgressIndicator(
//                                 color: AppTheme.primary, strokeWidth: 2),
//                           );
//                         },
//                       )
//                 : _AvatarInitial(name: p?.name ?? ''),
//           ),
//         ),
//         Obx(() => Container(
//               padding: const EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2)),
//                 ],
//               ),
//               child: ctrl.isUploading.value
//                   ? const SizedBox(
//                       width: 12,
//                       height: 12,
//                       child: CircularProgressIndicator(
//                           color: AppTheme.primary, strokeWidth: 2),
//                     )
//                   : const Icon(Icons.camera_alt_rounded,
//                       color: AppTheme.primary, size: 12),
//             )),
//       ]),
//     );
//   }

//   void _showPhotoOptions(BuildContext context) {
//     HapticFeedback.lightImpact();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PhotoOptionsSheet(ctrl: ctrl, hasPhoto: hasPhoto),
//     );
//   }
// }

// class _AvatarInitial extends StatelessWidget {
//   final String name;
//   const _AvatarInitial({required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppTheme.primaryLight,
//       child: Center(
//         child: Text(
//           name.isNotEmpty ? name[0].toUpperCase() : 'U',
//           style: const TextStyle(
//             color: AppTheme.primary,
//             fontSize: 28,
//             fontWeight: FontWeight.w800,
//             fontFamily: 'Poppins',
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RoleBadge extends StatelessWidget {
//   final String role;
//   const _RoleBadge({required this.role});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.white.withOpacity(0.35)),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
//             const SizedBox(width: 5),
//             Text(role.toLowerCase(),
//                 style: const TextStyle(
//                     fontSize: 11,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins')),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  TAB 1 — Profile
// // ═══════════════════════════════════════════════
// class _ProfileTab extends StatefulWidget {
//   final ProfileController ctrl;
//   const _ProfileTab({required this.ctrl});

//   @override
//   State<_ProfileTab> createState() => _ProfileTabState();
// }

// class _ProfileTabState extends State<_ProfileTab> {
//   bool _isEditing = false;

//   static const List<String> _departments = [
//     'Administration',
//     'Accounts & Finance',
//     'Operations',
//     'Quality Control',
//     'Logistics',
//     'IT & Technology',
//     'Human Resources',
//     'Procurement',
//     'Sales & Marketing',
//   ];

//   static const List<String> _designations = [
//     'Manager',
//     'Senior Executive',
//     'Executive',
//     'Supervisor',
//     'Team Lead',
//     'Analyst',
//     'Operator',
//     'Assistant',
//     'Intern',
//   ];

//   void _toggleEdit() {
//     setState(() => _isEditing = !_isEditing);
//     HapticFeedback.lightImpact();
//   }

//   Future<void> _saveAndLock() async {
//     HapticFeedback.mediumImpact();
//     final success = await widget.ctrl.updateProfile();
//     if (success) {
//       setState(() => _isEditing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               // ── Account Info (READ-ONLY) ─────────
//               Obx(() => _SectionCard(
//                     title: 'Account Info',
//                     icon: Icons.badge_rounded,
//                     iconColor: AppTheme.primary,
//                     child: Column(children: [
//                       _InfoRow(
//                         icon: Icons.person_rounded,
//                         label: 'Full Name',
//                         value: widget.ctrl.profile.value?.name ?? '—',
//                       ),
//                       const _HDivider(),
//                       _InfoRow(
//                         icon: Icons.alternate_email_rounded,
//                         label: 'Email',
//                         value: widget.ctrl.profile.value?.email ?? '—',
//                       ),
//                       const _HDivider(),
//                       _InfoRow(
//                         icon: Icons.star_rounded,
//                         label: 'Role',
//                         value: (widget.ctrl.profile.value?.role ?? '—')
//                             .toLowerCase(),
//                         valueColor: AppTheme.primary,
//                       ),
//                       if (widget.ctrl.profile.value?.joiningDate
//                               ?.isNotEmpty ==
//                           true) ...[
//                         const _HDivider(),
//                         _InfoRow(
//                           icon: Icons.calendar_today_rounded,
//                           label: 'Joining Date',
//                           value: widget.ctrl.profile.value!.joiningDate!,
//                         ),
//                       ],
//                     ]),
//                   )),

//               const SizedBox(height: 14),

//               // ── Edit Details ─────────────────────
//               _SectionCard(
//                 title: 'Edit Details',
//                 icon: Icons.edit_rounded,
//                 iconColor: const Color(0xFF6366F1),
//                 trailing: GestureDetector(
//                   onTap: _toggleEdit,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _isEditing
//                           ? AppTheme.primary.withOpacity(0.12)
//                           : AppTheme.background,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: _isEditing
//                             ? AppTheme.primary
//                             : AppTheme.divider,
//                       ),
//                     ),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(
//                         _isEditing
//                             ? Icons.close_rounded
//                             : Icons.edit_rounded,
//                         size: 13,
//                         color: _isEditing
//                             ? AppTheme.primary
//                             : AppTheme.textSecondary,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         _isEditing ? 'Cancel' : 'Edit',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w600,
//                           color: _isEditing
//                               ? AppTheme.primary
//                               : AppTheme.textSecondary,
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ),
//                 child: Column(children: [
//                   // ── Phone ────────────────────────
//                   _AnimatedField(
//                     controller: widget.ctrl.phoneCtrl,
//                     label: 'Phone',
//                     icon: Icons.phone_rounded,
//                     hint: 'Enter phone number',
//                     keyboardType: TextInputType.phone,
//                     enabled: _isEditing,
//                   ),
//                   const SizedBox(height: 14),

//                   // ── Department (Search Dropdown) ──
//                   _AnimatedDropdown(
//                     controller: widget.ctrl.departmentCtrl,
//                     label: 'Department',
//                     icon: Icons.corporate_fare_rounded,
//                     hint: 'Select Department',
//                     items: _departments,
//                     enabled: _isEditing,
//                   ),
//                   const SizedBox(height: 14),

//                   // ── Designation (Search Dropdown) ─
//                   _AnimatedDropdown(
//                     controller: widget.ctrl.designationCtrl,
//                     label: 'Designation',
//                     icon: Icons.work_rounded,
//                     hint: 'Select Designation',
//                     items: _designations,
//                     enabled: _isEditing,
//                   ),
//                   const SizedBox(height: 14),

//                   // ── Emergency Contact ─────────────
//                   _AnimatedField(
//                     controller: widget.ctrl.emergencyContactCtrl,
//                     label: 'Emergency Contact',
//                     icon: Icons.emergency_rounded,
//                     hint: 'Emergency contact number',
//                     keyboardType: TextInputType.phone,
//                     enabled: _isEditing,
//                   ),
//                   const SizedBox(height: 14),

//                   // ── Address ───────────────────────
//                   _AnimatedField(
//                     controller: widget.ctrl.addressCtrl,
//                     label: 'Address',
//                     icon: Icons.location_on_rounded,
//                     hint: 'Enter your address',
//                     maxLines: 3,
//                     enabled: _isEditing,
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 8),
//             ]),
//           ),
//         ),

//         // ── Sticky Save Button ───────────────────
//         if (_isEditing)
//           _StickyBottomBar(
//             child: Obx(() => _PrimaryButton(
//                   label: 'Save Changes',
//                   loadingLabel: 'Saving...',
//                   icon: Icons.save_rounded,
//                   isLoading: widget.ctrl.isSaving.value,
//                   onPressed: _saveAndLock,
//                 )),
//           ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  TAB 2 — Change Password
// // ═══════════════════════════════════════════════
// class _ChangePasswordTab extends StatefulWidget {
//   final ProfileController ctrl;
//   const _ChangePasswordTab({required this.ctrl});

//   @override
//   State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
// }

// class _ChangePasswordTabState extends State<_ChangePasswordTab> {
//   final _formKey = GlobalKey<FormState>();
//   bool _showCurrent = false;
//   bool _showNew = false;
//   bool _showConfirm = false;
//   double _strength = 0;
//   String _strengthLabel = '';
//   Color _strengthColor = Colors.transparent;

//   void _evaluateStrength(String pass) {
//     double s = 0;
//     if (pass.length >= 6) s += 0.25;
//     if (pass.length >= 10) s += 0.15;
//     if (pass.contains(RegExp(r'[A-Z]'))) s += 0.2;
//     if (pass.contains(RegExp(r'[0-9]'))) s += 0.2;
//     if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s += 0.2;
//     setState(() {
//       _strength = s.clamp(0.0, 1.0);
//       if (s <= 0.25) {
//         _strengthLabel = 'Weak';
//         _strengthColor = AppTheme.error;
//       } else if (s <= 0.5) {
//         _strengthLabel = 'Fair';
//         _strengthColor = const Color(0xFFF59E0B);
//       } else if (s <= 0.75) {
//         _strengthLabel = 'Good';
//         _strengthColor = const Color(0xFF3B82F6);
//       } else {
//         _strengthLabel = 'Strong';
//         _strengthColor = const Color(0xFF10B981);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Form(
//               key: _formKey,
//               child: Column(children: [
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: [
//                       AppTheme.primary.withOpacity(0.08),
//                       AppTheme.secondary.withOpacity(0.05),
//                     ]),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                         color: AppTheme.primary.withOpacity(0.15)),
//                   ),
//                   child: Row(children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: AppTheme.primary.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(Icons.security_rounded,
//                           color: AppTheme.primary, size: 20),
//                     ),
//                     const SizedBox(width: 14),
//                     const Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Keep your account secure',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w700,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textPrimary)),
//                             SizedBox(height: 3),
//                             Text('Use uppercase, numbers & symbols.',
//                                 style: TextStyle(
//                                     fontSize: 11,
//                                     fontFamily: 'Poppins',
//                                     color: AppTheme.textSecondary)),
//                           ]),
//                     ),
//                   ]),
//                 ),
//                 const SizedBox(height: 14),

//                 _SectionCard(
//                   title: 'Update Password',
//                   icon: Icons.lock_rounded,
//                   iconColor: const Color(0xFF8B5CF6),
//                   child: Column(children: [
//                     _PasswordField(
//                       controller: widget.ctrl.currentPasswordCtrl,
//                       label: 'Current Password',
//                       showPassword: _showCurrent,
//                       onToggle: () =>
//                           setState(() => _showCurrent = !_showCurrent),
//                       validator: (v) => (v == null || v.trim().isEmpty)
//                           ? 'Current password is required'
//                           : null,
//                     ),
//                     const SizedBox(height: 14),
//                     _PasswordField(
//                       controller: widget.ctrl.newPasswordCtrl,
//                       label: 'New Password',
//                       showPassword: _showNew,
//                       onToggle: () => setState(() => _showNew = !_showNew),
//                       onChanged: _evaluateStrength,
//                       validator: (v) {
//                         if (v == null || v.trim().isEmpty)
//                           return 'New password is required';
//                         if (v.trim().length < 6)
//                           return 'Minimum 6 characters required';
//                         return null;
//                       },
//                     ),
//                     if (_strength > 0) ...[
//                       const SizedBox(height: 10),
//                       _PasswordStrengthBar(
//                         strength: _strength,
//                         label: _strengthLabel,
//                         color: _strengthColor,
//                       ),
//                     ],
//                     const SizedBox(height: 14),
//                     _PasswordField(
//                       controller: widget.ctrl.confirmPasswordCtrl,
//                       label: 'Confirm New Password',
//                       showPassword: _showConfirm,
//                       onToggle: () =>
//                           setState(() => _showConfirm = !_showConfirm),
//                       validator: (v) {
//                         if (v == null || v.trim().isEmpty)
//                           return 'Please confirm your password';
//                         if (v.trim() !=
//                             widget.ctrl.newPasswordCtrl.text.trim()) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                   ]),
//                 ),
//                 const SizedBox(height: 8),
//               ]),
//             ),
//           ),
//         ),

//         _StickyBottomBar(
//           child: Obx(() => _PrimaryButton(
//                 label: 'Update Password',
//                 loadingLabel: 'Updating...',
//                 icon: Icons.lock_reset_rounded,
//                 isLoading: widget.ctrl.isChangingPassword.value,
//                 onPressed: () async {
//                   HapticFeedback.mediumImpact();
//                   if (_formKey.currentState!.validate()) {
//                     await widget.ctrl.changePassword();
//                   }
//                 },
//               )),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  STICKY BOTTOM BAR
// // ═══════════════════════════════════════════════
// class _StickyBottomBar extends StatelessWidget {
//   final Widget child;
//   const _StickyBottomBar({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//           16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
//       decoration: BoxDecoration(
//         color: AppTheme.cardBackground,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  PASSWORD STRENGTH BAR (Animated)
// // ═══════════════════════════════════════════════
// class _PasswordStrengthBar extends StatefulWidget {
//   final double strength;
//   final String label;
//   final Color color;
//   const _PasswordStrengthBar(
//       {required this.strength, required this.label, required this.color});

//   @override
//   State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
// }

// class _PasswordStrengthBarState extends State<_PasswordStrengthBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ac;
//   late Animation<double> _anim;

//   @override
//   void initState() {
//     super.initState();
//     _ac = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 400));
//     _anim = Tween<double>(begin: 0, end: widget.strength)
//         .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
//     _ac.forward();
//   }

//   @override
//   void didUpdateWidget(_PasswordStrengthBar old) {
//     super.didUpdateWidget(old);
//     _anim = Tween<double>(begin: old.strength, end: widget.strength)
//         .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
//     _ac.forward(from: 0);
//   }

//   @override
//   void dispose() {
//     _ac.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: AnimatedBuilder(
//             animation: _anim,
//             builder: (_, __) => LinearProgressIndicator(
//               value: _anim.value,
//               minHeight: 5,
//               backgroundColor: AppTheme.divider,
//               valueColor: AlwaysStoppedAnimation<Color>(widget.color),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(width: 10),
//       Text(widget.label,
//           style: TextStyle(
//               fontSize: 11,
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w600,
//               color: widget.color)),
//     ]);
//   }
// }

// // ═══════════════════════════════════════════════
// //  LOADING / ERROR STATES
// // ═══════════════════════════════════════════════
// class _LoadingState extends StatelessWidget {
//   const _LoadingState();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text('My Profile',
//             style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textPrimary)),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           CircularProgressIndicator(color: AppTheme.primary),
//           SizedBox(height: 16),
//           Text('Loading profile...',
//               style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 13,
//                   color: AppTheme.textSecondary)),
//         ]),
//       ),
//     );
//   }
// }

// class _ErrorState extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _ErrorState({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                   color: AppTheme.primaryLight, shape: BoxShape.circle),
//               child: const Icon(Icons.person_off_rounded,
//                   color: AppTheme.primary, size: 44),
//             ),
//             const SizedBox(height: 20),
//             const Text('Could not load profile',
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary)),
//             const SizedBox(height: 8),
//             const Text('Check your connection and try again.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textSecondary)),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh_rounded, size: 18),
//               label: const Text('Retry',
//                   style: TextStyle(
//                       fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppTheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 32, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//                 elevation: 0,
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  PHOTO OPTIONS SHEET
// // ═══════════════════════════════════════════════
// class _PhotoOptionsSheet extends StatelessWidget {
//   final ProfileController ctrl;
//   final bool hasPhoto;
//   const _PhotoOptionsSheet({required this.ctrl, required this.hasPhoto});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Container(
//           width: 40,
//           height: 4,
//           decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10)),
//         ),
//         const SizedBox(height: 20),
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//               color: AppTheme.primaryLight,
//               borderRadius: BorderRadius.circular(16)),
//           child: const Icon(Icons.photo_camera_rounded,
//               color: AppTheme.primary, size: 30),
//         ),
//         const SizedBox(height: 12),
//         const Text('Profile Photo',
//             style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textPrimary)),
//         const SizedBox(height: 4),
//         const Text('Update your profile picture',
//             style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textSecondary)),
//         const SizedBox(height: 24),
//         _SheetOption(
//           icon: Icons.photo_library_rounded,
//           iconBg: AppTheme.primaryLight,
//           iconColor: AppTheme.primary,
//           title: 'Choose from Gallery',
//           subtitle: 'Pick a photo from your device',
//           onTap: () {
//             Get.back();
//             ctrl.pickAndUploadPhoto();
//           },
//         ),
//         if (hasPhoto) ...[
//           const SizedBox(height: 10),
//           _SheetOption(
//             icon: Icons.delete_outline_rounded,
//             iconBg: AppTheme.errorLight,
//             iconColor: AppTheme.error,
//             title: 'Remove Photo',
//             subtitle: 'Delete your current profile picture',
//             onTap: () {
//               Get.back();
//               ctrl.deletePhoto();
//             },
//           ),
//         ],
//       ]),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  ANIMATED FIELD
// // ═══════════════════════════════════════════════
// class _AnimatedField extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final String hint;
//   final TextInputType keyboardType;
//   final int maxLines;
//   final bool enabled;
//   final String? Function(String?)? validator;

//   const _AnimatedField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     required this.hint,
//     this.keyboardType = TextInputType.text,
//     this.maxLines = 1,
//     this.enabled = true,
//     this.validator,
//   });

//   @override
//   State<_AnimatedField> createState() => _AnimatedFieldState();
// }

// class _AnimatedFieldState extends State<_AnimatedField> {
//   final _focus = FocusNode();
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _focus.addListener(
//         () => setState(() => _isFocused = _focus.hasFocus));
//   }

//   @override
//   void dispose() {
//     _focus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: (_isFocused && widget.enabled)
//             ? [
//                 BoxShadow(
//                     color: AppTheme.primary.withOpacity(0.12),
//                     blurRadius: 8,
//                     spreadRadius: 1)
//               ]
//             : [],
//       ),
//       child: TextFormField(
//         controller: widget.controller,
//         focusNode: _focus,
//         keyboardType: widget.keyboardType,
//         maxLines: widget.maxLines,
//         validator: widget.validator,
//         enabled: widget.enabled,
//         style: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 14,
//             color: widget.enabled
//                 ? AppTheme.textPrimary
//                 : AppTheme.textSecondary),
//         decoration: InputDecoration(
//           labelText: widget.label,
//           hintText: widget.hint,
//           hintStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 13,
//               color: AppTheme.textHint),
//           labelStyle: const TextStyle(
//               fontFamily: 'Poppins', color: AppTheme.textSecondary),
//           prefixIcon: Icon(widget.icon,
//               size: 20,
//               color: (_isFocused && widget.enabled)
//                   ? AppTheme.primary
//                   : AppTheme.textSecondary),
//           filled: true,
//           fillColor: widget.enabled
//               ? AppTheme.background
//               : AppTheme.background.withOpacity(0.5),
//           disabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: AppTheme.divider)),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: AppTheme.divider)),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: AppTheme.divider)),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: AppTheme.primary, width: 1.5)),
//           errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: AppTheme.error)),
//           focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide:
//                   const BorderSide(color: AppTheme.error, width: 1.5)),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  ANIMATED DROPDOWN  ✅ SEARCH ICON VERSION
// // ═══════════════════════════════════════════════
// class _AnimatedDropdown extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final String hint;
//   final List<String> items;
//   final bool enabled;

//   const _AnimatedDropdown({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     required this.hint,
//     required this.items,
//     this.enabled = true,
//   });

//   void _openSearchSheet(BuildContext context) {
//     if (!enabled) return;
//     HapticFeedback.lightImpact();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _SearchableDropdownSheet(
//         title: label,
//         items: items,
//         selected: controller.text,
//         onSelected: (val) => controller.text = val,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: enabled
//             ? [
//                 BoxShadow(
//                   color: AppTheme.primary.withOpacity(0.08),
//                   blurRadius: 8,
//                   spreadRadius: 1,
//                 )
//               ]
//             : [],
//       ),
//       child: TextFormField(
//         controller: controller,
//         readOnly: true,
//         enabled: enabled,
//         // onTap: () => _openSearchSheet(context),
//         style: TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 14,
//           color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           hintStyle: const TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 13,
//             color: AppTheme.textHint,
//           ),
//           labelStyle: TextStyle(
//             fontFamily: 'Poppins',
//             color: enabled ? AppTheme.textSecondary : AppTheme.textHint,
//           ),
//           prefixIcon: Icon(
//             icon,
//             size: 20,
//             color: enabled ? AppTheme.primary : AppTheme.textSecondary,
//           ),
//           // ✅ Search icon — tap to open searchable sheet
//           suffixIcon: enabled
//               ? IconButton(
//                   icon: const Icon(
//                     Icons.search_rounded,
//                     color: AppTheme.primary,
//                     size: 22,
//                   ),
//                   onPressed: () => _openSearchSheet(context),
//                 )
//               : const Icon(
//                   Icons.search_rounded,
//                   color: AppTheme.textSecondary,
//                   size: 22,
//                 ),
//           filled: true,
//           fillColor: enabled
//               ? AppTheme.background
//               : AppTheme.background.withOpacity(0.5),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  SEARCHABLE DROPDOWN BOTTOM SHEET  ✅ NEW
// // ═══════════════════════════════════════════════
// class _SearchableDropdownSheet extends StatefulWidget {
//   final String title;
//   final List<String> items;
//   final String selected;
//   final ValueChanged<String> onSelected;

//   const _SearchableDropdownSheet({
//     required this.title,
//     required this.items,
//     required this.selected,
//     required this.onSelected,
//   });

//   @override
//   State<_SearchableDropdownSheet> createState() =>
//       _SearchableDropdownSheetState();
// }

// class _SearchableDropdownSheetState
//     extends State<_SearchableDropdownSheet> {
//   late List<String> _filtered;
//   final _searchCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _filtered = widget.items;
//     _searchCtrl.addListener(_filter);
//   }

//   void _filter() {
//     final q = _searchCtrl.text.toLowerCase();
//     setState(() {
//       _filtered = widget.items
//           .where((e) => e.toLowerCase().contains(q))
//           .toList();
//     });
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.85,
//       builder: (_, scrollCtrl) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             // ── Handle ──────────────────────────
//             const SizedBox(height: 12),
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // ── Title ────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryLight,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.search_rounded,
//                       color: AppTheme.primary, size: 18),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Select ${widget.title}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//               ]),
//             ),
//             const SizedBox(height: 14),

//             // ── Search Field ─────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 controller: _searchCtrl,
//                 autofocus: true,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 14,
//                     color: AppTheme.textPrimary),
//                 decoration: InputDecoration(
//                   hintText: 'Search ${widget.title}...',
//                   hintStyle: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       color: AppTheme.textHint),
//                   prefixIcon: const Icon(Icons.search_rounded,
//                       color: AppTheme.primary, size: 20),
//                   suffixIcon: ValueListenableBuilder<TextEditingValue>(
//                     valueListenable: _searchCtrl,
//                     builder: (_, value, __) => value.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear_rounded,
//                                 size: 18,
//                                 color: AppTheme.textSecondary),
//                             onPressed: () => _searchCtrl.clear(),
//                           )
//                         : const SizedBox.shrink(),
//                   ),
//                   filled: true,
//                   fillColor: AppTheme.background,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: AppTheme.divider),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: AppTheme.divider),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                         color: AppTheme.primary, width: 1.5),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14, vertical: 12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Divider(height: 1, color: AppTheme.divider),

//             // ── List ─────────────────────────────
//             Expanded(
//               child: _filtered.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.search_off_rounded,
//                               size: 44,
//                               color: AppTheme.textSecondary
//                                   .withOpacity(0.35)),
//                           const SizedBox(height: 10),
//                           const Text('No results found',
//                               style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 13,
//                                   color: AppTheme.textSecondary)),
//                         ],
//                       ),
//                     )
//                   : ListView.separated(
//                       controller: scrollCtrl,
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       itemCount: _filtered.length,
//                       separatorBuilder: (_, __) => const Divider(
//                           height: 1, color: AppTheme.divider),
//                       itemBuilder: (_, i) {
//                         final item = _filtered[i];
//                         final isSelected = item == widget.selected;
//                         return ListTile(
//                           onTap: () {
//                             widget.onSelected(item);
//                             Get.back();
//                           },
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 4),
//                           leading: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppTheme.primaryLight
//                                   : AppTheme.background,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(
//                               Icons.label_outline_rounded,
//                               size: 16,
//                               color: isSelected
//                                   ? AppTheme.primary
//                                   : AppTheme.textSecondary,
//                             ),
//                           ),
//                           title: Text(
//                             item,
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 14,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.w400,
//                               color: isSelected
//                                   ? AppTheme.primary
//                                   : AppTheme.textPrimary,
//                             ),
//                           ),
//                           trailing: isSelected
//                               ? const Icon(Icons.check_circle_rounded,
//                                   color: AppTheme.primary, size: 20)
//                               : null,
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════
// //  SECTION CARD
// // ═══════════════════════════════════════════════
// class _SectionCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color iconColor;
//   final Widget child;
//   final Widget? trailing;

//   const _SectionCard({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//     required this.child,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Icon(icon, color: iconColor, size: 16),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(title,
//                   style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary)),
//             ),
//             if (trailing != null) trailing!,
//           ]),
//         ),
//         const SizedBox(height: 14),
//         const Divider(height: 1, color: AppTheme.divider),
//         Padding(padding: const EdgeInsets.all(16), child: child),
//       ]),
//     );
//   }
// }

// class _HDivider extends StatelessWidget {
//   const _HDivider();
//   @override
//   Widget build(BuildContext context) =>
//       const Divider(height: 1, color: AppTheme.divider);
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color? valueColor;
//   const _InfoRow(
//       {required this.icon,
//       required this.label,
//       required this.value,
//       this.valueColor});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//               color: AppTheme.background,
//               borderRadius: BorderRadius.circular(9)),
//           child: Icon(icon, color: AppTheme.textSecondary, size: 16),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontSize: 10,
//                     color: AppTheme.textSecondary,
//                     fontFamily: 'Poppins')),
//             const SizedBox(height: 2),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'Poppins',
//                     color: valueColor ?? AppTheme.textPrimary)),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// class _PasswordField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final bool showPassword;
//   final VoidCallback onToggle;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onChanged;

//   const _PasswordField({
//     required this.controller,
//     required this.label,
//     required this.showPassword,
//     required this.onToggle,
//     this.validator,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: !showPassword,
//       validator: validator,
//       onChanged: onChanged,
//       style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontSize: 14,
//           color: AppTheme.textPrimary),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//             fontFamily: 'Poppins', color: AppTheme.textSecondary),
//         prefixIcon: const Icon(Icons.lock_outline_rounded,
//             size: 20, color: AppTheme.textSecondary),
//         suffixIcon: IconButton(
//           onPressed: onToggle,
//           icon: Icon(
//               showPassword
//                   ? Icons.visibility_off_rounded
//                   : Icons.visibility_rounded,
//               size: 20,
//               color: AppTheme.textSecondary),
//         ),
//         filled: true,
//         fillColor: AppTheme.background,
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.divider)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide:
//                 const BorderSide(color: AppTheme.primary, width: 1.5)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppTheme.error)),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide:
//                 const BorderSide(color: AppTheme.error, width: 1.5)),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       ),
//     );
//   }
// }

// class _PrimaryButton extends StatelessWidget {
//   final String label;
//   final String loadingLabel;
//   final IconData icon;
//   final bool isLoading;
//   final VoidCallback? onPressed;

//   const _PrimaryButton(
//       {required this.label,
//       required this.loadingLabel,
//       required this.icon,
//       required this.isLoading,
//       this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: isLoading ? null : onPressed,
//         icon: isLoading
//             ? const SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2))
//             : Icon(icon, color: Colors.white, size: 20),
//         label: Text(isLoading ? loadingLabel : label,
//             style: const TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//                 fontSize: 15)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppTheme.primary,
//           disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
//           padding: const EdgeInsets.symmetric(vertical: 15),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14)),
//           elevation: 0,
//         ),
//       ),
//     );
//   }
// }

// class _SheetOption extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _SheetOption(
//       {required this.icon,
//       required this.iconBg,
//       required this.iconColor,
//       required this.title,
//       required this.subtitle,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//               color: AppTheme.background,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppTheme.divider)),
//           child: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(10)),
//               child: Icon(icon, color: iconColor, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary)),
//               const SizedBox(height: 2),
//               Text(subtitle,
//                   style: const TextStyle(
//                       fontSize: 11,
//                       color: AppTheme.textSecondary,
//                       fontFamily: 'Poppins')),
//             ]),
//           ]),
//         ),
//       ),
//     );
//   }
// }











import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final ctrl = Get.find<ProfileController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Obx(() {
          if (ctrl.isLoading.value) return const _LoadingState();
          if (ctrl.profile.value == null) {
            return _ErrorState(onRetry: ctrl.fetchProfile);
          }
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _ProfileSliverAppBar(
                ctrl: ctrl,
                innerBoxIsScrolled: innerBoxIsScrolled,
              ),
            ],
            body: TabBarView(
              children: [
                _ProfileTab(ctrl: ctrl),
                _ChangePasswordTab(ctrl: ctrl),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SLIVER APP BAR
// ═══════════════════════════════════════════════
class _ProfileSliverAppBar extends StatelessWidget {
  final ProfileController ctrl;
  final bool innerBoxIsScrolled;
  const _ProfileSliverAppBar(
      {required this.ctrl, required this.innerBoxIsScrolled});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.cardBackground,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      title: AnimatedOpacity(
        opacity: innerBoxIsScrolled ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Obx(() => Text(
              ctrl.profile.value?.name ?? 'My Profile',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary,
              ),
            )),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.parallax,
        background: _ProfileHeader(ctrl: ctrl),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppTheme.cardBackground,
          child: const TabBar(
            labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13),
            unselectedLabelStyle:
                TextStyle(fontFamily: 'Poppins', fontSize: 13),
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'Profile'),
              Tab(icon: Icon(Icons.lock_rounded, size: 18), text: 'Password'),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  PROFILE HEADER
// ═══════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final ProfileController ctrl;
  const _ProfileHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = ctrl.profile.value;
      final hasPhoto = p?.photoUrl != null && p!.photoUrl!.isNotEmpty;

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary, AppTheme.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CompactAvatar(ctrl: ctrl, hasPhoto: hasPhoto, p: p),
                    const SizedBox(height: 6),
                    Text(
                      p?.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p?.email ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RoleBadge(role: p?.role ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════
//  COMPACT AVATAR
// ═══════════════════════════════════════════════
class _CompactAvatar extends StatelessWidget {
  final ProfileController ctrl;
  final bool hasPhoto;
  final dynamic p;

  const _CompactAvatar(
      {required this.ctrl, required this.hasPhoto, required this.p});

  bool _isLocalPath(String url) => !url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Stack(alignment: Alignment.bottomRight, children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19.5),
            child: hasPhoto
                ? _isLocalPath(p!.photoUrl!)
                    ? Image.file(
                        File(p!.photoUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AvatarInitial(name: p?.name ?? ''),
                      )
                    : Image.network(
                        p!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AvatarInitial(name: p?.name ?? ''),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary, strokeWidth: 2),
                          );
                        },
                      )
                : _AvatarInitial(name: p?.name ?? ''),
          ),
        ),
        Obx(() => Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: ctrl.isUploading.value
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_rounded,
                      color: AppTheme.primary, size: 12),
            )),
      ]),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoOptionsSheet(ctrl: ctrl, hasPhoto: hasPhoto),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  final String name;
  const _AvatarInitial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
            const SizedBox(width: 5),
            Text(role.toLowerCase(),
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins')),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  TAB 1 — Profile
// ═══════════════════════════════════════════════
class _ProfileTab extends StatefulWidget {
  final ProfileController ctrl;
  const _ProfileTab({required this.ctrl});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _isEditing = false;

  // ✅ FIX 2: Permanently lock after first save
  bool _isPermanentlyLocked = false;

  static const List<String> _departments = [
    'Administration',
    'Accounts & Finance',
    'Operations',
    'Quality Control',
    'Logistics',
    'IT & Technology',
    'Human Resources',
    'Procurement',
    'Sales & Marketing',
  ];

  static const List<String> _designations = [
    'Manager',
    'Senior Executive',
    'Executive',
    'Supervisor',
    'Team Lead',
    'Analyst',
    'Operator',
    'Assistant',
    'Intern',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ FIX 2: If profile already has data → lock on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadySaved();
    });
  }

  void _checkIfAlreadySaved() {
    final phone       = widget.ctrl.phoneCtrl.text.trim();
    final department  = widget.ctrl.departmentCtrl.text.trim();
    final designation = widget.ctrl.designationCtrl.text.trim();

    if (phone.isNotEmpty || department.isNotEmpty || designation.isNotEmpty) {
      setState(() => _isPermanentlyLocked = true);
    }
  }

  void _toggleEdit() {
    if (_isPermanentlyLocked) return; // ✅ FIX 2: block if already saved
    setState(() => _isEditing = !_isEditing);
    HapticFeedback.lightImpact();
  }

  Future<void> _saveAndLock() async {
    HapticFeedback.mediumImpact();
    final success = await widget.ctrl.updateProfile();
    if (success) {
      setState(() {
        _isEditing           = false;
        _isPermanentlyLocked = true; // ✅ FIX 2: lock forever after save
      });

      // ✅ FIX 1: Success snackbar at TOP
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        backgroundColor: AppTheme.success,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline_rounded,
            color: Colors.white, size: 22),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // ── Account Info (READ-ONLY) ─────────
              Obx(() => _SectionCard(
                    title: 'Account Info',
                    icon: Icons.badge_rounded,
                    iconColor: AppTheme.primary,
                    child: Column(children: [
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Full Name',
                        value: widget.ctrl.profile.value?.name ?? '—',
                      ),
                      const _HDivider(),
                      _InfoRow(
                        icon: Icons.alternate_email_rounded,
                        label: 'Email',
                        value: widget.ctrl.profile.value?.email ?? '—',
                      ),
                      const _HDivider(),
                      _InfoRow(
                        icon: Icons.star_rounded,
                        label: 'Role',
                        value: (widget.ctrl.profile.value?.role ?? '—')
                            .toLowerCase(),
                        valueColor: AppTheme.primary,
                      ),
                      if (widget.ctrl.profile.value?.joiningDate
                              ?.isNotEmpty ==
                          true) ...[
                        const _HDivider(),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Joining Date',
                          value: widget.ctrl.profile.value!.joiningDate!,
                        ),
                      ],
                    ]),
                  )),

              const SizedBox(height: 14),

              // ── Edit Details ─────────────────────
              _SectionCard(
                title: 'Edit Details',
                icon: Icons.edit_rounded,
                iconColor: const Color(0xFF6366F1),
                // ✅ FIX 2: Show "Saved" lock badge OR edit toggle
                trailing: _isPermanentlyLocked
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.success.withOpacity(0.4)),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 12, color: AppTheme.success),
                              SizedBox(width: 4),
                              Text('Saved',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.success)),
                            ]),
                      )
                    : GestureDetector(
                        onTap: _toggleEdit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? AppTheme.primary.withOpacity(0.12)
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isEditing
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Icon(
                              _isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_rounded,
                              size: 13,
                              color: _isEditing
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isEditing ? 'Cancel' : 'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: _isEditing
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ]),
                        ),
                      ),
                child: Column(children: [
                  // ── Phone ────────────────────────
                  _AnimatedField(
                    controller: widget.ctrl.phoneCtrl,
                    label: 'Phone',
                    icon: Icons.phone_rounded,
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing && !_isPermanentlyLocked,
                  ),
                  const SizedBox(height: 14),

                  // ── Department (Search Dropdown) ──
                  _AnimatedDropdown(
                    controller: widget.ctrl.departmentCtrl,
                    label: 'Department',
                    icon: Icons.corporate_fare_rounded,
                    hint: 'Select Department',
                    items: _departments,
                    enabled: _isEditing && !_isPermanentlyLocked,
                  ),
                  const SizedBox(height: 14),

                  // ── Designation (Search Dropdown) ─
                  _AnimatedDropdown(
                    controller: widget.ctrl.designationCtrl,
                    label: 'Designation',
                    icon: Icons.work_rounded,
                    hint: 'Select Designation',
                    items: _designations,
                    enabled: _isEditing && !_isPermanentlyLocked,
                  ),
                  const SizedBox(height: 14),

                  // ── Emergency Contact ─────────────
                  _AnimatedField(
                    controller: widget.ctrl.emergencyContactCtrl,
                    label: 'Emergency Contact',
                    icon: Icons.emergency_rounded,
                    hint: 'Emergency contact number',
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing && !_isPermanentlyLocked,
                  ),
                  const SizedBox(height: 14),

                  // ── Address ───────────────────────
                  _AnimatedField(
                    controller: widget.ctrl.addressCtrl,
                    label: 'Address',
                    icon: Icons.location_on_rounded,
                    hint: 'Enter your address',
                    maxLines: 3,
                    enabled: _isEditing && !_isPermanentlyLocked,
                  ),
                ]),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),

        // ── Sticky Save Button (only when editing & not locked) ──
        if (_isEditing && !_isPermanentlyLocked)
          _StickyBottomBar(
            child: Obx(() => _PrimaryButton(
                  label: 'Save Changes',
                  loadingLabel: 'Saving...',
                  icon: Icons.save_rounded,
                  isLoading: widget.ctrl.isSaving.value,
                  onPressed: _saveAndLock,
                )),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  TAB 2 — Change Password
// ═══════════════════════════════════════════════
class _ChangePasswordTab extends StatefulWidget {
  final ProfileController ctrl;
  const _ChangePasswordTab({required this.ctrl});

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  void _evaluateStrength(String pass) {
    double s = 0;
    if (pass.length >= 6) s += 0.25;
    if (pass.length >= 10) s += 0.15;
    if (pass.contains(RegExp(r'[A-Z]'))) s += 0.2;
    if (pass.contains(RegExp(r'[0-9]'))) s += 0.2;
    if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s += 0.2;
    setState(() {
      _strength = s.clamp(0.0, 1.0);
      if (s <= 0.25) {
        _strengthLabel = 'Weak';
        _strengthColor = AppTheme.error;
      } else if (s <= 0.5) {
        _strengthLabel = 'Fair';
        _strengthColor = const Color(0xFFF59E0B);
      } else if (s <= 0.75) {
        _strengthLabel = 'Good';
        _strengthColor = const Color(0xFF3B82F6);
      } else {
        _strengthLabel = 'Strong';
        _strengthColor = const Color(0xFF10B981);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Form(
              key: _formKey,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.primary.withOpacity(0.08),
                      AppTheme.secondary.withOpacity(0.05),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.15)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.security_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Keep your account secure',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textPrimary)),
                            SizedBox(height: 3),
                            Text('Use uppercase, numbers & symbols.',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Poppins',
                                    color: AppTheme.textSecondary)),
                          ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  title: 'Update Password',
                  icon: Icons.lock_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  child: Column(children: [
                    _PasswordField(
                      controller: widget.ctrl.currentPasswordCtrl,
                      label: 'Current Password',
                      showPassword: _showCurrent,
                      onToggle: () =>
                          setState(() => _showCurrent = !_showCurrent),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Current password is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _PasswordField(
                      controller: widget.ctrl.newPasswordCtrl,
                      label: 'New Password',
                      showPassword: _showNew,
                      onToggle: () => setState(() => _showNew = !_showNew),
                      onChanged: _evaluateStrength,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'New password is required';
                        if (v.trim().length < 6)
                          return 'Minimum 6 characters required';
                        return null;
                      },
                    ),
                    if (_strength > 0) ...[
                      const SizedBox(height: 10),
                      _PasswordStrengthBar(
                        strength: _strength,
                        label: _strengthLabel,
                        color: _strengthColor,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _PasswordField(
                      controller: widget.ctrl.confirmPasswordCtrl,
                      label: 'Confirm New Password',
                      showPassword: _showConfirm,
                      onToggle: () =>
                          setState(() => _showConfirm = !_showConfirm),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please confirm your password';
                        if (v.trim() !=
                            widget.ctrl.newPasswordCtrl.text.trim()) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),

        _StickyBottomBar(
          child: Obx(() => _PrimaryButton(
                label: 'Update Password',
                loadingLabel: 'Updating...',
                icon: Icons.lock_reset_rounded,
                isLoading: widget.ctrl.isChangingPassword.value,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  if (_formKey.currentState!.validate()) {
                    await widget.ctrl.changePassword();
                  }
                },
              )),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  STICKY BOTTOM BAR
// ═══════════════════════════════════════════════
class _StickyBottomBar extends StatelessWidget {
  final Widget child;
  const _StickyBottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════
//  PASSWORD STRENGTH BAR (Animated)
// ═══════════════════════════════════════════════
class _PasswordStrengthBar extends StatefulWidget {
  final double strength;
  final String label;
  final Color color;
  const _PasswordStrengthBar(
      {required this.strength, required this.label, required this.color});

  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: widget.strength)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void didUpdateWidget(_PasswordStrengthBar old) {
    super.didUpdateWidget(old);
    _anim = Tween<double>(begin: old.strength, end: widget.strength)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward(from: 0);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => LinearProgressIndicator(
              value: _anim.value,
              minHeight: 5,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(widget.label,
          style: TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: widget.color)),
    ]);
  }
}

// ═══════════════════════════════════════════════
//  LOADING / ERROR STATES
// ═══════════════════════════════════════════════
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Loading profile...',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: AppTheme.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.person_off_rounded,
                  color: AppTheme.primary, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Could not load profile',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  PHOTO OPTIONS SHEET
// ═══════════════════════════════════════════════
class _PhotoOptionsSheet extends StatelessWidget {
  final ProfileController ctrl;
  final bool hasPhoto;
  const _PhotoOptionsSheet({required this.ctrl, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.photo_camera_rounded,
              color: AppTheme.primary, size: 30),
        ),
        const SizedBox(height: 12),
        const Text('Profile Photo',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('Update your profile picture',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        _SheetOption(
          icon: Icons.photo_library_rounded,
          iconBg: AppTheme.primaryLight,
          iconColor: AppTheme.primary,
          title: 'Choose from Gallery',
          subtitle: 'Pick a photo from your device',
          onTap: () {
            Get.back();
            ctrl.pickAndUploadPhoto();
          },
        ),
        if (hasPhoto) ...[
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.delete_outline_rounded,
            iconBg: AppTheme.errorLight,
            iconColor: AppTheme.error,
            title: 'Remove Photo',
            subtitle: 'Delete your current profile picture',
            onTap: () {
              Get.back();
              ctrl.deletePhoto();
            },
          ),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════════
//  ANIMATED FIELD
// ═══════════════════════════════════════════════
class _AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const _AnimatedField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(
        () => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: (_isFocused && widget.enabled)
            ? [
                BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 8,
                    spreadRadius: 1)
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        validator: widget.validator,
        enabled: widget.enabled,
        style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: widget.enabled
                ? AppTheme.textPrimary
                : AppTheme.textSecondary),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppTheme.textHint),
          labelStyle: const TextStyle(
              fontFamily: 'Poppins', color: AppTheme.textSecondary),
          prefixIcon: Icon(widget.icon,
              size: 20,
              color: (_isFocused && widget.enabled)
                  ? AppTheme.primary
                  : AppTheme.textSecondary),
          filled: true,
          fillColor: widget.enabled
              ? AppTheme.background
              : AppTheme.background.withOpacity(0.5),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.error, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ANIMATED DROPDOWN  ✅ SEARCH ICON VERSION
// ═══════════════════════════════════════════════
class _AnimatedDropdown extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final List<String> items;
  final bool enabled;

  const _AnimatedDropdown({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    required this.items,
    this.enabled = true,
  });

  void _openSearchSheet(BuildContext context) {
    if (!enabled) return;
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableDropdownSheet(
        title: label,
        items: items,
        selected: controller.text,
        onSelected: (val) => controller.text = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        enabled: enabled,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppTheme.textHint,
          ),
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            color: enabled ? AppTheme.textSecondary : AppTheme.textHint,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: enabled ? AppTheme.primary : AppTheme.textSecondary,
          ),
          suffixIcon: enabled
              ? IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                  onPressed: () => _openSearchSheet(context),
                )
              : const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
          filled: true,
          fillColor: enabled
              ? AppTheme.background
              : AppTheme.background.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SEARCHABLE DROPDOWN BOTTOM SHEET
// ═══════════════════════════════════════════════
class _SearchableDropdownSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownSheet> createState() =>
      _SearchableDropdownSheetState();
}

class _SearchableDropdownSheetState
    extends State<_SearchableDropdownSheet> {
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_filter);
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((e) => e.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Select ${widget.title}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title}...',
                  hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.textHint),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.primary, size: 20),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (_, value, __) => value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 18,
                                color: AppTheme.textSecondary),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppTheme.divider),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 44,
                              color: AppTheme.textSecondary
                                  .withOpacity(0.35)),
                          const SizedBox(height: 10),
                          const Text('No results found',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: AppTheme.divider),
                      itemBuilder: (_, i) {
                        final item = _filtered[i];
                        final isSelected = item == widget.selected;
                        return ListTile(
                          onTap: () {
                            widget.onSelected(item);
                            Get.back();
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryLight
                                  : AppTheme.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.label_outline_rounded,
                              size: 16,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          title: Text(
                            item,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.primary, size: 20)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  SECTION CARD
// ═══════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: AppTheme.textPrimary)),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppTheme.divider),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }
}

class _HDivider extends StatelessWidget {
  const _HDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppTheme.divider);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: AppTheme.textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: valueColor ?? AppTheme.textPrimary)),
          ]),
        ),
      ]),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool showPassword;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.showPassword,
    required this.onToggle,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontFamily: 'Poppins', color: AppTheme.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            size: 20, color: AppTheme.textSecondary),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
              showPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: AppTheme.textSecondary),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.error, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton(
      {required this.label,
      required this.loadingLabel,
      required this.icon,
      required this.isLoading,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(icon, color: Colors.white, size: 20),
        label: Text(isLoading ? loadingLabel : label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption(
      {required this.icon,
      required this.iconBg,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider)),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Poppins')),
            ]),
          ]),
        ),
      ),
    );
  }
}