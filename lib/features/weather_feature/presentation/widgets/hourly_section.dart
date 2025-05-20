
import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class HourlySection extends StatelessWidget {
  const HourlySection({
    super.key,
    required this.forecast,
  });

  final ForecastEntity forecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 16,
      ),
      padding: const EdgeInsets.only(
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(
          (0.1 * 255).round(),
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
            const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text(
                  "پیش‌بینی ساعتی",
                  style: TextStyle(
                    fontFamily:
                    "entezar",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons
                      .access_time_outlined,
                  color:
                  Colors
                      .grey
                      .shade200,
                  size: 30,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection:
              Axis.horizontal,
              cacheExtent: 200,
              itemExtent: 54,
              // اندازه ثابت هر آیتم برای بهینه‌سازی رندر
              itemCount:
              forecast.hours.length,
              physics:
              const BouncingScrollPhysics(
                parent:
                AlwaysScrollableScrollPhysics(),
              ),
              // اسکرول روان‌تر
              itemBuilder: (ctx, i) {
                final h =
                forecast.hours[i];
                final lbl = DateFormat(
                  'HH:mm',
                ).format(
                  DateTime.parse(
                    h.time,
                  ),
                );
                return Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children:
                  [
                    Text(
                      i == 0
                          ? "اکنون"
                          : lbl,
                      style: const TextStyle(
                        color:
                        Colors
                            .white70,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Image.asset(
                      h.conditionIcon,
                      width: 30,
                      height: 30,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) => const Icon(
                        Icons
                            .error,
                        color:
                        Colors.red,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${h.temperature.round()}°',
                      style: const TextStyle(
                        color:
                        Colors
                            .white,
                      ),
                    ),
                  ].animate(interval: 300.ms).scale(), // افزایش interval برای کاهش فشار
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}