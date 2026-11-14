import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/driver/driver_home_screen.dart';
import '../features/parent/parent_home_screen.dart';

/// Central router widget resolving the active screen from authentication state and user role.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    switch (authController.status) {
      case AuthStatus.initial:
        return const _SplashScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.sendingOtp:
        return const LoginScreen();

      case AuthStatus.otpSent:
      case AuthStatus.verifyingOtp:
        return const OtpScreen();

      case AuthStatus.unregistered:
        return const _UnregisteredNoticeScreen();

      case AuthStatus.error:
        if (authController.verificationId != null) {
          return const OtpScreen();
        }
        return const LoginScreen();

      case AuthStatus.authenticated:
        final role = authController.currentRole;
        if (role.isParent) {
          return const ParentHomeScreen();
        } else if (role.isDriver) {
          return const DriverHomeScreen();
        } else if (role.isAdmin) {
          return const _AdminNoticeScreen();
        } else {
          return const _UnregisteredNoticeScreen();
        }
    }
  }
}

/// Loading splash screen while checking session persistence on cold boot.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 72,
              color: AppColors.accentBusYellow,
            ),
            SizedBox(height: 20),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 36),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBusYellow),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Controlled onboarding screen displayed when an authenticated phone number
/// does not match any registered school record. Prevents self-promotion to admin.
class _UnregisteredNoticeScreen extends StatelessWidget {
  const _UnregisteredNoticeScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  size: 56,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.accountPendingTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.accountPendingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(AppStrings.logout),
                onPressed: () => auth.logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notice screen informing administrator users to access the dedicated React Admin Web Portal.
class _AdminNoticeScreen extends StatelessWidget {
  const _AdminNoticeScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Administrator Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You are logged in as an Administrator. The mobile application is optimized for Parents and Drivers.\n\nPlease open the SchoolBus360 Admin Web Portal on your computer to manage routes, buses, drivers, and students.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(AppStrings.logout),
                onPressed: () => auth.logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
