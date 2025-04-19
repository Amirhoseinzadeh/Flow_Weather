
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';
import 'package:flow_weather/features/bookmark_feature/domain/repository/city_repository.dart';

class UpdateCityUseCase implements UseCase<DataState<City>, City> {
  final CityRepository _cityRepository;

  UpdateCityUseCase(this._cityRepository);

  @override
  Future<DataState<City>> call(City params) async {
    return await _cityRepository.updateCity(params);
  }
}
