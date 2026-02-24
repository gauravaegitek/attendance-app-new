// lib/widgets/notification_badge.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notification_controller.dart';
import '../theme/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final Color iconColor;
  const NotificationBadge({super.key, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return GestureDetector(
      onTap: () => Get.toNamed('/notifications'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Obx(() {
          final count = ctrl.unreadCount.value;
          return Stack(clipBehavior: Clip.none, children: [
            Icon(Icons.notifications_outlined, color: iconColor, size: 26),
            if (count > 0)
              Positioned(
                top: -4, right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ]);
        }),
      ),
    );
  }
}