import 'package:flow_weather/features/bookmark_feature/data/data_source/local/city_model.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';

City toEntity(CityModel model) {
  return City(name: model.name, lat: model.lat, lon: model.lon);
}

CityModel toModel(City entity) {
  return CityModel(name: entity.name, lat: entity.lat, lon: entity.lon);
}