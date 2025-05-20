import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';

class AirQualityModel extends AirQualityEntity {
  const AirQualityModel({
    required super.pm25,
    required super.pm10,
    required super.ozone,
    super.co,
    super.no2,
    super.so2,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    try {
      final current = json['current'];


      if (current == null) {
        throw Exception('داده‌های current وجود ندارد');
      }

      final pm25 = current['pm2_5'] as num? ?? 0.0;
      final pm10 = current['pm10'] as num? ?? 0.0;
      final ozone = current['ozone'] as num? ?? 0.0;
      final co = current['carbon_monoxide'] as num?;
      final no2 = current['nitrogen_dioxide'] as num?;
      final so2 = current['sulphur_dioxide'] as num?;


      return AirQualityModel(
        pm25: pm25.toDouble(),
        pm10: pm10.toDouble(),
        ozone: ozone.toDouble(),
        co: co?.toDouble(),
        no2: no2?.toDouble(),
        so2: so2?.toDouble(),
      );
    } catch (e) {
      throw Exception('خطا در پارس کردن داده‌های کیفیت هوا: $e');
    }
  }

  static int _calculateAqi(double concentration, List<double> concentrationBreakpoints, List<int> aqiBreakpoints) {


    if (concentration <= 0) {
      return 0;
    }

    for (int i = 0; i < concentrationBreakpoints.length - 1; i++) {
      if (concentration > concentrationBreakpoints[i] && concentration <= concentrationBreakpoints[i + 1]) {

        double cLow = concentrationBreakpoints[i];
        double cHigh = concentrationBreakpoints[i + 1];
        int aqiLow = aqiBreakpoints[i];
        int aqiHigh = aqiBreakpoints[i + 1];
        int calculatedAqi = ((aqiHigh - aqiLow) / (cHigh - cLow) * (concentration - cLow) + aqiLow).round();

        return calculatedAqi;
      }
    }
    return aqiBreakpoints.last;
  }

  int _calculatePm25Aqi() {
    final concentrationBreakpoints = [0.0, 12.0, 35.4, 55.4, 150.4, 250.4, 500.4];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(pm25, concentrationBreakpoints, aqiBreakpoints);
  }

  int _calculatePm10Aqi() {
    final concentrationBreakpoints = [0.0, 54.0, 154.0, 254.0, 354.0, 424.0, 604.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(pm10, concentrationBreakpoints, aqiBreakpoints);
  }

  int _calculateOzoneAqi() {
    double ozonePpb = ozone / 2;
    final concentrationBreakpoints = [0.0, 54.0, 70.0, 85.0, 105.0, 200.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300];
    return _calculateAqi(ozonePpb, concentrationBreakpoints, aqiBreakpoints);
  }


  int? _calculateCoAqi() {
    if (co == null) return null;
    double coPpm = co! * 0.000873;
    final concentrationBreakpoints = [0.0, 4.4, 9.4, 12.4, 15.4, 30.4, 50.4];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(coPpm, concentrationBreakpoints, aqiBreakpoints);
  }


  int? _calculateNo2Aqi() {
    if (no2 == null) return null;
    double no2Ppb = no2! * 0.532;
    final concentrationBreakpoints = [0.0, 53.0, 100.0, 360.0, 649.0, 1249.0, 2049.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(no2Ppb, concentrationBreakpoints, aqiBreakpoints);
  }

  int? _calculateSo2Aqi() {
    if (so2 == null) return null;
    double so2Ppb = so2! * 0.382;
    final concentrationBreakpoints = [0.0, 35.0, 75.0, 185.0, 304.0, 604.0, 1004.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(so2Ppb, concentrationBreakpoints, aqiBreakpoints);
  }


  Map<String, dynamic> calculateAqi() {
    List<int> aqiValues = [];
    List<String> pollutants = [];

    aqiValues.add(_calculatePm25Aqi());
    pollutants.add('PM2.5');
    aqiValues.add(_calculatePm10Aqi());
    pollutants.add('PM10');
    aqiValues.add(_calculateOzoneAqi());
    pollutants.add('Ozone');
    if (co != null) {
      aqiValues.add(_calculateCoAqi()!);
      pollutants.add('CO');
    }
    if (no2 != null) {
      aqiValues.add(_calculateNo2Aqi()!);
      pollutants.add('NO2');
    }
    if (so2 != null) {
      aqiValues.add(_calculateSo2Aqi()!);
      pollutants.add('SO2');
    }

    int overallAqi = aqiValues.reduce((a, b) => a > b ? a : b);
    String dominantPollutant = pollutants[aqiValues.indexOf(overallAqi)];

    String category;
    if (overallAqi <= 50) {
      category = 'خوب';
    } else if (overallAqi <= 100) {
      category = 'متوسط';
    } else if (overallAqi <= 150) {
      category = 'متوسط';
    } else if (overallAqi <= 200) {
      category = 'ناسالم';
    } else if (overallAqi <= 300) {
      category = 'ناسالم';
    } else {
      category = 'خطرناک';
    }

    return {
      'aqi': overallAqi,
      'category': category,
      'dominantPollutant': dominantPollutant,
    };
  }
}