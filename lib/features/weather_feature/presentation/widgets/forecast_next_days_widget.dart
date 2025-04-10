import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastNextDaysWidget extends StatelessWidget {
  final List<ForecastDayEntity> forecastDays;
  const ForecastNextDaysWidget({Key? key, required this.forecastDays})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastDays.length,
        itemBuilder: (context, i) {
          final day = forecastDays[i];
          final dateLabel = DateFormat('MMM dd')
              .format(DateTime.parse(day.date));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dateLabel, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Image.asset(
                  day.conditionIcon,
                  width: 50,
                  height: 50,
                  errorBuilder: (c, e, s) =>
                  const Icon(Icons.error, color: Colors.red),
                ),
                const SizedBox(height: 6),
                Text('${day.maxTempC.round()}°',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}

