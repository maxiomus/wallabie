part of 'login_bloc.dart';

/// Status of the login process.
enum LoginStatus {
  /// Initial state, no action taken.
  idle,

  /// Login request is in progress.
  submitting,

  /// Login completed successfully.
  success,

  /// Login failed with an error.
  failure,
}

/// State of the login form and submission process.
class LoginState extends Equatable {
  /// Creates a [LoginState] with optional status and error message.
  const LoginState({this.status = LoginStatus.idle, this.errorMessage});

  /// Current status of the login process.
  final LoginStatus status;

  /// Error message if login failed, null otherwise.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  LoginState copyWith({LoginStatus? status, String? errorMessage}) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

