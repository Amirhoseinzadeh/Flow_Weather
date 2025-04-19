import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetSuggestionCityUseCase implements UseCase<List<NeshanCityItem>, String> {
  final WeatherRepository _weatherRepository;
  GetSuggestionCityUseCase(this._weatherRepository);

  @override
  Future<List<NeshanCityItem>> call(String params) {
    return _weatherRepository.fetchSuggestData(params);
  }
}