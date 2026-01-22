import 'package:august_chat/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Bloc that handles the login form submission and authentication.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  /// Creates a [LoginBloc] with the required [AuthRepository].
  LoginBloc({
    required AuthRepository authRepo,
  }) : _authRepo = authRepo,
    super(const LoginState()) {

    on<LoginSubmitEvent>(_onSubmit);
  }

  final AuthRepository _authRepo;

  Future<void> _onSubmit(
    LoginSubmitEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        status: LoginStatus.submitting,
      ),
    );

    try {
            
      await _authRepo.signInWithEmail(
        email: event.email, 
        password: event.password
      );

      emit(
        state.copyWith(
          status: LoginStatus.success,
        )
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e.message ?? e.code
        ),
      );

    } catch(e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
