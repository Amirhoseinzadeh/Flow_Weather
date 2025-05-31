import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_state.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/get_city_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookMarkIcon extends StatelessWidget {
  final String name;
  final double? lat;
  final double? lon;

  const BookMarkIcon({
    super.key,
    required this.name,
    this.lat,
    this.lon,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        bool isBookmarked = false;
        if (state.getCityStatus is GetCityCompleted) {
          final city = (state.getCityStatus as GetCityCompleted).city;
          isBookmarked = city != null && city.name == name;
        }

        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              size: 30,
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              key: ValueKey<bool>(isBookmarked),
            ),
          ),
          onPressed: () {
            if (isBookmarked) {
              context.read<BookmarkBloc>().add(DeleteCityEvent(name));
            } else {
              if (lat == null || lon == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مختصات شهر در دسترس نیست')),
                );
                return;
              }
              final city = City(name: name, lat: lat, lon: lon);
              context.read<BookmarkBloc>().add(SaveCityEvent(city));
            }
            context.read<BookmarkBloc>().add(FindCityByNameEvent(name));
          },
        );
      },
    );
  }
}