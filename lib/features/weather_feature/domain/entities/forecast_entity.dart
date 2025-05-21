// forecast_entity.dart
import 'package:equatable/equatable.dart';

class ForecastDayEntity extends Equatable {
  final String date;
  final double minTempC;
  final double maxTempC;
  final String conditionIcon;
  final double precipitationSum; // مجموع بارش روزانه (میلی‌متر)
  final double windSpeedMax;     // حداکثر سرعت باد (متر بر ثانیه)

  const ForecastDayEntity({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.conditionIcon,
    required this.precipitationSum,
    required this.windSpeedMax,
  });

  @override
  List<Object?> get props => [date, minTempC, maxTempC, conditionIcon, precipitationSum, windSpeedMax];
}

class ForecastHourEntity extends Equatable {
  final String time;
  final double temperature;
  final String conditionIcon;
  final double precipitationProbability; // احتمال بارش (درصد)
  final double windSpeed;                // سرعت باد (متر بر ثانیه)
  final double humidity;                 // رطوبت نسبی (درصد)

  const ForecastHourEntity({
    required this.time,
    required this.temperature,
    required this.conditionIcon,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.humidity,
  });

  @override
  List<Object?> get props => [time, temperature, conditionIcon, precipitationProbability, windSpeed, humidity];
}

class ForecastEntity extends Equatable {
  final List<ForecastDayEntity> days;
  final List<ForecastHourEntity> hours;

  const ForecastEntity({
    required this.days,
    required this.hours,
  });

  @override
  List<Object?> get props => [days, hours];
}