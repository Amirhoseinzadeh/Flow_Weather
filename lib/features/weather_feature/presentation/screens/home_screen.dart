// lib/features/weather_feature/presentation/screens/home_screen.dart

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
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
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
    // پاک کردن اولیه
    _searchController.clear();
    // انتخاب متن وقتی فیلد فوکوس می‌گیره
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
    // محاسبهٔ پس‌زمینه
    final now = DateTime.now();
    final hourStr = DateFormat('kk').format(now);
    final bgImage = AppBackground.getBackGroundImage(hourStr);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _bookmarkBloc),
      ],
      child: Scaffold(
        drawer: const Drawer(child: BookmarkDrawerContent()),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bgImage,
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ——— Search Row ———
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Builder(builder: (ctx) {
                        return IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        );
                      }),
                      // داخل HomeScreen، جایگزینِ کد قبلیِ TypeAheadField
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TypeAheadField<Data>(
                            // ۱) از کنترلر و فوکوس خودت استفاده کن
                            controller: _searchController,
                            focusNode: _searchFocus,

                            // ۲) وقتی کاربر تایپ می‌کند، پیشنهادها اینجا ساخته می‌شوند
                            suggestionsCallback: (pattern) =>
                                _suggestionUseCase(pattern),

                            // ۳) این تابع ویجتِ هر پیشنهاد را می‌سازد
                            itemBuilder: (context, Data model) {
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(model.name ?? ''),
                                subtitle: Text('${model.region ?? ''}, ${model.country ?? ''}'),
                              );
                            },

                            // ۴) این تابع خودش TextField را می‌سازد (جایگزین textFieldConfiguration شده)
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
                                  // سلکت کامل متن هنگام فوکوس
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    controller.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset: controller.text.length,
                                    );
                                  });
                                },
                                onChanged: (value) {
                                  // caret رو آخر متن نگه دار
                                  controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: controller.text.length),
                                  );
                                },
                                onSubmitted: (value) {
                                  // وقتی اینتر زد، فقط Current Weather رو لود کن
                                  context.read<HomeBloc>().add(LoadCwEvent(value));
                                },
                              );
                            },

                            // ۵) وقتی روی یک پیشنهاد کلیک شد
                            onSelected: (Data model) async {
                              FocusScope.of(context).unfocus();                // کیبورد رو ببند
                              _searchController.text = model.name ?? '';       // متن فیلد رو ست کن
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _searchController.text.length),
                              );

                              // بعدش Current + Forecast رو لود کن
                              final latLon = await getCoordinatesFromCityName(model.name!);
                              context.read<HomeBloc>().add(LoadCwEvent(model.name!));
                              context.read<HomeBloc>().add(
                                LoadFwEvent(ForecastParams(latLon.latitude, latLon.longitude)),
                              );
                            },

                            // ۶) سفارشی‌سازی لودینگ و حالت خالی
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
                            final name =
                            (state.cwStatus as CwCompleted).currentCityEntity.name!;
                            // رفرش وضعیت بوکمارک
                            _bookmarkBloc.add(GetCityByNameEvent(name));
                            return BookMarkIcon(name: name);
                          }
                          if (state.cwStatus is CwLoading) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  buildWhen: (p, c) =>
                  p.cwStatus != c.cwStatus || p.fwStatus != c.fwStatus,
                  builder: (context, state) {
                    // 1) Loading Current
                    if (state.cwStatus is CwLoading) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: DotLoadingWidget()),
                      );
                    }
                    // 2) Error Current
                    if (state.cwStatus is CwError) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red, size: 36),
                        ),
                      );
                    }
                    // 3) Completed Current
                    if (state.cwStatus is CwCompleted) {
                      final city = (state.cwStatus as CwCompleted).currentCityEntity;
                      // لود یکبار Forecast
                      if (!_isForecastLoaded) {
                        _homeBloc.add(LoadFwEvent(ForecastParams(
                          city.coord!.lat!,
                          city.coord!.lon!,
                        )));
                        _isForecastLoaded = true;
                      }
                      final sunrise = DateConverter.changeDtToDateTimeHour(
                          city.sys!.sunrise, city.timezone);
                      final sunset = DateConverter.changeDtToDateTimeHour(
                          city.sys!.sunset, city.timezone);

                      return Column(
                        children: [
                          // — Current City PageView —
                          SizedBox(
                            height: 400,
                            child: PageView(
                              children: [
                                // صفحهٔ اصلی
                                _buildCurrentPage(city, sunrise, sunset),
                                // صفحهٔ جزئیات (اختیاری)
                                const Center(
                                    child: Text("More details...",
                                        style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24, thickness: 2),

                          // — Hourly & Daily Forecast —
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (p, c) => p.fwStatus != c.fwStatus,
                            builder: (context, s2) {
                              if (s2.fwStatus is FwLoading) {
                                return const DotLoadingWidget();
                              }
                              if (s2.fwStatus is FwError) {
                                return const Center(
                                  child: Text("Error loading forecast",
                                      style: TextStyle(color: Colors.red)),
                                );
                              }
                              final forecast =
                                  (s2.fwStatus as FwCompleted).forecastEntity;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 110,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: forecast.hours.length,
                                      itemBuilder: (ctx, i) {
                                        final h = forecast.hours[i];
                                        final lbl = DateFormat('HH:mm')
                                            .format(DateTime.parse(h.time));
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Text(lbl,
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                              const SizedBox(height: 6),
                                              Image.asset(h.conditionIcon,
                                                  width: 36, height: 36),
                                              const SizedBox(height: 6),
                                              Text('${h.temperature.round()}°',
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(
                                      color: Colors.white24, thickness: 2),
                                  ForecastNextDaysWidget(
                                      forecastDays: forecast.days),
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

  Widget _buildCurrentPage(
      CurrentCityEntity city, String sunrise, String sunset) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(city.name ?? '',
            style: const TextStyle(fontSize: 32, color: Colors.white)),
        const SizedBox(height: 8),
        Text(city.weather?[0].description ?? '',
            style: const TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 16),
        AppBackground.setIconForMain(
            city.weather?[0].description ?? ''),
        const SizedBox(height: 16),
        Text('${city.main?.temp?.round() ?? 0}°',
            style: const TextStyle(fontSize: 64, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              const Text('Max', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('${city.main?.tempMax?.round() ?? 0}°',
                  style: const TextStyle(color: Colors.white)),
            ]),
            const SizedBox(width: 24),
            Column(children: [
              const Text('Min', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('${city.main?.tempMin?.round() ?? 0}°',
                  style: const TextStyle(color: Colors.white)),
            ]),
            const SizedBox(width: 24),
            Column(children: [
              const Text('Wind', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('${city.wind?.speed ?? 0} m/s',
                  style: const TextStyle(color: Colors.white)),
            ]),
            const SizedBox(width: 24),
            Column(children: [
              const Text('Humidity', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('${city.main?.humidity ?? 0}%',
                  style: const TextStyle(color: Colors.white)),
            ]),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// تابع کمکی برای تبدیل نام شهر به Lat/Lon
Future<LatLon> getCoordinatesFromCityName(String cityName) async {
  final resp = await Dio().get(
      'https://geocoding-api.open-meteo.com/v1/search?name=$cityName');
  final r = resp.data['results'][0];
  return LatLon(r['latitude'], r['longitude']);
}

class LatLon {
  final double latitude, longitude;
  LatLon(this.latitude, this.longitude);
}
