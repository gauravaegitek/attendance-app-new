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












// lib/screens/asset/asset_model_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/asset_controller.dart';
import '../../core/theme/app_theme.dart';

class AssetModelScreen extends StatelessWidget {
  final AssetModel asset;
  const AssetModelScreen({super.key, required this.asset});

  // ── Static Helpers ────────────────────────────────────────────────────
  static Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'assigned':    return AppTheme.primary;
      case 'available':   return AppTheme.success;
      case 'maintenance': return AppTheme.warning;
      default:            return AppTheme.textSecondary;
    }
  }

  static IconData statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'assigned':    return Icons.person_rounded;
      case 'available':   return Icons.check_circle_rounded;
      case 'maintenance': return Icons.build_rounded;
      default:            return Icons.device_unknown_rounded;
    }
  }

  static Color typeColor(String t) {
    switch (t.toLowerCase()) {
      case 'laptop':   return const Color(0xFF6366F1);
      case 'mobile':   return const Color(0xFF0EA5E9);
      case 'tablet':   return const Color(0xFF8B5CF6);
      case 'monitor':  return const Color(0xFF10B981);
      case 'keyboard': return const Color(0xFFF59E0B);
      case 'mouse':    return const Color(0xFFEF4444);
      default:         return AppTheme.accent;
    }
  }

  static IconData typeIcon(String t) {
    switch (t.toLowerCase()) {
      case 'laptop':   return Icons.laptop_rounded;
      case 'mobile':   return Icons.smartphone_rounded;
      case 'tablet':   return Icons.tablet_rounded;
      case 'monitor':  return Icons.monitor_rounded;
      case 'keyboard': return Icons.keyboard_rounded;
      case 'mouse':    return Icons.mouse_rounded;
      default:         return Icons.devices_rounded;
    }
  }

  bool get _isOverdue =>
      asset.expectedReturnDate != null &&
      DateTime.now().isAfter(asset.expectedReturnDate!);

  int get _daysLeft => asset.expectedReturnDate != null
      ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
      : -1;

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!',
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = typeColor(asset.assetType);
    final ti = typeIcon(asset.assetType);
    final sc = statusColor(asset.status);
    final si = statusIcon(asset.status);

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_rounded,
                      color: Colors.white, size: 18),
                ),
                onPressed: () {
                  _copy(
                    context,
                    'Asset: ${asset.assetName}\nCode: ${asset.assetCodeSafe}\nSerial: ${asset.serialNumberSafe}\nStatus: ${asset.status}',
                    'Asset info',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5),
                            ),
                            child: Icon(ti, color: Colors.white, size: 34),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.assetName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Fix: brand/model nullable → use safe getters
                                Text(
                                  '${asset.brandSafe}  ·  ${asset.modelSafe}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(si, size: 12, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Text(
                                        asset.status,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                // ── Quick Stats Row ────────────────────────────────────
                Row(children: [
                  _StatChip(
                    icon: Icons.qr_code_rounded,
                    label: 'Code',
                    // Fix: assetCode nullable → assetCodeSafe
                    value: asset.assetCodeSafe,
                    color: tc,
                    onTap: () => _copy(context, asset.assetCodeSafe, 'Asset Code'),
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: Icons.category_rounded,
                    label: 'Type',
                    value: asset.assetType,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    icon: si,
                    label: 'Status',
                    value: asset.status,
                    color: sc,
                  ),
                ]),
                const SizedBox(height: 22),

                // ── Asset Identity ─────────────────────────────────────
                _SectionHeader(
                    title: 'Asset Identity',
                    icon: Icons.badge_rounded,
                    iconColor: tc),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(
                    icon: Icons.qr_code_rounded,
                    iconColor: AppTheme.primary,
                    label: 'Asset Code',
                    // Fix: nullable → safe getter
                    value: asset.assetCodeSafe,
                    onCopy: () => _copy(context, asset.assetCodeSafe, 'Asset Code'),
                  ),
                  _CardDivider(),
                  _DetailRow(
                    icon: Icons.tag_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Serial Number',
                    // Fix: nullable → safe getter
                    value: asset.serialNumberSafe,
                    onCopy: () => _copy(context, asset.serialNumberSafe, 'Serial Number'),
                  ),
                  _CardDivider(),
                  _DetailRow(
                    icon: typeIcon(asset.assetType),
                    iconColor: tc,
                    label: 'Asset Type',
                    value: asset.assetType,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Model Information ──────────────────────────────────
                _SectionHeader(
                    title: 'Model Information',
                    icon: Icons.memory_rounded,
                    iconColor: const Color(0xFF8B5CF6)),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(
                    icon: Icons.business_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    label: 'Brand',
                    // Fix: nullable → safe getter
                    value: asset.brandSafe,
                  ),
                  _CardDivider(),
                  _DetailRow(
                    icon: Icons.memory_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Model',
                    // Fix: nullable → safe getter
                    value: asset.modelSafe,
                  ),
                  // Fix: description nullable — use ?. instead of .
                  if (asset.description?.isNotEmpty ?? false) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.description_rounded,
                      iconColor: AppTheme.textSecondary,
                      label: 'Description',
                      value: asset.descriptionSafe,
                      isMultiline: true,
                    ),
                  ],
                ]),
                const SizedBox(height: 20),

                // ── Assignment Details ─────────────────────────────────
                _SectionHeader(
                    title: 'Assignment Details',
                    icon: Icons.assignment_ind_rounded,
                    iconColor: sc),
                const SizedBox(height: 10),
                _DetailCard(children: [
                  _DetailRow(
                    icon: si,
                    iconColor: sc,
                    label: 'Current Status',
                    value: asset.status,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sc.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        asset.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: sc,
                        ),
                      ),
                    ),
                  ),
                  // assignedToName is a getter → String? (fine to use != null check)
                  if (asset.assignedToName != null) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.person_rounded,
                      iconColor: AppTheme.primary,
                      label: 'Assigned To',
                      value: asset.assignedToName!,
                    ),
                  ],
                  if (asset.assignedToUserId != null) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.numbers_rounded,
                      iconColor: AppTheme.textSecondary,
                      label: 'User ID',
                      value: '#${asset.assignedToUserId}',
                    ),
                  ],
                  if (asset.expectedReturnDate != null) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.event_rounded,
                      iconColor: _isOverdue ? AppTheme.error : AppTheme.success,
                      label: 'Expected Return',
                      value: DateFormat('EEEE, dd MMMM yyyy')
                          .format(asset.expectedReturnDate!),
                      isMultiline: true,
                      trailing: _isOverdue
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.errorLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OVERDUE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.error,
                                ),
                              ),
                            )
                          : _daysLeft <= 3
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warning.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$_daysLeft days',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: AppTheme.warning,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$_daysLeft days left',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ),
                    ),
                  ],
                  if (asset.assignmentNote != null &&
                      asset.assignmentNote!.isNotEmpty) ...[
                    _CardDivider(),
                    _DetailRow(
                      icon: Icons.sticky_note_2_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      label: 'Assignment Note',
                      value: asset.assignmentNote!,
                      isMultiline: true,
                    ),
                  ],
                ]),
                const SizedBox(height: 20),

                // ── Status Banner ──────────────────────────────────────
                _StatusBanner(
                  status: asset.status,
                  statusColor: sc,
                  statusIcon: si,
                  // assignedToName is a getter → fine
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
//  STAT CHIP
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: AppTheme.cardDecoration(),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                color: AppTheme.textHint,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          color: AppTheme.textPrimary,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  DETAIL CARD
// ─────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(children: children));
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppTheme.divider));
}

// ─────────────────────────────────────────────
//  DETAIL ROW
// ─────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isMultiline;
  final Widget? trailing;
  final VoidCallback? onCopy;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.trailing,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onCopy,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment:
              isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Poppins',
                      color: AppTheme.textHint,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.copy_rounded, size: 14, color: AppTheme.textHint),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATUS BANNER
// ─────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String? assignedToName;
  final DateTime? expectedReturnDate;
  final bool isOverdue;
  final int daysLeft;

  const _StatusBanner({
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    this.assignedToName,
    this.expectedReturnDate,
    required this.isOverdue,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    switch (status.toLowerCase()) {
      case 'assigned':
        message = assignedToName != null
            ? 'This asset is currently assigned to $assignedToName.'
            : 'This asset is currently assigned to an employee.';
        break;
      case 'available':
        message =
            'This asset is available and ready to be assigned to any employee.';
        break;
      case 'maintenance':
        message =
            'This asset is currently undergoing maintenance and is not available.';
        break;
      default:
        message = 'Current asset status is: $status.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue ? AppTheme.errorLight : statusColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : statusColor.withOpacity(0.2),
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isOverdue
                ? AppTheme.error.withOpacity(0.15)
                : statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            isOverdue ? Icons.warning_rounded : statusIcon,
            size: 18,
            color: isOverdue ? AppTheme.error : statusColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOverdue ? 'Return Overdue!' : 'Current Status',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: isOverdue ? AppTheme.error : statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOverdue
                    ? 'This asset was due on ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}. Please return it immediately.'
                    : message,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: isOverdue
                      ? AppTheme.error.withOpacity(0.85)
                      : statusColor.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
              if (!isOverdue && expectedReturnDate != null && daysLeft >= 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Return by: ${DateFormat('dd MMM yyyy').format(expectedReturnDate!)}  ·  $daysLeft day${daysLeft != 1 ? 's' : ''} remaining',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: daysLeft <= 3 ? AppTheme.warning : statusColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}