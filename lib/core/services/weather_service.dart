import 'package:dio/dio.dart';
import 'package:flow_weather/locator.dart';

class WeatherService {
  final Dio dio = locator<Dio>();

  WeatherService();

  Future<Map<String, double>> getCoordinatesFromCityName(String cityName) async {

    try {
      return {'latitude': 35.6892, 'longitude': 51.3890};
    } catch (e) {
      throw Exception('Failed to get coordinate: $e');
    }
  }
}