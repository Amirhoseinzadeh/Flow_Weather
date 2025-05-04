

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppBackground {

  static AssetImage getBackGroundImage(String formattedDate){
    if(6 > int.parse(formattedDate)){
      return AssetImage('assets/images/nightpic.jpg');
    }else if(18 > int.parse(formattedDate)){
      return AssetImage('assets/images/pic_bg.jpg');
    }else{
      return AssetImage('assets/images/nightpic.jpg');
    }
  }

  static StatefulWidget setIconForMain(String? description) {
    if (description == null || description.isEmpty) {
      print("Description is null or empty, using default icon");
      return Image(image: AssetImage('assets/images/icons8-windy-weather-80.png'));
    }

    print("Description received: $description");

    if (description == "آفتابی") {
      return Lottie.asset('assets/lotties/sunny.json',repeat: true,
        animate: true,);
    } else if (description == "کمی ابری") {
      return Lottie.asset('assets/lotties/half_cloudy.json',repeat: true,
        animate: true,);
    } else if (description.contains("ابری")) {
      return Lottie.asset('assets/lotties/cloudy.json',repeat: true,
        animate: true,);
    } else if (description.contains("مه")) {
      return Lottie.asset('assets/lotties/fog.json',repeat: true,
        animate: true,);
    } else if (description.contains("رعد و برق")) {
      return Lottie.asset('assets/lotties/thunderstorm.json',repeat: true,
        animate: true,);
    } else if (description.contains("باران ریز")) {
      return Lottie.asset('assets/lotties/light_rain.json',repeat: true,
        animate: true,);
    } else if (description.contains("باران یخ زده")) {
      return Lottie.asset('assets/lotties/tagarg.json',repeat: true,
        animate: true,);
    } else if (description.contains("باران") ) {
      return Lottie.asset('assets/lotties/rain.json',repeat: true,
        animate: true,);
    } else if (description.contains("رگبار")) {
      return Lottie.asset('assets/lotties/storm.json',repeat: true,
        animate: true,);
    } else if (description.contains("برف")) {
      return Lottie.asset('assets/lotties/snow.json',repeat: true,
        animate: true,);
    } else if (description == "برف سبک" || description == "دانه برف") {
      return Lottie.asset('assets/lotties/light_snow.json',repeat: true,
        animate: true,);
    } else {
      print("Description '$description' not matched, using default icon");
      return Lottie.asset('assets/lotties/windy.json',repeat: true,
        animate: true,);
    }
  }
}