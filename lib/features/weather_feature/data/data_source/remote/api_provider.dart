import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/utils/constants.dart';
import 'package:flow_weather/features/weather_feature/data/models/meteo_current_weather_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/neshan__city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';
import 'package:intl/intl.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final String apiKeys = Constants.apiKey;


  Future<NeshanCityEntity> sendRequestCitySuggestion(String prefix) async {
    try {
      var response = await _dio.get(
        "https://api.neshan.org/v1/search",
        queryParameters: {
          'term': prefix,
          'lat': 35.6892,
          'lng': 51.3890,
        },
        options: Options(
          headers: {
            'Api-Key': apiKeys,
          },
        ),
      );

      if (response.statusCode == 200) {
        final model = NeshanCityModel.fromJson(response.data);
        return NeshanCityEntity(
          count: model.count,
          items: model.items?.map((item) => NeshanCityItem(
            title: item.title,
            address: item.address,
            location: item.location != null
                ? Location(x: item.location!.x, y: item.location!.y)
                : null,
          )).toList(),
        );
      }
      throw Exception('خطا در دریافت داده‌های شهر');
    } catch (e) {
      throw Exception('خطا در جستجوی شهر: $e');
    }
  }

  Future<MeteoCurrentWeatherEntity> callCurrentWeather(String cityName) async {
    try {
      final cityData = await sendRequestCitySuggestion(cityName);
      final city = cityData.items?.first;
      if (city == null || city.location == null) {
        throw Exception('شهر پیدا نشد یا مختصات نامعتبر است');
      }

      final now = DateTime.now();
      final df = DateFormat('yyyy-MM-ddTHH:00');
      final currentHour = df.format(now);

      var response = await _dio.get(
        "https://api.open-meteo.com/v1/forecast",
        queryParameters: {
          'latitude': city.location!.y,
          'longitude': city.location!.x,
          'hourly': 'temperature_2m,relative_humidity_2m,pressure_msl,wind_speed_10m,wind_direction_10m,weathercode',
          'start_date': DateFormat('yyyy-MM-dd').format(now),
          'end_date': DateFormat('yyyy-MM-dd').format(now),
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        var hourlyData = response.data['hourly'];
        int index = hourlyData['time'].indexOf(currentHour);
        if (index == -1) {
          throw Exception('داده برای ساعت فعلی پیدا نشد');
        }

        final model = MeteoCurrentWeatherModel(
          name: city.title,
          coord: Coord(lat: city.location!.y, lon: city.location!.x),
          temperature: hourlyData['temperature_2m'][index]?.toDouble(),
          humidity: hourlyData['relative_humidity_2m'][index],
          pressure: hourlyData['pressure_msl'][index]?.toDouble(),
          windSpeed: hourlyData['wind_speed_10m'][index]?.toDouble(),
          windDirection: hourlyData['wind_direction_10m'][index],
          weatherCode: hourlyData['weathercode'][index],
          description: _mapWeatherCodeToDescription(
              hourlyData['weathercode'][index] ?? 0, 'fa'), // تغییر فراخوانی
        );

        return MeteoCurrentWeatherEntity(
          name: model.name,
          coord: model.coord,
          sys: Sys(sunrise: 0, sunset: 0),
          timezone: 0,
          main: Main(
            temp: model.main?.temp,
            humidity: model.main?.humidity,
            pressure: model.main?.pressure,
          ),
          wind: Wind(
            speed: model.wind?.speed,
            deg: model.wind?.deg,
          ),
          weather: model.weather,
        );
      }
      throw Exception('خطا در دریافت داده‌های آب‌وهوای کنونی');
    } catch (e) {
      throw Exception('خطا در دریافت آب‌وهوای کنونی: $e');
    }
  }

  Future<Map<String, dynamic>> getForecastWeather(ForecastParams params) async {
    try {
      final now = DateTime.now();
      final df = DateFormat('yyyy-MM-dd');
      final startDate = df.format(now);
      final endDate = df.format(now.add(const Duration(days: 14)));

      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': params.lat,
          'longitude': params.lon,
          'daily': 'weathercode,temperature_2m_max,temperature_2m_min',
          'hourly': 'temperature_2m,weathercode',
          'start_date': startDate,
          'end_date': endDate,
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('خطا در دریافت داده‌های پیش‌بینی آب‌وهوا');
    } catch (e) {
      throw Exception('خطا در دریافت پیش‌بینی آب‌وهوا: $e');
    }
  }

  String _mapWeatherCodeToDescription(int code, String lang) {
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