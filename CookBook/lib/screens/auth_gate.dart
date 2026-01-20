import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'nav_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        if (user == null) {
          return const LoginScreen();
        }
        if (authProvider.isEmailVerified) {
          return const NavScreen();
        } else {
          return const VerifyEmailScreen();
        }
      },
    );
  }
}
