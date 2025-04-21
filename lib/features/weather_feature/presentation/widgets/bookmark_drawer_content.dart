import 'dart:ui';
import 'package:flow_weather/core/utils/load_city_weather.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_state.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_all_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarkDrawerContent extends StatelessWidget {
  const BookmarkDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BookmarkBloc>().add(GetAllCitiesEvent());
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: BlocBuilder<BookmarkBloc, BookmarkState>(
        buildWhen: (prev, curr) => prev.getAllCityStatus != curr.getAllCityStatus,
        builder: (context, state) {
          if (state.getAllCityStatus is GetAllCityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.getAllCityStatus is GetAllCityError) {
            final err = state.getAllCityStatus as GetAllCityError;
            return Center(child: Text(err.message ?? 'خطا', style: const TextStyle(color: Colors.white)));
          }
          final cities = (state.getAllCityStatus as GetAllCityCompleted).cities;
          if (cities.isEmpty) {
            return const Center(child: Text("هیچ شهری بوکمارک نشده است", style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipPath(
                  child: Container(
                    width: width,
                    height: 55.0,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: ListTile(
                      title: Text(city.name, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () {
                          context.read<BookmarkBloc>().add(DeleteCityEvent(city.name));
                          context.read<BookmarkBloc>().add(GetAllCitiesEvent());
                          final cwStatus = context.read<HomeBloc>().state.cwStatus;
                          if (cwStatus is CwCompleted && cwStatus.meteoCurrentWeatherEntity.name == city.name) {
                            context.read<BookmarkBloc>().add(FindCityByNameEvent(city.name));
                          }
                        },
                      ),
                      onTap: () async {
                        print('نام شهر انتخاب‌شده: ${city.name}');
                        await loadCityWeather(context, city.name);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}