import 'package:equatable/equatable.dart';

abstract class DeleteCityStatus extends Equatable {}

class DeleteCityInitial extends DeleteCityStatus {
  @override
  List<Object?> get props => [];
}

class DeleteCityLoading extends DeleteCityStatus {
  @override
  List<Object?> get props => [];
}

class DeleteCityCompleted extends DeleteCityStatus {
  final String name;
  DeleteCityCompleted(this.name);

  @override
  List<Object?> get props => [name];
}

class DeleteCityError extends DeleteCityStatus {
  final String? message;
  DeleteCityError(this.message);

  @override
  List<Object?> get props => [message];
}