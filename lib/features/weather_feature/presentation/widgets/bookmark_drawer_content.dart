// lib/features/weather_feature/presentation/widgets/bookmark_drawer.dart

import 'dart:ui';

import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_all_city_status.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/screens/bookmark_screen.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';

class BookmarkDrawerContent extends StatelessWidget {
  const BookmarkDrawerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // وقتی Drawer باز می‌شه، لیست بوکمارک‌ها رو لود کن
    context.read<BookmarkBloc>().add(GetAllCityEvent());
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: BlocBuilder<BookmarkBloc, BookmarkState>(
        buildWhen: (prev, curr) =>
        prev.getAllCityStatus != curr.getAllCityStatus,
        builder: (context, state) {
          if (state.getAllCityStatus is GetAllCityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.getAllCityStatus is GetAllCityError) {
            final err = state.getAllCityStatus as GetAllCityError;
            return Center(child: Text(err.message!));
          }
          // Completed
          final cities = (state.getAllCityStatus as GetAllCityCompleted).cities;
          if (cities.isEmpty) {
            return const Center(child: Text("No bookmarked cities"));
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(20)),
                        color:
                        Colors.grey.withOpacity(0.2)),
                    child: ListTile(
                      title: Text(city.name,style: TextStyle(color: Colors.white),),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () {
                          // ۱) حذف از DB
                          context.read<BookmarkBloc>().add(DeleteCityEvent(city.name));
                          // ۲) رفرش لیست
                          context.read<BookmarkBloc>().add(GetAllCityEvent());
                          // ۳) اگر HomeScreen داره همین شهر رو نشون می‌ده، آیکنش رو آپدیت کن
                          final cwStatus = context.read<HomeBloc>().state.cwStatus;
                          if (cwStatus is CwCompleted &&
                              cwStatus.currentCityEntity.name == city.name) {
                            context
                                .read<BookmarkBloc>()
                                .add(GetCityByNameEvent(city.name));
                          }
                        },
                      ),
                      onTap: () async {
                        // وقتی کاربر روی نام شهر زد، دیتا رو لود کن و Drawer رو ببند
                        final latLon = await getCoordinatesFromCityName(city.name);
                        context
                            .read<HomeBloc>()
                            .add(LoadCwEvent(city.name));
                        context
                            .read<HomeBloc>()
                            .add(LoadFwEvent(ForecastParams(latLon.latitude, latLon.longitude)));
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
