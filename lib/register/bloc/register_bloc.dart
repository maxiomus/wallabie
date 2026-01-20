import 'package:august_chat/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepo,
  }) : _authRepo = authRepo,
    super(const RegisterState()) {    

    on<RegisterSubmitEvent>(_onSubmit);
  }

  final AuthRepository _authRepo;

  Future<void> _onSubmit(
    RegisterSubmitEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RegisterStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      if(event.displayName.trim().isEmpty) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'Display name is required.',
          ),
        );
        return;
      }

      if(event.password.length < 6) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'Password must be at least 6 characters.',
          ),
        );
        return;
      }

      await _authRepo.registerWithEmail(
        email: event.email, 
        password: event.password, 
        displayName: event.displayName
      );

      emit(
        state.copyWith(
          status: RegisterStatus.success,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.message ?? e.code,
        )
      );
    }
    catch(e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        )
      );
    }
  }
}
