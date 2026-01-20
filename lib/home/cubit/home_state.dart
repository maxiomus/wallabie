part of 'home_cubit.dart';

enum HomeTab { users, rooms, options }

final class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.rooms,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}