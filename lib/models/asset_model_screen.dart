// // lib/screens/asset/asset_model_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../core/theme/app_theme.dart';

// class AssetModelScreen extends StatelessWidget {
//   final AssetModel asset;
//   const AssetModelScreen({super.key, required this.asset});

//   // ── Static Helpers ────────────────────────────────────────────────────
//   static Color statusColor(String s) {
//     switch (s.toLowerCase()) {
//       case 'assigned':    return AppTheme.primary;
//       case 'available':   return AppTheme.success;
//       case 'maintenance': return AppTheme.warning;
//       default:            return AppTheme.textSecondary;
//     }
//   }

//   static IconData statusIcon(String s) {
//     switch (s.toLowerCase()) {
//       case 'assigned':    return Icons.person_rounded;
//       case 'available':   return Icons.check_circle_rounded;
//       case 'maintenance': return Icons.build_rounded;
//       default:            return Icons.device_unknown_rounded;
//     }
//   }

//   static Color typeColor(String t) {
//     switch (t.toLowerCase()) {
//       case 'laptop':   return const Color(0xFF6366F1);
//       case 'mobile':   return const Color(0xFF0EA5E9);
//       case 'tablet':   return const Color(0xFF8B5CF6);
//       case 'monitor':  return const Color(0xFF10B981);
//       case 'keyboard': return const Color(0xFFF59E0B);
//       case 'mouse':    return const Color(0xFFEF4444);
//       default:         return AppTheme.accent;
//     }
//   }

//   static IconData typeIcon(String t) {
//     switch (t.toLowerCase()) {
//       case 'laptop':   return Icons.laptop_rounded;
//       case 'mobile':   return Icons.smartphone_rounded;
//       case 'tablet':   return Icons.tablet_rounded;
//       case 'monitor':  return Icons.monitor_rounded;
//       case 'keyboard': return Icons.keyboard_rounded;
//       case 'mouse':    return Icons.mouse_rounded;
//       default:         return Icons.devices_rounded;
//     }
//   }

//   bool get _isOverdue =>
//       asset.expectedReturnDate != null &&
//       DateTime.now().isAfter(asset.expectedReturnDate!);

//   int get _daysLeft => asset.expectedReturnDate != null
//       ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
//       : -1;

//   void _copy(BuildContext context, String value, String label) {
//     Clipboard.setData(ClipboardData(text: value));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$label copied!',
//             style: const TextStyle(fontFamily: 'Poppins')),
//         backgroundColor: AppTheme.success,
//         behavior: SnackBarBehavior.floating,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tc = typeColor(asset.assetType);
//     final ti = typeIcon(asset.assetType);
//     final sc = statusColor(asset.status);
//     final si = statusIcon(asset.status);

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // ── Hero Header ───────────────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 230,
//             pinned: true,
//             backgroundColor: tc,
//             elevation: 0,
//             leading: IconButton(
//               icon: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.arrow_back_ios_rounded,
//                     color: Colors.white, size: 16),
//               ),
//               onPressed: () => Get.back(),
//             ),
//             actions: [
//               IconButton(
//                 icon: Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.share_rounded,
//                       color: Colors.white, size: 18),
//                 ),
//                 onPressed: () {
//                   _copy(
//                     context,
//                     'Asset: ${asset.assetName}\nCode: ${asset.assetCode}\nSerial: ${asset.serialNumber}\nStatus: ${asset.status}',
//                     'Asset info',
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [tc, tc.withOpacity(0.75)],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           Container(
//                             width: 68,
//                             height: 68,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                   color: Colors.white.withOpacity(0.3),
//                                   width: 1.5),
//                             ),
//                             child: Icon(ti, color: Colors.white, size: 34),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   asset.assetName,
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w800,
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     height: 1.2,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(
//                                   '${asset.brand}  ·  ${asset.model}',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white.withOpacity(0.85),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                         color:
//                                             Colors.white.withOpacity(0.3)),
//                                   ),
//                                   child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(si, size: 12, color: Colors.white),
//                                         const SizedBox(width: 5),
//                                         Text(
//                                           asset.status,
//                                           style: const TextStyle(
//                                             fontSize: 11,
//                                             fontWeight: FontWeight.w700,
//                                             fontFamily: 'Poppins',
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // ── Body ──────────────────────────────────────────────────────
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 22, 18, 50),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([

//                 // ── Quick Stats Row ────────────────────────────────────
//                 Row(children: [
//                   _StatChip(
//                     icon: Icons.qr_code_rounded,
//                     label: 'Code',
//                     value: asset.assetCode,
//                     color: tc,
//                     onTap: () => _copy(context, asset.assetCode, 'Asset Code'),
//                   ),
//                   const SizedBox(width: 10),
//                   _StatChip(
//                     icon: Icons.category_rounded,
//                     label: 'Type',
//                     value: asset.assetType,
//                     color: const Color(0xFF8B5CF6),
//                   ),
//                   const SizedBox(width: 10),
//                   _StatChip(
//                     icon: si,
//                     label: 'Status',
//                     value: asset.status,
//                     color: sc,
//                   ),
//                 ]),
//                 const SizedBox(height: 22),

//                 // ── Asset Identity ─────────────────────────────────────
//                 _SectionHeader(
//                     title: 'Asset Identity',
//                     icon: Icons.badge_rounded,
//                     iconColor: tc),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: Icons.qr_code_rounded,
//                     iconColor: AppTheme.primary,
//                     label: 'Asset Code',
//                     value: asset.assetCode,
//                     onCopy: () =>
//                         _copy(context, asset.assetCode, 'Asset Code'),
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: Icons.tag_rounded,
//                     iconColor: const Color(0xFF6366F1),
//                     label: 'Serial Number',
//                     value: asset.serialNumber,
//                     onCopy: () =>
//                         _copy(context, asset.serialNumber, 'Serial Number'),
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: typeIcon(asset.assetType),
//                     iconColor: tc,
//                     label: 'Asset Type',
//                     value: asset.assetType,
//                   ),
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Model Information ──────────────────────────────────
//                 _SectionHeader(
//                     title: 'Model Information',
//                     icon: Icons.memory_rounded,
//                     iconColor: const Color(0xFF8B5CF6)),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: Icons.business_rounded,
//                     iconColor: const Color(0xFF0EA5E9),
//                     label: 'Brand',
//                     value: asset.brand,
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: Icons.memory_rounded,
//                     iconColor: const Color(0xFF8B5CF6),
//                     label: 'Model',
//                     value: asset.model,
//                   ),
//                   if (asset.description.isNotEmpty) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.description_rounded,
//                       iconColor: AppTheme.textSecondary,
//                       label: 'Description',
//                       value: asset.description,
//                       isMultiline: true,
//                     ),
//                   ],
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Assignment Details ─────────────────────────────────
//                 _SectionHeader(
//                     title: 'Assignment Details',
//                     icon: Icons.assignment_ind_rounded,
//                     iconColor: sc),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: si,
//                     iconColor: sc,
//                     label: 'Current Status',
//                     value: asset.status,
//                     trailing: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: sc.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         asset.status,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: sc,
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (asset.assignedToName != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.person_rounded,
//                       iconColor: AppTheme.primary,
//                       label: 'Assigned To',
//                       value: asset.assignedToName!,
//                     ),
//                   ],
//                   if (asset.assignedToUserId != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.numbers_rounded,
//                       iconColor: AppTheme.textSecondary,
//                       label: 'User ID',
//                       value: '#${asset.assignedToUserId}',
//                     ),
//                   ],
//                   if (asset.expectedReturnDate != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.event_rounded,
//                       iconColor:
//                           _isOverdue ? AppTheme.error : AppTheme.success,
//                       label: 'Expected Return',
//                       value: DateFormat('EEEE, dd MMMM yyyy')
//                           .format(asset.expectedReturnDate!),
//                       isMultiline: true,
//                       trailing: _isOverdue
//                           ? Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.errorLight,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Text(
//                                 'OVERDUE',
//                                 style: TextStyle(
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.w800,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.error,
//                                 ),
//                               ),
//                             )
//                           : _daysLeft <= 3
//                               ? Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.warning.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '$_daysLeft days',
//                                     style: const TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Poppins',
//                                       color: AppTheme.warning,
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.success.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '$_daysLeft days left',
//                                     style: const TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Poppins',
//                                       color: AppTheme.success,
//                                     ),
//                                   ),
//                                 ),
//                     ),
//                   ],
//                   if (asset.assignmentNote != null &&
//                       asset.assignmentNote!.isNotEmpty) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.sticky_note_2_rounded,
//                       iconColor: const Color(0xFFF59E0B),
//                       label: 'Assignment Note',
//                       value: asset.assignmentNote!,
//                       isMultiline: true,
//                     ),
//                   ],
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Status Banner ──────────────────────────────────────
//                 _StatusBanner(
//                   status: asset.status,
//                   statusColor: sc,
//                   statusIcon: si,
//                   assignedToName: asset.assignedToName,
//                   expectedReturnDate: asset.expectedReturnDate,
//                   isOverdue: _isOverdue,
//                   daysLeft: _daysLeft,
//                 ),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STAT CHIP
// // ─────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//   final VoidCallback? onTap;

//   const _StatChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//           decoration: AppTheme.cardDecoration(),
//           child: Column(children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//             const SizedBox(height: 7),
//             Text(
//               value,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textHint,
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SECTION HEADER
// // ─────────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color iconColor;

//   const _SectionHeader({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Container(
//         padding: const EdgeInsets.all(7),
//         decoration: BoxDecoration(
//           color: iconColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(9),
//         ),
//         child: Icon(icon, size: 16, color: iconColor),
//       ),
//       const SizedBox(width: 10),
//       Text(
//         title,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w700,
//           fontFamily: 'Poppins',
//           color: AppTheme.textPrimary,
//         ),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  DETAIL CARD
// // ─────────────────────────────────────────────
// class _DetailCard extends StatelessWidget {
//   final List<Widget> children;
//   const _DetailCard({required this.children});

//   @override
//   Widget build(BuildContext context) => Container(
//       decoration: AppTheme.cardDecoration(),
//       child: Column(children: children));
// }

// class _CardDivider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Divider(height: 1, color: AppTheme.divider));
// }

// // ─────────────────────────────────────────────
// //  DETAIL ROW
// // ─────────────────────────────────────────────
// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String label;
//   final String value;
//   final bool isMultiline;
//   final Widget? trailing;
//   final VoidCallback? onCopy;

//   const _DetailRow({
//     required this.icon,
//     required this.iconColor,
//     required this.label,
//     required this.value,
//     this.isMultiline = false,
//     this.trailing,
//     this.onCopy,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: onCopy,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           crossAxisAlignment:
//               isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               child: Icon(icon, size: 18, color: iconColor),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.textHint,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       value,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.textPrimary,
//                         fontWeight: FontWeight.w600,
//                         height: 1.4,
//                       ),
//                     ),
//                   ]),
//             ),
//             if (trailing != null) ...[const SizedBox(width: 8), trailing!],
//             if (onCopy != null) ...[
//               const SizedBox(width: 6),
//               const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textHint),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STATUS BANNER
// // ─────────────────────────────────────────────
// class _StatusBanner extends StatelessWidget {
//   final String status;
//   final Color statusColor;
//   final IconData statusIcon;
//   final String? assignedToName;
//   final DateTime? expectedReturnDate;
//   final bool isOverdue;
//   final int daysLeft;

//   const _StatusBanner({
//     required this.status,
//     required this.statusColor,
//     required this.statusIcon,
//     this.assignedToName,
//     this.expectedReturnDate,
//     required this.isOverdue,
//     required this.daysLeft,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String message;
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         message = assignedToName != null
//             ? 'This asset is currently assigned to $assignedToName.'
//             : 'This asset is currently assigned to an employee.';
//         break;
//       case 'available':
//         message = 'This asset is available and ready to be assigned to any employee.';
//         break;
//       case 'maintenance':
//         message = 'This asset is currently undergoing maintenance and is not available.';
//         break;
//       default:
//         message = 'Current asset status is: $status.';
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isOverdue
//             ? AppTheme.errorLight
//             : statusColor.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isOverdue
//               ? AppTheme.error.withOpacity(0.3)
//               : statusColor.withOpacity(0.2),
//         ),
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(9),
//           decoration: BoxDecoration(
//             color: isOverdue
//                 ? AppTheme.error.withOpacity(0.15)
//                 : statusColor.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(11),
//           ),
//           child: Icon(
//             isOverdue ? Icons.warning_rounded : statusIcon,
//             size: 18,
//             color: isOverdue ? AppTheme.error : statusColor,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isOverdue ? 'Return Overdue!' : 'Current Status',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w700,
//                     color: isOverdue ? AppTheme.error : statusColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   isOverdue
//                       ? 'This asset was due on ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}. Please return it immediately.'
//                       : message,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontFamily: 'Poppins',
//                     color: isOverdue
//                         ? AppTheme.error.withOpacity(0.85)
//                         : statusColor.withOpacity(0.85),
//                     height: 1.5,
//                   ),
//                 ),
//                 if (!isOverdue &&
//                     expectedReturnDate != null &&
//                     daysLeft >= 0) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     'Return by: ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}  ·  $daysLeft day${daysLeft != 1 ? 's' : ''} remaining',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       color: daysLeft <= 3
//                           ? AppTheme.warning
//                           : statusColor,
//                     ),
//                   ),
//                 ],
//               ]),
//         ),
//       ]),
//     );
//   }
// }












// // lib/screens/asset/asset_model_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../core/theme/app_theme.dart';

// class AssetModelScreen extends StatelessWidget {
//   final AssetModel asset;
//   const AssetModelScreen({super.key, required this.asset});

//   // ── Static Helpers ────────────────────────────────────────────────────
//   static Color statusColor(String s) {
//     switch (s.toLowerCase()) {
//       case 'assigned':    return AppTheme.primary;
//       case 'available':   return AppTheme.success;
//       case 'maintenance': return AppTheme.warning;
//       default:            return AppTheme.textSecondary;
//     }
//   }

//   static IconData statusIcon(String s) {
//     switch (s.toLowerCase()) {
//       case 'assigned':    return Icons.person_rounded;
//       case 'available':   return Icons.check_circle_rounded;
//       case 'maintenance': return Icons.build_rounded;
//       default:            return Icons.device_unknown_rounded;
//     }
//   }

//   static Color typeColor(String t) {
//     switch (t.toLowerCase()) {
//       case 'laptop':   return const Color(0xFF6366F1);
//       case 'mobile':   return const Color(0xFF0EA5E9);
//       case 'tablet':   return const Color(0xFF8B5CF6);
//       case 'monitor':  return const Color(0xFF10B981);
//       case 'keyboard': return const Color(0xFFF59E0B);
//       case 'mouse':    return const Color(0xFFEF4444);
//       default:         return AppTheme.accent;
//     }
//   }

//   static IconData typeIcon(String t) {
//     switch (t.toLowerCase()) {
//       case 'laptop':   return Icons.laptop_rounded;
//       case 'mobile':   return Icons.smartphone_rounded;
//       case 'tablet':   return Icons.tablet_rounded;
//       case 'monitor':  return Icons.monitor_rounded;
//       case 'keyboard': return Icons.keyboard_rounded;
//       case 'mouse':    return Icons.mouse_rounded;
//       default:         return Icons.devices_rounded;
//     }
//   }

//   bool get _isOverdue =>
//       asset.expectedReturnDate != null &&
//       DateTime.now().isAfter(asset.expectedReturnDate!);

//   int get _daysLeft => asset.expectedReturnDate != null
//       ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
//       : -1;

//   void _copy(BuildContext context, String value, String label) {
//     Clipboard.setData(ClipboardData(text: value));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$label copied!',
//             style: const TextStyle(fontFamily: 'Poppins')),
//         backgroundColor: AppTheme.success,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tc = typeColor(asset.assetType);
//     final ti = typeIcon(asset.assetType);
//     final sc = statusColor(asset.status);
//     final si = statusIcon(asset.status);

//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // ── Hero Header ───────────────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 230,
//             pinned: true,
//             backgroundColor: tc,
//             elevation: 0,
//             leading: IconButton(
//               icon: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.arrow_back_ios_rounded,
//                     color: Colors.white, size: 16),
//               ),
//               onPressed: () => Get.back(),
//             ),
//             actions: [
//               IconButton(
//                 icon: Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.share_rounded,
//                       color: Colors.white, size: 18),
//                 ),
//                 onPressed: () {
//                   _copy(
//                     context,
//                     'Asset: ${asset.assetName}\nCode: ${asset.assetCodeSafe}\nSerial: ${asset.serialNumberSafe}\nStatus: ${asset.status}',
//                     'Asset info',
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [tc, tc.withOpacity(0.75)],
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           Container(
//                             width: 68,
//                             height: 68,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                   color: Colors.white.withOpacity(0.3),
//                                   width: 1.5),
//                             ),
//                             child: Icon(ti, color: Colors.white, size: 34),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   asset.assetName,
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w800,
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white,
//                                     height: 1.2,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 // Fix: brand/model nullable → use safe getters
//                                 Text(
//                                   '${asset.brandSafe}  ·  ${asset.modelSafe}',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontFamily: 'Poppins',
//                                     color: Colors.white.withOpacity(0.85),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(20),
//                                     border: Border.all(
//                                         color: Colors.white.withOpacity(0.3)),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(si, size: 12, color: Colors.white),
//                                       const SizedBox(width: 5),
//                                       Text(
//                                         asset.status,
//                                         style: const TextStyle(
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w700,
//                                           fontFamily: 'Poppins',
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // ── Body ──────────────────────────────────────────────────────
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(18, 22, 18, 50),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([

//                 // ── Quick Stats Row ────────────────────────────────────
//                 Row(children: [
//                   _StatChip(
//                     icon: Icons.qr_code_rounded,
//                     label: 'Code',
//                     // Fix: assetCode nullable → assetCodeSafe
//                     value: asset.assetCodeSafe,
//                     color: tc,
//                     onTap: () => _copy(context, asset.assetCodeSafe, 'Asset Code'),
//                   ),
//                   const SizedBox(width: 10),
//                   _StatChip(
//                     icon: Icons.category_rounded,
//                     label: 'Type',
//                     value: asset.assetType,
//                     color: const Color(0xFF8B5CF6),
//                   ),
//                   const SizedBox(width: 10),
//                   _StatChip(
//                     icon: si,
//                     label: 'Status',
//                     value: asset.status,
//                     color: sc,
//                   ),
//                 ]),
//                 const SizedBox(height: 22),

//                 // ── Asset Identity ─────────────────────────────────────
//                 _SectionHeader(
//                     title: 'Asset Identity',
//                     icon: Icons.badge_rounded,
//                     iconColor: tc),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: Icons.qr_code_rounded,
//                     iconColor: AppTheme.primary,
//                     label: 'Asset Code',
//                     // Fix: nullable → safe getter
//                     value: asset.assetCodeSafe,
//                     onCopy: () => _copy(context, asset.assetCodeSafe, 'Asset Code'),
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: Icons.tag_rounded,
//                     iconColor: const Color(0xFF6366F1),
//                     label: 'Serial Number',
//                     // Fix: nullable → safe getter
//                     value: asset.serialNumberSafe,
//                     onCopy: () => _copy(context, asset.serialNumberSafe, 'Serial Number'),
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: typeIcon(asset.assetType),
//                     iconColor: tc,
//                     label: 'Asset Type',
//                     value: asset.assetType,
//                   ),
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Model Information ──────────────────────────────────
//                 _SectionHeader(
//                     title: 'Model Information',
//                     icon: Icons.memory_rounded,
//                     iconColor: const Color(0xFF8B5CF6)),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: Icons.business_rounded,
//                     iconColor: const Color(0xFF0EA5E9),
//                     label: 'Brand',
//                     // Fix: nullable → safe getter
//                     value: asset.brandSafe,
//                   ),
//                   _CardDivider(),
//                   _DetailRow(
//                     icon: Icons.memory_rounded,
//                     iconColor: const Color(0xFF8B5CF6),
//                     label: 'Model',
//                     // Fix: nullable → safe getter
//                     value: asset.modelSafe,
//                   ),
//                   // Fix: description nullable — use ?. instead of .
//                   if (asset.description?.isNotEmpty ?? false) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.description_rounded,
//                       iconColor: AppTheme.textSecondary,
//                       label: 'Description',
//                       value: asset.descriptionSafe,
//                       isMultiline: true,
//                     ),
//                   ],
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Assignment Details ─────────────────────────────────
//                 _SectionHeader(
//                     title: 'Assignment Details',
//                     icon: Icons.assignment_ind_rounded,
//                     iconColor: sc),
//                 const SizedBox(height: 10),
//                 _DetailCard(children: [
//                   _DetailRow(
//                     icon: si,
//                     iconColor: sc,
//                     label: 'Current Status',
//                     value: asset.status,
//                     trailing: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: sc.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         asset.status,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           fontFamily: 'Poppins',
//                           color: sc,
//                         ),
//                       ),
//                     ),
//                   ),
//                   // assignedToName is a getter → String? (fine to use != null check)
//                   if (asset.assignedToName != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.person_rounded,
//                       iconColor: AppTheme.primary,
//                       label: 'Assigned To',
//                       value: asset.assignedToName!,
//                     ),
//                   ],
//                   if (asset.assignedToUserId != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.numbers_rounded,
//                       iconColor: AppTheme.textSecondary,
//                       label: 'User ID',
//                       value: '#${asset.assignedToUserId}',
//                     ),
//                   ],
//                   if (asset.expectedReturnDate != null) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.event_rounded,
//                       iconColor: _isOverdue ? AppTheme.error : AppTheme.success,
//                       label: 'Expected Return',
//                       value: DateFormat('EEEE, dd MMMM yyyy')
//                           .format(asset.expectedReturnDate!),
//                       isMultiline: true,
//                       trailing: _isOverdue
//                           ? Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.errorLight,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Text(
//                                 'OVERDUE',
//                                 style: TextStyle(
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.w800,
//                                   fontFamily: 'Poppins',
//                                   color: AppTheme.error,
//                                 ),
//                               ),
//                             )
//                           : _daysLeft <= 3
//                               ? Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.warning.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '$_daysLeft days',
//                                     style: const TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Poppins',
//                                       color: AppTheme.warning,
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 3),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.success.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '$_daysLeft days left',
//                                     style: const TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Poppins',
//                                       color: AppTheme.success,
//                                     ),
//                                   ),
//                                 ),
//                     ),
//                   ],
//                   if (asset.assignmentNote != null &&
//                       asset.assignmentNote!.isNotEmpty) ...[
//                     _CardDivider(),
//                     _DetailRow(
//                       icon: Icons.sticky_note_2_rounded,
//                       iconColor: const Color(0xFFF59E0B),
//                       label: 'Assignment Note',
//                       value: asset.assignmentNote!,
//                       isMultiline: true,
//                     ),
//                   ],
//                 ]),
//                 const SizedBox(height: 20),

//                 // ── Status Banner ──────────────────────────────────────
//                 _StatusBanner(
//                   status: asset.status,
//                   statusColor: sc,
//                   statusIcon: si,
//                   // assignedToName is a getter → fine
//                   assignedToName: asset.assignedToName,
//                   expectedReturnDate: asset.expectedReturnDate,
//                   isOverdue: _isOverdue,
//                   daysLeft: _daysLeft,
//                 ),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STAT CHIP
// // ─────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//   final VoidCallback? onTap;

//   const _StatChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//           decoration: AppTheme.cardDecoration(),
//           child: Column(children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, size: 16, color: color),
//             ),
//             const SizedBox(height: 7),
//             Text(
//               value,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 fontFamily: 'Poppins',
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 10,
//                 fontFamily: 'Poppins',
//                 color: AppTheme.textHint,
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  SECTION HEADER
// // ─────────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color iconColor;

//   const _SectionHeader({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Container(
//         padding: const EdgeInsets.all(7),
//         decoration: BoxDecoration(
//           color: iconColor.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(9),
//         ),
//         child: Icon(icon, size: 16, color: iconColor),
//       ),
//       const SizedBox(width: 10),
//       Text(
//         title,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w700,
//           fontFamily: 'Poppins',
//           color: AppTheme.textPrimary,
//         ),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  DETAIL CARD
// // ─────────────────────────────────────────────
// class _DetailCard extends StatelessWidget {
//   final List<Widget> children;
//   const _DetailCard({required this.children});

//   @override
//   Widget build(BuildContext context) => Container(
//       decoration: AppTheme.cardDecoration(),
//       child: Column(children: children));
// }

// class _CardDivider extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Divider(height: 1, color: AppTheme.divider));
// }

// // ─────────────────────────────────────────────
// //  DETAIL ROW
// // ─────────────────────────────────────────────
// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String label;
//   final String value;
//   final bool isMultiline;
//   final Widget? trailing;
//   final VoidCallback? onCopy;

//   const _DetailRow({
//     required this.icon,
//     required this.iconColor,
//     required this.label,
//     required this.value,
//     this.isMultiline = false,
//     this.trailing,
//     this.onCopy,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: onCopy,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           crossAxisAlignment:
//               isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               child: Icon(icon, size: 18, color: iconColor),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textHint,
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontFamily: 'Poppins',
//                       color: AppTheme.textPrimary,
//                       fontWeight: FontWeight.w600,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) ...[const SizedBox(width: 8), trailing!],
//             if (onCopy != null) ...[
//               const SizedBox(width: 6),
//               const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textHint),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  STATUS BANNER
// // ─────────────────────────────────────────────
// class _StatusBanner extends StatelessWidget {
//   final String status;
//   final Color statusColor;
//   final IconData statusIcon;
//   final String? assignedToName;
//   final DateTime? expectedReturnDate;
//   final bool isOverdue;
//   final int daysLeft;

//   const _StatusBanner({
//     required this.status,
//     required this.statusColor,
//     required this.statusIcon,
//     this.assignedToName,
//     this.expectedReturnDate,
//     required this.isOverdue,
//     required this.daysLeft,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String message;
//     switch (status.toLowerCase()) {
//       case 'assigned':
//         message = assignedToName != null
//             ? 'This asset is currently assigned to $assignedToName.'
//             : 'This asset is currently assigned to an employee.';
//         break;
//       case 'available':
//         message =
//             'This asset is available and ready to be assigned to any employee.';
//         break;
//       case 'maintenance':
//         message =
//             'This asset is currently undergoing maintenance and is not available.';
//         break;
//       default:
//         message = 'Current asset status is: $status.';
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isOverdue ? AppTheme.errorLight : statusColor.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isOverdue
//               ? AppTheme.error.withOpacity(0.3)
//               : statusColor.withOpacity(0.2),
//         ),
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(9),
//           decoration: BoxDecoration(
//             color: isOverdue
//                 ? AppTheme.error.withOpacity(0.15)
//                 : statusColor.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(11),
//           ),
//           child: Icon(
//             isOverdue ? Icons.warning_rounded : statusIcon,
//             size: 18,
//             color: isOverdue ? AppTheme.error : statusColor,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isOverdue ? 'Return Overdue!' : 'Current Status',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w700,
//                   color: isOverdue ? AppTheme.error : statusColor,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 isOverdue
//                     ? 'This asset was due on ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}. Please return it immediately.'
//                     : message,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontFamily: 'Poppins',
//                   color: isOverdue
//                       ? AppTheme.error.withOpacity(0.85)
//                       : statusColor.withOpacity(0.85),
//                   height: 1.5,
//                 ),
//               ),
//               if (!isOverdue && expectedReturnDate != null && daysLeft >= 0) ...[
//                 const SizedBox(height: 6),
//                 Text(
//                   'Return by: ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}  ·  $daysLeft day${daysLeft != 1 ? 's' : ''} remaining',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w600,
//                     color: daysLeft <= 3 ? AppTheme.warning : statusColor,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ]),
//     );
//   }
// }

















// lib/models/asset_model_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
//  MAINTENANCE STATUS CONSTANTS
// ─────────────────────────────────────────────
class MaintenanceStatus {
  static const String open       = 'open';
  static const String inProgress = 'in_progress';
  static const String completed  = 'completed';
}

// ─────────────────────────────────────────────
//  ASSET STATUS CONSTANTS
// ─────────────────────────────────────────────
class AssetStatus {
  static const String available   = 'available';
  static const String assigned    = 'assigned';
  static const String open        = 'open';
  static const String maintenance = 'maintenance';

  static const List<String> filterLabels = [
    'Available',
    'Assigned',
    'Open',
    'Maintenance',
  ];
}

// ─────────────────────────────────────────────
//  ASSET TYPE CONSTANTS
// ─────────────────────────────────────────────
class AssetTypeNames {
  static const String laptop   = 'laptop';
  static const String mobile   = 'mobile';
  static const String tablet   = 'tablet';
  static const String monitor  = 'monitor';
  static const String keyboard = 'keyboard';
  static const String mouse    = 'mouse';

  static const List<String> filterLabels = [
    'Laptop',
    'Mobile',
    'Tablet',
    'Monitor',
    'Keyboard',
    'Mouse',
  ];
}

// ─────────────────────────────────────────────
//  ASSET COLORS  (asset-specific palette)
// ─────────────────────────────────────────────
class AssetColors {
  static const Color indigo  = Color(0xFF6366F1);
  static const Color sky     = Color(0xFF0EA5E9);
  static const Color violet  = Color(0xFF8B5CF6);
  static const Color neutral = Color(0xFF64748B);
  static const Color muted   = Color(0xFF94A3B8);
  static const Color emerald = Color(0xFF10B981);
}

// ─────────────────────────────────────────────
//  HISTORY ACTION CONSTANTS
// ─────────────────────────────────────────────
class HistoryAction {
  static const String assigned             = 'assigned';
  static const String returned             = 'returned';
  static const String added                = 'added';
  static const String maintenanceOpen      = 'maintenance_open';
  static const String maintenanceStarted   = 'maintenance_started';
  static const String maintenance          = 'maintenance';
  static const String inProgress          = 'in_progress';
  static const String maintenanceCompleted = 'maintenance_completed';
  static const String completed            = 'completed';
  static const String updated              = 'updated';
}

// ─────────────────────────────────────────────
//  ASSET MODEL
// ─────────────────────────────────────────────
class AssetModel {
  final int       id;
  final String    assetName;
  final String    assetType;
  final String?   assetCode;
  final String?   serialNumber;
  final String?   brand;
  final String?   model;
  final String?   description;
  final String    status;
  final String?   assignedToUserName;
  final int?      assignedToUserId;
  final String?   assignedByUserName;
  final DateTime? assignedDate;
  final DateTime? expectedReturnDate;
  final String?   assignmentNote;
  final DateTime? returnedDate;
  final String?   returnNote;
  final String?   returnCondition;
  final String?   returnedByUserName;
  final DateTime  createdOn;

  const AssetModel({
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
    this.assignedByUserName,
    this.assignedDate,
    this.expectedReturnDate,
    this.assignmentNote,
    this.returnedDate,
    this.returnNote,
    this.returnCondition,
    this.returnedByUserName,
    required this.createdOn,
  });

  String? get assignedToName => assignedToUserName;
  String? get returnedByName => returnedByUserName;

  static const String _kNa = '—';
  String get assetCodeSafe    => assetCode    ?? _kNa;
  String get serialNumberSafe => serialNumber ?? _kNa;
  String get brandSafe        => brand        ?? _kNa;
  String get modelSafe        => model        ?? _kNa;
  String get descriptionSafe  => description  ?? '';

  // ── UI Helpers ────────────────────────────────────────────────────────
  static Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case AssetStatus.assigned:    return AssetColors.indigo;
      case AssetStatus.available:   return AppTheme.success;
      case AssetStatus.open:        return AppTheme.warning;
      case AssetStatus.maintenance: return AppTheme.error;
      default:                      return AssetColors.muted;
    }
  }

  static IconData statusIcon(String s) {
    switch (s.toLowerCase()) {
      case AssetStatus.assigned:    return Icons.person_rounded;
      case AssetStatus.available:   return Icons.check_circle_rounded;
      case AssetStatus.open:        return Icons.pending_actions_rounded;
      case AssetStatus.maintenance: return Icons.build_rounded;
      default:                      return Icons.device_unknown_rounded;
    }
  }

  static Color typeColor(String t) {
    switch (t.toLowerCase()) {
      case AssetTypeNames.laptop:   return AssetColors.indigo;
      case AssetTypeNames.mobile:   return AssetColors.sky;
      case AssetTypeNames.tablet:   return AssetColors.violet;
      case AssetTypeNames.monitor:  return AppTheme.success;
      case AssetTypeNames.keyboard: return AppTheme.warning;
      case AssetTypeNames.mouse:    return AppTheme.error;
      default:                      return AssetColors.neutral;
    }
  }

  static IconData typeIcon(String t) {
    switch (t.toLowerCase()) {
      case AssetTypeNames.laptop:   return Icons.laptop_rounded;
      case AssetTypeNames.mobile:   return Icons.smartphone_rounded;
      case AssetTypeNames.tablet:   return Icons.tablet_rounded;
      case AssetTypeNames.monitor:  return Icons.monitor_rounded;
      case AssetTypeNames.keyboard: return Icons.keyboard_rounded;
      case AssetTypeNames.mouse:    return Icons.mouse_rounded;
      default:                      return Icons.devices_rounded;
    }
  }

  static String statusLabel(String s) {
    switch (s.toLowerCase()) {
      case AssetStatus.assigned:    return 'Assigned';
      case AssetStatus.available:   return 'Available';
      case AssetStatus.open:        return 'Maintenance Open';
      case AssetStatus.maintenance: return 'In Maintenance';
      default:
        return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
    }
  }

  factory AssetModel.fromJson(Map<String, dynamic> j) => AssetModel(
        id:                 j['assetId']           ?? 0,
        assetName:          j['assetName']          ?? '',
        assetType:          j['assetType']          ?? '',
        assetCode:          j['assetCode'],
        serialNumber:       j['serialNumber'],
        brand:              j['brand'],
        model:              j['model'],
        description:        j['description'],
        status:             j['status']             ?? AssetStatus.available,
        assignedToUserName: j['assignedToUserName'],
        assignedToUserId:   j['assignedToUserId'],
        assignedByUserName: j['assignedByUserName'],
        assignedDate: j['assignedDate'] != null
            ? DateTime.tryParse(j['assignedDate'])
            : null,
        expectedReturnDate: j['expectedReturnDate'] != null
            ? DateTime.tryParse(j['expectedReturnDate'])
            : null,
        assignmentNote:     j['assignmentNote'],
        returnedDate: j['returnedDate'] != null
            ? DateTime.tryParse(j['returnedDate'])
            : null,
        returnNote:         j['returnNote'],
        returnCondition:    j['returnCondition'],
        returnedByUserName: j['returnedByUserName'],
        createdOn: j['createdOn'] != null
            ? DateTime.tryParse(j['createdOn']) ?? DateTime.now()
            : DateTime.now(),
      );
}

// ─────────────────────────────────────────────
//  ASSET HISTORY MODEL
// ─────────────────────────────────────────────
class AssetHistoryModel {
  final int       historyId;
  final int       assetId;
  final String?   assetName;
  final String?   assetType;
  final int?      userId;
  final String?   userName;
  final String    action;
  final String?   note;
  final String?   condition;
  final DateTime  actionDate;
  final String?   actionByUserName;
  final String?   maintenanceType;
  final DateTime? startDate;
  final DateTime? endDate;

  const AssetHistoryModel({
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
    this.maintenanceType,
    this.startDate,
    this.endDate,
  });

  String? get targetUserName  => userName;
  String? get performedByName => actionByUserName;
  DateTime get createdAt      => actionDate;
  String  get assetNameSafe   => assetName ?? '';

  // ── Action UI Helpers ─────────────────────────────────────────────────
  static Color actionColor(String a) {
    switch (a.toLowerCase()) {
      case HistoryAction.assigned:             return AssetColors.indigo;
      case HistoryAction.returned:             return AssetColors.emerald;
      case HistoryAction.added:                return AssetColors.sky;
      case HistoryAction.maintenanceOpen:
      case HistoryAction.maintenance:          return AppTheme.warning;
      case HistoryAction.maintenanceStarted:
      case HistoryAction.inProgress:           return AppTheme.error;
      case HistoryAction.maintenanceCompleted:
      case HistoryAction.completed:            return AssetColors.emerald;
      case HistoryAction.updated:              return AssetColors.neutral;
      default:                                 return AssetColors.muted;
    }
  }

  static IconData actionIcon(String a) {
    switch (a.toLowerCase()) {
      case HistoryAction.assigned:             return Icons.assignment_ind_rounded;
      case HistoryAction.returned:             return Icons.assignment_return_rounded;
      case HistoryAction.added:                return Icons.add_box_rounded;
      case HistoryAction.maintenanceOpen:
      case HistoryAction.maintenance:          return Icons.pending_actions_rounded;
      case HistoryAction.maintenanceStarted:
      case HistoryAction.inProgress:           return Icons.build_rounded;
      case HistoryAction.maintenanceCompleted:
      case HistoryAction.completed:            return Icons.check_circle_rounded;
      default:                                 return Icons.history_rounded;
    }
  }

  static String actionLabel(String a) {
    switch (a.toLowerCase()) {
      case HistoryAction.assigned:             return 'Assigned';
      case HistoryAction.returned:             return 'Returned';
      case HistoryAction.added:                return 'Added';
      case HistoryAction.maintenanceOpen:      return 'Maint. Opened';
      case HistoryAction.maintenanceStarted:
      case HistoryAction.maintenance:
      case HistoryAction.inProgress:           return 'Maint. Started';
      case HistoryAction.maintenanceCompleted:
      case HistoryAction.completed:            return 'Maint. Done';
      case HistoryAction.updated:              return 'Updated';
      default:
        return a.isEmpty ? a : a[0].toUpperCase() + a.substring(1).toLowerCase();
    }
  }

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
            ? (DateTime.tryParse(j['actionDate']) ?? DateTime.now()).toLocal()
            : DateTime.now(),
        actionByUserName: j['actionByUserName'],
        maintenanceType:  j['maintenanceType'],
        startDate: j['startDate'] != null
            ? DateTime.tryParse(j['startDate'])?.toLocal()
            : null,
        endDate: j['endDate'] != null
            ? DateTime.tryParse(j['endDate'])?.toLocal()
            : null,
      );
}

// ─────────────────────────────────────────────
//  ASSET SUMMARY MODEL
// ─────────────────────────────────────────────
class AssetSummaryModel {
  final int total;
  final int available;
  final int assigned;
  final int openMaintenance;
  final int underMaintenance;
  final List<AssetTypeCount> byType;

  const AssetSummaryModel({
    required this.total,
    required this.available,
    required this.assigned,
    required this.openMaintenance,
    required this.underMaintenance,
    required this.byType,
  });

  factory AssetSummaryModel.fromJson(Map<String, dynamic> j) {
    final total            = j['total']            ?? 0;
    final available        = j['available']        ?? 0;
    final assigned         = j['assigned']         ?? 0;
    final openMaintenance  = j['open']             ?? 0;
    final underMaintenance = j['underMaintenance'] ??
        (total - available - assigned - openMaintenance).clamp(0, total);

    return AssetSummaryModel(
      total:            total,
      available:        available,
      assigned:         assigned,
      openMaintenance:  openMaintenance,
      underMaintenance: underMaintenance,
      byType: (j['byType'] as List? ?? [])
          .map((e) => AssetTypeCount.fromJson(e))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  ASSET TYPE COUNT
// ─────────────────────────────────────────────
class AssetTypeCount {
  final String assetType;
  final int    count;

  const AssetTypeCount({required this.assetType, required this.count});

  factory AssetTypeCount.fromJson(Map<String, dynamic> j) => AssetTypeCount(
        assetType: j['assetType'] ?? '',
        count:     j['count']     ?? 0,
      );
}

// ─────────────────────────────────────────────
//  MAINTENANCE MODEL
// ─────────────────────────────────────────────
class MaintenanceModel {
  final int       maintenanceId;
  final int       assetId;
  final String?   assetName;
  final String?   assetType;
  final String    maintenanceType;
  final String?   vendorName;
  final String?   ticketNo;
  final String?   issueDescription;
  final DateTime  startDate;
  final DateTime? endDate;
  final String    status;
  final double?   cost;
  final String?   resolutionNote;

  const MaintenanceModel({
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
            ? (DateTime.tryParse(j['startDate']) ?? DateTime.now()).toLocal()
            : DateTime.now(),
        endDate: j['endDate'] != null
            ? DateTime.tryParse(j['endDate'])?.toLocal()
            : null,
        status:         j['status']         ?? MaintenanceStatus.open,
        cost:           (j['cost'] as num?)?.toDouble(),
        resolutionNote: j['resolutionNote'],
      );
}


class AssetModelScreen extends StatelessWidget {
  final AssetModel asset;
  const AssetModelScreen({super.key, required this.asset});

  bool get _isOverdue =>
      asset.expectedReturnDate != null &&
      DateTime.now().isAfter(asset.expectedReturnDate!);

  int get _daysLeft => asset.expectedReturnDate != null
      ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
      : -1;

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied!', style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tc = AssetModel.typeColor(asset.assetType);
    final ti = AssetModel.typeIcon(asset.assetType);
    final sc = AssetModel.statusColor(asset.status);
    final si = AssetModel.statusIcon(asset.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: tc,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () => _copy(context,
                  'Asset: ${asset.assetName}\nCode: ${asset.assetCodeSafe}\nSerial: ${asset.serialNumberSafe}\nStatus: ${asset.status}',
                  'Asset info'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [tc, tc.withOpacity(0.75)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 68, height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            child: Icon(ti, color: Colors.white, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(asset.assetName,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Colors.white, height: 1.2)),
                              const SizedBox(height: 5),
                              Text('${asset.brandSafe}  ·  ${asset.modelSafe}',
                                  style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Colors.white.withOpacity(0.85))),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(si, size: 12, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(AssetModel.statusLabel(asset.status),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Colors.white)),
                                ]),
                              ),
                            ],
                          )),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 50),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                Row(children: [
                  _StatChip(icon: Icons.qr_code_rounded,  label: 'Code',   value: asset.assetCodeSafe,               color: tc,
                      onTap: () => _copy(context, asset.assetCodeSafe, 'Asset Code')),
                  const SizedBox(width: 10),
                  _StatChip(icon: Icons.category_rounded, label: 'Type',   value: asset.assetType,                   color: AssetColors.violet),
                  const SizedBox(width: 10),
                  _StatChip(icon: si,                     label: 'Status', value: AssetModel.statusLabel(asset.status), color: sc),
                ]),
                const SizedBox(height: 22),

                // Asset Identity
                _SectionHeader(title: 'Asset Identity', icon: Icons.badge_rounded, iconColor: tc),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(icon: Icons.qr_code_rounded,        iconColor: AppTheme.primary,      label: 'Asset Code',    value: asset.assetCodeSafe,    onCopy: () => _copy(context, asset.assetCodeSafe, 'Asset Code')),
                  _CardDivider(),
                  _DetailRow(icon: Icons.tag_rounded,            iconColor: AssetColors.indigo,    label: 'Serial Number', value: asset.serialNumberSafe, onCopy: () => _copy(context, asset.serialNumberSafe, 'Serial Number')),
                  _CardDivider(),
                  _DetailRow(icon: AssetModel.typeIcon(asset.assetType), iconColor: tc,            label: 'Asset Type',    value: asset.assetType),
                ]),
                const SizedBox(height: 20),

                // Model Information
                _SectionHeader(title: 'Model Information', icon: Icons.memory_rounded, iconColor: AssetColors.violet),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(icon: Icons.business_rounded, iconColor: AssetColors.sky,    label: 'Brand', value: asset.brandSafe),
                  _CardDivider(),
                  _DetailRow(icon: Icons.memory_rounded,   iconColor: AssetColors.violet, label: 'Model', value: asset.modelSafe),
                  if (asset.description?.isNotEmpty ?? false) ...[
                    _CardDivider(),
                    _DetailRow(icon: Icons.description_rounded, iconColor: AppTheme.textSecondary, label: 'Description', value: asset.descriptionSafe, isMultiline: true),
                  ],
                ]),
                const SizedBox(height: 20),

                // Assignment Details
                _SectionHeader(title: 'Assignment Details', icon: Icons.assignment_ind_rounded, iconColor: sc),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(
                    icon: si, iconColor: sc, label: 'Current Status',
                    value: AssetModel.statusLabel(asset.status),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(AssetModel.statusLabel(asset.status),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: sc)),
                    ),
                  ),
                  if (asset.assignedToName != null) ...[
                    _CardDivider(),
                    _DetailRow(icon: Icons.person_rounded, iconColor: AppTheme.primary, label: 'Assigned To', value: asset.assignedToName!),
                  ],
                  if (asset.assignedByUserName != null && asset.assignedByUserName!.isNotEmpty) ...[
                    _CardDivider(),
                    _DetailRow(icon: Icons.manage_accounts_rounded, iconColor: AssetColors.violet, label: 'Assigned By', value: asset.assignedByUserName!),
                  ],
                  if (asset.assignedToUserId != null) ...[
                    _CardDivider(),
                    _DetailRow(icon: Icons.numbers_rounded, iconColor: AppTheme.textSecondary, label: 'User ID', value: '#${asset.assignedToUserId}'),
                  ],
                  if (asset.expectedReturnDate != null) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.event_rounded,
                      iconColor: _isOverdue ? AppTheme.error : AppTheme.success,
                      label: 'Expected Return',
                      value: DateFormat('EEEE, dd MMMM yyyy').format(asset.expectedReturnDate!),
                      isMultiline: true,
                      trailing: _isOverdue
                          ? _BadgeWidget(text: 'OVERDUE', color: AppTheme.error)
                          : _daysLeft <= 3
                              ? _BadgeWidget(text: '$_daysLeft days', color: AppTheme.warning)
                              : _BadgeWidget(text: '$_daysLeft days left', color: AppTheme.success),
                    ),
                  ],
                  if (asset.assignmentNote != null && asset.assignmentNote!.isNotEmpty) ...[
                    _CardDivider(),
                    _DetailRow(icon: Icons.sticky_note_2_rounded, iconColor: AppTheme.warning, label: 'Assignment Note', value: asset.assignmentNote!, isMultiline: true),
                  ],
                ]),
                const SizedBox(height: 20),

                // Return Details
                if (asset.returnedDate != null || asset.returnedByName != null) ...[
                  _SectionHeader(title: 'Return Details', icon: Icons.assignment_return_rounded, iconColor: AppTheme.success),
                  const SizedBox(height: 10),
                  _DetailCard(children: [
                    if (asset.returnedDate != null)
                      _DetailRow(
                        icon: Icons.calendar_today_rounded, iconColor: AppTheme.success,
                        label: 'Returned On',
                        value: DateFormat('EEEE, dd MMMM yyyy').format(asset.returnedDate!),
                        isMultiline: true,
                      ),
                    if (asset.returnedByName != null && asset.returnedByName!.isNotEmpty) ...[
                      if (asset.returnedDate != null) _CardDivider(),
                      _DetailRow(icon: Icons.manage_accounts_rounded, iconColor: AssetColors.indigo, label: 'Return Taken By', value: asset.returnedByName!),
                    ],
                    if (asset.returnCondition != null && asset.returnCondition!.isNotEmpty) ...[
                      _CardDivider(),
                      _DetailRow(icon: Icons.info_outline_rounded, iconColor: AppTheme.warning, label: 'Condition', value: asset.returnCondition!),
                    ],
                    if (asset.returnNote != null && asset.returnNote!.isNotEmpty) ...[
                      _CardDivider(),
                      _DetailRow(icon: Icons.notes_rounded, iconColor: AppTheme.textSecondary, label: 'Return Note', value: asset.returnNote!, isMultiline: true),
                    ],
                  ]),
                  const SizedBox(height: 20),
                ],

                _StatusBanner(
                  status: asset.status,
                  statusColor: sc,
                  statusIcon: si,
                  assignedToName: asset.assignedToName,
                  expectedReturnDate: asset.expectedReturnDate,
                  isOverdue: _isOverdue,
                  daysLeft: _daysLeft,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BADGE
// ─────────────────────────────────────────────
class _BadgeWidget extends StatelessWidget {
  final String text; final Color color;
  const _BadgeWidget({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: color)),
  );
}

// ─────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon; final String label, value; final Color color; final VoidCallback? onTap;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: AppTheme.cardDecoration(),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: color)),
          const SizedBox(height: 7),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, fontFamily: 'Poppins', color: AppTheme.textHint)),
        ]),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title; final IconData icon; final Color iconColor;
  const _SectionHeader({required this.title, required this.icon, required this.iconColor});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 16, color: iconColor),
    ),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppTheme.textPrimary)),
  ]);
}

// ─────────────────────────────────────────────
//  DETAIL CARD / DIVIDER / ROW
// ─────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});
  @override
  Widget build(BuildContext context) =>
      Container(decoration: AppTheme.cardDecoration(), child: Column(children: children));
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: AppTheme.divider),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String label, value;
  final bool isMultiline;
  final Widget? trailing;
  final VoidCallback? onCopy;
  const _DetailRow({
    required this.icon, required this.iconColor,
    required this.label, required this.value,
    this.isMultiline = false, this.trailing, this.onCopy,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPress: onCopy,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppTheme.textHint, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: AppTheme.textPrimary, fontWeight: FontWeight.w600, height: 1.4)),
          ])),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (onCopy != null)   ...[const SizedBox(width: 6), const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textHint)],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  STATUS BANNER
// ─────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String     status;
  final Color      statusColor;
  final IconData   statusIcon;
  final String?    assignedToName;
  final DateTime?  expectedReturnDate;
  final bool       isOverdue;
  final int        daysLeft;

  const _StatusBanner({
    required this.status, required this.statusColor, required this.statusIcon,
    this.assignedToName,  this.expectedReturnDate,
    required this.isOverdue, required this.daysLeft,
  });

  String get _message {
    switch (status.toLowerCase()) {
      case AssetStatus.assigned:
        return assignedToName != null
            ? 'This asset is currently assigned to $assignedToName.'
            : 'This asset is currently assigned to an employee.';
      case AssetStatus.available:
        return 'This asset is available and ready to be assigned to any employee.';
      case AssetStatus.open:
        return 'A maintenance request has been opened for this asset. Waiting for admin to start.';
      case AssetStatus.maintenance:
        return 'This asset is currently undergoing maintenance and is not available.';
      default:
        return 'Current asset status is: $status.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue ? AppTheme.errorLight : statusColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? AppTheme.error.withOpacity(0.3) : statusColor.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isOverdue ? AppTheme.error.withOpacity(0.15) : statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(isOverdue ? Icons.warning_rounded : statusIcon, size: 18,
              color: isOverdue ? AppTheme.error : statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isOverdue ? 'Return Overdue!' : 'Current Status',
              style: TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  color: isOverdue ? AppTheme.error : statusColor)),
          const SizedBox(height: 4),
          Text(
            isOverdue
                ? 'This asset was due on ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}. Please return it immediately.'
                : _message,
            style: TextStyle(fontSize: 12, fontFamily: 'Poppins',
                color: isOverdue ? AppTheme.error.withOpacity(0.85) : statusColor.withOpacity(0.85), height: 1.5),
          ),
          if (!isOverdue && expectedReturnDate != null && daysLeft >= 0) ...[
            const SizedBox(height: 6),
            Text(
              'Return by: ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}  ·  $daysLeft day${daysLeft != 1 ? 's' : ''} remaining',
              style: TextStyle(fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                  color: daysLeft <= 3 ? AppTheme.warning : statusColor),
            ),
          ],
        ])),
      ]),
    );
  }
}