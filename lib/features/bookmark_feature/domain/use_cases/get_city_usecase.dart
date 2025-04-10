

import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/bookmark_feature/domain/repository/city_repository.dart';

import '../entities/city_model.dart';

class GetCityUseCase implements UseCase<DataState<City?>, String>{
  final CityRepository _cityRepository;
  GetCityUseCase(this._cityRepository);

  @override
  Future<DataState<City?>> call(String params) {
      return _cityRepository.findCityByName(params);
  }
}