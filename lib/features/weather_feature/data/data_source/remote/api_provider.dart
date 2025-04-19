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
      final today = DateFormat('yyyy-MM-dd').format(now);

      var response = await _dio.get(
        "https://api.open-meteo.com/v1/forecast",
        queryParameters: {
          'latitude': city.location!.y,
          'longitude': city.location!.x,
          'current_weather': true, // برای گرفتن داده‌های فعلی
          'daily': 'sunrise,sunset', // برای گرفتن طلوع و غروب
          'start_date': today,
          'end_date': today,
          'timezone': 'Asia/Tehran', // وقت ایران
        },
      );

      if (response.statusCode == 200) {
        // استفاده از متد fromJson با پارامترهای name و coord
        final model = MeteoCurrentWeatherModel.fromJson(
          response.data,
          name: city.title,
          coord: Coord(lat: city.location!.y, lon: city.location!.x),
        );

        return MeteoCurrentWeatherEntity(
          name: model.name,
          coord: model.coord,
          sys: model.sys,
          timezone: model.timezone,
          main: model.main,
          wind: model.wind,
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
}