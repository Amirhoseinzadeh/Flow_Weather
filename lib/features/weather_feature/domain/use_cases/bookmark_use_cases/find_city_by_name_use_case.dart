
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/use_case.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/city_repository.dart';

class FindCityByNameUseCase implements UseCase<DataState<City?>, String> {
  final CityRepository _cityRepository;

  FindCityByNameUseCase(this._cityRepository);

  @override
  Future<DataState<City?>> call(String params) async {
    return await _cityRepository.findCityByName(params);
  }
}