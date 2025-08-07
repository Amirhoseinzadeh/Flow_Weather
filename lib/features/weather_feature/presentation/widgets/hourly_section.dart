import 'package:flow_weather/features/weather_feature/domain/entities/forecast_entity.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:intl/intl.dart';

class HourlySection extends StatelessWidget {
  const HourlySection({
    super.key,
    required this.forecast,
  });

  final ForecastEntity forecast;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "پیش‌بینی ساعتی",
                  style: TextStyle(
                    fontFamily: "entezar",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.access_time_outlined,
                  color: Colors.grey.shade200,
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.hours.length,
              itemBuilder: (ctx, i) {
                final h = forecast.hours[i];
                return BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) => p.selectedHourIndex != c.selectedHourIndex,
                  builder: (context, state) {
                    final isSelected = state.selectedHourIndex == i;
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          context.read<HomeBloc>().add(SelectHourEvent(-1));
                        } else {
                          context.read<HomeBloc>().add(SelectHourEvent(i));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent,
                          borderRadius: isSelected
                              ? const BorderRadius.vertical(
                            top: Radius.circular(12),
                            bottom: Radius.circular(0),
                          )
                              : BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              i == 0 ? "اکنون" : DateFormat('HH:mm').format(DateTime.parse(h.time)),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 2),
                            Image.asset(h.conditionIcon, width: 30, height: 30),
                            const SizedBox(height: 2),
                            Text('${h.temperature.round()}°', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (p, c) => p.selectedHourIndex != c.selectedHourIndex,
            builder: (context, state) {
              final selectedHour = state.selectedHourIndex != null && state.selectedHourIndex! >= 0
                  ? forecast.hours[state.selectedHourIndex!]
                  : null;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: selectedHour != null ? 96 : 0, // افزایش ارتفاع برای UV
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: selectedHour != null
                      ? Padding(
                    padding: const EdgeInsets.all(8),
                    key: ValueKey(selectedHour.time),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              DateFormat('HH:mm').format(DateTime.parse(selectedHour.time)),
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Image.asset(selectedHour.conditionIcon, width: 30, height: 30),
                            Text('${selectedHour.temperature.round()}°', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(width: width *.04),

                        Row(
                          children: [
                            Column(
                              children: [
                                SizedBox(height: height *.014),
                                Text('باد: ${selectedHour.windSpeed} km/h', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white)),
                                SizedBox(height: height *.012),
                                Text('دما: ${selectedHour.temperature.round()}°', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white)),
                              ],
                            ),
                            SizedBox(width: width *.04),
                            Column(
                              children: [
                                SizedBox(height: height *.014),
                                Text('رطوبت: ${selectedHour.humidity}%', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white)),
                                SizedBox(height: height *.012),
                                Text('UV: ${selectedHour.uvIndex.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}