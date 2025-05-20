// forecast_model.dart
import 'dart:math';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.days,
    required super.hours,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    // --- نگاشت روزانه ---
    final daily = json['daily'];
    final timesD = daily['time'] as List;
    final tempsMaxD = daily['temperature_2m_max'] as List;
    final tempsMinD = daily['temperature_2m_min'] as List;
    final codesD = daily['weathercode'] as List;

    final days = List<ForecastDayEntity>.generate(timesD.length, (i) {
      return ForecastDayEntity(
        date: timesD[i] as String,
        minTempC: (tempsMinD[i] as num).toDouble(),
        maxTempC: (tempsMaxD[i] as num).toDouble(),
        conditionIcon: _mapWeatherCodeToIcon(codesD[i] as int),
      );
    });

    // --- نگاشت ساعتی از ساعت کنونی ---
    final hourly = json['hourly'];
    final timesH = hourly['time'] as List;
    final tempsH = hourly['temperature_2m'] as List;
    final codesH = hourly['weathercode'] as List;

    final dateTimes = timesH.map((t) => DateTime.parse(t as String)).toList();
    final now = DateTime.now();
    final nowRounded = DateTime(now.year, now.month, now.day, now.hour);

    int startIndex = dateTimes.indexWhere((dt) => dt.isAfter(nowRounded) || dt.isAtSameMomentAs(nowRounded));
    if (startIndex < 0) startIndex = 0;

    final count = min(dateTimes.length - startIndex, 24);

    final hours = List<ForecastHourEntity>.generate(count, (i) {
      final idx = startIndex + i;
      return ForecastHourEntity(
        time: timesH[idx] as String,
        temperature: (tempsH[idx] as num).toDouble(),
        conditionIcon: _mapWeatherCodeToIcon(codesH[idx] as int),
      );
    });

    return ForecastModel(days: days, hours: hours);
  }
}

String _mapWeatherCodeToIcon(int code) {
  if (code == 0) {
    return "assets/images/icons8-sun-96.png";
  } else if (code >= 1 && code <= 3) {
    return "assets/images/icons8-partly-cloudy-day-80.png";
  } else if (code == 45 || code == 48) {
    return "assets/images/icons8-clouds-80.png";
  } else if (code >= 51 && code <= 57) {
    return "assets/images/icons8-clouds-80.png";
  } else if (code >= 61 && code <= 67) {
    return "assets/images/icons8-heavy-rain-80.png";
  } else if (code >= 71 && code <= 77) {
    return "assets/images/icons8-snow-80.png";
  } else if (code >= 80 && code <= 82) {
    return "assets/images/icons8-heavy-rain-80.png";
  } else if (code >= 85 && code <= 86) {
    return "assets/images/icons8-snow-80.png";
  } else if (code == 95) {
    return "assets/images/icons8-storm-80.png";
  } else if (code == 96 || code == 99) {
    return "assets/images/icons8-storm-80.png";
  } else {
    return "assets/images/icons8-windy-weather-80.png";
  }
}