
part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final bool isVerified;
  final String firstName; // Added
  final String lastName;  // Added

  const AuthenticationAuthenticated({required this.isVerified, required this.firstName, required this.lastName}); // Modified constructor

  @override
  List<Object> get props => [isVerified, firstName, lastName]; // Modified props
}

class AuthenticationUnauthenticated extends AuthenticationState {}
