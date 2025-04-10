


import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/data/models/suggest_city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';

abstract class WeatherRepository{

  Future<DataState<CurrentCityEntity>> fetchCurrentWeatherData(String cityName);

  Future<DataState<ForecastEntity>> fetchForecast(ForecastParams params);

  Future<List<Data>> fetchSuggestData(cityName);

}