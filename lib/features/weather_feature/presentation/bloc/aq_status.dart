import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';

abstract class AirQualityStatus extends Equatable {
  const AirQualityStatus();

  @override
  List<Object?> get props => [];
}

class AirQualityInitial extends AirQualityStatus {}

class AirQualityLoading extends AirQualityStatus {}

class AirQualityCompleted extends AirQualityStatus {
  final AirQualityEntity airQualityEntity;
  final int aqi;
  final String category;
  final String dominantPollutant;

  const AirQualityCompleted({
    required this.airQualityEntity,
    required this.aqi,
    required this.category,
    required this.dominantPollutant,
  });

  @override
  List<Object?> get props => [airQualityEntity, aqi, category, dominantPollutant];
}

class AirQualityError extends AirQualityStatus {
  final String? message;

  AirQualityError(this.message);

  @override
  List<Object?> get props => [message];
}