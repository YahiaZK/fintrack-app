import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../theme/app_colors.dart';
import 'auth_form.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _submit(String email, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _friendly(e));
    } catch (e) {
      if (mounted) setState(() => _error = 'Sign in failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Sign in failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Welcome back',
      subtitle: 'Sign in to continue your journey.',
      ctaLabel: 'Sign in',
      busy: _busy,
      error: _error,
      onSubmit: _submit,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          GestureDetector(
            onTap: () => context.go('/auth/sign-up'),
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
