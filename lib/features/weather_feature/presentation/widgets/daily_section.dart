
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DailySection extends StatelessWidget {
  final List<ForecastDayEntity> forecastDays;
  const DailySection({
    super.key,
    required this.forecast, required this.forecastDays,
  });
  static const Map<String, String> _weekDayMap = {
    'Mon': 'دوشنبه',
    'Tue': 'سه‌شنبه',
    'Wed': 'چهارشنبه',
    'Thu': 'پنجشنبه',
    'Fri': 'جمعه',
    'Sat': 'شنبه',
    'Sun': 'یکشنبه',
  };


  final ForecastEntity forecast;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin:
      const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 16,
      ),
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(
          (0.18 * 255).round(),
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.only(
              right: 10,
              left: 24,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text(
                  "پیش‌بینی ۱۴ روزه",
                  style: TextStyle(
                    fontFamily:
                    "entezar",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons
                      .calendar_month_sharp,
                  color:
                  Colors
                      .grey
                      .shade300,
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: forecastDays.length,
            itemBuilder: (context, index) {
              final day = forecastDays[index];
              final date = DateTime.parse(day.date);
              final jalaliDate = Jalali.fromDateTime(date);

              final weekDayEn = DateFormat('E').format(date);
              final weekDayFa = _weekDayMap[weekDayEn] ?? weekDayEn;

              final dateLabel = '${jalaliDate.day} ${jalaliDate.formatter.mN}'; // اسم ماه به فارسی + روز

              final minTemp = day.minTempC.round();
              final maxTemp = day.maxTempC.round();
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        index == 0 ? "امروز" : weekDayFa,
                        style: const TextStyle(
                          fontFamily: "lalezar",
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Image.asset(
                      day.conditionIcon,
                      width: 35,
                      height: 35,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: width * .04),
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
                    SizedBox(width: width * .02),
                    SizedBox(
                      width: width * .09,
                      child: Text(
                        '$maxTemp°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 77,
                      child: Text(
                        maxLines: 1,
                        dateLabel,
                        style: const TextStyle(
                          fontFamily: "lalezar",
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ].animate(interval: 300.ms).scale(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}