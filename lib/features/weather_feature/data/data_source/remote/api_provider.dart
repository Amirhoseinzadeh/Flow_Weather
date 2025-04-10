import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/utils/constants.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/screens/bookmark_screen.dart';
import 'package:intl/intl.dart';

class ApiProvider{
  final Dio _dio = Dio();

  var apiKey = Constants.apiKeys1;

  Future<dynamic> callCurrentWeather(cityName)async{
    var response = await _dio.get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {
          'q' : cityName,
          // 'lat': params.lat,
          // 'lon': params.lon,
          // 'exclude': 'minutely,hourly',
          'appid': apiKey,
          'units': 'metric'
        });
    return response;
  }

  Future<Map<String, dynamic>> getForecastWeather(ForecastParams params) async {
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    final startDate = df.format(now);                   // امروز
    final endDate = df.format(now.add(const Duration(days: 7))); // هفت روز بعد

    final response = await dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': params.lat,
        'longitude': params.lon,
        'daily': 'weathercode,temperature_2m_max',
        'hourly': 'temperature_2m,weathercode',
        'start_date': startDate,   // ← باید همین باشه
        'end_date': endDate,       // ← هفت روز جلوتر
        'timezone': 'auto',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<dynamic> sendRequestCitySuggestion(String prefix) async {
    var response = await _dio.get(
        "http://geodb-free-service.wirefreethought.com/v1/geo/cities",
        queryParameters: {'limit': 7, 'offset': 0, 'namePrefix': prefix});

    return response;
  }
}