import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/form_status.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/theme_toggle_row.dart';
import '../../../data/repositories/auth_repository.dart';
import '../cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
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
          final cubit = context.read<LoginCubit>();
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
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(colors: p.heroGradient),
                      boxShadow: [BoxShadow(color: p.brand.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
                    ),
                    alignment: Alignment.center,
                    child: const Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26)),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Log in to continue building toward your dreams.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 28),
                  TextField(
                    onChanged: cubit.emailChanged,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: cubit.passwordChanged,
                    obscureText: state.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(state.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: cubit.toggleObscure,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(value: state.rememberMe, onChanged: (_) => cubit.toggleRemember()),
                          const Text('Remember me', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GradientButton(
                    label: 'Log in',
                    loading: state.status == FormStatus.submitting,
                    onPressed: cubit.submit,
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: Divider(color: p.borderSubtle)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR CONTINUE WITH', style: Theme.of(context).textTheme.labelSmall),
                    ),
                    Expanded(child: Divider(color: p.borderSubtle)),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
                          label: const Text('Google'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const Icon(Icons.code_rounded, size: 18),
                          label: const Text('GitHub'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text('Create one free',
                              style: TextStyle(color: p.brand, fontWeight: FontWeight.w700, fontSize: 13.5)),
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
