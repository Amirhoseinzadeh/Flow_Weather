import 'package:flow_weather/features/weather_feature/domain/entities/air_quality_entity.dart';

class AirQualityModel extends AirQualityEntity {
  AirQualityModel({
    required double pm25,
    required double pm10,
    required double ozone,
    double? co,
    double? no2,
    double? so2,
  }) : super(pm25: pm25, pm10: pm10, ozone: ozone, co: co, no2: no2, so2: so2);

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    try {
      final current = json['current'];
      print('Current Data: $current');

      if (current == null) {
        throw Exception('داده‌های current وجود ندارد');
      }

      final pm25 = current['pm2_5'] as num? ?? 0.0;
      final pm10 = current['pm10'] as num? ?? 0.0;
      final ozone = current['ozone'] as num? ?? 0.0;
      final co = current['carbon_monoxide'] as num?;
      final no2 = current['nitrogen_dioxide'] as num?;
      final so2 = current['sulphur_dioxide'] as num?;

      print('مقادیر پارس‌شده: PM2.5=$pm25, PM10=$pm10, Ozone=$ozone, CO=$co, NO2=$no2, SO2=$so2');

      return AirQualityModel(
        pm25: pm25.toDouble(),
        pm10: pm10.toDouble(),
        ozone: ozone.toDouble(),
        co: co?.toDouble(),
        no2: no2?.toDouble(),
        so2: so2?.toDouble(),
      );
    } catch (e) {
      print('Error parsing air quality data: $e');
      throw Exception('خطا در پارس کردن داده‌های کیفیت هوا: $e');
    }
  }

  // تابع محاسبه AQI برای یه آلاینده
  static int _calculateAqi(double concentration, List<double> concentrationBreakpoints, List<int> aqiBreakpoints) {
    print('محاسبه AQI برای غلظت: $concentration');
    // اگه غلظت صفر یا منفی باشه، AQI باید 0 باشه
    if (concentration <= 0) {
      print('غلظت صفر یا منفی است، AQI=0');
      return 0;
    }

    // اگه غلظت توی بازه‌ها قرار نگیره، باید درست مدیریت بشه
    for (int i = 0; i < concentrationBreakpoints.length - 1; i++) {
      if (concentration > concentrationBreakpoints[i] && concentration <= concentrationBreakpoints[i + 1]) {
        print('بازه انتخاب‌شده: ${concentrationBreakpoints[i]} - ${concentrationBreakpoints[i + 1]}');
        double cLow = concentrationBreakpoints[i];
        double cHigh = concentrationBreakpoints[i + 1];
        int aqiLow = aqiBreakpoints[i];
        int aqiHigh = aqiBreakpoints[i + 1];
        int calculatedAqi = ((aqiHigh - aqiLow) / (cHigh - cLow) * (concentration - cLow) + aqiLow).round();
        print('AQI محاسبه‌شده: $calculatedAqi');
        return calculatedAqi;
      }
    }

    // اگه غلظت از آخرین بازه بیشتر باشه، حداکثر AQI رو برگردون
    print('غلظت از آخرین بازه بیشتر است، AQI=${aqiBreakpoints.last}');
    return aqiBreakpoints.last;
  }

  // محاسبه AQI برای PM2.5
  int _calculatePm25Aqi() {
    final concentrationBreakpoints = [0.0, 12.0, 35.4, 55.4, 150.4, 250.4, 500.4];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(pm25, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI برای PM10
  int _calculatePm10Aqi() {
    final concentrationBreakpoints = [0.0, 54.0, 154.0, 254.0, 354.0, 424.0, 604.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(pm10, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI برای ازون (تبدیل µg/m³ به ppb)
  int _calculateOzoneAqi() {
    double ozonePpb = ozone / 2; // تقریباً 1 µg/m³ = 0.5 ppb برای ازون
    print('ازون به ppb تبدیل شد: $ozonePpb');
    final concentrationBreakpoints = [0.0, 54.0, 70.0, 85.0, 105.0, 200.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300];
    return _calculateAqi(ozonePpb, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI برای CO (تبدیل µg/m³ به ppm)
  int? _calculateCoAqi() {
    if (co == null) return null;
    double coPpm = co! * 0.000873; // فرمول درست: µg/m³ به ppm برای CO
    print('CO به ppm تبدیل شد: $coPpm');
    final concentrationBreakpoints = [0.0, 4.4, 9.4, 12.4, 15.4, 30.4, 50.4];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(coPpm, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI برای NO2 (ppb, برای 1 ساعت)
  int? _calculateNo2Aqi() {
    if (no2 == null) return null;
    double no2Ppb = no2! * 0.532;
    print('NO2 به ppb تبدیل شد: $no2Ppb');
    final concentrationBreakpoints = [0.0, 53.0, 100.0, 360.0, 649.0, 1249.0, 2049.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(no2Ppb, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI برای SO2 (ppb, برای 1 ساعت)
  int? _calculateSo2Aqi() {
    if (so2 == null) return null;
    double so2Ppb = so2! * 0.382;
    print('SO2 به ppb تبدیل شد: $so2Ppb');
    final concentrationBreakpoints = [0.0, 35.0, 75.0, 185.0, 304.0, 604.0, 1004.0];
    final aqiBreakpoints = [0, 50, 100, 150, 200, 300, 500];
    return _calculateAqi(so2Ppb, concentrationBreakpoints, aqiBreakpoints);
  }

  // محاسبه AQI نهایی و دسته‌بندی
  Map<String, dynamic> calculateAqi() {
    print('شروع محاسبه AQI برای: PM2.5=$pm25, PM10=$pm10, Ozone=$ozone');
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

    print('مقادیر AQI محاسبه‌شده: $aqiValues');
    int overallAqi = aqiValues.reduce((a, b) => a > b ? a : b);
    String dominantPollutant = pollutants[aqiValues.indexOf(overallAqi)];

    String category;
    if (overallAqi <= 50) {
      category = 'خوب';
    } else if (overallAqi <= 100) {
      category = 'متوسط';
    } else if (overallAqi <= 150) {
      category = 'ناسالم برای گروه‌های حساس';
    } else if (overallAqi <= 200) {
      category = 'ناسالم';
    } else if (overallAqi <= 300) {
      category = 'خیلی ناسالم';
    } else {
      category = 'خطرناک';
    }

    print('AQI نهایی: $overallAqi, دسته‌بندی: $category, آلاینده غالب: $dominantPollutant');
    return {
      'aqi': overallAqi,
      'category': category,
      'dominantPollutant': dominantPollutant,
    };
  }
}