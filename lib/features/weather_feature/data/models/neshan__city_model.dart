// neshan_city_model.dart
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';

class NeshanCityModel extends NeshanCityEntity {
  const NeshanCityModel({
    super.count,
    super.items,
  });

  factory NeshanCityModel.fromJson(dynamic json) {
    List<NeshanCityItem> items = [];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        final locationJson = v['location'];
        items.add(NeshanCityItem(
          title: v['title'],
          address: v['address'],
          location: locationJson != null
              ? Location(
            x: locationJson['x']?.toDouble(),
            y: locationJson['y']?.toDouble(),
          )
              : null,
        ));
      });
    }

    return NeshanCityModel(
      count: json['count'],
      items: items,
    );
  }
}