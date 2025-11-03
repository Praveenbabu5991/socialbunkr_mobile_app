part of 'host_bank_details_bloc.dart';

abstract class HostBankDetailsEvent extends Equatable {
  const HostBankDetailsEvent();

  @override
  List<Object> get props => [];
}

class SaveBankDetailsButtonPressed extends HostBankDetailsEvent {
  final String accountNumber;
  final String ifscCode;

  const SaveBankDetailsButtonPressed({
    required this.accountNumber,
    required this.ifscCode,
  });

  @override
  List<Object> get props => [accountNumber, ifscCode];
}
