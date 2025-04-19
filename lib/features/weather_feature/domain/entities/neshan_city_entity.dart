// neshan_city_entity.dart
import 'package:equatable/equatable.dart';

class NeshanCityEntity extends Equatable {
  final int? count;
  final List<NeshanCityItem>? items;

  NeshanCityEntity({
    this.count,
    this.items,
  });

  @override
  List<Object?> get props => [count, items];

  @override
  bool get stringify => true;
}

class NeshanCityItem extends Equatable {
  final String? title;
  final String? address;
  final Location? location;

  NeshanCityItem({
    this.title,
    this.address,
    this.location,
  });

  @override
  List<Object?> get props => [title, address, location];

  @override
  bool get stringify => true;
}

class Location extends Equatable {
  final double? x;
  final double? y;

  Location({
    this.x,
    this.y,
  });

  @override
  List<Object?> get props => [x, y];

  @override
  bool get stringify => true;
}