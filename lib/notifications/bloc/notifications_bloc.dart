import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// Bloc that manages notifications list and read status.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  /// Creates a [NotificationsBloc].
  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<AllNotificationsMarkedAsRead>(_onAllMarkedAsRead);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    // Simulate loading notifications
    await Future.delayed(const Duration(milliseconds: 500));

    final notifications = [
      NotificationItem(
        id: '1',
        title: 'New message',
        body: 'John sent you a message',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Group invite',
        body: 'You were added to "Project Team"',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Welcome!',
        body: 'Thanks for joining August Chat',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    emit(state.copyWith(
      status: NotificationsStatus.loaded,
      notifications: notifications,
    ));
  }

  void _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) {
    final updated = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updated));
  }

  void _onAllMarkedAsRead(
    AllNotificationsMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updated));
  }
}
