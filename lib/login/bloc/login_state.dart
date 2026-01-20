part of 'login_bloc.dart';

enum LoginStatus { idle, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.idle, this.errorMessage});

  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({LoginStatus? status, String? errorMessage}) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

