// // lib/screens/notification/notification_screen.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/notification_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../models/notification_model.dart';
// import '../../models/models.dart';
// import '../../services/api_service.dart';
// import '../../services/storage_service.dart';

// // ══════════════════════════════════════════════════════════════════════════════
// //  NOTIFICATION SCREEN
// // ══════════════════════════════════════════════════════════════════════════════
// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.isRegistered<NotificationController>()
//         ? Get.find<NotificationController>()
//         : Get.put(NotificationController());

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF050B14),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         actions: [
//           Obx(() => ctrl.notifications.any((n) => !n.isRead)
//               ? TextButton(
//                   onPressed: ctrl.markAllRead,
//                   child: Text(
//                     'Mark all read',
//                     style: TextStyle(
//                       color: AppTheme.primary,
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 )
//               : const SizedBox.shrink()),
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: ctrl.loadNotifications,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),

//       // FAB: sirf Admin ko dikhega
//       floatingActionButton: ctrl.isAdmin
//           ? FloatingActionButton.extended(
//               onPressed: () => _showSendSheet(context, ctrl),
//               backgroundColor: AppTheme.primary,
//               icon: const Icon(Icons.send_rounded, color: Colors.white),
//               label: const Text(
//                 'Send',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             )
//           : null,

//       body: Obx(() {
//         if (ctrl.isLoading.value) {
//           return Center(
//               child: CircularProgressIndicator(color: AppTheme.primary));
//         }

//         if (ctrl.notifications.isEmpty) {
//           return const _EmptyState();
//         }

//         final unread = ctrl.notifications.where((n) => !n.isRead).toList();
//         final read   = ctrl.notifications.where((n) =>  n.isRead).toList();

//         return RefreshIndicator(
//           color: AppTheme.primary,
//           onRefresh: ctrl.loadNotifications,
//           child: ListView(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             children: [
//               if (unread.isNotEmpty) ...[
//                 _SectionHeader(
//                     label: 'New',
//                     count: unread.length,
//                     color: AppTheme.primary),
//                 const SizedBox(height: 8),
//                 ...unread.map((n) => _NotifCard(n: n, ctrl: ctrl)),
//                 const SizedBox(height: 16),
//               ],
//               if (read.isNotEmpty) ...[
//                 _SectionHeader(
//                     label: 'Earlier',
//                     count: read.length,
//                     color: Colors.grey),
//                 const SizedBox(height: 8),
//                 ...read.map((n) => _NotifCard(n: n, ctrl: ctrl)),
//               ],
//               const SizedBox(height: 80),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   void _showSendSheet(BuildContext context, NotificationController ctrl) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _SendNotificationSheet(ctrl: ctrl),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  NOTIFICATION CARD
// // ══════════════════════════════════════════════════════════════════════════════
// class _NotifCard extends StatelessWidget {
//   final NotificationModel n;
//   final NotificationController ctrl;
//   const _NotifCard({required this.n, required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     final cfg = _typeConfig(n.type);

//     return GestureDetector(
//       onTap: () => ctrl.markRead(n),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           color: n.isRead ? Colors.white : cfg.bgColor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: n.isRead ? const Color(0xFFEEEFF3) : cfg.borderColor,
//             width: 1.2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(n.isRead ? 0.03 : 0.06),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child:
//               Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // Icon
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: cfg.iconBg,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(cfg.icon, color: cfg.color, size: 20),
//             ),
//             const SizedBox(width: 12),

//             // Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Expanded(
//                       child: Text(
//                         n.title,
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontWeight: n.isRead
//                               ? FontWeight.w500
//                               : FontWeight.w700,
//                           fontSize: 14,
//                           color: const Color(0xFF1A1D2E),
//                         ),
//                       ),
//                     ),
//                     if (!n.isRead)
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: AppTheme.primary,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                   ]),
//                   const SizedBox(height: 4),
//                   Text(
//                     n.message,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: cfg.iconBg,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         n.type.toUpperCase(),
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 9,
//                           fontWeight: FontWeight.w700,
//                           color: cfg.color,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       _formatDate(n.createdAt),
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 10,
//                         color: Colors.grey[400],
//                       ),
//                     ),
//                   ]),
//                 ],
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime dt) {
//     final diff = DateTime.now().difference(dt);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inHours < 1)  return '${diff.inMinutes}m ago';
//     if (diff.inDays < 1)   return '${diff.inHours}h ago';
//     if (diff.inDays == 1)  return 'Yesterday';
//     return DateFormat('dd MMM').format(dt);
//   }

//   _TypeConfig _typeConfig(String type) {
//     switch (type.toLowerCase()) {
//       case 'warning':
//         return _TypeConfig(
//           icon: Icons.warning_amber_rounded,
//           color: const Color(0xFFF59E0B),
//           iconBg: const Color(0xFFFEF3C7),
//           bgColor: const Color(0xFFFFFBEB),
//           borderColor: const Color(0xFFFDE68A),
//         );
//       case 'success':
//         return _TypeConfig(
//           icon: Icons.check_circle_rounded,
//           color: const Color(0xFF22C55E),
//           iconBg: const Color(0xFFDCFCE7),
//           bgColor: const Color(0xFFF0FDF4),
//           borderColor: const Color(0xFFBBF7D0),
//         );
//       case 'alert':
//         return _TypeConfig(
//           icon: Icons.error_rounded,
//           color: const Color(0xFFEF4444),
//           iconBg: const Color(0xFFFEE2E2),
//           bgColor: const Color(0xFFFFF5F5),
//           borderColor: const Color(0xFFFECDD3),
//         );
//       default:
//         return _TypeConfig(
//           icon: Icons.notifications_rounded,
//           color: AppTheme.primary,
//           iconBg: AppTheme.primary.withOpacity(0.12),
//           bgColor: AppTheme.primary.withOpacity(0.04),
//           borderColor: AppTheme.primary.withOpacity(0.20),
//         );
//     }
//   }
// }

// class _TypeConfig {
//   final IconData icon;
//   final Color color, iconBg, bgColor, borderColor;
//   const _TypeConfig({
//     required this.icon,
//     required this.color,
//     required this.iconBg,
//     required this.bgColor,
//     required this.borderColor,
//   });
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  USER ITEM — UserModel wrapper (toJson nahi chahiye)
// //  ⚠️  Agar error aaye to sirf _UserItem class mein field names fix karo
// // ══════════════════════════════════════════════════════════════════════════════
// class _UserItem {
//   final int id;
//   final String displayName;

//   const _UserItem({required this.id, required this.displayName});

//   /// ⚠️  Yahan UserModel ke ACTUAL field names use karo
//   /// StorageService dekhke guess: userId, userName, role
//   static _UserItem fromModel(UserModel u) {
//     // --- OPTION A: agar fields hain userId, userName, role ---
//     // return _UserItem(
//     //   id: u.userId,
//     //   displayName: '${u.userName} (${u.role})',
//     // );

//     // --- OPTION B: agar fields hain id, name, role ---
//     // return _UserItem(
//     //   id: u.id,
//     //   displayName: '${u.name} (${u.role})',
//     // );

//     // --- DEFAULT: StorageService naming se guess ---
//     // Uncomment jo sahi ho, baaki comment karo
//     return _UserItem(
//       id:          u.userId,                          // ← fix karo agar error aaye
//       displayName: '${u.userName} (${u.role})',       // ← fix karo agar error aaye
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  SEND NOTIFICATION SHEET — Admin only
// // ══════════════════════════════════════════════════════════════════════════════
// class _SendNotificationSheet extends StatefulWidget {
//   final NotificationController ctrl;
//   const _SendNotificationSheet({required this.ctrl});

//   @override
//   State<_SendNotificationSheet> createState() => _SendNotificationSheetState();
// }

// class _SendNotificationSheetState extends State<_SendNotificationSheet> {
//   List<_UserItem> _users = [];
//   bool _loadingUsers = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     try {
//       final list  = await ApiService.getAllUsers();
//       final myId  = StorageService.getUserId();
//       final items = list
//           .map((u) => _UserItem.fromModel(u))
//           .where((item) => item.id != myId)
//           .toList();

//       if (mounted) {
//         setState(() {
//           _users        = items;
//           _loadingUsers = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _loadingUsers = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ctrl   = widget.ctrl;
//     final bottom = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           // Handle
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),

//           // Header
//           Row(children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: AppTheme.primary.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(Icons.send_rounded,
//                   color: AppTheme.primary, size: 18),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Send Notification',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//                 color: Color(0xFF1A1D2E),
//               ),
//             ),
//           ]),
//           const SizedBox(height: 20),

//           Form(
//             key: ctrl.sendFormKey,
//             child: Column(children: [

//               // ── User select ──────────────────────────────────────
//               _loadingUsers
//                   ? LinearProgressIndicator(color: AppTheme.primary)
//                   : Obx(() => DropdownButtonFormField<int>(
//                         value: ctrl.selectedUserId.value,
//                         decoration: _fd(
//                             'To (Select User)',
//                             Icons.person_outline_rounded),
//                         isExpanded: true,
//                         items: _users
//                             .map((item) => DropdownMenuItem<int>(
//                                   value: item.id,
//                                   child: Text(
//                                     item.displayName,
//                                     style: const TextStyle(
//                                         fontFamily: 'Poppins',
//                                         fontSize: 13),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ))
//                             .toList(),
//                         onChanged: (v) =>
//                             ctrl.selectedUserId.value = v,
//                         validator: (v) => v == null
//                             ? 'Please select a user'
//                             : null,
//                         style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 13,
//                           color: Color(0xFF1A1D2E),
//                         ),
//                       )),
//               const SizedBox(height: 14),

//               // ── Type ─────────────────────────────────────────────
//               Obx(() => DropdownButtonFormField<String>(
//                     value: ctrl.selectedType.value,
//                     decoration: _fd('Type', Icons.label_outline_rounded),
//                     items: const [
//                       DropdownMenuItem(
//                           value: 'info', child: Text('ℹ️  Info')),
//                       DropdownMenuItem(
//                           value: 'success', child: Text('✅  Success')),
//                       DropdownMenuItem(
//                           value: 'warning', child: Text('⚠️  Warning')),
//                       DropdownMenuItem(
//                           value: 'alert', child: Text('🚨  Alert')),
//                     ],
//                     onChanged: (v) => ctrl.selectedType.value = v!,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 13,
//                       color: Color(0xFF1A1D2E),
//                     ),
//                   )),
//               const SizedBox(height: 14),

//               // ── Title ─────────────────────────────────────────────
//               TextFormField(
//                 controller: ctrl.titleCtrl,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 13),
//                 decoration: _fd('Title', Icons.title_rounded),
//                 validator: (v) => (v == null || v.trim().isEmpty)
//                     ? 'Title required'
//                     : null,
//               ),
//               const SizedBox(height: 14),

//               // ── Message ───────────────────────────────────────────
//               TextFormField(
//                 controller: ctrl.messageCtrl,
//                 maxLines: 3,
//                 style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 13),
//                 decoration: _fd('Message', Icons.message_outlined),
//                 validator: (v) => (v == null || v.trim().isEmpty)
//                     ? 'Message required'
//                     : null,
//               ),
//               const SizedBox(height: 20),

//               // ── Send button ───────────────────────────────────────
//               Obx(() => SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton.icon(
//                       onPressed: ctrl.isSending.value
//                           ? null
//                           : ctrl.sendNotification,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.primary,
//                         disabledBackgroundColor:
//                             AppTheme.primary.withOpacity(0.55),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14)),
//                         elevation: 0,
//                       ),
//                       icon: ctrl.isSending.value
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Icon(Icons.send_rounded,
//                               color: Colors.white, size: 18),
//                       label: Text(
//                         ctrl.isSending.value
//                             ? 'Sending...'
//                             : 'Send Notification',
//                         style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   )),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }

//   InputDecoration _fd(String hint, IconData icon) => InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 13,
//             color: Colors.grey[400]),
//         prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
//         filled: true,
//         fillColor: const Color(0xFFF7F8FA),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide: BorderSide.none),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide:
//                 const BorderSide(color: Color(0xFFEEEFF3), width: 1.2)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide:
//                 BorderSide(color: AppTheme.primary, width: 1.6)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide:
//                 const BorderSide(color: Colors.red, width: 1.2)),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(13),
//             borderSide:
//                 const BorderSide(color: Colors.red, width: 1.6)),
//       );
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  EMPTY STATE
// // ══════════════════════════════════════════════════════════════════════════════
// class _EmptyState extends StatelessWidget {
//   const _EmptyState();

//   @override
//   Widget build(BuildContext context) => Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Icon(Icons.notifications_off_outlined,
//               size: 64, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           Text(
//             'No notifications yet',
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//               color: Colors.grey[400],
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "You're all caught up!",
//             style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.grey[400]),
//           ),
//         ]),
//       );
// }

// // ══════════════════════════════════════════════════════════════════════════════
// //  SECTION HEADER
// // ══════════════════════════════════════════════════════════════════════════════
// class _SectionHeader extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//   const _SectionHeader(
//       {required this.label, required this.count, required this.color});

//   @override
//   Widget build(BuildContext context) => Row(children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w700,
//             fontSize: 13,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           padding:
//               const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             '$count',
//             style: TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ),
//       ]);
// }









// lib/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/notification_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(() => ctrl.notifications.any((n) => !n.isRead)
              ? TextButton(
                  onPressed: ctrl.markAllRead,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),

      floatingActionButton: ctrl.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showSendSheet(context, ctrl),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                'Send',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,

      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }

        if (ctrl.notifications.isEmpty) {
          return const _EmptyState();
        }

        final unread = ctrl.notifications.where((n) => !n.isRead).toList();
        final read   = ctrl.notifications.where((n) =>  n.isRead).toList();

        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: ctrl.loadNotifications,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(
                    label: 'New',
                    count: unread.length,
                    color: AppTheme.primary),
                const SizedBox(height: 8),
                ...unread.map((n) => _NotifCard(n: n, ctrl: ctrl)),
                const SizedBox(height: 16),
              ],
              if (read.isNotEmpty) ...[
                _SectionHeader(
                    label: 'Earlier',
                    count: read.length,
                    color: Colors.grey),
                const SizedBox(height: 8),
                ...read.map((n) => _NotifCard(n: n, ctrl: ctrl)),
              ],
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  void _showSendSheet(BuildContext context, NotificationController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SendNotificationSheet(ctrl: ctrl),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════════
class _NotifCard extends StatelessWidget {
  final NotificationModel n;
  final NotificationController ctrl;
  const _NotifCard({required this.n, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cfg = _typeConfig(n.type);

    return GestureDetector(
      onTap: () => ctrl.markRead(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : cfg.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead ? const Color(0xFFEEEFF3) : cfg.borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(n.isRead ? 0.03 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cfg.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cfg.icon, color: cfg.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              n.isRead ? FontWeight.w500 : FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF1A1D2E),
                        ),
                      ),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cfg.iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        n.type.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: cfg.color,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(n.createdAt),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1)   return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)   return 'Yesterday';
    return DateFormat('dd MMM').format(dt);
  }

  _TypeConfig _typeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return _TypeConfig(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFEF3C7),
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
        );
      case 'success':
        return _TypeConfig(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
          iconBg: const Color(0xFFDCFCE7),
          bgColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFBBF7D0),
        );
      case 'alert':
        return _TypeConfig(
          icon: Icons.error_rounded,
          color: const Color(0xFFEF4444),
          iconBg: const Color(0xFFFEE2E2),
          bgColor: const Color(0xFFFFF5F5),
          borderColor: const Color(0xFFFECDD3),
        );
      default:
        return _TypeConfig(
          icon: Icons.notifications_rounded,
          color: AppTheme.primary,
          iconBg: AppTheme.primary.withOpacity(0.12),
          bgColor: AppTheme.primary.withOpacity(0.04),
          borderColor: AppTheme.primary.withOpacity(0.20),
        );
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color, iconBg, bgColor, borderColor;
  const _TypeConfig({
    required this.icon,
    required this.color,
    required this.iconBg,
    required this.bgColor,
    required this.borderColor,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
//  USER ITEM
// ══════════════════════════════════════════════════════════════════════════════
class _UserItem {
  final int id;
  final String displayName;
  const _UserItem({required this.id, required this.displayName});

  static _UserItem fromModel(UserModel u) {
    return _UserItem(
      id:          u.userId,
      displayName: '${u.userName} (${u.role})',
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SEND NOTIFICATION SHEET — Admin only
// ══════════════════════════════════════════════════════════════════════════════
class _SendNotificationSheet extends StatefulWidget {
  final NotificationController ctrl;
  const _SendNotificationSheet({required this.ctrl});

  @override
  State<_SendNotificationSheet> createState() => _SendNotificationSheetState();
}

class _SendNotificationSheetState extends State<_SendNotificationSheet> {
  List<_UserItem> _users = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final list  = await ApiService.getAllUsers();
      final myId  = StorageService.getUserId();
      final items = list
          .map((u) => _UserItem.fromModel(u))
          .where((item) => item.id != myId)
          .toList();
      if (mounted) {
        setState(() {
          _users        = items;
          _loadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl   = widget.ctrl;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.send_rounded, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Send Notification',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1A1D2E),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          Form(
            key: ctrl.sendFormKey,
            child: Column(children: [
              _loadingUsers
                  ? LinearProgressIndicator(color: AppTheme.primary)
                  : Obx(() => DropdownButtonFormField<int>(
                        value: ctrl.selectedUserId.value,
                        decoration: _fd('To (Select User)', Icons.person_outline_rounded),
                        isExpanded: true,
                        items: _users
                            .map((item) => DropdownMenuItem<int>(
                                  value: item.id,
                                  child: Text(
                                    item.displayName,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => ctrl.selectedUserId.value = v,
                        validator: (v) =>
                            v == null ? 'Please select a user' : null,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF1A1D2E),
                        ),
                      )),
              const SizedBox(height: 14),

              Obx(() => DropdownButtonFormField<String>(
                    value: ctrl.selectedType.value,
                    decoration: _fd('Type', Icons.label_outline_rounded),
                    items: const [
                      DropdownMenuItem(value: 'info',    child: Text('ℹ️  Info')),
                      DropdownMenuItem(value: 'success', child: Text('✅  Success')),
                      DropdownMenuItem(value: 'warning', child: Text('⚠️  Warning')),
                      DropdownMenuItem(value: 'alert',   child: Text('🚨  Alert')),
                    ],
                    onChanged: (v) => ctrl.selectedType.value = v!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF1A1D2E),
                    ),
                  )),
              const SizedBox(height: 14),

              TextFormField(
                controller: ctrl.titleCtrl,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: _fd('Title', Icons.title_rounded),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: ctrl.messageCtrl,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                decoration: _fd('Message', Icons.message_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Message required' : null,
              ),
              const SizedBox(height: 20),

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: ctrl.isSending.value
                          ? null
                          : ctrl.sendNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor:
                            AppTheme.primary.withOpacity(0.55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: ctrl.isSending.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                      label: Text(
                        ctrl.isSending.value ? 'Sending...' : 'Send Notification',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )),
            ]),
          ),
        ]),
      ),
    );
  }

  InputDecoration _fd(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide:
                const BorderSide(color: Color(0xFFEEEFF3), width: 1.2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: AppTheme.primary, width: 1.6)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.red, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Colors.red, width: 1.6)),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up!",
            style: TextStyle(
                fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
          ),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SectionHeader(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ]);
}