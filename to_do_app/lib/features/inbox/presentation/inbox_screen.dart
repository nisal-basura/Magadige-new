import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../cubit/inbox_cubit.dart';
import '../cubit/unread_count_cubit.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InboxCubit(context.read<NotificationRepository>(), context.read<UnreadCountCubit>()),
      child: const _InboxView(),
    );
  }
}

class _InboxView extends StatelessWidget {
  const _InboxView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxCubit, InboxState>(
      builder: (context, state) {
        final cubit = context.read<InboxCubit>();
        final unread = state.unreadOnes;
        final read = state.readOnes;

        return AppScaffold(
          title: 'Inbox',
          subtitle: 'Everything Magadige Task wants you to know.',
          extraActions: [
            IconButton(icon: const Icon(Icons.done_all_rounded), tooltip: 'Mark all read', onPressed: cubit.markAllRead),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(context, 'All', InboxFilter.all, state.filter, cubit),
                      _filterChip(context, 'Unread', InboxFilter.unread, state.filter, cubit),
                      _filterChip(context, 'Reminders', InboxFilter.taskDue, state.filter, cubit),
                      _filterChip(context, 'Achievements', InboxFilter.badgeEarned, state.filter, cubit),
                      _filterChip(context, 'Dreams', InboxFilter.dreamProgress, state.filter, cubit),
                      _filterChip(context, 'System', InboxFilter.system, state.filter, cubit),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: state.filtered.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.mark_email_read_outlined,
                        title: "You're all caught up",
                        message: "No notifications here. We'll let you know when something needs your attention.",
                      )
                    : RefreshIndicator(
                        onRefresh: cubit.load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            if (unread.isNotEmpty) ...[
                              _sectionLabel(context, 'NEW'),
                              ...unread.map((n) => _NotificationTile(n: n, onTap: () => cubit.markRead(n.id), onDelete: () => cubit.delete(n.id))),
                            ],
                            if (read.isNotEmpty) ...[
                              _sectionLabel(context, 'EARLIER'),
                              ...read.map((n) => _NotificationTile(n: n, onTap: () {}, onDelete: () => cubit.delete(n.id))),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(BuildContext context, String label, InboxFilter value, InboxFilter current, InboxCubit cubit) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: current == value, onSelected: (_) => cubit.setFilter(value)),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel n;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _NotificationTile({required this.n, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.coral600, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: n.isUnread ? p.brandSoft : p.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.borderSubtle),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: n.type.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                  child: Icon(n.type.icon, size: 19, color: n.type.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(height: 2),
                      Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(n.time, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
