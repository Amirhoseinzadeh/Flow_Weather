import 'dart:ui';
import 'package:flow_weather/core/utils/load_city_weather.dart';
import 'package:flow_weather/features/bookmark_feature/domain/entities/city.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_state.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/get_all_city_status.dart';

class BookmarkScreen extends StatefulWidget {
  final PageController pageController;

  const BookmarkScreen({super.key, required this.pageController});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(GetAllCitiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        buildWhen: (previous, current) {
          return previous.getAllCityStatus != current.getAllCityStatus;
        },
        builder: (context, state) {
          if (state.getAllCityStatus is GetAllCityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.getAllCityStatus is GetAllCityCompleted) {
            final getAllCityCompleted = state.getAllCityStatus as GetAllCityCompleted;
            final List<City> cities = getAllCityCompleted.cities;

            return SafeArea(
              child: Column(
                children: [
                  const Text(
                    'WatchList',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: cities.isEmpty
                        ? const Center(
                      child: Text(
                        'هیچ شهری بوکمارک نشده است',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                        : ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return GestureDetector(
                          onTap: () async {
                            await loadCityWeather(context, city.name);
                            widget.pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  width: width,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          city.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            context.read<BookmarkBloc>().add(DeleteCityEvent(city.name));
                                            context.read<BookmarkBloc>().add(GetAllCitiesEvent());
                                            final homeState = context.read<HomeBloc>().state.cwStatus;
                                            if (homeState is CwCompleted && homeState.meteoCurrentWeatherEntity.name == city.name) {
                                              context.read<BookmarkBloc>().add(FindCityByNameEvent(city.name));
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.getAllCityStatus is GetAllCityError) {
            final getAllCityError = state.getAllCityStatus as GetAllCityError;
            return Center(child: Text(getAllCityError.message ?? 'خطا', style: const TextStyle(color: Colors.white)));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
