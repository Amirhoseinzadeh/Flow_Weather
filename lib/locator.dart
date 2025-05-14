import 'package:dio/dio.dart';
import 'package:flow_weather/core/bloc/bottom_icon_cubit.dart';
import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/core/services/weather_service.dart'; // اضافه کردن WeatherService
import 'package:flow_weather/features/bookmark_feature/data/data_source/local/city_model.dart';
import 'package:flow_weather/features/bookmark_feature/data/data_source/repository/city_repositoryimpl.dart';
import 'package:flow_weather/features/bookmark_feature/domain/repository/city_repository.dart';
import 'package:flow_weather/features/bookmark_feature/domain/use_cases/delete_city_usecase.dart';
import 'package:flow_weather/features/bookmark_feature/domain/use_cases/find_city_by_name_use_case.dart'; // تغییر نام
import 'package:flow_weather/features/bookmark_feature/domain/use_cases/get_all_city_usecase.dart'; // تغییر نام
import 'package:flow_weather/features/bookmark_feature/domain/use_cases/save_city_usecase.dart';
import 'package:flow_weather/features/bookmark_feature/domain/use_cases/update_city_usecase.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_icon_cubit.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/data/repository/weather_repositoryimpl.dart';
import 'package:flow_weather/features/weather_feature/domain/repository/weather_repository.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_air_quality_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_current_weather_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

GetIt locator = GetIt.instance;

Future<void> setup() async {
  // ۱) Dio
  locator.registerLazySingleton<Dio>(() => Dio());

  // ۲) ApiProvider
  locator.registerSingleton<ApiProvider>(ApiProvider());

  // ۳) Database
  await Hive.initFlutter();
  Hive.registerAdapter(CityModelAdapter());
  await Hive.openBox<CityModel>('cities');

  // ۴) WeatherService
  locator.registerSingleton<WeatherService>(WeatherService());

  // ۵) Repositories
  locator.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(locator()),
  );
  locator.registerSingleton<CityRepository>(
    CityRepositoryImpl(),
  );

  // ۶) UseCases
  locator.registerSingleton<GetCurrentWeatherUseCase>(
    GetCurrentWeatherUseCase(locator()),
  );
  locator.registerSingleton<GetForecastWeatherUseCase>(
    GetForecastWeatherUseCase(locator()),
  );
  locator.registerSingleton<GetSuggestionCityUseCase>(
    GetSuggestionCityUseCase(locator()),
  );
  locator.registerSingleton<SaveCityUseCase>(
    SaveCityUseCase(locator()),
  );
  locator.registerSingleton<GetAllCitiesUseCase>(
    GetAllCitiesUseCase(locator()),
  );
  locator.registerSingleton<FindCityByNameUseCase>(
    FindCityByNameUseCase(locator()),
  );
  locator.registerSingleton<DeleteCityUseCase>(
    DeleteCityUseCase(locator()),
  );
  locator.registerFactory(() => UpdateCityUseCase(locator()));
  locator.registerLazySingleton<GetAirQualityUseCase>(() => GetAirQualityUseCase(locator()));

  // ۷) Blocs / Cubits
  locator.registerSingleton<HomeBloc>(
    HomeBloc(locator(), locator(), locator()),
  );
  locator.registerSingleton<BookmarkBloc>(
    BookmarkBloc(locator(), locator(), locator(), locator(), locator()),
  );
  locator.registerSingleton<BottomIconCubit>(BottomIconCubit());
  locator.registerSingleton<DetailCubit>(DetailCubit());
  locator.registerSingleton<BookmarkIconCubit>(BookmarkIconCubit());
}
