import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';

Future<void> loadCityWeather(BuildContext context, String cityName, {double? lat, double? lon}) async {
  // فعال کردن حالت لودینگ برای شهر
  context.read<HomeBloc>().add(const SetCityLoading(true));

  // فراخوانی رویدادهای لازم برای لود کردن داده‌های شهر
  final params = lat != null && lon != null ? ForecastParams(lat, lon) : null;
  context.read<HomeBloc>().add(LoadCwEvent(cityName, lat: lat, lon: lon));
  if (params != null) {
    context.read<HomeBloc>().add(LoadFwEvent(params));
    context.read<HomeBloc>().add(LoadAirQualityEvent(params));
  }

  // نیازی به SetCityLoading(false) نیست، چون توی LoadCwEvent مدیریت می‌شه
}