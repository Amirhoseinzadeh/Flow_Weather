import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';


class GetCurrentWeatherUseCase implements UseCase<DataState<CurrentCityEntity>, String>{
  final WeatherRepository _weatherRepository;
  GetCurrentWeatherUseCase(this._weatherRepository);

  @override
  Future<DataState<CurrentCityEntity>> call(String params) {
    return _weatherRepository.fetchCurrentWeatherData(params);
  }

}