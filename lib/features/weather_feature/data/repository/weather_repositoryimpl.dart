import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/data/models/current_city_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/forecast_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/suggest_city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/suggest_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';

class WeatherRepositoryImpl extends WeatherRepository{
  ApiProvider _apiProvider;

  WeatherRepositoryImpl(this._apiProvider);

  @override
  Future<DataState<CurrentCityEntity>> fetchCurrentWeatherData(String cityName) async {
    try{
      Response response = await _apiProvider.callCurrentWeather(cityName);

      if(response.statusCode == 200){
        /// init model
        CurrentCityEntity currentCityEntity = CurrentCityModel.fromJson(response.data);
        /// convert Model to Entity
        // CurrentCityEntity currentCityEntity = currentCityModel.toEntity();
        return DataSuccess(currentCityEntity);
      }else{
        return DataFailed("Something Went Wrong. try again...");
      }
    }catch(e){
      print(e.toString());
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
  Future<List<Data>> fetchSuggestData(cityName) async {

    Response response = await _apiProvider.sendRequestCitySuggestion(cityName);

    SuggestCityEntity suggestCityEntity = SuggestCityModel.fromJson(response.data);

    return suggestCityEntity.data!;

  }
}