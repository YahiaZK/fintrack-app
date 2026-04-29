import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/user_providers.dart';
import '../../theme/app_colors.dart';
import 'auth_form.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _submit(String email, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final cred = await ref.read(authServiceProvider).signUp(
            email: email,
            password: password,
          );
      final uid = cred.user?.uid;
      if (uid != null) {
        await ref
            .read(userServiceProvider)
            ?.createInitial(email: email.trim());
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = _friendly(e));
    } catch (e) {
      if (mounted) setState(() => _error = 'Sign up failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled.';
      default:
        return e.message ?? 'Sign up failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Create account',
      subtitle: 'Start tracking your finances today.',
      ctaLabel: 'Sign up',
      busy: _busy,
      error: _error,
      onSubmit: _submit,
      minPasswordLength: 6,
      requireConfirmPassword: true,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          GestureDetector(
            onTap: () => context.go('/auth/sign-in'),
            child: const Text(
              'Sign in',
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
