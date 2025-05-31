import 'package:equatable/equatable.dart';

class Coord extends Equatable {
  final double? lat;
  final double? lon;

  const Coord({this.lat, this.lon});

  @override
  List<Object?> get props => [lat, lon];
}

class Sys extends Equatable {
  final String? sunrise;
  final String? sunset;

  const Sys({this.sunrise, this.sunset});

  @override
  List<Object?> get props => [sunrise, sunset];
}

class Main extends Equatable {
  final double? temp;
  final int? humidity;
  final int? pressure;

  const Main({this.temp, this.humidity, this.pressure});

  @override
  List<Object?> get props => [temp, humidity, pressure];
}

class Wind extends Equatable {
  final double? speed;
  final int? deg;

  const Wind({this.speed, this.deg});

  @override
  List<Object?> get props => [speed, deg];
}

class Weather extends Equatable {
  final int? id;
  final String? description;

  const Weather({this.id, this.description});

  @override
  List<Object?> get props => [id, description];
}

class MeteoCurrentWeatherEntity extends Equatable {
  final String? name;
  final Coord? coord;
  final Sys? sys;
  final int? timezone; // تغییر از String? به int?
  final Main? main;
  final Wind? wind;
  final List<Weather>? weather;
  final double? uvIndex;
  final int? precipitationProbability;
  final double? elevation;

  const MeteoCurrentWeatherEntity({
    this.name,
    this.coord,
    this.sys,
    this.timezone,
    this.main,
    this.wind,
    this.weather,
    this.uvIndex,
    this.precipitationProbability,
    this.elevation,
  });

  MeteoCurrentWeatherEntity copyWith({
    String? name,
    Coord? coord,
    Sys? sys,
    int? timezone, // تغییر از String? به int?
    Main? main,
    Wind? wind,
    List<Weather>? weather,
    double? uvIndex,
    int? precipitationProbability,
    double? elevation,
  }) {
    return MeteoCurrentWeatherEntity(
      name: name ?? this.name,
      coord: coord ?? this.coord,
      sys: sys ?? this.sys,
      timezone: timezone ?? this.timezone,
      main: main ?? this.main,
      wind: wind ?? this.wind,
      weather: weather ?? this.weather,
      uvIndex: uvIndex ?? this.uvIndex,
      precipitationProbability: precipitationProbability ?? this.precipitationProbability,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  List<Object?> get props => [
    name,
    coord,
    sys,
    timezone,
    main,
    wind,
    weather,
    uvIndex,
    precipitationProbability,
    elevation,
  ];
}