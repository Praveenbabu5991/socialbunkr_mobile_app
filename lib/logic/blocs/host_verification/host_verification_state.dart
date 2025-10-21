
part of 'host_verification_bloc.dart';

abstract class HostVerificationState extends Equatable {
  const HostVerificationState();

  @override
  List<Object> get props => [];
}

class HostVerificationInitial extends HostVerificationState {}

class HostVerificationLoading extends HostVerificationState {}

class HostVerificationSuccess extends HostVerificationState {}

class HostVerificationFailure extends HostVerificationState {
  final String error;

  const HostVerificationFailure({required this.error});

  @override
  List<Object> get props => [error];
}
