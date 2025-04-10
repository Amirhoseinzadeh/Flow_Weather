import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CwStatus extends Equatable{}

/// loading state
class CwLoading extends CwStatus{

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

/// loaded state
class CwCompleted extends CwStatus{
  final CurrentCityEntity currentCityEntity;
  CwCompleted(this.currentCityEntity);

  @override
  // TODO: implement props
  List<Object?> get props => [
    currentCityEntity,
  ];
}

/// error state
class CwError extends CwStatus{
  final String? message;
  CwError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [
    message
  ];
}
