import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/network_service.dart';
import '../auth/auth_controller.dart';

/// Parent Home Screen for Phase 1.
/// Proves role-based authentication, student privacy scoping, and session persistence.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logoutConfirmTitle),
        content: const Text(AppStrings.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final networkService = context.watch<NetworkService>();
    final user = authController.currentUser;
    final school = authController.currentSchool;
    final students = authController.parentStudents;
    final isOnline = networkService.isOnline;

    final parentName = user?.name.isNotEmpty == true ? user!.name : 'Parent';
    final schoolName = school?.name.isNotEmpty == true ? school!.name : 'School ID: ${user?.schoolId ?? "N/A"}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Offline Indicator Banner
              if (!isOnline) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.offlineBannerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.offlineMessage,
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Role Proof Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentBusYellow.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.family_restroom,
                              color: AppColors.accentBusYellowDark,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.welcome,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  parentName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),

                      // Role Field
                      _buildInfoRow(
                        label: AppStrings.roleLabel,
                        value: 'Parent',
                        chipColor: Colors.blue.shade50,
                        chipTextColor: Colors.blue.shade800,
                      ),
                      const SizedBox(height: 12),

                      // School Field
                      _buildInfoRow(
                        label: AppStrings.schoolLabel,
                        value: schoolName,
                      ),
                      const SizedBox(height: 12),

                      // Platform Tag
                      _buildInfoRow(
                        label: 'Platform:',
                        value: AppStrings.appName,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Linked Students Card (Child Safety & Scoped Access Demonstration)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.child_care, color: AppColors.primary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Linked Children',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (students.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No children linked to this parent account yet.\nPlease contact the school transport administrator.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        )
                      else
                        ...students.map(
                          (student) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: AppColors.accentBusYellowDark),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Bus: ${student.busId ?? "Not assigned"}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
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

              const SizedBox(height: 24),

              // Logout Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(AppStrings.logout),
                onPressed: () => _confirmLogout(context),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Phase 1: Foundation Mode\n(Live GPS tracking enabled in Phase 2)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? chipColor,
    Color? chipTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: chipColor != null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: chipTextColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
