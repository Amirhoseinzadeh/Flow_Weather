import 'package:equatable/equatable.dart';

class AirQualityEntity extends Equatable {
  final double pm25;
  final double pm10;
  final double ozone;
  final double? co; // مونوکسید کربن
  final double? no2; // دی‌اکسید نیتروژن
  final double? so2; // دی‌اکسید گوگرد

  const AirQualityEntity({
    required this.pm25,
    required this.pm10,
    required this.ozone,
    this.co,
    this.no2,
    this.so2,
  });

  @override
  List<Object?> get props => [pm25, pm10, ozone, co, no2, so2];
}