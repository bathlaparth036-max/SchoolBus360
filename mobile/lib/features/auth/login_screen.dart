import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/network_service.dart';
import '../../core/utils/phone_formatter.dart';
import '../../core/utils/validators.dart';
import 'auth_controller.dart';

/// Lightweight, high-contrast login screen tailored for low-end Android phones.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final normalized = PhoneFormatter.normalizeToE164(_phoneController.text.trim());
    context.read<AuthController>().sendOtp(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final networkService = context.watch<NetworkService>();
    final isOnline = networkService.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Offline Warning Banner
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

                const SizedBox(height: 16),

                // SchoolBus360 Logo & Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentBusYellow.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      size: 54,
                      color: AppColors.accentBusYellowDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  AppStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Error Banner
                if (authController.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      border: Border.all(color: AppColors.error.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authController.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Phone Input Field
                const Text(
                  AppStrings.phoneLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Text(
                        '+91 ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: AppStrings.phonePlaceholder,
                    counterText: '',
                  ),
                  validator: Validators.validateIndianPhone,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _handleSubmit,
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(AppStrings.sendOtp),
                ),
                const SizedBox(height: 24),

                // Security Note
                const Center(
                  child: Text(
                    'SchoolBus360 protects student privacy.\nOnly authorized school users can access transportation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
