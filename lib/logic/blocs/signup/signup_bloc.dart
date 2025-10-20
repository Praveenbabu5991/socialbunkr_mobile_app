
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/user_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final UserRepository userRepository;

  SignupBloc({required this.userRepository}) : super(SignupInitial()) {
    on<SignupButtonPressed>((event, emit) async {
      emit(SignupLoading());
      try {
        final userData = await userRepository.signup(event.email, event.password, event.firstName, event.lastName, event.role);
        emit(SignupSuccess(userData: userData));
      } catch (error) {
        emit(SignupFailure(error: error.toString()));
      }
    });
  }
}
