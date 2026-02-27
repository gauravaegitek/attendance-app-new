// // lib/widgets/notification_badge.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../controllers/notification_controller.dart';
// import '../theme/app_theme.dart';

// class NotificationBadge extends StatelessWidget {
//   final Color iconColor;
//   const NotificationBadge({super.key, this.iconColor = Colors.white});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.isRegistered<NotificationController>()
//         ? Get.find<NotificationController>()
//         : Get.put(NotificationController());

//     return GestureDetector(
//       onTap: () => Get.toNamed('/notifications'),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Obx(() {
//           final count = ctrl.unreadCount.value;
//           return Stack(clipBehavior: Clip.none, children: [
//             Icon(Icons.notifications_outlined, color: iconColor, size: 26),
//             if (count > 0)
//               Positioned(
//                 top: -4, right: -4,
//                 child: Container(
//                   padding: const EdgeInsets.all(3),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primary,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 1.5),
//                   ),
//                   constraints:
//                       const BoxConstraints(minWidth: 18, minHeight: 18),
//                   child: Text(
//                     count > 99 ? '99+' : '$count',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w700,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ]);
//         }),
//       ),
//     );
//   }
// }










// lib/core/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';

class NotificationBadge extends StatelessWidget {
  final Color iconColor;
  const NotificationBadge({super.key, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    return GestureDetector(
      onTap: () {
        // ✅ Sirf bell tap pe API call hogi
        ctrl.loadUnreadCount();
        ctrl.loadNotifications();
        Get.toNamed('/notifications');
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: iconColor,
              size: 22,
            ),
          ),
          Obx(() {
            if (ctrl.unreadCount.value == 0) return const SizedBox.shrink();
            return Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  ctrl.unreadCount.value > 99
                      ? '99+'
                      : '${ctrl.unreadCount.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}