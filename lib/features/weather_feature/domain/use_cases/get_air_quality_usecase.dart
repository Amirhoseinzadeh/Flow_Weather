import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/use_case.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetAirQualityUseCase implements UseCase<DataState<AirQualityEntity>, ForecastParams>{
  final WeatherRepository _weatherRepository;

  GetAirQualityUseCase(this._weatherRepository);

  @override
  Future<DataState<AirQualityEntity>> call(ForecastParams params) {
    return _weatherRepository.getAirQuality(params);
  }
}