import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetForecastUseCase implements UseCase<DataState<ForecastEntity>, ForecastParams>{
  final WeatherRepository _weatherRepository;
  GetForecastUseCase(this._weatherRepository);

  @override
  Future<DataState<ForecastEntity>> call(ForecastParams params) {
    return _weatherRepository.fetchForecast(params);
  }

}