import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/repositories/dream_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../cubit/dreams_cubit.dart';
import 'widgets/add_dream_sheet.dart';
import 'widgets/dream_card.dart';
import 'widgets/dream_detail_sheet.dart';

class DreamsScreen extends StatelessWidget {
  const DreamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DreamsCubit(context.read<DreamRepository>(), context.read<TaskRepository>()),
      child: const _DreamsView(),
    );
  }
}

class _DreamsView extends StatelessWidget {
  const _DreamsView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<DreamsCubit, DreamsState>(
      builder: (context, state) {
        final cubit = context.read<DreamsCubit>();

        return AppScaffold(
          title: 'Dream Board',
          subtitle: 'Life goals, tracked like tasks.',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddDreamSheet(context, onSave: cubit.addDream),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Dream'),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✦ Today\'s work builds tomorrow\'s dream.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, fontFamily: 'SpaceGrotesk')),
                      const SizedBox(height: 8),
                      const Text(
                        'Every task you complete quietly moves one of these goals forward.',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('${state.dreams.length} goal${state.dreams.length == 1 ? "" : "s"} in motion', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (state.dreams.isEmpty)
                  EmptyStateView(
                    icon: Icons.star_border_rounded,
                    title: 'No dreams yet',
                    message: 'Define one life goal and watch your daily tasks quietly build toward it.',
                    actionLabel: 'Define your first dream',
                    onAction: () => showAddDreamSheet(context, onSave: cubit.addDream),
                  )
                else
                  ...state.dreams.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: DreamCard(
                          dream: d,
                          onTap: () => showDreamDetailSheet(
                            context,
                            dream: d,
                            relatedTasks: state.relatedTasks(d),
                            onDelete: () => cubit.deleteDream(d),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}
