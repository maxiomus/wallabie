part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginSubmitEvent extends LoginEvent {
  const LoginSubmitEvent(this.email, this.password);

  final String email;
  final String password;  
  
  @override  
  List<Object> get props => [email, password];
}
