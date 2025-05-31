import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> loadCityWeather(BuildContext context, String cityName, {double? lat, double? lon}) async {
  if (lat == null || lon == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مختصات شهر در دسترس نیست')),
    );
    context.read<HomeBloc>().add(const SetCityLoading(false));
    return;
  }
  final homeBloc = context.read<HomeBloc>();
  homeBloc.add(LoadCwEvent(cityName, lat: lat, lon: lon, skipNeshanLookup: true));
}