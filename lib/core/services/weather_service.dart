import 'package:dio/dio.dart';
import 'package:flow_weather/locator.dart';

class WeatherService {
  final Dio dio = locator<Dio>();

  WeatherService();

  Future<Map<String, double>> getCoordinatesFromCityName(String cityName) async {
    // این فقط یه نمونه‌ست، باید با API واقعی جایگزین بشه
    try {
      // مثلاً فراخوانی یه API برای گرفتن مختصات
      return {'latitude': 35.6892, 'longitude': 51.3890}; // مختصات تهران
    } catch (e) {
      throw Exception('Failed to get coordinates: $e');
    }
  }
}