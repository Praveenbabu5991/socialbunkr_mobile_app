
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
        final String? organizationId = await userRepository.getOrganizationId();
        if (organizationId != null) {
          await userRepository.fetchAndPersistOrganizationVerificationStatus(organizationId);
        }
        final bool isVerified = await userRepository.isOrganizationVerified();
        final String? firstName = await userRepository.getFirstName(); // Get first name
        final String? lastName = await userRepository.getLastName();   // Get last name
        final String? userId = await userRepository.getUserId();       // Get user ID
        emit(AuthenticationAuthenticated(isVerified: isVerified, firstName: firstName ?? '', lastName: lastName ?? '', userId: userId ?? ''));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    });

    on<LoggedIn>((event, emit) async {
      await userRepository.persistToken(event.token);
      final bool isVerified = await userRepository.isOrganizationVerified();
      final String? firstName = await userRepository.getFirstName(); // Get first name
      final String? lastName = await userRepository.getLastName();   // Get last name
      final String? userId = await userRepository.getUserId();       // Get user ID
      emit(AuthenticationAuthenticated(isVerified: isVerified, firstName: firstName ?? '', lastName: lastName ?? '', userId: userId ?? ''));
    });

    on<LoggedOut>((event, emit) async {
      await userRepository.deleteToken();
      emit(AuthenticationUnauthenticated());
    });
  }
}
