import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetCurrentWeatherUseCase implements UseCase<DataState<MeteoCurrentWeatherEntity>, String> {
  final WeatherRepository _weatherRepository;
  GetCurrentWeatherUseCase(this._weatherRepository);

  @override
  Future<DataState<MeteoCurrentWeatherEntity>> call(String params) {
    return _weatherRepository.fetchCurrentWeatherData(params);
  }
}