part of 'notifications_bloc.dart';

/// Status of the notifications loading process.
enum NotificationsStatus {
  /// Initial state, no action taken.
  idle,

  /// Notifications are being loaded.
  loading,

  /// Notifications loaded successfully.
  loaded,

  /// Failed to load notifications.
  failure,
}

/// Represents a single notification item.
class NotificationItem extends Equatable {
  /// Creates a [NotificationItem].
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  /// Unique notification identifier.
  final String id;

  /// Notification title.
  final String title;

  /// Notification body text.
  final String body;

  /// When the notification was created.
  final DateTime createdAt;

  /// Whether the notification has been read.
  final bool isRead;

  /// Creates a copy with the given fields replaced.
  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, isRead];
}

/// State of the notifications screen.
class NotificationsState extends Equatable {
  /// Creates a [NotificationsState] with optional parameters.
  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.notifications = const [],
    this.errorMessage,
  });

  /// Current loading status.
  final NotificationsStatus status;

  /// List of notifications.
  final List<NotificationItem> notifications;

  /// Error message if loading failed.
  final String? errorMessage;

  /// Number of unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Creates a copy of this state with the given fields replaced.
  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationItem>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
