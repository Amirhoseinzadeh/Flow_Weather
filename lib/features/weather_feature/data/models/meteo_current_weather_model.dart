
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';

class MeteoCurrentWeatherModel extends MeteoCurrentWeatherEntity {
  MeteoCurrentWeatherModel({
    String? name,
    Coord? coord,
    Sys? sys,
    int? timezone,
    double? temperature,
    int? humidity,
    double? pressure,
    double? windSpeed,
    int? windDirection,
    int? weatherCode,
    String? description,
  }) : super(
    name: name,
    coord: coord,
    sys: sys,
    timezone: timezone,
    main: Main(
      temp: temperature,
      humidity: humidity,
      pressure: pressure?.toInt(),
    ),
    wind: Wind(
      speed: windSpeed,
      deg: windDirection,
    ),
    weather: weatherCode != null && description != null
        ? [Weather(id: weatherCode, description: description)]
        : [],
  );

  // متد استاتیک برای تبدیل weatherCode به توضیحات
  static String _mapWeatherCodeToDescription(int code, String lang) {
    Map<int, String> weatherDescriptions = {
      0: 'آفتابی',
      1: 'کمی ابری',
      2: 'ابری',
      3: 'ابری کامل',
      45: 'مه',
      48: 'مه شدید',
      51: 'باران ریز سبک',
      53: 'باران ریز',
      55: 'باران ریز شدید',
      56: 'باران ریز یخ‌زده',
      57: 'باران ریز یخ‌زده شدید',
      61: 'باران سبک',
      63: 'باران',
      65: 'باران شدید',
      66: 'باران یخ‌زده سبک',
      67: 'باران یخ‌زده شدید',
      71: 'برف سبک',
      73: 'برف',
      75: 'برف شدید',
      77: 'دانه برف',
      80: 'رگبار سبک',
      81: 'رگبار',
      82: 'رگبار شدید',
      85: 'برف سبک',
      86: 'برف شدید',
      95: 'رعد و برق',
      96: 'رعد و برق با تگرگ سبک',
      99: 'رعد و برق با تگرگ شدید',
    };

    return weatherDescriptions[code] ?? 'ناشناخته';
  }
}