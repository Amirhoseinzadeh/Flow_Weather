import 'dart:ui';
import 'package:flow_weather/core/utils/load_city_weather.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_state.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_all_city_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class BookmarkDrawerContent extends StatelessWidget {
  const BookmarkDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BookmarkBloc>().add(GetAllCitiesEvent());
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          // Item for getting current location
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, curr) => prev.isLocationLoading != curr.isLocationLoading,
            builder: (context, state) {
              final isLoading = state.isLocationLoading;
              return ListTile(
                leading: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.my_location, color: Colors.white),
                title: const Text(
                  'دریافت لوکیشن کنونی',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: isLoading
                    ? null
                    : () {
                  // فعال کردن حالت لودینگ و درخواست موقعیت
                  context.read<HomeBloc>().add(const SetLocationLoading(true));
                  context.read<HomeBloc>().getCurrentLocation(context, forceRequest: true);
                },
              );
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              buildWhen: (prev, curr) => prev.getAllCityStatus != curr.getAllCityStatus || prev.loadingIndex != curr.loadingIndex,
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
                    final isLoading = state.loadingIndex == index;
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
                          child: isLoading
                              ? Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[300]!,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                color: Colors.white.withOpacity(.2),
                              ),
                              child: ListTile(
                                title: Text(city.name, style: const TextStyle(color: Colors.white)),
                                trailing: const Icon(Icons.remove_circle, color: Colors.redAccent),
                              ),
                            ),
                          )
                              : ListTile(
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
                              context.read<BookmarkBloc>().add(LoadCityWeatherEvent(index));
                              await loadCityWeather(context, city.name, lat: city.lat, lon: city.lon);
                              // دراور توسط HomeScreen بسته می‌شه
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}