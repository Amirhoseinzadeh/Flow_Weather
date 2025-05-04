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
    String? sunrise,
    String? sunset,
    double? uvIndex,
    int? precipitationProbability,
  }) : super(
    name: name,
    coord: coord,
    sys: sys ?? Sys(sunrise: sunrise, sunset: sunset),
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
    uvIndex: uvIndex,
    precipitationProbability: precipitationProbability,
  );

  factory MeteoCurrentWeatherModel.fromJson(Map<String, dynamic> json, {String? name, Coord? coord, String? currentHour}) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    final daily = json['daily'] ?? {};
    final weatherCode = current['weathercode'] as int? ?? 0;

    // پیدا کردن UV Index و احتمال بارندگی
    double? uvIndex;
    int? precipitationProbability;

    if (currentHour != null && hourly['time'] != null) {
      final times = (hourly['time'] as List<dynamic>?)?.cast<String>() ?? [];
      print('ساعت فعلی: $currentHour');
      print('لیست زمان‌ها: $times');

      // پیدا کردن نزدیک‌ترین زمان به ساعت فعلی
      DateTime currentDateTime = DateTime.parse(currentHour);
      int closestIndex = -1;
      Duration minDifference = Duration(days: 365); // یک مقدار اولیه بزرگ

      for (int i = 0; i < times.length; i++) {
        DateTime timeDate = DateTime.parse(times[i]);
        Duration difference = currentDateTime.difference(timeDate).abs();
        if (difference < minDifference) {
          minDifference = difference;
          closestIndex = i;
        }
      }

      if (closestIndex != -1) {
        // UV Index
        final uvIndexes = (hourly['uv_index'] as List<dynamic>?)?.cast<double>() ?? [];
        if (closestIndex < uvIndexes.length) {
          uvIndex = uvIndexes[closestIndex];
          print('UV Index برای نزدیک‌ترین زمان (${times[closestIndex]}): $uvIndex');
        }

        // پیدا کردن حداکثر احتمال بارندگی برای 6 ساعت آینده
        final probabilities = (hourly['precipitation_probability'] as List<dynamic>?)?.cast<int>() ?? [];
        if (closestIndex < probabilities.length) {
          // از زمان فعلی تا 6 ساعت بعد
          int maxProbability = 0;
          for (int i = closestIndex; i < probabilities.length && i < closestIndex + 6; i++) {
            if (probabilities[i] > maxProbability) {
              maxProbability = probabilities[i];
            }
          }
          precipitationProbability = maxProbability;
          print('حداکثر احتمال بارندگی برای 6 ساعت آینده از (${times[closestIndex]}): $precipitationProbability%');
        }
      }
    }

    // تبدیل timezone از رشته (مثل "Asia/Tehran") به عدد (offset ثانیه‌ای)
    final timezoneStr = json['timezone'] as String? ?? 'UTC';
    final timezoneOffset = _getTimezoneOffset(timezoneStr);

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
    );
  }

  // متد استاتیک برای تبدیل weatherCode به توضیحات
  static String _mapWeatherCodeToDescription(int code, String lang) {
    Map<int, String> weatherDescriptions = {
      0: 'آفتابی',
      1: 'کمی ابری',
      2: 'ابری',
      3: 'ابری کامل',
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

  // متد برای تبدیل timezone به offset ثانیه‌ای
  static int _getTimezoneOffset(String timezone) {
    const timezoneOffsets = {
      'UTC': 0,
      'Asia/Tehran': 12600,
    };
    return timezoneOffsets[timezone] ?? 0;
  }
}