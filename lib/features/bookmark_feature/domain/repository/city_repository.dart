

import 'package:flow_weather/core/resources/data_state.dart';

import '../entities/city_model.dart';

abstract class CityRepository{

  Future<DataState<City>> saveCityToDB(String cityName);

  Future<DataState<List<City>>> getAllCityFromDB();

  Future<DataState<City?>> findCityByName(String name);

  Future<DataState<String>> deleteCityByName(String name);


}