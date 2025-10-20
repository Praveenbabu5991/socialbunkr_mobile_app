
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/property_repository.dart';

part 'verify_property_event.dart';
part 'verify_property_state.dart';

class VerifyPropertyBloc extends Bloc<VerifyPropertyEvent, VerifyPropertyState> {
  final PropertyRepository propertyRepository;

  VerifyPropertyBloc({required this.propertyRepository}) : super(VerifyPropertyInitial()) {
    on<VerifyPropertyButtonPressed>((event, emit) async {
      emit(VerifyPropertyLoading());
      try {
        await propertyRepository.verifyProperty(event.propertyId, event.documentType, event.document);
        emit(VerifyPropertySuccess());
      } catch (error) {
        emit(VerifyPropertyFailure(error: error.toString()));
      }
    });
  }
}
