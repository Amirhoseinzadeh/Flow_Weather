import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_drawer_content.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_icon.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/forecast_next_days_widget.dart';
import 'package:flow_weather/locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  String getInitialCity() {
    return "آمل";
  }

  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  bool _isForecastLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final HomeBloc _homeBloc;
  final _bookmarkBloc = locator<BookmarkBloc>();
  final _suggestionUseCase = locator<GetSuggestionCityUseCase>();

  @override
  void initState() {
    super.initState();
    _homeBloc = locator<HomeBloc>()..add(LoadCwEvent(getInitialCity()));
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchController.clear();

    // لاگ برای بررسی تغییرات فوکوس
    _searchFocus.addListener(() {
      print('TextField focus changed: ${_searchFocus.hasFocus}');
    });
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '--:--';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '--:--';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _homeBloc.close();
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
        key: _scaffoldKey,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          print('Drawer icon tapped, unfocusing TextField');
                          _searchFocus.unfocus();
                          FocusScope.of(context).unfocus();
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TypeAheadField<NeshanCityItem>(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            suggestionsCallback: (pattern) async {
                              print('Suggestions requested for pattern: "$pattern"');
                              if (pattern.isEmpty) {
                                return [];
                              }
                              return await _suggestionUseCase(pattern);
                            },
                            itemBuilder: (context, NeshanCityItem model) {
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(model.title ?? ''),
                                subtitle: Text('${model.address?.split(', ')[0] ?? ''}, ${model.address?.split(', ').last ?? ''}'),
                              );
                            },
                            builder: (context, TextEditingController controller, FocusNode focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "جستجوی شهر...",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white38),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onSubmitted: (value) {
                                  print('Text submitted: $value');
                                  context.read<HomeBloc>().add(LoadCwEvent(value));
                                  _isForecastLoaded = false;
                                },
                              );
                            },
                            onSelected: (NeshanCityItem model) async {
                              print('City selected: ${model.title}, clearing TextField');
                              _searchController.clear();
                              _searchFocus.unfocus();
                              FocusScope.of(context).unfocus();
                              final lat = model.location?.y;
                              final lon = model.location?.x;
                              if (lat != null && lon != null) {
                                context.read<HomeBloc>().add(LoadCwEvent(model.title!));
                                context.read<HomeBloc>().add(LoadFwEvent(ForecastParams(lat, lon)));
                                _isForecastLoaded = false;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('مختصات شهر پیدا نشد')),
                                );
                              }
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
                            final name = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity.name ?? '';
                            _bookmarkBloc.add(FindCityByNameEvent(name));
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
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            'خطا در بارگذاری هواشناسی: ${(state.cwStatus as CwError).message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }
                    if (state.cwStatus is CwCompleted) {
                      final city = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity;
                      if (!_isForecastLoaded) {
                        final lat = city.coord?.lat;
                        final lon = city.coord?.lon;
                        if (lat != null && lon != null) {
                          _homeBloc.add(LoadFwEvent(ForecastParams(lat, lon)));
                          _isForecastLoaded = true;
                        }
                      }

                      double minTemp = 0.0;
                      double maxTemp = 0.0;
                      if (state.fwStatus is FwCompleted) {
                        final forecast = (state.fwStatus as FwCompleted).forecastEntity;
                        if (forecast.days.isNotEmpty) {
                          minTemp = forecast.days[0].minTempC;
                          maxTemp = forecast.days[0].maxTempC;
                        }
                      }
                      final sunrise = _formatTime(city.sys?.sunrise);
                      final sunset = _formatTime(city.sys?.sunset);
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Text(city.name ?? '', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(
                                  city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
                                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                AppBackground.setIconForMain(
                                  city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
                                ),
                                Text('${city.main?.temp?.round() ?? 0}°', style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const Text("سرعت باد", style: TextStyle(color: Colors.amber)),
                                        Text("${city.wind?.speed ?? 0} km", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("حداقل دما", style: TextStyle(color: Colors.amber)),
                                        Text("${minTemp.round()}°", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("حداکثر دما", style: TextStyle(color: Colors.amber)),
                                        Text("${maxTemp.round()}°", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("رطوبت", style: TextStyle(color: Colors.amber)),
                                        Text("${city.main?.humidity ?? 0}%", style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const Text("طلوع", style: TextStyle(color: Colors.amber)),
                                        Text(sunrise, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    Container(color: Colors.white24, height: 30, width: 2, margin: const EdgeInsets.symmetric(horizontal: 10)),
                                    Column(
                                      children: [
                                        const Text("غروب", style: TextStyle(color: Colors.amber)),
                                        Text(sunset, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white12, thickness: 1),
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (p, c) => p.fwStatus != c.fwStatus,
                            builder: (context, s2) {
                              if (s2.fwStatus is FwLoading) {
                                return const DotLoadingWidget();
                              }
                              if (s2.fwStatus is FwError) {
                                return const Center(
                                  child: Text("خطا در بارگذاری پیش‌بینی", style: TextStyle(color: Colors.red)),
                                );
                              }
                              final forecast = (s2.fwStatus as FwCompleted).forecastEntity;
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "پیش‌بینی ساعتی",
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
                                                      i == 0 ? "اکنون" : lbl,
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
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "پیش‌بینی ۱۴ روزه",
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