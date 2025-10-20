
part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final bool isVerified;

  const AuthenticationAuthenticated({required this.isVerified});

  @override
  List<Object> get props => [isVerified];
}

class AuthenticationUnauthenticated extends AuthenticationState {}
