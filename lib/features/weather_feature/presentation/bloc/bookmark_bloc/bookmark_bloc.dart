import 'package:bloc/bloc.dart';
import 'package:flow_weather/core/resources/data_state.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/bookmark_use_cases/delete_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/bookmark_use_cases/find_city_by_name_use_case.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/bookmark_use_cases/get_all_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/bookmark_use_cases/save_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/bookmark_use_cases/update_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_state.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/delete_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/get_all_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/get_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/save_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/update_city_status.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final SaveCityUseCase _saveCityUseCase;
  final GetAllCitiesUseCase _getAllCitiesUseCase;
  final FindCityByNameUseCase _findCityByNameUseCase;
  final DeleteCityUseCase _deleteCityUseCase;
  final UpdateCityUseCase _updateCityUseCase;

  BookmarkBloc(
      this._saveCityUseCase,
      this._getAllCitiesUseCase,
      this._findCityByNameUseCase,
      this._deleteCityUseCase,
      this._updateCityUseCase,
      ) : super(BookmarkState.initial()) {
    on<SaveCityEvent>((event, emit) async {
      emit(state.copyWith(newSaveStatus: SaveCityLoading()));
      final result = await _saveCityUseCase(event.city);
      if (result is DataSuccess) {
        emit(state.copyWith(newSaveStatus: SaveCityCompleted(result.data!)));
        final cities = await _getAllCitiesUseCase(null);
        if (cities is DataSuccess) {
          emit(state.copyWith(newAllCityStatus: GetAllCityCompleted(cities.data!)));
        } else {
          emit(state.copyWith(newAllCityStatus: GetAllCityError('خطا در دریافت شهرها')));
        }
        add(FindCityByNameEvent(event.city.name));
      } else {
        emit(state.copyWith(newSaveStatus: SaveCityError('خطا در ذخیره شهر: ${result.error}')));
      }
    });

    on<GetAllCitiesEvent>((event, emit) async {
      emit(state.copyWith(newAllCityStatus: GetAllCityLoading()));
      final result = await _getAllCitiesUseCase(null);
      if (result is DataSuccess) {
        emit(state.copyWith(newAllCityStatus: GetAllCityCompleted(result.data!)));
      } else {
        emit(state.copyWith(newAllCityStatus: GetAllCityError('خطا در دریافت شهرها')));
      }
    });

    on<FindCityByNameEvent>((event, emit) async {
      emit(state.copyWith(newCityStatus: GetCityLoading()));
      final result = await _findCityByNameUseCase(event.name);
      if (result is DataSuccess) {
        emit(state.copyWith(newCityStatus: GetCityCompleted(result.data)));
      } else {
        emit(state.copyWith(newCityStatus: GetCityError('خطا در جستجوی شهر')));
      }
    });

    on<DeleteCityEvent>((event, emit) async {
      emit(state.copyWith(newDeleteStatus: DeleteCityLoading()));
      final result = await _deleteCityUseCase(event.name);
      if (result is DataSuccess) {
        emit(state.copyWith(newDeleteStatus: DeleteCityCompleted(result.data!)));
        final cities = await _getAllCitiesUseCase(null);
        if (cities is DataSuccess) {
          emit(state.copyWith(newAllCityStatus: GetAllCityCompleted(cities.data!)));
        } else {
          emit(state.copyWith(newAllCityStatus: GetAllCityError('خطا در دریافت شهرها')));
        }
      } else {
        emit(state.copyWith(newDeleteStatus: DeleteCityError('خطا در حذف شهر')));
      }
    });

    on<UpdateCityEvent>((event, emit) async {
      emit(state.copyWith(newUpdateStatus: UpdateCityLoading()));
      final result = await _updateCityUseCase(event.city);
      if (result is DataSuccess) {
        emit(state.copyWith(newUpdateStatus: UpdateCityCompleted(result.data!)));
        final cities = await _getAllCitiesUseCase(null);
        if (cities is DataSuccess) {
          emit(state.copyWith(newAllCityStatus: GetAllCityCompleted(cities.data!)));
        } else {
          emit(state.copyWith(newAllCityStatus: GetAllCityError('خطا در دریافت شهرها')));
        }
      } else {
        emit(state.copyWith(newUpdateStatus: UpdateCityError('خطا در آپدیت شهر')));
      }
    });

    on<LoadCityWeatherEvent>((event, emit) async {
      emit(state.copyWith(loadingIndex: event.index));
    });

    on<ResetLoadingIndexEvent>((event, emit) async {
      emit(state.copyWith(loadingIndex: null));
    });
  }
}