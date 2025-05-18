import 'dart:async';
import 'package:flow_weather/config/notification/notification_service.dart';
import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/data/data_source/remote/api_provider.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart' as neshan;
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/aq_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_drawer_content.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_icon.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/forecast_next_days_widget.dart';
import 'package:flow_weather/locator.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  String getInitialCity() => "آمل";

  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  bool _isForecastLoaded = false;
  bool _isAirQualityLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final HomeBloc _homeBloc;
  final _bookmarkBloc = locator<BookmarkBloc>();
  final _suggestionUseCase = locator<GetSuggestionCityUseCase>();
  final DetailCubit _detailCubit = locator<DetailCubit>();

  String _currentCity = 'تهران';
  double _currentLat = 35.6892;
  double _currentLon = 51.3890;

  @override
  void initState() {
    super.initState();
    _homeBloc = locator<HomeBloc>();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchController.clear();

    _searchFocus.addListener(() {
      print('TextField focus changed: ${_searchFocus.hasFocus}');
    });

    _homeBloc.getCurrentLocation(context, forceRequest: false);
  }

  Future<void> _loadDefaultData() async {
    final params = ForecastParams(_currentLat, _currentLon);
    print('بارگذاری داده‌های پیش‌فرض برای تهران: lat=$_currentLat, lon=$_currentLon');
    try {
      _homeBloc.add(LoadCwEvent(_currentCity, lat: _currentLat, lon: _currentLon));
      _homeBloc.add(LoadFwEvent(params));
      _homeBloc.add(LoadAirQualityEvent(params));
      print('داده‌های پیش‌فرض برای تهران بارگذاری شد');
    } catch (e) {
      print('خطا در بارگذاری داده‌های پیش‌فرض: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در بارگذاری داده‌های پیش‌فرض')));
    }
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _bookmarkBloc),
        BlocProvider.value(value: _detailCubit),
      ],
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) => previous.cwStatus != current.cwStatus,
        listener: (context, state) {
          if (state.cwStatus is CwCompleted && _scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context); // Close drawer after current weather loading completes
            print('Drawer closed after CwCompleted');
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            backgroundColor: Colors.black,
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
                            child: TypeAheadField<neshan.NeshanCityItem>(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              suggestionsCallback: (pattern) async {
                                print('Suggestions requested for pattern: "$pattern"');
                                if (pattern.isEmpty) return [];
                                return await _suggestionUseCase(pattern);
                              },
                              itemBuilder: (context, neshan.NeshanCityItem model) {
                                return ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(model.title ?? '', style: const TextStyle(fontSize: 16), maxLines: 1),
                                  subtitle: Text('${model.address?.split(', ')[0] ?? ''}, ${model.address?.split(', ').last ?? ''}', style: const TextStyle(fontSize: 12), maxLines: 2),
                                );
                              },
                              builder: (context, TextEditingController controller, FocusNode focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  style: const TextStyle(fontFamily: "nazanin", color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "جستجوی شهر...",
                                    hintStyle: TextStyle(color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                  ),
                                  onSubmitted: (value) {
                                    print('Text submitted: $value');
                                    context.read<HomeBloc>().add(LoadCwEvent(value));
                                    _isForecastLoaded = false;
                                    _isAirQualityLoaded = false;
                                  },
                                );
                              },
                              onSelected: (neshan.NeshanCityItem model) async {
                                print('City selected: ${model.title}, clearing TextField');
                                _searchController.clear();
                                _searchFocus.unfocus();
                                FocusScope.of(context).unfocus();
                                final lat = model.location?.y;
                                final lon = model.location?.x;
                                print('مختصات شهر انتخاب‌شده (${model.title}): lat=$lat, lon=$lon');
                                if (lat != null && lon != null) {
                                  setState(() {
                                    _currentCity = model.title!;
                                    _currentLat = lat;
                                    _currentLon = lon;
                                  });
                                  final params = ForecastParams(lat, lon);
                                  context.read<HomeBloc>().add(LoadCwEvent(model.title!, lat: lat, lon: lon));
                                  context.read<HomeBloc>().add(LoadFwEvent(params));
                                  context.read<HomeBloc>().add(LoadAirQualityEvent(params));
                                  _isForecastLoaded = false;
                                  _isAirQualityLoaded = false;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مختصات شهر پیدا نشد')));
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
                      ].animate(interval: 200.ms).scale(),
                    ),
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (p, c) => p.cwStatus != c.cwStatus || p.fwStatus != c.fwStatus || p.aqStatus != c.aqStatus,
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
                              style: const TextStyle(fontFamily: "nazanin", color: Colors.red),
                            ),
                          ),
                        );
                      }
                      if (state.cwStatus is CwCompleted) {
                        final city = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity;
                        final temp = city.main?.temp?.round() ?? 0;
                        final cityName = city.name ?? 'شهر نامشخص';

                        if (!_isForecastLoaded) {
                          final lat = city.coord?.lat ?? _currentLat;
                          final lon = city.coord?.lon ?? _currentLon;
                          print('مختصات از آب‌وهوای فعلی یا پیش‌فرض: lat=$lat, lon=$lon');
                          if (lat != null && lon != null) {
                            final params = ForecastParams(lat, lon);
                            _homeBloc.add(LoadFwEvent(params));
                            _homeBloc.add(LoadAirQualityEvent(params));
                            _isForecastLoaded = true;
                            _isAirQualityLoaded = true;
                          } else {
                            print('مختصات آب‌وهوای فعلی نامعتبر است');
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
                        print('ارتفاع دریافت‌شده برای نمایش: ${city.elevation ?? 0}');
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Text(
                                    _currentCity == 'موقعیت نامشخص' ? 'موقعیت نامشخص: $cityName' : cityName,
                                    maxLines: 1,
                                    style: const TextStyle(fontFamily: "Titr", fontSize: 30, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
                                    style: const TextStyle(fontFamily: "Titr", fontSize: 20, color: Colors.white70),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: AppBackground.setIconForMain(
                                      city.weather?.isNotEmpty == true ? city.weather![0].description ?? '' : '',
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "حداقل دما",
                                            style: TextStyle(fontFamily: "lalezar", color: Colors.white54, fontSize: 14),
                                          ),
                                          Text(
                                            "${minTemp.round()}°",
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$temp°',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "حداکثر دما",
                                            style: TextStyle(fontFamily: "lalezar", color: Colors.white54, fontSize: 14),
                                          ),
                                          Text(
                                            "${maxTemp.round()}°",
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  BlocBuilder<DetailCubit, bool>(
                                    builder: (context, isExpanded) {
                                      return ExpansionTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: width * 0.1),
                                            const Text(
                                              'جزئیات',
                                              style: TextStyle(
                                                fontFamily: "entezar",
                                                fontSize: 22,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              isExpanded ? Icons.expand_less : Icons.expand_more,
                                              color: Colors.white70,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                        trailing: const SizedBox.shrink(),
                                        backgroundColor: Colors.transparent,
                                        collapsedBackgroundColor: Colors.transparent,
                                        onExpansionChanged: (expanded) {
                                          _detailCubit.toggleDetail();
                                        },
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  const Text(
                                                    "سرعت باد",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellowAccent,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${city.wind?.speed?.toStringAsFixed(1) ?? '0'} km/h",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                color: Colors.white24,
                                                height: 31,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "حداقل دما",
                                                    style: TextStyle(fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellowAccent,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${minTemp.round()}°",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              // Column(
                                              //   children: [
                                              //     const Text(
                                              //       "احتمال بارندگی",
                                              //       style: TextStyle(
                                              //         fontFamily: "nikoo",
                                              //         fontSize: 18,
                                              //         color: Colors.yellow,
                                              //       ),
                                              //     ),
                                              //     Text(
                                              //       "${city.precipitationProbability ?? 0}%",
                                              //       style: const TextStyle(color: Colors.white),
                                              //     ),
                                              //   ],
                                              // ),
                                              Container(
                                                color: Colors.white24,
                                                height: 30,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "حداکثر دما",
                                                    style: TextStyle(fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellowAccent,),
                                                  ),
                                                  Text(
                                                    "${maxTemp.round()}°",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                color: Colors.white24,
                                                height: 30,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "رطوبت",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellowAccent,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${city.main?.humidity ?? 0}%",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Column(
                                              //   children: [
                                              //     const Text(
                                              //       "جهت باد",
                                              //       style: TextStyle(
                                              //         fontFamily: "nikoo",
                                              //         fontSize: 18,
                                              //         color: Colors.yellow,
                                              //       ),
                                              //     ),
                                              //     Text(
                                              //       _getWindDirection(city.wind?.deg ?? 0),
                                              //       style: const TextStyle(color: Colors.white),
                                              //     ),
                                              //   ],
                                              // ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "فشار",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellow,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${city.main?.pressure ?? 0} hPa",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                color: Colors.white24,
                                                height: 30,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              if (state.aqStatus is AirQualityLoading)
                                                const SizedBox(
                                                  height: 50,
                                                  child: Center(child: DotLoadingWidget()),
                                                ),
                                              if (state.aqStatus is AirQualityError)
                                                Text(
                                                  'خطا در بارگذاری کیفیت هوا: ${(state.aqStatus as AirQualityError).message}',
                                                  style: const TextStyle(fontFamily: "nikoo", color: Colors.red),
                                                ),
                                              if (state.aqStatus is AirQualityCompleted)
                                                Builder(
                                                  builder: (context) {
                                                    final airQuality = (state.aqStatus as AirQualityCompleted);
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          "کیفیت هوا",
                                                          style: TextStyle(
                                                            fontFamily: "nikoo",
                                                            fontSize: 18,
                                                            color: Colors.yellow,
                                                          ),
                                                        ),
                                                        Text(
                                                          'AQI: ${airQuality.aqi} (${airQuality.category})',
                                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              Container(
                                                color: Colors.white24,
                                                height: 30,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "اشعه UV",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.yellow,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${city.uvIndex?.toStringAsFixed(1) ?? '0'}",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Column(
                                              //   children: [
                                              //     const Text(
                                              //       "ارتفاع از سطح دریا",
                                              //       style: TextStyle(
                                              //         fontFamily: "nikoo",
                                              //         fontSize: 18,
                                              //         color: Colors.yellow,
                                              //       ),
                                              //     ),
                                              //     Text(
                                              //       "${city.elevation?.toStringAsFixed(0) ?? '0'} متر",
                                              //       style: const TextStyle(color: Colors.white),
                                              //     ),
                                              //   ],
                                              // ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "طلوع",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.orangeAccent
                                                    ),
                                                  ),
                                                  Text(
                                                    sunrise,
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                color: Colors.white24,
                                                height: 30,
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                              ),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "غروب",
                                                    style: TextStyle(
                                                      fontFamily: "nikoo",
                                                      fontSize: 18,
                                                      color: Colors.orangeAccent
                                                    ),
                                                  ),
                                                  Text(
                                                    sunset,
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                  ),
                                ].animate(interval: 200.ms).scale(),
                              ),
                            ),
                            // const Divider(color: Colors.white12, thickness: 2),
                            BlocBuilder<HomeBloc, HomeState>(
                              buildWhen: (p, c) => p.fwStatus != c.fwStatus,
                              builder: (context, s2) {
                                if (s2.fwStatus is FwLoading) {
                                  return const DotLoadingWidget();
                                }
                                if (s2.fwStatus is FwError) {
                                  return const Center(
                                    child: Text(
                                      "خطا در بارگذاری پیش‌بینی",
                                      style: TextStyle(fontFamily: "nazanin", color: Colors.red),
                                    ),
                                  );
                                }
                                final forecast = (s2.fwStatus as FwCompleted).forecastEntity;
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 36),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "پیش‌بینی ساعتی",
                                                  style: TextStyle(fontFamily: "entezar", fontSize: 22, color: Colors.white),
                                                ),
                                                Icon(Icons.access_time_outlined, color: Colors.grey.shade200, size: 30),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              cacheExtent: 1000,
                                              itemCount: forecast.hours.length,
                                              itemBuilder: (ctx, i) {
                                                final h = forecast.hours[i];
                                                final lbl = DateFormat('HH:mm').format(DateTime.parse(h.time));
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(i == 0 ? "اکنون" : lbl, style: const TextStyle(color: Colors.white70)),
                                                      const SizedBox(height: 2),
                                                      Image.asset(
                                                        h.conditionIcon,
                                                        width: 30,
                                                        height: 30,
                                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text('${h.temperature.round()}°', style: const TextStyle(color: Colors.white)),
                                                    ].animate(interval: 200.ms).scale(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ].animate(interval: 200.ms).scale(),
                                      ),
                                    ),
                                    const Divider(color: Colors.white12, thickness: 2),
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "پیش‌بینی ۱۴ روزه",
                                                  style: TextStyle(fontFamily: "entezar", fontSize: 22, color: Colors.white),
                                                ),
                                                Icon(Icons.calendar_month_sharp, color: Colors.grey.shade300, size: 30),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ForecastNextDaysWidget(forecastDays: forecast.days),
                                        ],
                                      ),
                                    ),
                                  ].animate(interval: 200.ms).scale(),
                                );
                              },
                            ),
                          ].animate(interval: 200.ms).scale(),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// String _getWindDirection(int degrees) {
//   if (degrees >= 337.5 || degrees < 22.5) return "شمال";
//   if (degrees >= 22.5 && degrees < 67.5) return "شمال‌شرقی";
//   if (degrees >= 67.5 && degrees < 112.5) return "شرق";
//   if (degrees >= 112.5 && degrees < 157.5) return "جنوب‌شرقی";
//   if (degrees >= 157.5 && degrees < 202.5) return "جنوب";
//   if (degrees >= 202.5 && degrees < 247.5) return "جنوب‌غربی";
//   if (degrees >= 247.5 && degrees < 292.5) return "غرب";
//   if (degrees >= 292.5 && degrees < 337.5) return "شمال‌غربی";
//   return "نامشخص";
// }