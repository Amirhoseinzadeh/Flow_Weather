import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';

abstract class WeatherRepository {
  Future<DataState<MeteoCurrentWeatherEntity>> fetchCurrentWeatherData(String cityName);

  Future<DataState<ForecastEntity>> fetchForecast(ForecastParams params);

  Future<List<NeshanCityItem>> fetchSuggestData(String cityName);
}