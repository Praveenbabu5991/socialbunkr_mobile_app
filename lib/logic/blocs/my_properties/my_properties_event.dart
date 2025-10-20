
part of 'my_properties_bloc.dart';

abstract class MyPropertiesEvent extends Equatable {
  const MyPropertiesEvent();

  @override
  List<Object> get props => [];
}

class FetchMyProperties extends MyPropertiesEvent {}
