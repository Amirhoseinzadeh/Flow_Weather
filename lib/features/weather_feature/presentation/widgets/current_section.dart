import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CurrentSection extends StatelessWidget {
  const CurrentSection({
    super.key,
    required this.cityName,
    required this.city,
    required this.minTemp,
    required this.temp,
    required this.maxTemp,
  });

  final String cityName;
  final MeteoCurrentWeatherEntity city;
  final double minTemp;
  final int temp;
  final double maxTemp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Text(
            cityName,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: "Titr",
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
            style: const TextStyle(
              fontFamily: "Titr",
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: AppBackground.setIconForMain(
              city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "حداقل دما",
                    style: TextStyle(
                      fontFamily: "entezar",
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${minTemp.round()}°",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$temp°',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Column(
                children: [
                  const Text(
                    "حداکثر دما",
                    style: TextStyle(
                      fontFamily: "entezar",
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${maxTemp.round()}°",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ].animate(interval: 300.ms).scale(),
      ),
    );
  }
}