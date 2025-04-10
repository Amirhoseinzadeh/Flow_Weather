import 'package:equatable/equatable.dart';

class ForecastDayEntity extends Equatable {
  final String date;           // YYYY-MM-DD
  final double maxTempC;       // دمای ماکزیمم
  final String conditionIcon;  // مسیر آیکون (assets)

  const ForecastDayEntity({
    required this.date,
    required this.maxTempC,
    required this.conditionIcon,
  });

  @override
  List<Object?> get props => [date, maxTempC, conditionIcon];
}

class ForecastHourEntity extends Equatable {
  final String time;           // YYYY-MM-DDTHH:mm
  final double temperature;    // دمای ساعت
  final String conditionIcon;  // مسیر آیکون (assets)

  const ForecastHourEntity({
    required this.time,
    required this.temperature,
    required this.conditionIcon,
  });

  @override
  List<Object?> get props => [time, temperature, conditionIcon];
}

/// ترکیب پیش‌بینی روزانه و ساعتی
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
