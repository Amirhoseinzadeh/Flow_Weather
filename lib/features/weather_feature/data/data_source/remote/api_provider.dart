import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/utils/constants.dart';
import 'package:flow_weather/features/weather_feature/data/models/air_quality_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/meteo_current_weather_model.dart';
import 'package:flow_weather/features/weather_feature/data/models/neshan__city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart' as neshan;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:intl/intl.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final String apiKeys = Constants.apiKey;

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
      print('در حال ارسال درخواست به API نشان برای مختصات: lat=$lat, lon=$lon');
      var response = await _dio.get(
        "https://api.neshan.org/v2/reverse",
        queryParameters: {
          'lat': lat,
          'lng': lon,
        },
        options: Options(
          headers: {
            'Api-Key': apiKeys,
          },
        ),
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('درخواست به API نشان بیش از حد طول کشید');
      });

      print('پاسخ دریافت‌شده از API نشان: ${response.statusCode} - ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        String cityName = data['city'] ??
            data['formatted_address']?.split(',')?.first ??
            'موقعیت نامشخص';
        return neshan.NeshanCityItem(
          title: cityName,
          address: data['formatted_address'] ?? 'آدرس نامشخص',
          location: neshan.Location(x: lon, y: lat),
        );
      } else {
        print('خطا در دریافت نام شهر از API نشان: وضعیت ${response.statusCode}');
        return await _getCityByGeocoding(lat, lon);
      }
    } catch (e) {
      print('خطا در getCityByCoordinates: $e');
      return await _getCityByGeocoding(lat, lon);
    }
  }

  Future<neshan.NeshanCityItem?> _getCityByGeocoding(double lat, double lon) async {
    try {
      print('تلاش برای دریافت نام شهر با geocoding...');
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('درخواست geocoding بیش از حد طول کشید');
      });
      if (placemarks.isNotEmpty) {
        String cityName = placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            'موقعیت نامشخص';
        String address = placemarks.first.street ?? 'آدرس نامشخص';
        print('نام شهر از geocoding: $cityName');
        return neshan.NeshanCityItem(
          title: cityName,
          address: address,
          location: neshan.Location(x: lon, y: lat),
        );
      } else {
        print('هیچ اطلاعاتی از geocoding دریافت نشد');
        return neshan.NeshanCityItem(
          title: 'موقعیت نامشخص',
          address: 'آدرس نامشخص',
          location: neshan.Location(x: lon, y: lat),
        );
      }
    } catch (e) {
      print('خطا در geocoding: $e');
      return neshan.NeshanCityItem(
        title: 'موقعیت نامشخص',
        address: 'آدرس نامشخص',
        location: neshan.Location(x: lon, y: lat),
      );
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
          'current_weather': true,
          'daily': 'sunrise,sunset',
          'start_date': today,
          'end_date': today,
          'timezone': 'Asia/Tehran',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
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
      throw Exception('خطا در دریافت داده‌های آب‌وهوای کنونی: وضعیت ${response.statusCode}');
    } catch (e) {
      throw Exception('خطا در دریافت آب‌وهوای کنونی: $e');
    }
  }

  Future<MeteoCurrentWeatherEntity> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      final city = await getCityByCoordinates(lat, lon);
      final cityName = city?.title ?? 'موقعیت نامشخص';

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      var response = await _dio.get(
        "https://api.open-meteo.com/v1/forecast",
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current_weather': true,
          'daily': 'sunrise,sunset',
          'start_date': today,
          'end_date': today,
          'timezone': 'Asia/Tehran',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final model = MeteoCurrentWeatherModel.fromJson(
          response.data,
          name: cityName,
          coord: Coord(lat: lat, lon: lon),
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
          'daily': 'weathercode,temperature_2m_max,temperature_2m_min',
          'hourly': 'temperature_2m,weathercode',
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
      final today = DateTime.now().toIso8601String().split('T')[0]; // مثلاً 2023-10-25
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
      print('پاسخ خام API برای مختصات (${params.lat}, ${params.lon}): ${response.data}');
      return AirQualityModel.fromJson(response.data);
    } catch (e) {
      print('خطا در دریافت داده‌های کیفیت هوا: $e');
      throw Exception('خطا در دریافت داده‌های کیفیت هوا: $e');
    }
  }
}