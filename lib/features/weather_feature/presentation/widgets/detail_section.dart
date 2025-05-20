import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/aq_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.width,
    required DetailCubit detailCubit,
    required this.city,
    required this.minTemp,
    required this.maxTemp,
    required this.sunrise,
    required this.sunset,
    required this.aqStatus,
  }) : _detailCubit = detailCubit;

  final double width;
  final DetailCubit _detailCubit;
  final MeteoCurrentWeatherEntity city;
  final double minTemp;
  final double maxTemp;
  final String sunrise;
  final String sunset;
  final dynamic aqStatus;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, bool>(
      builder: (context, isExpanded) {
        return ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: width * 0.1),
              const Text(
                'جزئیات',
                style: TextStyle(
                  fontFamily: "entezar",
                  fontSize: 22,
                  color: Colors.orangeAccent,
                ),
              ).animate(
                target: isExpanded ? 1 : 0,
                effects: [
                  ScaleEffect(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 400),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white70,
                size: 26,
              ),
            ],
          ),
          trailing: const SizedBox.shrink(),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          onExpansionChanged: (expanded) {
            _detailCubit.toggleDetail();
          },
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRow1(isExpanded),
                const SizedBox(height: 8),
                _buildRow2(isExpanded),
                const SizedBox(height: 8),
                _buildRow3(isExpanded),
                SizedBox(height: 8),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow1(bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "سرعت باد",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.yellow,
              ),
            ),
            Text(
              "${city.wind?.speed?.toStringAsFixed(1) ?? '0'} km/h",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(
          color: Colors.white24,
          height: 31,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Column(
          children: [
            const Text(
              "حداقل دما",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.yellow,
              ),
            ),
            Text(
              "${minTemp.round()}°",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(
          color: Colors.white24,
          height: 30,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Column(
          children: [
            const Text(
              "حداکثر دما",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.yellow,
              ),
            ),
            Text(
              "${maxTemp.round()}°",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(
          color: Colors.white24,
          height: 30,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Column(
          children: [
            const Text(
              "رطوبت",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.yellow,
              ),
            ),
            Text(
              "${city.main?.humidity ?? 0}%",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    ).animate(
      target: isExpanded ? 1 : 0,
      effects: [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildRow2(bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "فشار",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.amberAccent,
              ),
            ),
            Text(
              "${city.main?.pressure ?? 0} hPa",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(
          color: Colors.white24,
          height: 30,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        if (aqStatus is AirQualityLoading)
          const SizedBox(
            height: 50,
            child: Center(child: DotLoadingWidget()),
          ),
        if (aqStatus is AirQualityError)
          Text(
            'خطا در بارگذاری کیفیت هوا: ${(aqStatus as AirQualityError).message}',
            style: const TextStyle(fontFamily: "nikoo", color: Colors.red),
          ),
        if (aqStatus is AirQualityCompleted)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "کیفیت هوا",
                style: TextStyle(
                  fontFamily: "nikoo",
                  fontSize: 18,
                  color: Colors.amberAccent,
                ),
              ),
              Text(
                'AQI: ${(aqStatus as AirQualityCompleted).aqi} (${(aqStatus as AirQualityCompleted).category})',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        Container(
          color: Colors.white24,
          height: 30,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Column(
          children: [
            const Text(
              "اشعه UV",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.amberAccent,
              ),
            ),
            Text(
              city.uvIndex?.toStringAsFixed(1) ?? '0',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    ).animate(
      target: isExpanded ? 1 : 0,
      effects: [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildRow3(bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "طلوع",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.amber,
              ),
            ),
            Text(
              sunrise,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(
          color: Colors.white24,
          height: 30,
          width: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Column(
          children: [
            const Text(
              "غروب",
              style: TextStyle(
                fontFamily: "nikoo",
                fontSize: 18,
                color: Colors.amber,
              ),
            ),
            Text(
              sunset,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],

    ).animate(
      target: isExpanded ? 1 : 0,
      effects: [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}