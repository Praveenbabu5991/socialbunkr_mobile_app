
part of 'add_property_bloc.dart';

abstract class AddPropertyEvent extends Equatable {
  const AddPropertyEvent();

  @override
  List<Object> get props => [];
}

class AddPropertyButtonPressed extends AddPropertyEvent {
  final Map<String, dynamic> propertyData;
  final XFile? image;

  const AddPropertyButtonPressed({required this.propertyData, this.image});

  @override
  List<Object> get props => [propertyData];
}
