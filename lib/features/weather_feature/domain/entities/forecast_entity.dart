// forecast_entity.dart
import 'package:equatable/equatable.dart';

class ForecastDayEntity extends Equatable {
  final String date;
  final double minTempC;
  final double maxTempC;
  final String conditionIcon;

  const ForecastDayEntity({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.conditionIcon,
  });

  @override
  List<Object?> get props => [date, minTempC, maxTempC, conditionIcon];
}

class ForecastHourEntity extends Equatable {
  final String time;
  final double temperature;
  final String conditionIcon;

  const ForecastHourEntity({
    required this.time,
    required this.temperature,
    required this.conditionIcon,
  });

  @override
  List<Object?> get props => [time, temperature, conditionIcon];
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