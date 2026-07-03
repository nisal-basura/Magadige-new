import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/form_status.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/theme_toggle_row.dart';
import '../../../data/repositories/auth_repository.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(context.read<AuthRepository>()),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (a, b) => a.status != b.status || a.step != b.step,
        listener: (context, state) {
          if (state.status == FormStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.status == FormStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Password reset — please log in.')));
            context.go('/login');
          }
        },
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                      const ThemeToggleRow(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(3, (i) {
                      final stepNum = i + 1;
                      final active = stepNum == state.step;
                      final done = stepNum < state.step;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: done || active ? (done ? const Color(0xFF22C58B) : p.brand) : p.borderStrong,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (state.step == 1) _EmailStep(cubit: cubit, state: state, palette: p),
                  if (state.step == 2) _OtpStep(cubit: cubit, state: state, palette: p),
                  if (state.step == 3) _ResetStep(cubit: cubit, state: state),
                  const SizedBox(height: 20),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text('Remembered your password? ', style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Log in', style: TextStyle(color: p.brand, fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  const _MiniIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: p.brandStrong, size: 22),
    );
  }
}

class _EmailStep extends StatelessWidget {
  final ForgotPasswordCubit cubit;
  final ForgotPasswordState state;
  final AppPalette palette;
  const _EmailStep({required this.cubit, required this.state, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MiniIcon(Icons.mail_outline_rounded),
        Text('Forgot your password?', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text("No worries. Enter your email and we'll send a 4-digit code to reset it.",
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        TextField(
          onChanged: cubit.emailChanged,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email address', hintText: 'you@example.com', prefixIcon: Icon(Icons.mail_outline_rounded, size: 20)),
        ),
        const SizedBox(height: 20),
        GradientButton(label: 'Send reset code', loading: state.status == FormStatus.submitting, onPressed: cubit.submitEmail),
      ],
    );
  }
}

class _OtpStep extends StatelessWidget {
  final ForgotPasswordCubit cubit;
  final ForgotPasswordState state;
  final AppPalette palette;
  const _OtpStep({required this.cubit, required this.state, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MiniIcon(Icons.shield_outlined),
        Text('Enter verification code', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'We sent a 4-digit code to '),
              TextSpan(text: state.email.isEmpty ? 'your email' : state.email, style: const TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: '. It expires in 5 minutes.'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 60,
              height: 64,
              child: TextField(
                maxLength: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  final chars = state.otp.padRight(4).split('');
                  chars[i] = v.isEmpty ? ' ' : v;
                  cubit.otpChanged(chars.join().trim());
                  if (v.isNotEmpty && i < 3) FocusScope.of(context).nextFocus();
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: cubit.submitEmail, child: const Text("Didn't get a code? Resend")),
        const SizedBox(height: 14),
        GradientButton(label: 'Verify code', loading: state.status == FormStatus.submitting, onPressed: cubit.submitOtp),
      ],
    );
  }
}

class _ResetStep extends StatefulWidget {
  final ForgotPasswordCubit cubit;
  final ForgotPasswordState state;
  const _ResetStep({required this.cubit, required this.state});

  @override
  State<_ResetStep> createState() => _ResetStepState();
}

class _ResetStepState extends State<_ResetStep> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MiniIcon(Icons.lock_outline_rounded),
        Text('Set a new password', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Make it strong — at least 6 characters.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        TextField(
          onChanged: widget.cubit.newPasswordChanged,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'New password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: widget.cubit.confirmPasswordChanged,
          obscureText: _obscure,
          decoration: const InputDecoration(labelText: 'Confirm new password', prefixIcon: Icon(Icons.lock_outline_rounded, size: 20)),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Reset password',
          loading: widget.state.status == FormStatus.submitting,
          onPressed: widget.cubit.submitNewPassword,
        ),
      ],
    );
  }
}
