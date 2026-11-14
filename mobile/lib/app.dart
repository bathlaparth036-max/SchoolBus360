import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/services/network_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'routing/app_router.dart';

/// Root Application Widget configuring theme, dependency injection, and state listeners.
class SchoolBus360App extends StatelessWidget {
  const SchoolBus360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NetworkService>(
          create: (_) => NetworkService(),
        ),
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        ChangeNotifierProxyProvider2<AuthRepository, UserRepository, AuthController>(
          create: (ctx) => AuthController(
            authRepository: ctx.read<AuthRepository>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (ctx, authRepo, userRepo, previous) =>
              previous ?? AuthController(authRepository: authRepo, userRepository: userRepo),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRouter(),
      ),
    );
  }
}
