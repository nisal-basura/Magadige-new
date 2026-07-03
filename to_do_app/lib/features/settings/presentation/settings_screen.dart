import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/theme/theme_state.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/datasources/local_data_store.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final themeChoice = context.watch<ThemeCubit>().state.choice;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        return AppScaffold(
          title: 'Settings',
          subtitle: 'Tune Magadige Task to fit how you work.',
          showThemeToggle: false,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(context, 'Appearance', 'Choose how Magadige Task looks.', [
                Row(
                  children: [
                    _themePreview(context, 'Day', ThemeChoice.day, themeChoice, [const Color(0xFFF7F6FF), const Color(0xFFEEF8FF)]),
                    const SizedBox(width: 10),
                    _themePreview(context, 'Auto', ThemeChoice.auto, themeChoice, [const Color(0xFFF7F6FF), const Color(0xFF100F1C)]),
                    const SizedBox(width: 10),
                    _themePreview(context, 'Night', ThemeChoice.night, themeChoice, [const Color(0xFF100F1C), const Color(0xFF1A1930)]),
                  ],
                ),
              ]),
              const SizedBox(height: 14),
              _sectionCard(context, 'Notifications', 'Control what Magadige Task nudges you about.', [
                _toggleRow(context, 'Task due reminders', 'Get notified shortly before a task is due', state.taskReminders, (_) => cubit.toggleTaskReminders()),
                _toggleRow(context, 'Daily summary email', 'A recap of what you completed each evening', state.dailySummary, (_) => cubit.toggleDailySummary()),
                _toggleRow(context, 'Streak & achievement alerts', 'Celebrate milestones as they happen', state.streakAlerts, (_) => cubit.toggleStreakAlerts()),
                _toggleRow(context, 'Dream progress nudges', 'Gentle reminders tied to your life goals', state.dreamNudges, (_) => cubit.toggleDreamNudges()),
                _toggleRow(context, 'Marketing emails', 'Product news and tips — sent rarely', state.marketingEmails, (_) => cubit.toggleMarketingEmails(), showDivider: false),
              ]),
              const SizedBox(height: 14),
              _sectionCard(context, 'Language & Region', 'Set your preferred language.', [
                DropdownButtonFormField<String>(
                  initialValue: 'English (United States)',
                  decoration: const InputDecoration(labelText: 'App language'),
                  items: const ['English (United States)', 'English (United Kingdom)', 'French', 'Spanish', 'Portuguese']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (_) {},
                ),
              ]),
              const SizedBox(height: 14),
              _sectionCard(context, 'Privacy', "Manage what's visible and how your data is used.", [
                _toggleRow(context, 'Public productivity profile', "Let others see your streak & badges", state.publicProfile, (_) => cubit.togglePublicProfile()),
                _toggleRow(context, 'Usage analytics', 'Help us improve with anonymous usage data', state.usageAnalytics, (_) => cubit.toggleUsageAnalytics(), showDivider: false),
              ]),
              const SizedBox(height: 14),
              _sectionCard(context, 'Security', 'Protect your account.', [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: const Text('Last changed 3 months ago'),
                  trailing: OutlinedButton(onPressed: () {}, child: const Text('Change')),
                ),
                _toggleRow(context, 'Two-factor authentication', 'Add an extra layer of protection', state.twoFactor, (_) => cubit.toggleTwoFactor(), showDivider: false),
              ]),
              const SizedBox(height: 14),
              _sectionCard(context, 'Data', 'Export or remove your account data.', [
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Export started — this is a UI demo only.'))),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Export as JSON'),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFF1F1), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFD3D3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delete Account', style: TextStyle(color: Color(0xFFEE4F4F), fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text("This permanently deletes your account, tasks, and dreams.", style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE4F4F)),
                        onPressed: () => _confirmDelete(context),
                        child: const Text('Delete my account'),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This will permanently delete your account and all local data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              LocalDataStore.instance.reset();
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEE4F4F))),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, String title, String subtitle, List<Widget> children) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: p.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _toggleRow(BuildContext context, String title, String subtitle, bool value, ValueChanged<bool> onChanged, {bool showDivider = true}) {
    final p = context.palette;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        if (showDivider) Divider(color: p.borderSubtle, height: 20),
      ],
    );
  }

  Widget _themePreview(BuildContext context, String label, ThemeChoice value, ThemeChoice current, List<Color> gradient) {
    final p = context.palette;
    final active = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeCubit>().setChoice(value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? p.brand : p.borderDefault, width: active ? 2 : 1),
          ),
          child: Column(
            children: [
              Container(
                height: 56,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
