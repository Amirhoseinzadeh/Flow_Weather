import 'package:intl/intl.dart';

class DateConverter{

  static String changeDtToDateTime(dt){
    final formatter = DateFormat.MMMd();
    var result = formatter.format(DateTime.fromMillisecondsSinceEpoch(
        dt * 1000,
        isUtc: true));

    return result;
  }

  static String changeDtToDateTimeHour(dt, timeZone){
    final formatter = DateFormat.jm();
    return formatter.format(
        DateTime.fromMillisecondsSinceEpoch(
            (dt * 1000) +
                timeZone * 1000,
            isUtc: true));
  }


}