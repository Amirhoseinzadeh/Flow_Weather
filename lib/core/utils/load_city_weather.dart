import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';

Future<void> loadCityWeather(BuildContext context, String cityName) async {
  try {
    // ارسال ایونت برای بارگذاری آب‌وهوای فعلی
    context.read<HomeBloc>().add(LoadCwEvent(cityName));

    // صبر کردن تا آب‌وهوای فعلی بارگذاری بشه
    await for (var state in context.read<HomeBloc>().stream) {
      if (state.cwStatus is CwCompleted) {
        final city = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity;
        final lat = city.coord?.lat;
        final lon = city.coord?.lon;
        print('مختصات شهر $cityName: lat=$lat, lon=$lon');
        if (lat != null && lon != null) {
          final params = ForecastParams(lat, lon);
          context.read<HomeBloc>().add(LoadFwEvent(params));
          context.read<HomeBloc>().add(LoadAirQualityEvent(params));
        } else {
          print('مختصات شهر $cityName پیدا نشد');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('مختصات شهر پیدا نشد')),
          );
        }
        break; // بعد از بارگذاری موفق، از حلقه خارج شو
      } else if (state.cwStatus is CwError) {
        print('خطا در بارگذاری آب‌وهوای شهر $cityName: ${(state.cwStatus as CwError).message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری آب‌وهوا: ${(state.cwStatus as CwError).message}')),
        );
        break;
      }
    }
  } catch (e) {
    print('خطا در loadCityWeather: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطا در بارگذاری آب‌وهوا: $e')),
    );
  }
}