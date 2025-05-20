import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';

abstract class GetCityStatus extends Equatable {
  const GetCityStatus();

  @override
  List<Object?> get props => [];
}

class GetCityLoading extends GetCityStatus {
  const GetCityLoading();
}

class GetCityCompleted extends GetCityStatus {
  final City? city;

  const GetCityCompleted(this.city);

  @override
  List<Object?> get props => [city];
}

class GetCityError extends GetCityStatus {
  final String error;

  const GetCityError(this.error);

  @override
  List<Object?> get props => [error];
}