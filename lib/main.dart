import 'package:flow_weather/core/bloc/bottom_icon_cubit.dart';
import 'package:flow_weather/core/bloc/detail_cubit.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/bookmark_bloc/bookmark_icon_cubit.dart';
import 'package:flow_weather/features/weather_feature/presentation/bloc/home_bloc.dart';
import 'package:flow_weather/features/weather_feature/presentation/screens/home_screen.dart';
import 'package:flow_weather/generated/app_localizations.dart';
import 'package:flow_weather/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final notificationService = NotificationService();
  // await notificationService.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load(fileName: '.env');

  await setup();

  runApp(MyApp(/*notificationService: notificationService*/));
}

class MyApp extends StatelessWidget {
  // final NotificationService notificationService;
  const MyApp({super.key/*, required this.notificationService*/});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('fa'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('fa'), // Persian
      ],
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