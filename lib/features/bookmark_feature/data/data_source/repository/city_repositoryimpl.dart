import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/bookmark_feature/data/data_source/local/city_model.dart';
import 'package:flow_weather/features/bookmark_feature/data/data_source/local/mappers/city_mapper.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';
import 'package:flow_weather/features/bookmark_feature/domain/repository/city_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CityRepositoryImpl extends CityRepository {
  final Box<CityModel> _cityBox;

  CityRepositoryImpl() : _cityBox = Hive.box<CityModel>('cities');

  @override
  Future<DataState<City>> saveCityToDB(City city) async {
    try {
      final model = toModel(city);
      await _cityBox.put(model.name, model);
      return DataSuccess(city);
    } catch (e) {
      return DataFailed('خطا در ذخیره شهر: $e');
    }
  }

  @override
  Future<DataState<List<City>>> getAllCityFromDB() async {
    try {
      final models = _cityBox.values.toList();
      final entities = models.map((model) => toEntity(model)).toList();
      return DataSuccess(entities);
    } catch (e) {
      return DataFailed('خطا در دریافت شهرها: $e');
    }
  }

  @override
  Future<DataState<City?>> findCityByName(String name) async {
    try {
      final model = _cityBox.get(name);
      if (model == null) {
        return DataSuccess(null);
      }
      return DataSuccess(toEntity(model));
    } catch (e) {
      return DataFailed('خطا در جستجوی شهر: $e');
    }
  }

  @override
  Future<DataState<String>> deleteCityByName(String name) async {
    try {
      await _cityBox.delete(name);
      return DataSuccess(name);
    } catch (e) {
      return DataFailed('خطا در حذف شهر: $e');
    }
  }

  @override
  Future<DataState<City>> updateCity(City city) async {
    try {
      final model = toModel(city);
      await _cityBox.put(model.name, model);
      return DataSuccess(city);
    } catch (e) {
      return DataFailed('خطا در آپدیت شهر: $e');
    }
  }
}