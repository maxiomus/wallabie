part of 'register_bloc.dart';

/// Status of the registration process.
enum RegisterStatus {
  /// Initial state, no action taken.
  idle,

  /// Registration request is in progress.
  submitting,

  /// Registration completed successfully.
  success,

  /// Registration failed with an error.
  failure,
}

/// State of the registration form and submission process.
class RegisterState extends Equatable {
  /// Creates a [RegisterState] with optional status and error message.
  const RegisterState({
    this.status = RegisterStatus.idle,
    this.errorMessage,
  });

  /// Current status of the registration process.
  final RegisterStatus status;

  /// Error message if registration failed, null otherwise.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, ?errorMessage];
}
