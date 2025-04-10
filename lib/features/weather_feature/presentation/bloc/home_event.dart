part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class LoadCwEvent extends HomeEvent {
  final String cityName;
  LoadCwEvent(this.cityName);
}

class LoadFwEvent extends HomeEvent {
  final ForecastParams forecastParams;
  LoadFwEvent(this.forecastParams);
}