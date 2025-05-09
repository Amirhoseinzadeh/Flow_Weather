import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_city_status.dart';

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
        print('BookMarkIcon rebuilt: isBookmarked = $isBookmarked for city $name');

        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
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
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              key: ValueKey<bool>(isBookmarked),
            ),
          ),
          onPressed: () {
            print('Bookmark icon tapped for city: $name, isBookmarked: $isBookmarked');
            if (isBookmarked) {
              context.read<BookmarkBloc>().add(DeleteCityEvent(name));
            } else {
              context.read<BookmarkBloc>().add(SaveCityEvent(City(name: name)));
            }
            // دوباره وضعیت شهر رو بررسی کن تا آیکون آپدیت بشه
            context.read<BookmarkBloc>().add(FindCityByNameEvent(name));
          },
        );
      },
    );
  }
}