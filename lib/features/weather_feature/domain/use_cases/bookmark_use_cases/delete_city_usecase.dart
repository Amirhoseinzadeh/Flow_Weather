
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/use_case.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/city_repository.dart';

class DeleteCityUseCase implements UseCase<DataState<String>, String> {
  final CityRepository _cityRepository;

  DeleteCityUseCase(this._cityRepository);

  @override
  Future<DataState<String>> call(String params) async {
    return await _cityRepository.deleteCityByName(params);
  }
}