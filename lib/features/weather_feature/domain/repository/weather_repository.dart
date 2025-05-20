import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';

abstract class WeatherRepository {
  Future<DataState<MeteoCurrentWeatherEntity>> fetchCurrentWeatherData(String cityName);

  Future<DataState<MeteoCurrentWeatherEntity>> getCurrentWeatherByCoordinates(double lat, double lon);

  Future<DataState<ForecastEntity>> fetchForecast(ForecastParams params);

  Future<List<NeshanCityItem>> fetchSuggestData(String cityName);

  Future<DataState<AirQualityEntity>> getAirQuality(ForecastParams params);
}