import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';


abstract class CityRepository {
  Future<DataState<City>> saveCityToDB(City city);
  Future<DataState<List<City>>> getAllCityFromDB();
  Future<DataState<City?>> findCityByName(String name);
  Future<DataState<String>> deleteCityByName(String name);
  Future<DataState<City>> updateCity(City city);
}