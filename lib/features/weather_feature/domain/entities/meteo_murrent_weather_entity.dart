import 'package:equatable/equatable.dart';

class MeteoCurrentWeatherEntity extends Equatable {
  final String? name; // نام شهر
  final Coord? coord; // مختصات
  final Sys? sys; // طلوع و غروب خورشید
  final int? timezone; // منطقه زمانی
  final Main? main; // دما، رطوبت، فشار
  final Wind? wind; // سرعت و جهت باد
  final List<Weather>? weather; // وضعیت هوا (به‌صورت لیست)

  MeteoCurrentWeatherEntity({
    this.name,
    this.coord,
    this.sys,
    this.timezone,
    this.main,
    this.wind,
    this.weather,
  });

  @override
  List<Object?> get props => [name, coord, sys, timezone, main, wind, weather];

  @override
  bool get stringify => true;
}

class Coord extends Equatable {
  final double? lat;
  final double? lon;

  Coord({this.lat, this.lon});

  @override
  List<Object?> get props => [lat, lon];

  @override
  bool get stringify => true;
}

class Sys extends Equatable {
  final String? sunrise; // تغییر به String
  final String? sunset;  // تغییر به String

  Sys({this.sunrise, this.sunset});

  @override
  List<Object?> get props => [sunrise, sunset];

  @override
  bool get stringify => true;
}

class Main extends Equatable {
  final double? temp;
  final int? humidity;
  final int? pressure;

  Main({this.temp, this.humidity, this.pressure});

  @override
  List<Object?> get props => [temp, humidity, pressure];

  @override
  bool get stringify => true;
}

class Wind extends Equatable {
  final double? speed;
  final int? deg;

  Wind({this.speed, this.deg});

  @override
  List<Object?> get props => [speed, deg];

  @override
  bool get stringify => true;
}

class Weather extends Equatable {
  final int? id;
  final String? description;

  Weather({this.id, this.description});

  @override
  List<Object?> get props => [id, description];

  @override
  bool get stringify => true;
}