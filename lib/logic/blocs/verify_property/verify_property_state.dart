
part of 'verify_property_bloc.dart';

abstract class VerifyPropertyState extends Equatable {
  const VerifyPropertyState();

  @override
  List<Object> get props => [];
}

class VerifyPropertyInitial extends VerifyPropertyState {}

class VerifyPropertyLoading extends VerifyPropertyState {}

class VerifyPropertySuccess extends VerifyPropertyState {}

class VerifyPropertyFailure extends VerifyPropertyState {
  final String error;

  const VerifyPropertyFailure({required this.error});

  @override
  List<Object> get props => [error];
}
