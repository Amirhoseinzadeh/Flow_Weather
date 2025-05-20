import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';

Future<void> loadCityWeather(BuildContext context, String cityName, {double? lat, double? lon}) async {
  context.read<HomeBloc>().add(const SetCityLoading(true));
  final params = lat != null && lon != null ? ForecastParams(lat, lon) : null;
  try {
    context.read<HomeBloc>().add(LoadCwEvent(cityName, lat: lat, lon: lon));
    if (params != null) {
      context.read<HomeBloc>().add(LoadFwEvent(params));
      context.read<HomeBloc>().add(LoadAirQualityEvent(params));
    }
  } catch (e) {
    context.read<HomeBloc>().add(SetErrorMessage(e.toString()));
    rethrow;
  } finally {
    context.read<HomeBloc>().add(const SetCityLoading(false)); // اطمینان از غیرفعال شدن لودینگ
  }
}