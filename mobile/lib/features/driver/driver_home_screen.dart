import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/network_service.dart';
import '../auth/auth_controller.dart';

/// Driver Home Screen for Phase 1.
/// Verifies Driver role authorization, assigned bus association, and device-independent UID identity.
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

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
    final driver = authController.driverProfile;
    final bus = authController.assignedBus;
    final school = authController.currentSchool;
    final isOnline = networkService.isOnline;

    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : (user?.name.isNotEmpty == true ? user!.name : 'Driver');

    final assignedBusDisplay = bus?.busNumber.isNotEmpty == true
        ? bus!.busNumber
        : (driver?.assignedBusId != null ? 'Bus ID: ${driver!.assignedBusId}' : AppStrings.notAssigned);

    final schoolName = school?.name.isNotEmpty == true
        ? school!.name
        : (user?.schoolId.isNotEmpty == true ? 'School ID: ${user!.schoolId}' : 'N/A');

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

              // Driver Card
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
                              Icons.drive_eta,
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
                                  driverName,
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
                        value: 'Driver',
                        chipColor: Colors.amber.shade50,
                        chipTextColor: Colors.amber.shade900,
                      ),
                      const SizedBox(height: 14),

                      // School Field
                      _buildInfoRow(
                        label: AppStrings.schoolLabel,
                        value: schoolName,
                      ),
                      const SizedBox(height: 14),

                      // Assigned Bus Field
                      _buildInfoRow(
                        label: AppStrings.assignedBusLabel,
                        value: assignedBusDisplay,
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Device-Independent Session Card (Section 27: Driver Phone Switching Resilience)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phonelink_setup, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device-Independent Identity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Driver UID: ${user?.uid ?? "N/A"}\nIdentity is bound to Firebase UID, not hardware. Any phone can be switched seamlessly.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
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
                  'Phase 1: Foundation Mode\n(Driver GPS Tracking service will be enabled in Phase 2)',
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
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
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
                  style: TextStyle(
                    fontSize: isHighlight ? 16 : 14,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                    color: isHighlight ? AppColors.accentBusYellowDark : AppColors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
