import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

/// Cubit that manages the selected tab on the home screen.
class HomeCubit extends Cubit<HomeState> {
  /// Creates a [HomeCubit] with rooms tab selected by default.
  HomeCubit() : super(const HomeState());

  /// Changes the selected tab in the bottom navigation.
  void setTab(HomeTab tab) => emit(HomeState(tab: tab));
}
