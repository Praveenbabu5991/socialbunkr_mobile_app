
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/property_repository.dart';

part 'add_property_event.dart';
part 'add_property_state.dart';

class AddPropertyBloc extends Bloc<AddPropertyEvent, AddPropertyState> {
  final PropertyRepository propertyRepository;

  AddPropertyBloc({required this.propertyRepository}) : super(AddPropertyInitial()) {
    on<AddPropertyButtonPressed>((event, emit) async {
      emit(AddPropertyLoading());
      try {
        await propertyRepository.addProperty(event.propertyData);
        emit(AddPropertySuccess());
      } catch (error) {
        emit(AddPropertyFailure(error: error.toString()));
      }
    });
  }
}
