import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';

abstract class UpdateCityStatus extends Equatable {}

class UpdateCityInitial extends UpdateCityStatus {
  @override
  List<Object?> get props => [];
}

class UpdateCityLoading extends UpdateCityStatus {
  @override
  List<Object?> get props => [];
}

class UpdateCityCompleted extends UpdateCityStatus {
  final City city;
  UpdateCityCompleted(this.city);

  @override
  List<Object?> get props => [city];
}

class UpdateCityError extends UpdateCityStatus {
  final String? message;
  UpdateCityError(this.message);

  @override
  List<Object?> get props => [message];
}