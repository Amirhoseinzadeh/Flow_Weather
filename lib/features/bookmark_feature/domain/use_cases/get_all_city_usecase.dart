import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/core/usecases/UseCase.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';
import 'package:flow_weather/features/bookmark_feature/domain/repository/city_repository.dart';
class GetAllCitiesUseCase implements UseCase<DataState<List<City>>, void> {
  final CityRepository _cityRepository;

  GetAllCitiesUseCase(this._cityRepository);

  @override
  Future<DataState<List<City>>> call(void params) async {
    return await _cityRepository.getAllCityFromDB();
  }
}