
part of 'my_properties_bloc.dart';

abstract class MyPropertiesState extends Equatable {
  const MyPropertiesState();

  @override
  List<Object> get props => [];
}

class MyPropertiesInitial extends MyPropertiesState {}

class MyPropertiesLoading extends MyPropertiesState {}

class MyPropertiesLoaded extends MyPropertiesState {
  final List<dynamic> properties;

  const MyPropertiesLoaded({required this.properties});

  @override
  List<Object> get props => [properties];
}

class MyPropertiesError extends MyPropertiesState {
  final String error;

  const MyPropertiesError({required this.error});

  @override
  List<Object> get props => [error];
}
