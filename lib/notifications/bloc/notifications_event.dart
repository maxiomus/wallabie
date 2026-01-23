part of 'notifications_bloc.dart';

/// Base class for notifications events.
sealed class NotificationsEvent extends Equatable {
  /// Creates a [NotificationsEvent].
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

/// Event to load notifications.
final class NotificationsStarted extends NotificationsEvent {
  /// Creates a [NotificationsStarted] event.
  const NotificationsStarted();
}

/// Event to mark a single notification as read.
final class NotificationMarkedAsRead extends NotificationsEvent {
  /// Creates a [NotificationMarkedAsRead] event.
  const NotificationMarkedAsRead(this.notificationId);

  /// The ID of the notification to mark as read.
  final String notificationId;

  @override
  List<Object> get props => [notificationId];
}

/// Event to mark all notifications as read.
final class AllNotificationsMarkedAsRead extends NotificationsEvent {
  /// Creates an [AllNotificationsMarkedAsRead] event.
  const AllNotificationsMarkedAsRead();
}
