import 'package:hive_flutter/hive_flutter.dart';

part 'city_model.g.dart';

@HiveType(typeId: 0)
class CityModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double? lat;

  @HiveField(2)
  final double? lon;

  CityModel({required this.name, this.lat, this.lon});
}
