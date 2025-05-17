import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/aq_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/services/weather_service.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_air_quality_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_current_weather_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:flow_weather/locator.dart';
import 'package:geolocator/geolocator.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetForecastWeatherUseCase getForecastWeatherUseCase;
  final GetAirQualityUseCase getAirQualityUseCase;
  final WeatherService weatherService = locator<WeatherService>();
  bool _permissionDeniedForever = false;

  HomeBloc(this.getCurrentWeatherUseCase, this.getForecastWeatherUseCase, this.getAirQualityUseCase)
      : super( HomeState(cwStatus: CwLoading(), fwStatus: FwLoading(), aqStatus: AirQualityLoading(), isLocationLoading: false, isCityLoading: false)) {
    print('HomeBloc initialized with WeatherService: $weatherService');

    on<LoadCwEvent>((event, emit) async {
      emit(state.copyWith(newCwStatus: CwLoading(), isCityLoading: true));
      try {
        DataState dataState;
        if (event.lat != null && event.lon != null) {
          dataState = await getCurrentWeatherUseCase({
            'cityName': event.cityName,
            'lat': event.lat!,
            'lon': event.lon!,
          });
        } else {
          dataState = await getCurrentWeatherUseCase({'cityName': event.cityName});
        }
        if (dataState is DataSuccess) {
          final meteoCurrentWeatherModel = dataState.data;
          final elevation = meteoCurrentWeatherModel.elevation ?? 0;
          print('Elevation in HomeBloc before emitting: $elevation');
          emit(state.copyWith(newCwStatus: CwCompleted(meteoCurrentWeatherModel), isCityLoading: false));
        } else {
          emit(state.copyWith(newCwStatus: CwError(dataState.error), isCityLoading: false));
        }
      } catch (e) {
        print('Error loading current weather: $e');
        emit(state.copyWith(newCwStatus: CwError(e.toString()), isCityLoading: false));
      }
    });

    on<LoadFwEvent>((event, emit) async {
      emit(state.copyWith(newFwStatus: FwLoading()));
      try {
        DataState dataState = await getForecastWeatherUseCase(event.forecastParams);
        if (dataState is DataSuccess) {
          emit(state.copyWith(newFwStatus: FwCompleted(dataState.data)));
        } else {
          emit(state.copyWith(newFwStatus: FwError(dataState.error)));
        }
      } catch (e) {
        print('Error loading forecast: $e');
        emit(state.copyWith(newFwStatus: FwError(e.toString())));
      }
    });

    on<LoadAirQualityEvent>((event, emit) async {
      emit(state.copyWith(newAirQualityStatus: AirQualityLoading()));
      try {
        print('درخواست کیفیت هوا برای مختصات: lat=${event.forecastParams.lat}, lon=${event.forecastParams.lon}');
        DataState dataState = await getAirQualityUseCase(event.forecastParams);
        if (dataState is DataSuccess) {
          final airQuality = dataState.data;
          final aqiResult = airQuality.calculateAqi();
          print('AQI محاسبه‌شده: ${aqiResult['aqi']}, دسته‌بندی: ${aqiResult['category']}, آلاینده غالب: ${aqiResult['dominantPollutant']}');
          emit(state.copyWith(
            newAirQualityStatus: AirQualityCompleted(
              airQualityEntity: airQuality,
              aqi: aqiResult['aqi'],
              category: aqiResult['category'],
              dominantPollutant: aqiResult['dominantPollutant'],
            ),
          ));
        } else {
          print('Air quality loading failed: ${dataState.error}');
          emit(state.copyWith(newAirQualityStatus: AirQualityError(dataState.error)));
        }
      } catch (e) {
        print('Error loading air quality: $e');
        emit(state.copyWith(newAirQualityStatus: AirQualityError(e.toString())));
      }
    });

    on<SetLocationLoading>((event, emit) {
      emit(state.copyWith(isLocationLoading: event.isLoading));
    });

    on<SetCityLoading>((event, emit) {
      emit(state.copyWith(isCityLoading: event.isLoading));
    });
  }

  Future<void> getCurrentLocation(BuildContext context, {bool forceRequest = false}) async {
    add(const SetLocationLoading(true));
    try {
      print('چک کردن سرویس موقعیت‌یابی...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('سرویس موقعیت‌یابی غیرفعال است');
        throw Exception('سرویس موقعیت‌یابی غیرفعال است. لطفاً GPS را فعال کنید.');
      }

      print('چک کردن مجوز موقعیت‌یابی...');
      LocationPermission permission = await Geolocator.checkPermission();

      if (forceRequest) {
        print('forceRequest فعال است، درخواست مجوز جدید...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('کاربر مجوز موقعیت‌یابی را رد کرد');
          throw Exception("شهر مدنظر را سرچ کنید");
        } else if (permission == LocationPermission.deniedForever) {
          print('مجوز موقعیت‌یابی به‌طور دائم رد شده است');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('مجوز موقعیت‌یابی به‌طور دائم رد شده است و نمی‌توان دوباره درخواست داد. لطفاً از تنظیمات مجوز را فعال کنید.'),
              action: SnackBarAction(
                label: 'تنظیمات',
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
              ),
            ),
          );
          throw Exception("شهر مدنظر را سرچ کنید");
        }
      } else {
        if (_permissionDeniedForever) {
          print('مجوز موقعیت‌یابی قبلاً رد شده و forceRequest غیرفعال است.');
          throw Exception("شهر مدنظر را سرچ کنید");
        }

        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('کاربر مجوز موقعیت‌یابی را رد کرد');
            _permissionDeniedForever = true;
            throw Exception("شهر مدنظر را سرچ کنید");
          } else if (permission == LocationPermission.deniedForever) {
            print('مجوز موقعیت‌یابی به‌طور دائم رد شده است');
            _permissionDeniedForever = true;
            throw Exception('مجوز موقعیت‌یابی به‌طور دائم رد شده است. لطفاً از تنظیمات مجوز را فعال کنید.');
          }
        }
      }

      print('در حال گرفتن موقعیت فعلی...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        print('Timeout occurred while getting location');
        throw TimeoutException('گرفتن موقعیت مکانی بیش از حد طول کشید');
      });
      print('موقعیت دریافت شد: lat=${position.latitude}, lon=${position.longitude}');

      print('در حال دریافت نام شهر...');
      String cityName;
      try {
        final cityItem = await locator<ApiProvider>().getCityByCoordinates(position.latitude, position.longitude);
        cityName = cityItem?.title ?? 'موقعیت نامشخص';
        print('نام شهر دریافت شد: $cityName');
      } catch (e) {
        print('خطا در دریافت نام شهر: $e');
        cityName = 'موقعیت نامشخص';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در دریافت نام شهر: $e')),
        );
      }

      print('در حال بارگذاری داده‌های آب‌وهوا برای $cityName...');
      final params = ForecastParams(position.latitude, position.longitude);
      add(LoadCwEvent(cityName, lat: position.latitude, lon: position.longitude));
      add(LoadFwEvent(params));
      add(LoadAirQualityEvent(params));

      print('موقعیت فعلی: $cityName, lat=${position.latitude}, lon=${position.longitude}');
    } catch (e, stackTrace) {
      print('خطا در گرفتن موقعیت مکانی: $e');
      print('StackTrace: $stackTrace');
      final params = ForecastParams(35.6892, 51.3890);
      add(LoadCwEvent("تهران"));
      add(LoadFwEvent(params));
      add(LoadAirQualityEvent(params));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      add(const SetLocationLoading(false)); // همیشه لودینگ رو غیرفعال کن
    }
  }
}