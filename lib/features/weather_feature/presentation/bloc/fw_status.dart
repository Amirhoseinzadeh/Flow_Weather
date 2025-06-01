import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';

@immutable
abstract class FwStatus extends Equatable {}


class FwLoading extends FwStatus {
  @override
  List<Object?> get props => [];
}

class FwCompleted extends FwStatus {
  final ForecastEntity forecastEntity;

  FwCompleted(this.forecastEntity);

  @override
  List<Object?> get props => [forecastEntity];
}


class FwError extends FwStatus {
  final String? message;

  FwError(this.message);

  @override
  List<Object?> get props => [message];
}
