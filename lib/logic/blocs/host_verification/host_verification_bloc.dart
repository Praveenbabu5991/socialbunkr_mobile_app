
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/host_verification_api_provider.dart';

part 'host_verification_event.dart';
part 'host_verification_state.dart';

class HostVerificationBloc extends Bloc<HostVerificationEvent, HostVerificationState> {
  final HostVerificationApiProvider hostVerificationApiProvider;

  HostVerificationBloc({required this.hostVerificationApiProvider}) : super(HostVerificationInitial()) {
    on<HostVerificationSubmitted>((event, emit) async {
      emit(HostVerificationLoading());
      try {
        await hostVerificationApiProvider.verifyHost(event.documentType, event.document, event.userId);
        emit(HostVerificationSuccess());
      } catch (error) {
        emit(HostVerificationFailure(error: error.toString()));
      }
    });
  }
}
