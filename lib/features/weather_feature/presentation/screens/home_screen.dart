import 'package:dio/dio.dart';
import 'package:flow_weather/core/params/ForecastParams.dart';
import 'package:flow_weather/core/utils/date_converter.dart';
import 'package:flow_weather/core/widgets/app_background.dart';
import 'package:flow_weather/core/widgets/dot_loading_widget.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/data/models/suggest_city_model.dart';
import 'package:flow_weather/features/weather_feature/domain/entities/current_city_entity.dart';
import 'package:flow_weather/features/weather_feature/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/cw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/fw_status.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/bookmark_icon.dart';
import 'package:flow_weather/features/weather_feature/presentation/widgets/forecast_next_days_widget.dart';
import 'package:flow_weather/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController textEditingController;
  late FocusNode focusNode;
  final PageController _pageController = PageController();
  bool _isForecastLoaded = false;
  GetSuggestionCityUseCase getSuggestionCityUseCase = GetSuggestionCityUseCase(
    locator(),
  );

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    focusNode = FocusNode();

    // پاک کردن متن هنگام بارگذاری اولیه صفحه
    textEditingController.clear();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          textEditingController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textEditingController.text.length,
          );
        });
      }
    });

    // اضافه کردن listener برای نویگیشن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ModalRoute.of(context)?.addScopedWillPopCallback(() async {
        textEditingController.clear(); // پاک کردن متن هنگام بازگشت
        return true;
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // پاک کردن متن هنگام بازگشت به صفحه (در صورت استفاده از Navigator.pop)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        textEditingController.clear();
      }
    });

    return SafeArea(
      child: ListView( // جایگزین Column با ListView برای اسکرول همه محتوا
        physics: const BouncingScrollPhysics(), // برای اسکرول نرم‌تر
        children: [
          // سرچ باکس داخل ListView
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TypeAheadField<Data>(
                      controller: textEditingController,
                      focusNode: focusNode,
                      suggestionsCallback: (String pattern) async {
                        return await getSuggestionCityUseCase(pattern);
                      },
                      itemBuilder: (context, Data model) {
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(model.name ?? ''),
                          subtitle: Text('${model.region ?? ''}, ${model.country ?? ''}'),
                        );
                      },
                      onSelected: (Data model) async {
                        FocusScope.of(context).unfocus();
                        textEditingController.text = model.name ?? '';
                        textEditingController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: textEditingController.text.length,
                        );

                        final cityName = model.name;
                        final latLon = await getCoordinatesFromCityName(cityName!);
                        BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(cityName));
                        BlocProvider.of<HomeBloc>(context).add(
                          LoadFwEvent(ForecastParams(latLon.latitude, latLon.longitude)),
                        );
                      },
                      loadingBuilder: (context) => const SizedBox.shrink(),
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 50), () {
                              textEditingController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: textEditingController.text.length,
                              );
                            });
                          },
                          onChanged: (value) {
                            if (controller.text != value) {
                              controller.text = value;
                              controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: controller.text.length),
                              );
                            }
                          },
                          onSubmitted: (value) {
                            BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(value));
                          },
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
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) {
                    return previous.cwStatus != current.cwStatus;
                  },
                  builder: (context, state) {
                    if (state.cwStatus is CwLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (state.cwStatus is CwError) {
                      return IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 35,
                        ),
                      );
                    }
                    if (state.cwStatus is CwCompleted) {
                      final CwCompleted cwComplete = state.cwStatus as CwCompleted;
                      context
                          .read<BookmarkBloc>()
                          .add(GetCityByNameEvent(cwComplete.currentCityEntity.name!));
                      return BookMarkIcon(
                        name: cwComplete.currentCityEntity.name!,
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
            previous.cwStatus != current.cwStatus ||
                previous.fwStatus != current.fwStatus,
            builder: (context, state) {
              if (state.cwStatus is CwLoading) {
                return const SizedBox(
                  height: 200, // ارتفاع ثابت برای حالت لودینگ
                  child: Center(child: DotLoadingWidget()),
                );
              }
              if (state.cwStatus is CwCompleted) {
                final cwComplete = state.cwStatus as CwCompleted;
                final CurrentCityEntity currentCityEntity = cwComplete.currentCityEntity;
                if (!_isForecastLoaded) {
                  final forecastParams = ForecastParams(
                    currentCityEntity.coord!.lat!,
                    currentCityEntity.coord!.lon!,
                  );
                  BlocProvider.of<HomeBloc>(context).add(LoadFwEvent(forecastParams));
                  _isForecastLoaded = true;
                }
                final sunrise = DateConverter.changeDtToDateTimeHour(
                  currentCityEntity.sys!.sunrise,
                  currentCityEntity.timezone,
                );
                final sunset = DateConverter.changeDtToDateTimeHour(
                  currentCityEntity.sys!.sunset,
                  currentCityEntity.timezone,
                );
                return Column( // استفاده از Column به جای Expanded داخل ListView
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.47,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 2,
                        itemBuilder: (context, position) {
                          if (position == 0) {
                            return Column(
                              children: [
                                const SizedBox(height: 50),
                                Text(
                                  currentCityEntity.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  currentCityEntity.weather?[0].description ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                AppBackground.setIconForMain(
                                  currentCityEntity.weather?[0].description ?? '',
                                ),
                                SizedBox(height: height * 0.02),
                                Text(
                                  "${currentCityEntity.main?.temp?.round() ?? 0}\u00B0",
                                  style: TextStyle(
                                    fontSize: width * 0.15,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Text(
                                            "max",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${currentCityEntity.main?.tempMax?.round() ?? 0}\u00B0",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      width: 2,
                                      height: 60,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Text(
                                            "min",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "${currentCityEntity.main?.tempMin?.round() ?? 0}\u00B0",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "More details...",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          spacing: 8,
                          activeDotColor: Colors.white,
                        ),
                        onDotClicked: (index) => _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.bounceOut,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (prev, curr) => prev.fwStatus != curr.fwStatus,
                      builder: (context, state) {
                        if (state.fwStatus is FwLoading) {
                          return const DotLoadingWidget();
                        }
                        if (state.fwStatus is FwError) {
                          return const Center(
                            child: Text(
                              "Error loading forecast",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (state.fwStatus is FwCompleted) {
                          final forecast = (state.fwStatus as FwCompleted).forecastEntity;

                          return Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: forecast.hours.length,
                                  itemBuilder: (context, index) {
                                    final hour = forecast.hours[index];
                                    final timeLabel = DateFormat('HH:mm').format(DateTime.parse(hour.time));
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(timeLabel, style: const TextStyle(color: Colors.white70)),
                                          const SizedBox(height: 5),
                                          Image.asset(hour.conditionIcon, width: 40, height: 40),
                                          const SizedBox(height: 5),
                                          Text('${hour.temperature.round()}°',
                                              style: const TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(color: Colors.white24, thickness: 2),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: _buildInfoItem(
                                        "wind speed",
                                        "${currentCityEntity.wind?.speed ?? 0} m/s",
                                        height,
                                      ),
                                    ),
                                    _buildDivider(),
                                    Flexible(
                                      child: _buildInfoItem(
                                        "sunrise",
                                        sunrise,
                                        height,
                                      ),
                                    ),
                                    _buildDivider(),
                                    Flexible(
                                      child: _buildInfoItem(
                                        "sunset",
                                        sunset,
                                        height,
                                      ),
                                    ),
                                    _buildDivider(),
                                    Flexible(
                                      child: _buildInfoItem(
                                        "humidity",
                                        "${currentCityEntity.main?.humidity ?? 0}%",
                                        height,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Text(
                                  "Weekly",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ForecastNextDaysWidget(forecastDays: forecast.days),
                              const SizedBox(height: 20),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              }
              if (state.cwStatus is CwError) {
                return const SizedBox(
                  height: 200, // ارتفاع ثابت برای حالت خطا
                  child: Center(
                    child: Icon(Icons.error, color: Colors.red, size: 35),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, double height) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: height * 0.015, color: Colors.amber),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(fontSize: height * 0.015, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: VerticalDivider(color: Colors.white24, thickness: 2, width: 10),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

final dio = Dio();
Future<LatLon> getCoordinatesFromCityName(String cityName) async {
  final response = await dio.get('https://geocoding-api.open-meteo.com/v1/search?name=$cityName');
  final results = response.data['results'];
  final lat = results[0]['latitude'];
  final lon = results[0]['longitude'];
  return LatLon(lat, lon);
}

class LatLon {
  final double latitude;
  final double longitude;

  LatLon(this.latitude, this.longitude);
}