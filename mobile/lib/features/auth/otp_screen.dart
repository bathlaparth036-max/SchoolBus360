import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/phone_formatter.dart';
import '../../core/utils/validators.dart';
import 'auth_controller.dart';

/// Screen for entering and verifying 6-digit SMS OTP.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthController>().verifyOtp(_otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final phone = authController.phoneNumber ?? '';
    final formattedPhone = PhoneFormatter.formatDisplay(phone);
    final cooldown = authController.cooldownSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.otpTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            authController.changePhoneNumber();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentBusYellow.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 50,
                      color: AppColors.accentBusYellowDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.otpTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.otpSubtitle}\n$formattedPhone',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
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

                // OTP Input Field
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '• • • • • •',
                    counterText: '',
                  ),
                  validator: Validators.validateOtp,
                  onFieldSubmitted: (_) => _handleVerify(),
                ),
                const SizedBox(height: 24),

                // Verify Button
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _handleVerify,
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(AppStrings.verifyOtp),
                ),
                const SizedBox(height: 20),

                // Resend OTP / Cooldown Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cooldown > 0)
                      Text(
                        '${AppStrings.resendWait} ${cooldown}s',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: authController.isLoading
                            ? null
                            : () => authController.resendOtp(),
                        child: const Text(
                          AppStrings.resendOtp,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Change Phone Number
                Center(
                  child: TextButton(
                    onPressed: authController.isLoading
                        ? null
                        : () => authController.changePhoneNumber(),
                    child: const Text(
                      AppStrings.changePhoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
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
