
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
  final String userId;    // Added

  const AuthenticationAuthenticated({required this.isVerified, required this.firstName, required this.lastName, required this.userId}); // Modified constructor

  @override
  List<Object> get props => [isVerified, firstName, lastName, userId]; // Modified props
}

class AuthenticationUnauthenticated extends AuthenticationState {}
