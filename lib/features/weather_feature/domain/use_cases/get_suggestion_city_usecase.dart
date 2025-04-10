
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/weather_feature/data/models/suggest_city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetSuggestionCityUseCase implements UseCase<List<Data>, String>{
  final WeatherRepository _weatherRepository;
  GetSuggestionCityUseCase(this._weatherRepository);

  @override
  Future<List<Data>> call(String params) {
    return _weatherRepository.fetchSuggestData(params);
  }

}