import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // =================== APP BAR ===================
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: AppTheme.gradientDecoration,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Avatar & Name
                            Obx(() => Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  child: Text(
                                    authController.userName.value.isNotEmpty
                                        ? authController.userName.value[0]
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, ${authController.userName.value}!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        authController.userRole.value
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),

                            // Logout Button
                            IconButton(
                              icon: const Icon(Icons.logout,
                                  color: Colors.white),
                              onPressed: authController.logout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Date/Time
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: const [],
          ),

          // =================== CONTENT ===================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================== QUICK ACTIONS ===================
                  const Text('Quick Actions', style: AppTheme.headline3),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Check In
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.login,
                          label: 'Check In',
                          color: AppTheme.success,
                          bgColor: AppTheme.successLight,
                          onTap: () => Get.toNamed('/mark-in'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Check Out
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.logout,
                          label: 'Check Out',
                          color: AppTheme.error,
                          bgColor: AppTheme.errorLight,
                          onTap: () => Get.toNamed('/mark-out'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // My Summary
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.calendar_month,
                          label: 'My Summary',
                          color: AppTheme.primary,
                          bgColor: AppTheme.primaryLight,
                          onTap: () => Get.toNamed('/user-summary'),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Admin Summary (only for admin)
                      Expanded(
                        child: Obx(() => authController.isAdmin
                            ? _ActionCard(
                                icon: Icons.admin_panel_settings,
                                label: 'Admin Panel',
                                color: AppTheme.accent,
                                bgColor: AppTheme.warningLight,
                                onTap: () => Get.toNamed('/admin'),
                              )
                            : _ActionCard(
                                icon: Icons.history,
                                label: 'History',
                                color: AppTheme.textSecondary,
                                bgColor: AppTheme.background,
                                onTap: () => Get.toNamed('/user-summary'),
                              )),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =================== INFO CARDS ===================
                  const Text('Today\'s Info', style: AppTheme.headline3),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time,
                          label: 'Office Hours',
                          value: '9:00 AM - 6:00 PM',
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.work_outline,
                          label: 'Work Days',
                          value: 'Mon - Sat',
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Instructions Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text('How to Mark Attendance',
                                style: AppTheme.headline3),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InstructionStep(
                          number: '1',
                          text: 'Tap "Check In" or "Check Out"',
                        ),
                        _InstructionStep(
                          number: '2',
                          text: 'Allow location permission',
                        ),
                        _InstructionStep(
                          number: '3',
                          text: 'Take a selfie for verification',
                        ),
                        _InstructionStep(
                          number: '4',
                          text: 'Submit to mark attendance',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}
