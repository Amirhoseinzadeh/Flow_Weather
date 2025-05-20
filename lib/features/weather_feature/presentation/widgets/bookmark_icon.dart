import 'package:flow_weather/features/weather_feature/domain/entities/city.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_state.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/get_city_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookMarkIcon extends StatelessWidget {
  final String name;

  const BookMarkIcon({super.key, required this.name});

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
              context.read<BookmarkBloc>().add(SaveCityEvent(City(name: name)));
            }
            context.read<BookmarkBloc>().add(FindCityByNameEvent(name));
          },
        );
      },
    );
  }
}