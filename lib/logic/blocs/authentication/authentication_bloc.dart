
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({required this.userRepository}) : super(AuthenticationInitial()) {
    on<AppStarted>((event, emit) async {
      final bool hasToken = await userRepository.hasToken();
      if (hasToken) {
        final bool isVerified = await userRepository.isOrganizationVerified();
        emit(AuthenticationAuthenticated(isVerified: isVerified));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    });

    on<LoggedIn>((event, emit) async {
      await userRepository.persistToken(event.token);
      final bool isVerified = await userRepository.isOrganizationVerified();
      emit(AuthenticationAuthenticated(isVerified: isVerified));
    });

    on<LoggedOut>((event, emit) async {
      await userRepository.deleteToken();
      emit(AuthenticationUnauthenticated());
    });
  }
}
