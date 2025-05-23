import 'package:equatable/equatable.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class SaveCityEvent extends BookmarkEvent {
  final City city;
  const SaveCityEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class GetAllCitiesEvent extends BookmarkEvent {}

class FindCityByNameEvent extends BookmarkEvent {
  final String name;
  const FindCityByNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class DeleteCityEvent extends BookmarkEvent {
  final String name;
  const DeleteCityEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateCityEvent extends BookmarkEvent {
  final City city;
  const UpdateCityEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class LoadCityWeatherEvent extends BookmarkEvent {
  final int index;
  const LoadCityWeatherEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetLoadingIndexEvent extends BookmarkEvent {}