part of 'host_bank_details_bloc.dart';

abstract class HostBankDetailsState extends Equatable {
  const HostBankDetailsState();

  @override
  List<Object> get props => [];
}

class HostBankDetailsInitial extends HostBankDetailsState {}

class HostBankDetailsLoading extends HostBankDetailsState {}

class HostBankDetailsSuccess extends HostBankDetailsState {}

class HostBankDetailsFailure extends HostBankDetailsState {
  final String error;

  const HostBankDetailsFailure({required this.error});

  @override
  List<Object> get props => [error];
}
