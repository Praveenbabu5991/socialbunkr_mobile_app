
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/user_repository.dart';
import '../authentication/authentication_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({required this.userRepository, required this.authenticationBloc}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final userData = await userRepository.login(event.email, event.password);
        authenticationBloc.add(LoggedIn(token: userData['token']));
        emit(LoginSuccess(userData: userData));
      } catch (error) {
        emit(LoginFailure(error: error.toString()));
      }
    });
  }
}
