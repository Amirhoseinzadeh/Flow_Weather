import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DailySection extends StatelessWidget {
  final List<ForecastDayEntity> forecastDays;
  const DailySection({
    super.key,
    required this.forecastDays,
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      padding: const EdgeInsets.only(top: 14, bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha((0.18 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "پیش‌بینی ۱۴ روزه",
                  style: TextStyle(
                    fontFamily: "entezar",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.calendar_month_sharp,
                  color: Colors.grey.shade300,
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
              final dateLabel = '${jalaliDate.day} ${jalaliDate.formatter.mN}';
              final minTemp = day.minTempC.round();
              final maxTemp = day.maxTempC.round();
              return BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (p, c) => p.selectedDayIndex != c.selectedDayIndex,
                builder: (context, state) {
                  final isSelected = state.selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        context.read<HomeBloc>().add(SelectDayEvent(-1));
                      } else {
                        context.read<HomeBloc>().add(SelectDayEvent(index));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent,
                        borderRadius: isSelected
                            ? const BorderRadius.vertical(
                          top: Radius.circular(20),
                          bottom: Radius.circular(40),
                        )
                            : BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 64,
                                child: Text(
                                  index == 0 ? "امروز" : weekDayFa,
                                  style: const TextStyle(
                                    fontFamily: "nazanin",
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 17,
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
                              SizedBox(width: width * 0.04),
                              SizedBox(
                                width: width * 0.07,
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
                              SizedBox(width: width * 0.02),
                              SizedBox(
                                width: width * 0.09,
                                child: Text(
                                  '$maxTemp°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6, left: 16),
                                child: Text(
                                  dateLabel,
                                  style: const TextStyle(
                                    fontFamily: "nazanin",
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: isSelected ? 60 : 0,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius:  BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(4, 4),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: isSelected
                                  ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('سرعت باد: ${day.windSpeedMax} km/h', style: const TextStyle(color: Colors.white)),
                                    Text('رطوبت: ${day.humidity.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
                                    Text('UV:${day.uvIndex.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}