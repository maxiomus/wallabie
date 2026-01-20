part of 'rooms_bloc.dart';

sealed class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

final class RoomsStartEvent extends RoomsEvent {
  const RoomsStartEvent();

  @override
  List<Object> get props => [];
}
