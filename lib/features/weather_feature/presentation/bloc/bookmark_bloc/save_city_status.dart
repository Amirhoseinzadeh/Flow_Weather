import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';

abstract class SaveCityStatus extends Equatable {}

class SaveCityInitial extends SaveCityStatus {
  @override
  List<Object?> get props => [];
}

class SaveCityLoading extends SaveCityStatus {
  @override
  List<Object?> get props => [];
}

class SaveCityCompleted extends SaveCityStatus {
  final City city;
  SaveCityCompleted(this.city);

  @override
  List<Object?> get props => [city];
}

class SaveCityError extends SaveCityStatus {
  final String? message;
  SaveCityError(this.message);

  @override
  List<Object?> get props => [message];
}