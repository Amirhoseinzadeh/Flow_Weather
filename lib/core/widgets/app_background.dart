

import 'package:flutter/material.dart';

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

  static Image setIconForMain(String? description) {
    if (description == null || description.isEmpty) {
      print("Description is null or empty, using default icon");
      return Image(image: AssetImage('assets/images/icons8-windy-weather-80.png'));
    }

    print("Description received: $description");

    if (description == "آفتابی") {
      return Image(image: AssetImage('assets/images/icons8-sun-96.png'));
    } else if (description == "کمی ابری") {
      return Image(image: AssetImage('assets/images/icons8-partly-cloudy-day-80.png'));
    } else if (description.contains("ابری")) {
      return Image(image: AssetImage('assets/images/icons8-clouds-80.png'));
    } else if (description.contains("رعد و برق")) {
      return Image(image: AssetImage('assets/images/icons8-storm-80.png'));
    } else if (description.contains("باران ریز")) {
      return Image(image: AssetImage('assets/images/icons8-rain-cloud-80.png'));
    } else if (description.contains("باران") || description.contains("رگبار")) {
      return Image(image: AssetImage('assets/images/icons8-heavy-rain-80.png'));
    } else if (description.contains("برف") || description.contains("دانه برف")) {
      return Image(image: AssetImage('assets/images/icons8-snow-80.png'));
    } else {
      print("Description '$description' not matched, using default icon");
      return Image(image: AssetImage('assets/images/icons8-windy-weather-80.png'));
    }
  }
}