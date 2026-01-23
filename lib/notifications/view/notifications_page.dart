import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:august_chat/l10n/app_localizations.dart';
import '../bloc/notifications_bloc.dart';

/// Page displaying user notifications.
class NotificationsPage extends StatelessWidget {
  /// Creates a [NotificationsPage].
  const NotificationsPage({super.key});

  /// Route for navigation.
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const NotificationsPage());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => NotificationsBloc()..add(const NotificationsStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notifications),
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state.unreadCount == 0) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () {
                    context
                        .read<NotificationsBloc>()
                        .add(const AllNotificationsMarkedAsRead());
                  },
                  child: Text(l10n.markAllRead),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state.status == NotificationsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == NotificationsStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? l10n.failedToLoadNotifications),
              );
            }

            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return Center(child: Text(l10n.noNotifications));
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final timeAgo = _formatTimeAgo(notification.createdAt, l10n);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.notifications_outlined,
          color: notification.isRead
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        notification.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timeAgo,
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {
        if (!notification.isRead) {
          context
              .read<NotificationsBloc>()
              .add(NotificationMarkedAsRead(notification.id));
        }
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return l10n.timeNow;
  }
}
