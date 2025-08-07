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
  final ApiProvider apiProvider = locator<ApiProvider>();

  HomeBloc(this.getCurrentWeatherUseCase, this.getForecastWeatherUseCase, this.getAirQualityUseCase)
      : super(HomeState(
    cwStatus: CwLoading(),
    fwStatus: FwLoading(),
    aqStatus: AirQualityLoading(),
    isLocationLoading: false,
    isCityLoading: false,
    errorMessage: null,
  )) {
    on<LoadCwEvent>(_onLoadCwEvent);
    on<LoadFwEvent>(_onLoadFwEvent);
    on<LoadAirQualityEvent>(_onLoadAirQualityEvent);
    on<SetLocationLoading>(_onSetLocationLoading);
    on<SetCityLoading>(_onSetCityLoading);
    on<ClearErrorMessage>(_onClearErrorMessage);
    on<SetErrorMessage>(_onSetErrorMessage);
    on<SelectHourEvent>(_onSelectHourEvent);
    on<SelectDayEvent>(_onSelectDayEvent);
  }

  Future<void> _onLoadCwEvent(LoadCwEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newCwStatus: CwLoading(), isCityLoading: true));
    try {
      DataState dataState;
      String cityName = event.cityName;

      if (event.lat != null && event.lon != null) {
        if (!event.skipNeshanLookup) {
          final cityItem = await apiProvider.getCityByCoordinates(event.lat!, event.lon!);
          cityName = cityItem?.title?.isNotEmpty == true ? cityItem!.title! : event.cityName;
        }
        dataState = await getCurrentWeatherUseCase({
          'cityName': cityName,
          'lat': event.lat!,
          'lon': event.lon!,
        });
      } else {
        dataState = await getCurrentWeatherUseCase({'cityName': cityName});
      }

      if (dataState is DataSuccess) {
        emit(state.copyWith(
          newCwStatus: CwCompleted(dataState.data),
          isCityLoading: false,
          searchCityName: cityName,
        ));
      } else {
        emit(state.copyWith(newCwStatus: CwError(dataState.error!), isCityLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(newCwStatus: CwError(e.toString()), isCityLoading: false));
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

  void _onSelectHourEvent(SelectHourEvent event, Emitter<HomeState> emit) {
    final currentIndex = state.selectedHourIndex;
    if (currentIndex == event.hourIndex) {
      emit(state.copyWith(selectedHourIndex: null, selectedDayIndex: null));
    } else {
      emit(state.copyWith(selectedHourIndex: event.hourIndex, selectedDayIndex: null));
    }
  }

  void _onSelectDayEvent(SelectDayEvent event, Emitter<HomeState> emit) {
    final currentIndex = state.selectedDayIndex;
    if (currentIndex == event.dayIndex) {
      emit(state.copyWith(selectedDayIndex: null, selectedHourIndex: null));
    } else {
      emit(state.copyWith(selectedDayIndex: event.dayIndex, selectedHourIndex: null));
    }
  }

  Future<void> getCurrentLocation() async {
    add(const SetLocationLoading(true));
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'لطفا لوکیشن خود را روشن کنید ';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'شهر مورد نظر را سرچ کنید';
        }
      } else if (permission == LocationPermission.deniedForever) {
        throw 'شهر مورد نظر را سرچ کنید';
      }

      Position position = await Geolocator.getCurrentPosition(
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'شهر مورد نظر را سرچ کنید ';
      });

      String cityName;
      try {
        final cityItem = await apiProvider.getCityByCoordinates(position.latitude, position.longitude);
        cityName = cityItem?.title ?? 'موقعیت نامشخص';
      } catch (e) {
        cityName = 'موقعیت نامشخص';
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
    add(LoadCwEvent("تهران", lat: 35.6892, lon: 51.3890));
    add(LoadFwEvent(params));
    add(LoadAirQualityEvent(params));
  }
}