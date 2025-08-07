import 'package:equatable/equatable.dart';

class ForecastDayEntity extends Equatable {
  final String date;
  final double minTempC;
  final double maxTempC;
  final String conditionIcon;
  final double precipitationSum; // مجموع بارش روزانه (میلی‌متر)
  final double windSpeedMax;     // حداکثر سرعت باد (متر بر ثانیه)
  final double uvIndex;          // شاخص UV
  final double humidity;         // رطوبت نسبی روزانه (درصد)

  const ForecastDayEntity({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.conditionIcon,
    required this.precipitationSum,
    required this.windSpeedMax,
    required this.uvIndex,
    required this.humidity,
  });

  @override
  List<Object?> get props => [date, minTempC, maxTempC, conditionIcon, precipitationSum, windSpeedMax, uvIndex, humidity];
}

class ForecastHourEntity extends Equatable {
  final String time;
  final double temperature;
  final String conditionIcon;
  final double precipitationProbability; // احتمال بارش (درصد)
  final double windSpeed;                // سرعت باد (متر بر ثانیه)
  final double humidity;                 // رطوبت نسبی (درصد)
  final double uvIndex;                  // شاخص UV

  const ForecastHourEntity({
    required this.time,
    required this.temperature,
    required this.conditionIcon,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.humidity,
    required this.uvIndex,
  });

  @override
  List<Object?> get props => [time, temperature, conditionIcon, precipitationProbability, windSpeed, humidity, uvIndex];
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