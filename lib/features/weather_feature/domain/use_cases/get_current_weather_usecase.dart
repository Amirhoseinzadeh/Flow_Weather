import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/use_case.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class GetCurrentWeatherUseCase implements UseCase<DataState<MeteoCurrentWeatherEntity>, Map<String, dynamic>> {
  final WeatherRepository _weatherRepository;
  GetCurrentWeatherUseCase(this._weatherRepository);

  @override
  Future<DataState<MeteoCurrentWeatherEntity>> call(Map<String, dynamic> params) {
    final cityName = params['cityName'] as String;
    final lat = params['lat'] as double?;
    final lon = params['lon'] as double?;

    if (lat != null && lon != null) {
      return _weatherRepository.getCurrentWeatherByCoordinates(lat, lon, cityNameOverride: cityName); // اضافه کردن تایتل سرچ‌شده
    } else {
      return _weatherRepository.fetchCurrentWeatherData(cityName);
    }
  }
}