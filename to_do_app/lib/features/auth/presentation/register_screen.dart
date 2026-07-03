import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/form_status.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/theme_toggle_row.dart';
import '../../../data/repositories/auth_repository.dart';
import '../cubit/register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final strengthColors = [p.borderDefault, const Color(0xFFFF6B6B), const Color(0xFFFA8F0F), const Color(0xFF22C58B), const Color(0xFF16A374)];

    return Scaffold(
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            context.go('/dashboard');
          } else if (state.status == FormStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();
          final strength = state.passwordStrength;
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
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                      const ThemeToggleRow(),
                    ],
                  ),
                  Text('Create your account', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Start turning daily tasks into lifelong dreams — free forever.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Photo upload is a UI demo only.'))),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p.bgSunken,
                            border: Border.all(color: p.borderStrong, width: 2, style: BorderStyle.solid),
                          ),
                          child: Icon(Icons.camera_alt_outlined, color: p.textTertiary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(content: Text('Photo upload is a UI demo only.'))),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                            child: const Text('Upload photo', style: TextStyle(fontSize: 12.5)),
                          ),
                          const SizedBox(height: 4),
                          Text('Optional — PNG or JPG', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: cubit.nameChanged,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'Amaka Nwosu',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: cubit.emailChanged,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: cubit.passwordChanged,
                    obscureText: state.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(state.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: cubit.toggleObscure,
                      ),
                    ),
                  ),
                  if (state.password.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(4, (i) {
                        final active = i < strength;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: active ? strengthColors[strength] : p.bgSunken,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: cubit.confirmPasswordChanged,
                    obscureText: state.obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(value: state.agreedToTerms, onChanged: (_) => cubit.toggleAgreed()),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(text: 'Terms', style: TextStyle(color: p.brand, fontWeight: FontWeight.w700)),
                                const TextSpan(text: ' & '),
                                TextSpan(text: 'Privacy Policy', style: TextStyle(color: p.brand, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GradientButton(
                    label: 'Create account',
                    loading: state.status == FormStatus.submitting,
                    onPressed: cubit.submit,
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Divider(color: p.borderSubtle)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR SIGN UP WITH', style: Theme.of(context).textTheme.labelSmall),
                    ),
                    Expanded(child: Divider(color: p.borderSubtle)),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
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
