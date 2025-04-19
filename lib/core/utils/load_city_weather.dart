import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';

Future<void> loadCityWeather(BuildContext context, String cityName) async {
  try {
    context.read<HomeBloc>().add(LoadCwEvent(cityName));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری آب‌وهوا: $e')));
  }
}