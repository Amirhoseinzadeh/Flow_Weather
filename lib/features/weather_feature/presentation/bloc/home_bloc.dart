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
  bool _permissionDeniedForever = false; // متغیر برای جلوگیری از درخواست هنگام ورود

  HomeBloc(this.getCurrentWeatherUseCase, this.getForecastWeatherUseCase, this.getAirQualityUseCase)
      : super(HomeState(cwStatus: CwLoading(), fwStatus: FwLoading(), aqStatus: AirQualityLoading(), isLocationLoading: false)) {
    print('HomeBloc initialized with WeatherService: $weatherService');

    // Event handler for loading current weather
    on<LoadCwEvent>((event, emit) async {
      emit(state.copyWith(newCwStatus: CwLoading()));
      try {
        DataState dataState;
        if (event.lat != null && event.lon != null) {
          dataState = await getCurrentWeatherUseCase({
            'cityName': event.cityName,
            'lat': event.lat!,
            'lon': event.lon!,
          });
        } else {
          dataState = await getCurrentWeatherUseCase({
            'cityName': event.cityName,
          });
        }
        if (dataState is DataSuccess) {
          final meteoCurrentWeatherModel = dataState.data;
          final elevation = meteoCurrentWeatherModel.elevation;
          print('Elevation in HomeBloc before emitting: $elevation');
          emit(state.copyWith(newCwStatus: CwCompleted(meteoCurrentWeatherModel)));
        } else {
          emit(state.copyWith(newCwStatus: CwError(dataState.error)));
        }
      } catch (e) {
        print('Error loading current weather: $e');
        emit(state.copyWith(newCwStatus: CwError(e.toString())));
      }
    });

    // Event handler for loading forecast weather
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

    // Event handler for loading air quality
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

    // Event handler for setting location loading state
    on<SetLocationLoading>((event, emit) {
      emit(state.copyWith(isLocationLoading: event.isLoading));
    });
  }

  Future<void> getCurrentLocation(BuildContext context, {bool forceRequest = false}) async {
    add(const SetLocationLoading(true));
    try {
      // 1. Check if location service is enabled
      print('چک کردن سرویس موقعیت‌یابی...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('سرویس موقعیت‌یابی غیرفعال است');
        throw Exception('سرویس موقعیت‌یابی غیرفعال است. لطفاً GPS را فعال کنید.');
      }

      // 2. Check and request location permission
      print('چک کردن مجوز موقعیت‌یابی...');
      LocationPermission permission = await Geolocator.checkPermission();

      // اگر forceRequest فعال باشد (دراور)
      if (forceRequest) {
        print('forceRequest فعال است، درخواست مجوز جدید...');
        // همیشه درخواست مجوز جدید بده، حتی اگر denied یا deniedForever باشد
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('کاربر مجوز موقعیت‌یابی را رد کرد');
          throw Exception("شهر مدنظر را سرچ کنید");
        } else if (permission == LocationPermission.deniedForever) {
          print('مجوز موقعیت‌یابی به‌طور دائم رد شده است');
          // کاربر را به تنظیمات هدایت می‌کنیم
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'مجوز موقعیت‌یابی به‌طور دائم رد شده است و نمی‌توان دوباره درخواست داد. لطفاً از تنظیمات مجوز را فعال کنید.'),
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
        // اگر forceRequest غیرفعال باشد (ورود به برنامه)
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

      // 3. Get current position
      print('در حال گرفتن موقعیت فعلی...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('گرفتن موقعیت مکانی بیش از حد طول کشید');
      });
      print('موقعیت دریافت شد: lat=${position.latitude}, lon=${position.longitude}');

      // 4. Get city name
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

      // 5. Load weather data
      print('در حال بارگذاری داده‌های آب‌وهوا برای $cityName...');
      final params = ForecastParams(position.latitude, position.longitude);
      add(LoadCwEvent(cityName, lat: position.latitude, lon: position.longitude));
      add(LoadFwEvent(params));
      add(LoadAirQualityEvent(params));

      print('موقعیت فعلی: $cityName, lat=${position.latitude}, lon=${position.longitude}');
    } catch (e, stackTrace) {
      print('خطا در گرفتن موقعیت مکانی: $e');
      print('StackTrace: $stackTrace');
      // Load default Tehran data on error
      final params = ForecastParams(35.6892, 51.3890);
      add(LoadCwEvent("تهران"));
      add(LoadFwEvent(params));
      add(LoadAirQualityEvent(params));
      // نمایش پیام خطا به کاربر
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      // غیرفعال کردن حالت لودینگ
      add(const SetLocationLoading(false));
    }
  }
}