import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// Bloc that manages notifications list and read status.
///
/// Uses [NotificationsRepository] to stream notification history from
/// Firestore and manage read state.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  /// Creates a [NotificationsBloc] with the required repository.
  NotificationsBloc({
    required NotificationsRepository notificationsRepository,
  })  : _notificationsRepository = notificationsRepository,
        super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsReceived>(_onReceived);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
    on<AllNotificationsMarkedAsRead>(_onAllMarkedAsRead);
    on<NotificationTapped>(_onTapped);
  }

  final NotificationsRepository _notificationsRepository;
  StreamSubscription<List<Map<String, dynamic>>>? _notificationsSub;

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    await _notificationsSub?.cancel();
    _notificationsSub = _notificationsRepository
        .watchNotifications(event.userId)
        .listen(
      (notificationsData) {
        final notifications = notificationsData
            .map((data) => NotificationItem.fromFirestore(data))
            .toList();
        add(NotificationsReceived(notifications));
      },
      onError: (error) {
        emit(state.copyWith(
          status: NotificationsStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  void _onReceived(
    NotificationsReceived event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      status: NotificationsStatus.loaded,
      notifications: event.notifications,
    ));
  }

  Future<void> _onMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic update
    final updated = state.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updated));

    // Persist to Firestore
    await _notificationsRepository.markAsRead(
      event.userId,
      event.notificationId,
    );
  }

  Future<void> _onAllMarkedAsRead(
    AllNotificationsMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    // Optimistic update
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updated));

    // Persist to Firestore
    await _notificationsRepository.markAllAsRead(event.userId);
  }

  void _onTapped(
    NotificationTapped event,
    Emitter<NotificationsState> emit,
  ) {
    // Navigation is handled at the app layer via BlocListener
    // This event is primarily for tracking/analytics
  }

  @override
  Future<void> close() async {
    await _notificationsSub?.cancel();
    return super.close();
  }
}
