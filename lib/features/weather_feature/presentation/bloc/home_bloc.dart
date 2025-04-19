import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/services/weather_service.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_current_weather_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flow_weather/locator.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetForecastWeatherUseCase getForecastWeatherUseCase;
  final WeatherService weatherService = locator<WeatherService>();

  HomeBloc(this.getCurrentWeatherUseCase, this.getForecastWeatherUseCase)
      : super(HomeState(cwStatus: CwLoading(), fwStatus: FwLoading())) {
    print('HomeBloc initialized with WeatherService: $weatherService');
    on<LoadCwEvent>((event, emit) async {
      emit(state.copyWith(newCwStatus: CwLoading()));
      try {
        DataState dataState = await getCurrentWeatherUseCase(event.cityName);
        if (dataState is DataSuccess) {
          emit(state.copyWith(newCwStatus: CwCompleted(dataState.data)));
        } else {
          emit(state.copyWith(newCwStatus: CwError(dataState.error)));
        }
      } catch (e) {
        emit(state.copyWith(newCwStatus: CwError(e.toString())));
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
        emit(state.copyWith(newFwStatus: FwError(e.toString())));
      }
    });
  }
}