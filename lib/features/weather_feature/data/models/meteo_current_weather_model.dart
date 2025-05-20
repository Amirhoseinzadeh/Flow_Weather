import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';

class MeteoCurrentWeatherModel extends MeteoCurrentWeatherEntity {
  MeteoCurrentWeatherModel({
    super.name,
    super.coord,
    Sys? sys,
    super.timezone,
    double? temperature,
    int? humidity,
    double? pressure,
    double? windSpeed,
    int? windDirection,
    int? weatherCode,
    String? description,
    String? sunrise,
    String? sunset,
    super.uvIndex,
    super.precipitationProbability,
    super.elevation,
  }) : super(
    sys: sys ?? Sys(sunrise: sunrise, sunset: sunset),
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

  factory MeteoCurrentWeatherModel.fromJson(Map<String, dynamic> json, {String? name, Coord? coord, String? currentHour}) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    final daily = json['daily'] ?? {};
    final weatherCode = current['weathercode'] as int? ?? 0;


    double? uvIndex;
    int? precipitationProbability;

    if (currentHour != null && hourly['time'] != null) {
      final times = (hourly['time'] as List<dynamic>?)?.cast<String>() ?? [];


      DateTime currentDateTime = DateTime.parse(currentHour);
      int closestIndex = -1;
      Duration minDifference = Duration(days: 365);

      for (int i = 0; i < times.length; i++) {
        DateTime timeDate = DateTime.parse(times[i]);
        Duration difference = currentDateTime.difference(timeDate).abs();
        if (difference < minDifference) {
          minDifference = difference;
          closestIndex = i;
        }
      }

      if (closestIndex != -1 && closestIndex < times.length) {
        // UV Index
        final uvIndexes = (hourly['uv_index'] as List<dynamic>?)?.cast<double>() ?? [];
        if (closestIndex < uvIndexes.length) {
          uvIndex = uvIndexes[closestIndex];
        }

        final probabilities = (hourly['precipitation_probability'] as List<dynamic>?)?.cast<int>() ?? [];
        if (probabilities.isNotEmpty && closestIndex < probabilities.length) {
          int sumProbability = 0;
          int validHours = 0;
          for (int i = closestIndex; i < probabilities.length && i < closestIndex + 12; i++) {
            sumProbability += probabilities[i];
            validHours++;
          }
          precipitationProbability = validHours > 0 ? (sumProbability / validHours).round() : 0;
        } else {
          precipitationProbability = 0;
        }
      } else {
        precipitationProbability = 0;
      }
    } else {
      precipitationProbability = 0;
    }

    final timezoneStr = json['timezone'] as String? ?? 'UTC';
    final timezoneOffset = _getTimezoneOffset(timezoneStr);

    final elevation = json['elevation'] as double?;

    return MeteoCurrentWeatherModel(
      name: name ?? json['city_name'] as String?,
      coord: coord ?? Coord(
        lat: json['latitude'] as double?,
        lon: json['longitude'] as double?,
      ),
      temperature: current['temperature_2m'] as double?,
      humidity: current['relativehumidity_2m'] as int?,
      pressure: current['pressure_msl'] as double?,
      windSpeed: current['windspeed_10m'] as double?,
      windDirection: current['winddirection_10m'] as int?,
      weatherCode: weatherCode,
      description: _mapWeatherCodeToDescription(weatherCode, 'fa'),
      timezone: timezoneOffset,
      sunrise: daily['sunrise']?[0] as String?,
      sunset: daily['sunset']?[0] as String?,
      uvIndex: uvIndex,
      precipitationProbability: precipitationProbability,
      elevation: elevation,
    );
  }

  static String _mapWeatherCodeToDescription(int code, String lang) {
    Map<int, String> weatherDescriptions = {
      0: 'آفتابی',
      1: 'کمی ابری',
      2: 'ابری',
      3: 'ابری',
      45: 'مه',
      48: 'مه شدید',
      51: 'ابری',
      53: 'ابری',
      55: 'باران ریز شدید',
      56: 'ابری',
      57: 'باران ریز یخ‌زده شدید',
      61: 'ابری',
      63: 'باران',
      65: 'باران شدید',
      66: 'ابری',
      67: 'باران یخ‌زده شدید',
      71: 'برف سبک',
      73: 'برف',
      75: 'برف شدید',
      77: 'دانه برف',
      80: 'باران سبک',
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

  static int _getTimezoneOffset(String timezone) {
    const timezoneOffsets = {
      'UTC': 0,
      'Asia/Tehran': 12600,
    };
    return timezoneOffsets[timezone] ?? 0;
  }
}