import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/data/models/forecast_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class WeatherRepositoryImpl extends WeatherRepository {
  final ApiProvider _apiProvider;

  WeatherRepositoryImpl(this._apiProvider);

  @override
  Future<DataState<MeteoCurrentWeatherEntity>> fetchCurrentWeatherData(String cityName) async {
    try {
      MeteoCurrentWeatherEntity currentWeatherEntity = await _apiProvider.callCurrentWeather(cityName);
      return DataSuccess(currentWeatherEntity);
    } catch (e) {
      return DataFailed("please check your connection...");
    }
  }

  @override
  Future<DataState<MeteoCurrentWeatherEntity>> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      MeteoCurrentWeatherEntity currentWeatherEntity = await _apiProvider.getCurrentWeatherByCoordinates(lat, lon);
      return DataSuccess(currentWeatherEntity);
    } catch (e) {
      return DataFailed("please check your connection...");
    }
  }

  @override
  Future<DataState<ForecastEntity>> fetchForecast(ForecastParams params) async {
    try {
      final json = await _apiProvider.getForecastWeather(params);
      final forecast = ForecastModel.fromJson(json);
      return DataSuccess(forecast);
    } catch (e) {
      return DataFailed("خطا در دریافت پیش‌بینی: ${e.toString()}");
    }
  }

  @override
  Future<List<NeshanCityItem>> fetchSuggestData(String cityName) async {
    try {
      NeshanCityEntity suggestCityEntity = await _apiProvider.sendRequestCitySuggestion(cityName);
      return suggestCityEntity.items ?? [];
    } catch (e) {
      throw Exception("please check your connection...");
    }
  }

  @override
  Future<DataState<AirQualityEntity>> getAirQuality(ForecastParams params) async {
    try {
      AirQualityEntity airQualityEntity = await _apiProvider.getAirQuality(params);
      return DataSuccess(airQualityEntity);
    } catch (e) {
      return DataFailed("خطا در دریافت پیش‌بینی: ${e.toString()}");
    }
  }
}