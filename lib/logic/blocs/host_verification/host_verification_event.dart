
part of 'host_verification_bloc.dart';

abstract class HostVerificationEvent extends Equatable {
  const HostVerificationEvent();

  @override
  List<Object> get props => [];
}

class HostVerificationSubmitted extends HostVerificationEvent {
  final String documentType;
  final XFile document;
  final String userId;

  const HostVerificationSubmitted({required this.documentType, required this.document, required this.userId});

  @override
  List<Object> get props => [documentType, document, userId];
}
