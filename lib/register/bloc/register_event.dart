part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class RegisterSubmitEvent extends RegisterEvent {
  const RegisterSubmitEvent(this.email, this.password, this.displayName);

  final String email;
  final String password;
  final String displayName;
  
  @override  
  List<Object> get props => [email, password, displayName];
}
