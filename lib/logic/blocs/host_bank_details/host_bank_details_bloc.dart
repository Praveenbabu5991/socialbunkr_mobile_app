import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/user_repository.dart';

part 'host_bank_details_event.dart';
part 'host_bank_details_state.dart';

class HostBankDetailsBloc extends Bloc<HostBankDetailsEvent, HostBankDetailsState> {
  final UserRepository userRepository;

  HostBankDetailsBloc({required this.userRepository}) : super(HostBankDetailsInitial()) {
    on<SaveBankDetailsButtonPressed>((event, emit) async {
      emit(HostBankDetailsLoading());
      try {
        // This method doesn't exist yet, I will add it.
        await userRepository.saveBankDetails(
          accountNumber: event.accountNumber,
          ifscCode: event.ifscCode,
        );
        emit(HostBankDetailsSuccess());
      } catch (e) {
        emit(HostBankDetailsFailure(error: e.toString()));
      }
    });
  }
}
