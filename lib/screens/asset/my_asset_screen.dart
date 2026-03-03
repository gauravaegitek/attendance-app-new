// // lib/screens/asset/my_asset_screen.dart
// // ✅ User + Admin dono ke liye — apne assigned assets + detail navigation

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/asset_controller.dart';
// import '../../controllers/auth_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/asset_model_screen.dart';

// class MyAssetScreen extends StatefulWidget {
//   const MyAssetScreen({super.key});

//   @override
//   State<MyAssetScreen> createState() => _MyAssetScreenState();
// }

// class _MyAssetScreenState extends State<MyAssetScreen> {
//   late final AssetController _ctrl;
//   late final AuthController  _auth;

//   @override
//   void initState() {
//     super.initState();
//     _auth = Get.find<AuthController>();
//     if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
//     _ctrl = Get.find<AssetController>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _ctrl.fetchMyAssets(_auth.currentUserId);
//     });
//   }

//   // ── Helpers ──────────────────────────────────────────────────────────
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.background,
//       appBar: AppBar(
//         backgroundColor: AppTheme.cardBackground,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded,
//               color: AppTheme.textPrimary, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'My Assets',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
//             onPressed: () => _ctrl.fetchMyAssets(_auth.currentUserId),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (_ctrl.isLoading.value) {
//           return const Center(
//               child: CircularProgressIndicator(color: AppTheme.primary));
//         }
//         if (_ctrl.myAssets.isEmpty) {
//           return _EmptyState(
//             onRetry: () => _ctrl.fetchMyAssets(_auth.currentUserId),
//           );
//         }
//         return RefreshIndicator(
//           color: AppTheme.primary,
//           onRefresh: () => _ctrl.fetchMyAssets(_auth.currentUserId),
//           child: ListView.separated(
//             padding: const EdgeInsets.all(18),
//             itemCount: _ctrl.myAssets.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (_, i) {
//               final a = _ctrl.myAssets[i];
//               return GestureDetector(
//                 onTap: () => Get.to(() => AssetModelScreen(asset: a)),
//                 child: _MyAssetCard(
//                   asset: a,
//                   sColor: statusColor(a.status),
//                   sIcon: statusIcon(a.status),
//                   tColor: typeColor(a.assetType),
//                   tIcon: typeIcon(a.assetType),
//                 ),
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// //  ASSET CARD
// // ─────────────────────────────────────────────
// class _MyAssetCard extends StatelessWidget {
//   final AssetModel asset;
//   final Color   sColor;
//   final IconData sIcon;
//   final Color   tColor;
//   final IconData tIcon;

//   const _MyAssetCard({
//     required this.asset,
//     required this.sColor,
//     required this.sIcon,
//     required this.tColor,
//     required this.tIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isOverdue = asset.expectedReturnDate != null &&
//         DateTime.now().isAfter(asset.expectedReturnDate!);
//     final int daysLeft = asset.expectedReturnDate != null
//         ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
//         : -1;

//     return Container(
//       decoration: AppTheme.cardDecoration(),
//       padding: const EdgeInsets.all(16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         // ── Top row ────────────────────────────────────────────────────
//         Row(children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: tColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(tIcon, color: tColor, size: 26),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   asset.assetName,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                     fontFamily: 'Poppins',
//                     color: AppTheme.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${asset.brand}  ·  ${asset.model}',
//                   style: AppTheme.caption,
//                 ),
//               ],
//             ),
//           ),
//           // Status badge
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: sColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(sIcon, size: 11, color: sColor),
//               const SizedBox(width: 4),
//               Text(
//                 asset.status,
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: 'Poppins',
//                   color: sColor,
//                 ),
//               ),
//             ]),
//           ),
//         ]),

//         const SizedBox(height: 14),
//         const Divider(height: 1, color: AppTheme.divider),
//         const SizedBox(height: 12),

//         // ── Info Grid ──────────────────────────────────────────────────
//         Row(children: [
//           Expanded(
//               child: _InfoItem(label: 'Type',   value: asset.assetType)),
//           Expanded(
//               child: _InfoItem(label: 'Code',   value: asset.assetCode)),
//         ]),
//         const SizedBox(height: 10),
//         Row(children: [
//           Expanded(
//               child: _InfoItem(label: 'Serial', value: asset.serialNumber)),
//           Expanded(
//             child: _InfoItem(
//               label: 'Return By',
//               value: asset.expectedReturnDate != null
//                   ? DateFormat('dd MMM yyyy')
//                       .format(asset.expectedReturnDate!)
//                   : '—',
//               valueColor: isOverdue
//                   ? AppTheme.error
//                   : daysLeft <= 3 && daysLeft >= 0
//                       ? AppTheme.warning
//                       : null,
//             ),
//           ),
//         ]),

//         // ── Overdue badge ──────────────────────────────────────────────
//         if (isOverdue) ...[
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppTheme.errorLight,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(children: [
//               const Icon(Icons.warning_rounded,
//                   size: 14, color: AppTheme.error),
//               const SizedBox(width: 6),
//               const Text(
//                 'Return date overdue! Please return immediately.',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontFamily: 'Poppins',
//                   color: AppTheme.error,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ]),
//           ),
//         ] else if (daysLeft >= 0 && daysLeft <= 3) ...[
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppTheme.warning.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(children: [
//               const Icon(Icons.schedule_rounded,
//                   size: 14, color: AppTheme.warning),
//               const SizedBox(width: 6),
//               Text(
//                 'Due in $daysLeft day${daysLeft != 1 ? 's' : ''}. Please plan return.',
//                 style: const TextStyle(
//                   fontSize: 11,
//                   fontFamily: 'Poppins',
//                   color: AppTheme.warning,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ]),
//           ),
//         ],

//         // ── Assignment Note ────────────────────────────────────────────
//         if (asset.assignmentNote != null &&
//             asset.assignmentNote!.isNotEmpty) ...[
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: AppTheme.primary.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(10),
//               border:
//                   Border.all(color: AppTheme.primary.withOpacity(0.15)),
//             ),
//             child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.notes_rounded,
//                       size: 14, color: AppTheme.primary),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       asset.assignmentNote!,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontFamily: 'Poppins',
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                   ),
//                 ]),
//           ),
//         ],

//         // ── View Details CTA ───────────────────────────────────────────
//         const SizedBox(height: 12),
//         Row(children: [
//           const Spacer(),
//           Row(children: [
//             Text(
//               'View Details',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 color: tColor,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Icon(Icons.arrow_forward_ios_rounded, size: 12, color: tColor),
//           ]),
//         ]),
//       ]),
//     );
//   }
// }

// class _InfoItem extends StatelessWidget {
//   final String  label;
//   final String  value;
//   final Color?  valueColor;
//   const _InfoItem({required this.label, required this.value, this.valueColor});

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Poppins',
//           color: AppTheme.textHint,
//           letterSpacing: 0.5,
//         ),
//       ),
//       const SizedBox(height: 3),
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Poppins',
//           color: valueColor ?? AppTheme.textPrimary,
//         ),
//       ),
//     ]);
//   }
// }

// // ─────────────────────────────────────────────
// //  EMPTY STATE
// // ─────────────────────────────────────────────
// class _EmptyState extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _EmptyState({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Container(
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               color: AppTheme.primary.withOpacity(0.07),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.devices_other_rounded,
//                 color: AppTheme.primary, size: 52),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Assets Assigned',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Poppins',
//               color: AppTheme.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'You currently have no assets assigned.\nContact your admin for asset allocation.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               color: AppTheme.textSecondary,
//               fontSize: 13,
//               height: 1.6,
//             ),
//           ),
//           const SizedBox(height: 28),
//           ElevatedButton.icon(
//             onPressed: onRetry,
//             icon: const Icon(Icons.refresh_rounded, size: 18),
//             label: const Text('Refresh',
//                 style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               foregroundColor: Colors.white,
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               elevation: 0,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }














// lib/screens/asset/my_asset_screen.dart
// ✅ User + Admin dono ke liye — apne assigned assets + detail navigation

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/asset_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/asset_model_screen.dart';

class MyAssetScreen extends StatefulWidget {
  const MyAssetScreen({super.key});

  @override
  State<MyAssetScreen> createState() => _MyAssetScreenState();
}

class _MyAssetScreenState extends State<MyAssetScreen> {
  late final AssetController _ctrl;
  late final AuthController  _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    if (!Get.isRegistered<AssetController>()) Get.put(AssetController());
    _ctrl = Get.find<AssetController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchMyAssets(_auth.currentUserId);
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Assets',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: () => _ctrl.fetchMyAssets(_auth.currentUserId),
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (_ctrl.myAssets.isEmpty) {
          return _EmptyState(
            onRetry: () => _ctrl.fetchMyAssets(_auth.currentUserId),
          );
        }
        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => _ctrl.fetchMyAssets(_auth.currentUserId),
          child: ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: _ctrl.myAssets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final a = _ctrl.myAssets[i];
              return GestureDetector(
                onTap: () => Get.to(() => AssetModelScreen(asset: a)),
                child: _MyAssetCard(
                  asset: a,
                  sColor: statusColor(a.status),
                  sIcon: statusIcon(a.status),
                  tColor: typeColor(a.assetType),
                  tIcon: typeIcon(a.assetType),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  ASSET CARD
// ─────────────────────────────────────────────
class _MyAssetCard extends StatelessWidget {
  final AssetModel asset;
  final Color    sColor;
  final IconData sIcon;
  final Color    tColor;
  final IconData tIcon;

  const _MyAssetCard({
    required this.asset,
    required this.sColor,
    required this.sIcon,
    required this.tColor,
    required this.tIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = asset.expectedReturnDate != null &&
        DateTime.now().isAfter(asset.expectedReturnDate!);
    final int daysLeft = asset.expectedReturnDate != null
        ? asset.expectedReturnDate!.difference(DateTime.now()).inDays
        : -1;

    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Top row ────────────────────────────────────────────────────
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(tIcon, color: tColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.assetName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Fix: brand/model nullable → safe getters
                Text(
                  '${asset.brandSafe}  ·  ${asset.modelSafe}',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: sColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(sIcon, size: 11, color: sColor),
              const SizedBox(width: 4),
              Text(
                asset.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: sColor,
                ),
              ),
            ]),
          ),
        ]),

        const SizedBox(height: 14),
        const Divider(height: 1, color: AppTheme.divider),
        const SizedBox(height: 12),

        // ── Info Grid ──────────────────────────────────────────────────
        Row(children: [
          Expanded(
              child: _InfoItem(label: 'Type',   value: asset.assetType)),
          // Fix: assetCode nullable → assetCodeSafe
          Expanded(
              child: _InfoItem(label: 'Code',   value: asset.assetCodeSafe)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          // Fix: serialNumber nullable → serialNumberSafe
          Expanded(
              child: _InfoItem(label: 'Serial', value: asset.serialNumberSafe)),
          Expanded(
            child: _InfoItem(
              label: 'Return By',
              value: asset.expectedReturnDate != null
                  ? DateFormat('dd MMM yyyy')
                      .format(asset.expectedReturnDate!)
                  : '—',
              valueColor: isOverdue
                  ? AppTheme.error
                  : daysLeft <= 3 && daysLeft >= 0
                      ? AppTheme.warning
                      : null,
            ),
          ),
        ]),

        // ── Overdue badge ──────────────────────────────────────────────
        if (isOverdue) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.warning_rounded,
                  size: 14, color: AppTheme.error),
              const SizedBox(width: 6),
              const Text(
                'Return date overdue! Please return immediately.',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ] else if (daysLeft >= 0 && daysLeft <= 3) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppTheme.warning),
              const SizedBox(width: 6),
              Text(
                'Due in $daysLeft day${daysLeft != 1 ? 's' : ''}. Please plan return.',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Poppins',
                  color: AppTheme.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ],

        // ── Assignment Note ────────────────────────────────────────────
        if (asset.assignmentNote != null &&
            asset.assignmentNote!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.15)),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      asset.assignmentNote!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ]),
          ),
        ],

        // ── View Details CTA ───────────────────────────────────────────
        const SizedBox(height: 12),
        Row(children: [
          const Spacer(),
          Row(children: [
            Text(
              'View Details',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: tColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: tColor),
          ]),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO ITEM
// ─────────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItem(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: AppTheme.textHint,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: valueColor ?? AppTheme.textPrimary,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.devices_other_rounded,
                    color: AppTheme.primary, size: 52),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Assets Assigned',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You currently have no assets assigned.\nContact your admin for asset allocation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ]),
      ),
    );
  }
}