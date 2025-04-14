import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';

class ForecastNextDaysWidget extends StatelessWidget {
  final List<ForecastDayEntity> forecastDays;
  const ForecastNextDaysWidget({Key? key, required this.forecastDays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: forecastDays.length,
        itemBuilder: (context, index) {
          final day = forecastDays[index];
          final dayLabel = index == 0
              ? "Today"
              : DateFormat('E').format(DateTime.parse(day.date));
          final dateLabel = DateFormat('MMM d').format(DateTime.parse(day.date)); // فرمت تاریخ: Apr 13
          final minTemp = day.minTempC.round();
          final maxTemp = day.maxTempC.round();
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // روز هفته
                SizedBox(
                  width: width * .14,
                  child: Text(
                    dayLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                // آیکون وضعیت
                Image.asset(
                  day.conditionIcon,
                  width: 35,
                  height: 35,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: width *.04,),
                // دمای حداقل
                SizedBox(
                  width: width * .07,
                  child: Text(
                    '$minTemp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                // نوار دما
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (maxTemp - minTemp) / 25,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade500,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // دمای حداکثر
                SizedBox(width: width *.03,),
                SizedBox(
                  width: width * .1,
                  child: Text(
                    '$maxTemp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                // تاریخ (ماه و روز)
                SizedBox(
                  width: width * .13,
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}