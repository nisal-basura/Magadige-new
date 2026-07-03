import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/theme_toggle_row.dart';

/// Mobile equivalent of the web app's marketing landing page — a compact
/// welcome screen that gets the user to Login/Register quickly.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(alignment: Alignment.topRight, child: const ThemeToggleRow()),
              const Spacer(),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: p.brand.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 14))],
                ),
                alignment: Alignment.center,
                child: const Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 36)),
              ),
              const SizedBox(height: 28),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.displaySmall,
                  children: [
                    const TextSpan(text: 'Plan your day.\n'),
                    TextSpan(
                      text: 'Build your dream.',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = LinearGradient(colors: p.heroGradient).createShader(const Rect.fromLTWH(0, 0, 260, 70)),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'A calm, beautiful productivity workspace that connects your daily tasks to your life\'s biggest dreams.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              GradientButton(label: 'Get started free', onPressed: () => context.push('/register')),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => context.push('/login'),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 8),
              Text('No credit card required · Free forever plan', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
