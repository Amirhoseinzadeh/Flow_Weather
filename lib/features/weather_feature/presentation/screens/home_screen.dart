import 'package:flow_weather/features/weather_feature/data/models/suggest_city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_drawer_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/utils/date_converter.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_icon.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/forecast_next_days_widget.dart';
import 'package:flow_weather/locator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  static const _initialCity = "Amol";

  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  bool _isForecastLoaded = false;

  final _homeBloc = locator<HomeBloc>()..add(LoadCwEvent(_initialCity));
  final _bookmarkBloc = locator<BookmarkBloc>();
  final _suggestionUseCase = locator<GetSuggestionCityUseCase>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchController.clear();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _searchController.text.length,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final now = DateTime.now();
    final hourStr = DateFormat('kk').format(now);
    final bgImage = AppBackground.getBackGroundImage(hourStr);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _bookmarkBloc),
      ],
      child: Scaffold(
        drawer: Drawer(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/4.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const BookmarkDrawerContent(),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/5.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ——— Search Row ———
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Builder(builder: (ctx) {
                        return IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        );
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TypeAheadField<Data>(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            suggestionsCallback: (pattern) => _suggestionUseCase(pattern),
                            itemBuilder: (context, Data model) {
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(model.name ?? ''),
                                subtitle: Text('${model.region ?? ''}, ${model.country ?? ''}'),
                              );
                            },
                            builder: (context, TextEditingController controller, FocusNode focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Enter a City...",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white38),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onTap: () {
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    controller.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: controller.text.length,
                                    );
                                  });
                                },
                                onChanged: (value) {
                                  controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: controller.text.length),
                                  );
                                },
                                onSubmitted: (value) {
                                  context.read<HomeBloc>().add(LoadCwEvent(value));
                                },
                              );
                            },
                            onSelected: (Data model) async {
                              FocusScope.of(context).unfocus();
                              _searchController.text = model.name ?? '';
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _searchController.text.length),
                              );
                              final latLon = await getCoordinatesFromCityName(model.name!);
                              context.read<HomeBloc>().add(LoadCwEvent(model.name!));
                              context.read<HomeBloc>().add(
                                LoadFwEvent(ForecastParams(latLon.latitude, latLon.longitude)),
                              );
                            },
                            loadingBuilder: (context) => const SizedBox.shrink(),
                            emptyBuilder: (context) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (p, c) => p.cwStatus != c.cwStatus,
                        builder: (context, state) {
                          if (state.cwStatus is CwCompleted) {
                            final name = (state.cwStatus as CwCompleted).currentCityEntity.name!;
                            _bookmarkBloc.add(GetCityByNameEvent(name));
                            return BookMarkIcon(name: name);
                          }
                          if (state.cwStatus is CwLoading) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),

                // ——— Current Weather & Forecast ———
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) => p.cwStatus != c.cwStatus || p.fwStatus != c.fwStatus,
                  builder: (context, state) {
                    if (state.cwStatus is CwLoading) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: DotLoadingWidget()),
                      );
                    }
                    if (state.cwStatus is CwError) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red, size: 36),
                        ),
                      );
                    }
                    if (state.cwStatus is CwCompleted) {
                      final city = (state.cwStatus as CwCompleted).currentCityEntity;
                      if (!_isForecastLoaded) {
                        _homeBloc.add(LoadFwEvent(ForecastParams(
                          city.coord!.lat!,
                          city.coord!.lon!,
                        )));
                        _isForecastLoaded = true;
                      }
                      final sunrise = DateConverter.changeDtToDateTimeHour(city.sys!.sunrise, city.timezone);
                      final sunset = DateConverter.changeDtToDateTimeHour(city.sys!.sunset, city.timezone);

                      return Column(
                        children: [
                          // — Current City Info —
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 16),
                            padding: const EdgeInsets.all(5),
                            // decoration: BoxDecoration(
                            //   color: Colors.grey.withOpacity(.05),
                            //   borderRadius: BorderRadius.circular(16),
                            // ),
                            child: Column(
                              children: [
                                Text(city.name ?? '', style: const TextStyle(fontSize: 30, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(city.weather?[0].description ?? '', style: const TextStyle(fontSize: 20, color: Colors.white70)),
                                const SizedBox(height: 10),
                                AppBackground.setIconForMain(city.weather?[0].description ?? ''),
                                Text('${city.main?.temp?.round() ?? 0}°', style: const TextStyle(fontSize: 56, color: Colors.white)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const Text("Wind", style: TextStyle(color: Colors.amber)),
                                        Text("${city.wind!.speed!} m/s", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("Sunrise", style: TextStyle(color: Colors.amber)),
                                        Text(sunrise, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("Sunset", style: TextStyle(color: Colors.amber)),
                                        Text(sunset, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("Humidity", style: TextStyle(color: Colors.amber)),
                                        Text("${city.main!.humidity!}%", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white12, thickness: 1),

                          // — Hourly & Daily Forecast —
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (p, c) => p.fwStatus != c.fwStatus,
                            builder: (context, s2) {
                              if (s2.fwStatus is FwLoading) {
                                return const DotLoadingWidget();
                              }
                              if (s2.fwStatus is FwError) {
                                return const Center(
                                  child: Text("Error loading forecast", style: TextStyle(color: Colors.red)),
                                );
                              }
                              final forecast = (s2.fwStatus as FwCompleted).forecastEntity;
                              return Column(
                                children: [
                                  // Hourly Forecast
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Hourly Forecast",
                                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: forecast.hours.length,
                                            itemBuilder: (ctx, i) {
                                              final h = forecast.hours[i];
                                              final lbl = DateFormat('HH:mm').format(DateTime.parse(h.time));
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      i == 0 ? "Now" : lbl,
                                                      style: const TextStyle(color: Colors.white70),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Image.asset(
                                                      h.conditionIcon,
                                                      width: 40,
                                                      height: 40,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${h.temperature.round()}°',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: Colors.white12, thickness: 1),

                                  // Daily Forecast
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "14-Day Forecast",
                                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        ForecastNextDaysWidget(forecastDays: forecast.days),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<LatLon> getCoordinatesFromCityName(String cityName) async {
  final resp = await Dio().get('https://geocoding-api.open-meteo.com/v1/search?name=$cityName');
  final r = resp.data['results'][0];
  return LatLon(r['latitude'], r['longitude']);
}

class LatLon {
  final double latitude, longitude;
  LatLon(this.latitude, this.longitude);
}