import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/core/utils/constants.dart';
import 'package:flow_weather/features/weather_feature/data/models/air_quality_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/meteo_current_weather_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/neshan__city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart' as neshan;
import 'package:intl/intl.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final String? apiKeys = Constants.apiKey;

  Future<neshan.NeshanCityEntity> sendRequestCitySuggestion(String prefix) async {
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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final model = NeshanCityModel.fromJson(response.data);
        return neshan.NeshanCityEntity(
          count: model.count,
          items: model.items?.map((item) => neshan.NeshanCityItem(
            title: item.title,
            address: item.address,
            location: item.location != null
                ? neshan.Location(x: item.location!.x, y: item.location!.y)
                : null,
          )).toList(),
        );
      }
      throw Exception('خطا در دریافت داده‌های شهر: وضعیت ${response.statusCode}');
    } catch (e) {
      throw Exception('خطا در جستجوی شهر: $e');
    }
  }

  Future<neshan.NeshanCityItem?> getCityByCoordinates(double lat, double lon) async {
    try {
      if (lon < 44.0 || lon > 63.5 || lat < 25.0 || lat > 39.5) {
        return neshan.NeshanCityItem(
          title: 'نامشخص (خارج از ایران)',
          address: 'آدرس نامشخص',
          location: neshan.Location(x: lon, y: lat),
        );
      }

      if (apiKeys == null || apiKeys!.isEmpty) {
        throw Exception('API Key نیشان خالیه!');
      }

      var response = await _dio.get(
        "https://api.neshan.org/v1/reverse",
        queryParameters: {
          'lat': lat.toStringAsFixed(6),
          'lng': lon.toStringAsFixed(6),
        },
        options: Options(
          headers: {'Api-Key': apiKeys},
          validateStatus: (status) => status == 200,
        ),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = response.data;
        String cityName = _extractCityName(data);
        return neshan.NeshanCityItem(
          title: cityName,
          address: data['formatted_address'] ?? 'آدرس نامشخص',
          location: neshan.Location(x: lon, y: lat),
        );
      } else {
        throw Exception('خطا در API نیشان: کد ${response.statusCode}');
      }
    } catch (e) {
      return neshan.NeshanCityItem(
        title: 'موقعیت نامشخص',
        address: 'آدرس نامشخص',
        location: neshan.Location(x: lon, y: lat),
      );
    }
  }

  String _extractCityName(Map<String, dynamic> data) {
    try {
      if (data.containsKey('city') && data['city'] is String && (data['city'] as String).isNotEmpty) {
        return data['city'] as String;
      } else if (data.containsKey('neighbourhood') && data['neighbourhood'] is String && (data['neighbourhood'] as String).isNotEmpty) {
        return data['neighbourhood'] as String;
      } else if (data.containsKey('address') && data['address'] is String && (data['address'] as String).isNotEmpty) {
        final addressParts = (data['address'] as String).split(',');
        return addressParts.isNotEmpty ? addressParts.first.trim() : 'موقعیت نامشخص';
      } else if (data.containsKey('state') && data['state'] is String && (data['state'] as String).isNotEmpty) {
        return data['state'] as String;
      }
      return 'موقعیت نامشخص';
    } catch (e) {
      return 'موقعیت نامشخص';
    }
  }

  Future<MeteoCurrentWeatherEntity> callCurrentWeather(String cityName, {double? lat, double? lon}) async {
    try {
      if (lat == null || lon == null) {
        throw Exception('مختصات برای شهر $cityName نامعتبر است');
      }

      final usedLat = lat;
      final usedLon = lon;
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 1)));
      final currentHour = DateFormat('yyyy-MM-ddTHH:00').format(now);

      var response = await _dio.get(
        "https://api.open-meteo.com/v1/forecast",
        queryParameters: {
          'latitude': usedLat,
          'longitude': usedLon,
          'current': 'temperature_2m,relativehumidity_2m,pressure_msl,weathercode,windspeed_10m,winddirection_10m',
          'hourly': 'uv_index,precipitation_probability',
          'daily': 'sunrise,sunset',
          'start_date': today,
          'end_date': tomorrow,
          'timezone': 'Asia/Tehran',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final model = MeteoCurrentWeatherModel.fromJson(
          response.data,
          name: cityName, // تایتل سرچ‌شده رو اینجا اولویت می‌دیم
          coord: Coord(lat: usedLat, lon: usedLon),
          currentHour: currentHour,
        );

        return MeteoCurrentWeatherEntity(
          name: model.name, // تایتل سرچ‌شده حفظ می‌شه
          coord: model.coord,
          sys: model.sys,
          timezone: model.timezone,
          main: model.main,
          wind: model.wind,
          weather: model.weather,
          uvIndex: model.uvIndex,
          precipitationProbability: model.precipitationProbability,
        );
      }
      throw Exception('خطا در دریافت داده‌های آب‌وهوای کنونی: وضعیت ${response.statusCode}');
    } catch (e) {
      throw Exception('خطا در دریافت آب‌وهوای کنونی: $e');
    }
  }

  Future<MeteoCurrentWeatherEntity> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      final city = await getCityByCoordinates(lat, lon);
      final cityName = city?.title?.isNotEmpty == true ? city!.title! : 'نامشخص';

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 1)));
      final currentHour = DateFormat('yyyy-MM-ddTHH:00').format(now);

      var response = await _dio.get(
        "https://api.open-meteo.com/v1/forecast",
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relativehumidity_2m,pressure_msl,weathercode,windspeed_10m,winddirection_10m',
          'hourly': 'uv_index,precipitation_probability',
          'daily': 'sunrise,sunset',
          'start_date': today,
          'end_date': tomorrow,
          'timezone': 'Asia/Tehran',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final model = MeteoCurrentWeatherModel.fromJson(
          response.data,
          name: cityName, // تایتل از getCityByCoordinates
          coord: Coord(lat: lat, lon: lon),
          currentHour: currentHour,
        );

        return MeteoCurrentWeatherEntity(
          name: model.name,
          coord: model.coord,
          sys: model.sys,
          timezone: model.timezone,
          main: model.main,
          wind: model.wind,
          weather: model.weather,
          uvIndex: model.uvIndex,
          precipitationProbability: model.precipitationProbability,
        );
      }
      throw Exception('خطا در دریافت داده‌های آب‌وهوای کنونی: وضعیت ${response.statusCode}');
    } catch (e) {
      throw Exception('خطا در دریافت آب‌وهوای کنونی با مختصات: $e');
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
          'daily': 'weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max',
          'hourly': 'temperature_2m,relative_humidity_2m,weathercode,precipitation_probability,wind_speed_10m',
          'start_date': startDate,
          'end_date': endDate,
          'timezone': 'auto',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('خطا در دریافت داده‌های پیش‌بینی آب‌وهوا: وضعیت ${response.statusCode}');
    } catch (e) {
      throw Exception('خطا در دریافت پیش‌بینی آب‌وهوا: $e');
    }
  }

  Future<AirQualityModel> getAirQuality(ForecastParams params) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _dio.get(
        'https://air-quality-api.open-meteo.com/v1/air-quality',
        queryParameters: {
          'latitude': params.lat,
          'longitude': params.lon,
          'start_date': today,
          'end_date': today,
          'forecast_days': 0,
          'current': 'pm10,pm2_5,ozone,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide',
          'timezone': 'Asia/Tehran',
        },
      ).timeout(const Duration(seconds: 10));
      return AirQualityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('خطا در دریافت داده‌های کیفیت هوا: $e');
    }
  }
}