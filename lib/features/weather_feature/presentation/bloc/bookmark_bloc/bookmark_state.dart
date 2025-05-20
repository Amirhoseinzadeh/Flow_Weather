import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/save_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/update_city_status.dart';
import 'delete_city_status.dart' show DeleteCityInitial, DeleteCityStatus;
import 'get_all_city_status.dart' show GetAllCityLoading, GetAllCityStatus;
import 'get_city_status.dart' show GetCityLoading, GetCityStatus;

class BookmarkState extends Equatable {
  final SaveCityStatus saveCityStatus;
  final GetAllCityStatus getAllCityStatus;
  final GetCityStatus getCityStatus;
  final DeleteCityStatus deleteCityStatus;
  final UpdateCityStatus updateCityStatus;
  final int? loadingIndex; // ایندکس شهری که در حال لودینگ هست

  const BookmarkState({
    required this.saveCityStatus,
    required this.getAllCityStatus,
    required this.getCityStatus,
    required this.deleteCityStatus,
    required this.updateCityStatus,
    this.loadingIndex,
  });

  factory BookmarkState.initial() {
    return BookmarkState(
      saveCityStatus: SaveCityInitial(),
      getAllCityStatus: GetAllCityLoading(),
      getCityStatus: GetCityLoading(),
      deleteCityStatus: DeleteCityInitial(),
      updateCityStatus: UpdateCityInitial(),
      loadingIndex: null,
    );
  }

  BookmarkState copyWith({
    SaveCityStatus? newSaveStatus,
    GetAllCityStatus? newAllCityStatus,
    GetCityStatus? newCityStatus,
    DeleteCityStatus? newDeleteStatus,
    UpdateCityStatus? newUpdateStatus,
    int? loadingIndex,
  }) {
    return BookmarkState(
      saveCityStatus: newSaveStatus ?? saveCityStatus,
      getAllCityStatus: newAllCityStatus ?? getAllCityStatus,
      getCityStatus: newCityStatus ?? getCityStatus,
      deleteCityStatus: newDeleteStatus ?? deleteCityStatus,
      updateCityStatus: newUpdateStatus ?? updateCityStatus,
      loadingIndex: loadingIndex,
    );
  }

  @override
  List<Object?> get props => [
    saveCityStatus,
    getAllCityStatus,
    getCityStatus,
    deleteCityStatus,
    updateCityStatus,
    loadingIndex,
  ];
}