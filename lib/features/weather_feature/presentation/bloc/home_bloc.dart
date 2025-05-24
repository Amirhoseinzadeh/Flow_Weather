import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/aq_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/forecast_params.dart';
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

  HomeBloc(this.getCurrentWeatherUseCase, this.getForecastWeatherUseCase, this.getAirQualityUseCase)
      : super(HomeState(
    cwStatus: CwLoading(),
    fwStatus: FwLoading(),
    aqStatus: AirQualityLoading(),
    isLocationLoading: false,
    isCityLoading: false,
    errorMessage: null,
    isDetailsExpanded: false,
  )) {
    on<LoadCwEvent>(_onLoadCwEvent);
    on<LoadFwEvent>(_onLoadFwEvent);
    on<LoadAirQualityEvent>(_onLoadAirQualityEvent);
    on<SetLocationLoading>(_onSetLocationLoading);
    on<SetCityLoading>(_onSetCityLoading);
    on<ClearErrorMessage>(_onClearErrorMessage);
    on<SetErrorMessage>(_onSetErrorMessage);
    on<ToggleDetailsExpansion>(_onToggleDetailsExpansion);
  }

  void _onToggleDetailsExpansion(ToggleDetailsExpansion event, Emitter<HomeState> emit) {
    emit(state.copyWith(isDetailsExpanded: event.isExpanded));
  }

  Future<void> _onLoadCwEvent(LoadCwEvent event, Emitter<HomeState> emit) async {
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
        emit(state.copyWith(newCwStatus: CwCompleted(meteoCurrentWeatherModel), isCityLoading: false));
      } else {
        emit(state.copyWith(newCwStatus: CwError(dataState.error!), isCityLoading: false, errorMessage: dataState.error));
      }
    } catch (e) {
      emit(state.copyWith(newCwStatus: CwError(e.toString()), isCityLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadFwEvent(LoadFwEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newFwStatus: FwLoading()));
    try {
      DataState dataState = await getForecastWeatherUseCase(event.forecastParams);
      if (dataState is DataSuccess) {
        emit(state.copyWith(newFwStatus: FwCompleted(dataState.data)));
      } else {
        emit(state.copyWith(newFwStatus: FwError(dataState.error!), errorMessage: dataState.error));
      }
    } catch (e) {
      emit(state.copyWith(newFwStatus: FwError(e.toString()), errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadAirQualityEvent(LoadAirQualityEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newAirQualityStatus: AirQualityLoading()));
    try {
      DataState dataState = await getAirQualityUseCase(event.forecastParams);
      if (dataState is DataSuccess) {
        final airQuality = dataState.data;
        final aqiResult = airQuality.calculateAqi();
        emit(state.copyWith(
          newAirQualityStatus: AirQualityCompleted(
            airQualityEntity: airQuality,
            aqi: aqiResult['aqi'],
            category: aqiResult['category'],
            dominantPollutant: aqiResult['dominantPollutant'],
          ),
        ));
      } else {
        emit(state.copyWith(newAirQualityStatus: AirQualityError(dataState.error!), errorMessage: dataState.error));
      }
    } catch (e) {
      emit(state.copyWith(newAirQualityStatus: AirQualityError(e.toString()), errorMessage: e.toString()));
    }
  }

  void _onSetLocationLoading(SetLocationLoading event, Emitter<HomeState> emit) {
    emit(state.copyWith(isLocationLoading: event.isLoading));
  }

  void _onSetCityLoading(SetCityLoading event, Emitter<HomeState> emit) {
    emit(state.copyWith(isCityLoading: event.isLoading));
  }

  void _onClearErrorMessage(ClearErrorMessage event, Emitter<HomeState> emit) {
    emit(state.copyWith(errorMessage: null));
  }

  void _onSetErrorMessage(SetErrorMessage event, Emitter<HomeState> emit) {
    emit(state.copyWith(errorMessage: event.errorMessage));
  }

  Future<void> getCurrentLocation() async {
    add(const SetLocationLoading(true));
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'سرویس موقعیت‌یابی غیرفعال است. لطفاً لوکیشن را فعال کنید.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'مجوز موقعیت‌یابی رد شده است. لطفاً شهر را سرچ کنید.';
        } else if (permission == LocationPermission.deniedForever) {
          throw 'مجوز موقعیت‌یابی به‌طور دائم رد شده است. لطفاً از تنظیمات مجوز را فعال کنید.';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw 'عملیات موقعیت کنونی ناموفق بود. لطفاً شهر خود را سرچ کنید.';
      });

      String cityName;
      try {
        final cityItem = await locator<ApiProvider>().getCityByCoordinates(position.latitude, position.longitude);
        cityName = cityItem?.title ?? 'موقعیت نامشخص';
      } catch (e) {
        cityName = 'موقعیت نامشخص';
        throw 'خطا در دریافت نام شهر: $e';
      }

      final params = ForecastParams(position.latitude, position.longitude);
      add(LoadCwEvent(cityName, lat: position.latitude, lon: position.longitude));
      add(LoadFwEvent(params));
      add(LoadAirQualityEvent(params));
    } catch (e) {
      add(SetErrorMessage(e.toString()));
      loadDefaultCity();
    } finally {
      add(const SetLocationLoading(false));
    }
  }

  void loadDefaultCity() {
    final params = ForecastParams(35.6892, 51.3890);
    add(LoadCwEvent("تهران"));
    add(LoadFwEvent(params));
    add(LoadAirQualityEvent(params));
  }
}