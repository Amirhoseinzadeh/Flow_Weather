import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_event.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/current_section.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/daily_section.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/detail_section.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/hourly_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flow_weather/core/params/forecast_params.dart';
import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/neshan_city_entity.dart' as neshan;
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/screens/bookmark_drawer_content.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_icon.dart';
import 'package:flow_weather/locator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  bool _isForecastLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final HomeBloc _homeBloc;
  final _bookmarkBloc = locator<BookmarkBloc>();
  final _suggestionUseCase = locator<GetSuggestionCityUseCase>();
  final DetailCubit _detailCubit = locator<DetailCubit>();

  @override
  void initState() {
    super.initState();
    _homeBloc = locator<HomeBloc>();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchController.clear();
    _homeBloc.getCurrentLocation();
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

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('موقعیت شناسایی نشد'),
        content: const Text('لطفاً نام شهر خود را در باکس جستجو وارد کنید:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _searchFocus.requestFocus();
            },
            child: const Text('جستجوی شهر'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لغو'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk').format(now);
    final width = MediaQuery.of(context).size.width;

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if ((state.cwStatus is CwCompleted || state.cwStatus is CwError) &&
            !state.isLocationLoading &&
            !state.isCityLoading &&
            _scaffoldKey.currentState?.isDrawerOpen == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scaffoldKey.currentState?.isDrawerOpen == true) {
              Navigator.of(context).pop();
            }
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              action: state.errorMessage!.contains('تنظیمات')
                  ? SnackBarAction(
                label: 'تنظیمات',
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  _homeBloc.add(ClearErrorMessage());
                },
              )
                  : null,
            ),
          );
          _homeBloc.add(ClearErrorMessage());
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AppBackground.getBackGroundImage(formattedDate),
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
                          _searchFocus.unfocus();
                          FocusScope.of(context).unfocus();
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      SizedBox(
                        width: width * 0.7,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TypeAheadField<neshan.NeshanCityItem>(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            suggestionsCallback: (pattern) async {
                              if (pattern.isEmpty) return [];
                              return await _suggestionUseCase(pattern);
                            },
                            itemBuilder: (context, neshan.NeshanCityItem model) {
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                  model.title ?? '',
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  '${model.address?.split(', ')[0] ?? ''}, ${model.address?.split(', ').last ?? ''}',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                ),
                              );
                            },
                            builder: (context, TextEditingController controller, FocusNode focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  context.read<HomeBloc>().add(LoadCwEvent(value));
                                  _isForecastLoaded = false;
                                },
                              );
                            },
                            onSelected: (neshan.NeshanCityItem model) async {
                              _searchController.clear();
                              _searchFocus.unfocus();
                              FocusScope.of(context).unfocus();
                              final lat = model.location?.y;
                              final lon = model.location?.x;
                              if (lat != null && lon != null) {
                                final cityName = model.title?.isNotEmpty == true ? model.title! : 'نامشخص';
                                final params = ForecastParams(lat, lon);
                                context.read<HomeBloc>().add(LoadCwEvent(cityName, lat: lat, lon: lon, skipNeshanLookup: true));
                                context.read<HomeBloc>().add(LoadFwEvent(params));
                                context.read<HomeBloc>().add(LoadAirQualityEvent(params));
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
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: BlocBuilder<HomeBloc, HomeState>(
                          buildWhen: (p, c) => p.cwStatus != c.cwStatus,
                          builder: (context, state) {
                            if (state.cwStatus is CwCompleted) {
                              final name = state.searchCityName ?? 'نامشخص';
                              final lat = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity.coord?.lat;
                              final lon = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity.coord?.lon;
                              _bookmarkBloc.add(FindCityByNameEvent(name));
                              return BookMarkIcon(name: name, lat: lat, lon: lon).animate().fadeIn(duration: 300.ms).scale();
                            }
                            if (state.cwStatus is CwLoading) {
                              return LoadingAnimationWidget.bouncingBall(
                                size: 30,
                                color: Colors.white,
                              ).animate().fadeIn(duration: 300.ms).scale();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (p, c) => p.cwStatus != c.cwStatus || p.fwStatus != c.fwStatus || p.aqStatus != c.aqStatus,
                  builder: (context, state) {
                    if (state.isLocationLoading || state.isCityLoading) {
                      return const SizedBox(height: 200, child: Center(child: DotLoadingWidget())).animate().fadeIn(duration: 300.ms).scale();
                    }
                    if (state.cwStatus is CwError) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off, color: Colors.redAccent, size: 60),
                              const SizedBox(width: 10),
                              Text(
                                'اینترنت را روشن کنید',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).scale();
                    }
                    if (state.cwStatus is CwCompleted) {
                      final city = (state.cwStatus as CwCompleted).meteoCurrentWeatherEntity;
                      final temp = city.main?.temp?.round() ?? 0;
                      final cityName = state.searchCityName ?? 'نامشخص';

                      if (!_isForecastLoaded) {
                        final lat = city.coord?.lat ?? 35.6892;
                        final lon = city.coord?.lon ?? 51.3890;
                        final params = ForecastParams(lat, lon);
                        _homeBloc.add(LoadFwEvent(params));
                        _homeBloc.add(LoadAirQualityEvent(params));
                        _isForecastLoaded = true;
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
                          CurrentSection(
                            cityName: cityName,
                            city: city,
                            minTemp: minTemp,
                            temp: temp,
                            maxTemp: maxTemp,
                          ).animate().fadeIn(duration: 300.ms).scale(),
                          if (cityName == 'موقعیت نامشخص')
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ElevatedButton(
                                onPressed: _showCitySelectionDialog,
                                child: const Text('انتخاب دستی شهر'),
                              ).animate().fadeIn(duration: 300.ms).scale(),
                            ),
                          if (cityName == 'نامشخص (خارج از ایران)')
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ElevatedButton(
                                onPressed: _showCitySelectionDialog,
                                child: const Text('موقعیت شما خارج از ایران است، شهر را دستی انتخاب کنید'),
                              ).animate().fadeIn(duration: 300.ms).scale(),
                            ),
                          DetailSection(
                            width: width,
                            detailCubit: _detailCubit,
                            city: city,
                            minTemp: minTemp,
                            maxTemp: maxTemp,
                            sunrise: sunrise,
                            sunset: sunset,
                            aqStatus: state.aqStatus,
                          ).animate().fadeIn(duration: 300.ms).scale(),
                          const SizedBox(height: 6),
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (p, c) => p.fwStatus != c.fwStatus,
                            builder: (context, s2) {
                              if (s2.fwStatus is FwLoading) {
                                return const DotLoadingWidget().animate().fadeIn(duration: 300.ms).scale();
                              }
                              if (s2.fwStatus is FwError) {
                                return const Center(
                                  child: Text(
                                    "خطا در بارگذاری پیش‌بینی",
                                    style: TextStyle(fontFamily: "nazanin", color: Colors.red),
                                  ),
                                ).animate().fadeIn(duration: 300.ms).scale();
                              }
                              final forecast = (s2.fwStatus as FwCompleted).forecastEntity;
                              return Column(
                                children: [
                                  HourlySection(forecast: forecast).animate().fadeIn(duration: 300.ms).scale(),
                                  const Divider(color: Colors.white12, thickness: 2),
                                  DailySection(forecast: forecast, forecastDays: forecast.days).animate().fadeIn(duration: 300.ms).scale(),
                                ].animate(interval: 300.ms).scale(),
                              );
                            },
                          ),
                        ].animate(interval: 300.ms).scale(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
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
      ),
    );
  }
}