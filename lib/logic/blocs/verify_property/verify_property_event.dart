
part of 'verify_property_bloc.dart';

abstract class VerifyPropertyEvent extends Equatable {
  const VerifyPropertyEvent();

  @override
  List<Object> get props => [];
}

class VerifyPropertyButtonPressed extends VerifyPropertyEvent {
  final String propertyId;
  final String documentType;
  final XFile document;

  const VerifyPropertyButtonPressed({
    required this.propertyId,
    required this.documentType,
    required this.document,
  });

  @override
  List<Object> get props => [propertyId, documentType, document];
}
