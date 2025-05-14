import 'package:flow_weather/config/notification/notification_service.dart';
import 'package:flow_weather/core/bloc/bottom_icon_cubit.dart';
import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_icon_cubit.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/screens/home_screen.dart';
import 'package:flow_weather/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final notificationService = NotificationService();
  // await notificationService.initialize();


  await setup();

  runApp(MyApp(/*notificationService: notificationService*/));
}

class MyApp extends StatelessWidget {
  // final NotificationService notificationService;
  const MyApp({super.key/*, required this.notificationService*/});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => locator<HomeBloc>()),
          BlocProvider(create: (_) => locator<BottomIconCubit>()),
          BlocProvider(create: (_) => locator<BookmarkBloc>()),
          BlocProvider(create: (_) => locator<BookmarkIconCubit>()),
          BlocProvider(create: (_) => locator<DetailCubit>()),
        ],
        child: HomeScreen(/*notificationService: notificationService*/),
      ),
    );
  }
}