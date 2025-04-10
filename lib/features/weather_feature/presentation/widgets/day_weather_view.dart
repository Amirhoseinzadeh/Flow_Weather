
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flutter/material.dart';

class DayWeatherView extends StatelessWidget {
  final ForecastDayEntity day;

  const DayWeatherView({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // نمایش تاریخ
          Text(
            day.date,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          // نمایش آیکون
          Image.network(
            day.conditionIcon.startsWith('//')
                ? 'https:${day.conditionIcon}'
                : day.conditionIcon,
            width: 30,
            height: 30,
          ),
          const SizedBox(height: 8),
          // نمایش دما
          Text(
            '${day.maxTempC.round()}°',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
