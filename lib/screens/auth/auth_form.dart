import 'package:flutter/material.dart';

import '../../components/onboarding/fintrack_logo.dart';
import '../../theme/app_colors.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.busy,
    required this.error,
    required this.onSubmit,
    required this.footer,
    this.minPasswordLength = 1,
    this.requireConfirmPassword = false,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final bool busy;
  final String? error;
  final void Function(String email, String password) onSubmit;
  final Widget footer;
  final int minPasswordLength;
  final bool requireConfirmPassword;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _trySubmit() {
    if (widget.busy) return;
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(child: FintrackLogo()),
                const SizedBox(height: 32),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildLabel('Email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('you@example.com'),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email is required';
                    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value);
                    if (!ok) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: widget.requireConfirmPassword
                      ? TextInputAction.next
                      : TextInputAction.done,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _decoration('Your password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onFieldSubmitted: widget.requireConfirmPassword
                      ? null
                      : (_) => _trySubmit(),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Password is required';
                    if (value.length < widget.minPasswordLength) {
                      return 'Min ${widget.minPasswordLength} characters';
                    }
                    return null;
                  },
                ),
                if (widget.requireConfirmPassword) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Confirm Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _decoration('Re-enter password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (_) => _trySubmit(),
                    validator: (v) {
                      final value = v ?? '';
                      if (value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                if (widget.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      widget.error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.busy ? null : _trySubmit,
                    child: widget.busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : Text(widget.ctaLabel),
                  ),
                ),
                const SizedBox(height: 20),
                widget.footer,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.cardSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2E3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}
