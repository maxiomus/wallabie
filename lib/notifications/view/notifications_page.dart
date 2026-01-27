import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:august_chat/l10n/app_localizations.dart';
import 'package:august_chat/repositories/notifications_repository.dart';
import 'package:august_chat/chat/view/chat_page.dart';
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
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider(
      create: (context) => NotificationsBloc(
        notificationsRepository: context.read<NotificationsRepository>(),
      )..add(NotificationsStarted(userId: userId)),
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
                        .add(AllNotificationsMarkedAsRead(userId: userId));
                  },
                  child: Text(l10n.markAllRead),
                );
              },
            ),
          ],
        ),
        body: _NotificationsBody(userId: userId),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
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
            return _NotificationTile(
              notification: notification,
              userId: userId,
            );
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.userId,
  });

  final NotificationItem notification;
  final String userId;

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
          context.read<NotificationsBloc>().add(
                NotificationMarkedAsRead(
                  userId: userId,
                  notificationId: notification.id,
                ),
              );
        }

        // Navigate to chat if roomId is present
        final roomId = notification.roomId;
        if (roomId != null && roomId.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatPage(
                roomId: roomId,
                title: notification.title,
              ),
            ),
          );
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
