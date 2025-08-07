import 'package:equatable/equatable.dart';
import 'package:flow_weather/core/params/forecast_params.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadCwEvent extends HomeEvent {
  final String cityName;
  final double? lat;
  final double? lon;
  final bool skipNeshanLookup;

  const LoadCwEvent(this.cityName, {this.lat, this.lon, this.skipNeshanLookup = false});

  @override
  List<Object> get props => [cityName, lat ?? 0, lon ?? 0];
}

class LoadFwEvent extends HomeEvent {
  final ForecastParams forecastParams;

  const LoadFwEvent(this.forecastParams);

  @override
  List<Object> get props => [forecastParams];
}

class LoadAirQualityEvent extends HomeEvent {
  final ForecastParams forecastParams;

  const LoadAirQualityEvent(this.forecastParams);

  @override
  List<Object> get props => [forecastParams];
}

class SetLocationLoading extends HomeEvent {
  final bool isLoading;

  const SetLocationLoading(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class SetCityLoading extends HomeEvent {
  final bool isLoading;

  const SetCityLoading(this.isLoading);

  @override
  List<Object> get props => [isLoading];
}

class SetErrorMessage extends HomeEvent {
  final String errorMessage;

  const SetErrorMessage(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ClearErrorMessage extends HomeEvent {
  const ClearErrorMessage();

  @override
  List<Object> get props => [];
}

class SelectHourEvent extends HomeEvent {
  final int hourIndex;

  const SelectHourEvent(this.hourIndex);

  @override
  List<Object> get props => [hourIndex];
}

class SelectDayEvent extends HomeEvent {
  final int dayIndex;

  const SelectDayEvent(this.dayIndex);

  @override
  List<Object> get props => [dayIndex];
}