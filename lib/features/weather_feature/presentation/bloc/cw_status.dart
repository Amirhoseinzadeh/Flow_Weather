import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CwStatus extends Equatable{}

class CwLoading extends CwStatus{

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CwCompleted extends CwStatus{
  final MeteoCurrentWeatherEntity meteoCurrentWeatherEntity;
  CwCompleted(this.meteoCurrentWeatherEntity);

  @override
  // TODO: implement props
  List<Object?> get props => [
    meteoCurrentWeatherEntity,
  ];
}


class CwError extends CwStatus{
  final String? message;
  CwError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [
    message
  ];
}
