
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/user_repository.dart';

part 'my_properties_event.dart';
part 'my_properties_state.dart';

class MyPropertiesBloc extends Bloc<MyPropertiesEvent, MyPropertiesState> {
  final PropertyRepository propertyRepository;
  final UserRepository userRepository;

  MyPropertiesBloc({required this.propertyRepository, required this.userRepository}) : super(MyPropertiesInitial()) {
    on<FetchMyProperties>((event, emit) async {
      emit(MyPropertiesLoading());
      try {
        final organizationId = await userRepository.getOrganizationId();
        if (organizationId != null) {
          final properties = await propertyRepository.getMyProperties(organizationId);
          emit(MyPropertiesLoaded(properties: properties));
        } else {
          emit(const MyPropertiesError(error: 'Organization ID not found'));
        }
      } catch (error) {
        emit(MyPropertiesError(error: error.toString()));
      }
    });
  }
}
