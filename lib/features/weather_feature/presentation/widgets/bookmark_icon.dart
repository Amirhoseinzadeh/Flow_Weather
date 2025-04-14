import 'package:flow_weather/features/bookmark_feature/domain/entities/city_model.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_icon_cubit.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_city_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookMarkIcon extends StatefulWidget {
  final String name;

  const BookMarkIcon({Key? key, required this.name}) : super(key: key);

  @override
  _BookMarkIconState createState() => _BookMarkIconState();
}

class _BookMarkIconState extends State<BookMarkIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // تنظیم انیمیشن‌ها
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // مدت زمان انیمیشن
      vsync: this,
    );

    // انیمیشن مقیاس با افکت فنری
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // انیمیشن چرخش کامل (360 درجه)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // انیمیشن تغییر رنگ با حس گرادیانت
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.amberAccent,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // انیمیشن درخشش (Glow)
    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // گرفتن وضعیت اولیه بوکمارک
    context.read<BookmarkBloc>().add(GetCityByNameEvent(widget.name));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookmarkBloc, BookmarkState>(
      listenWhen: (previous, current) => previous.getCityStatus != current.getCityStatus,
      listener: (context, state) {
        if (state.getCityStatus is GetCityCompleted) {
          final getCityCompleted = state.getCityStatus as GetCityCompleted;
          final city = getCityCompleted.city;
          context.read<BookmarkIconCubit>().updateBookmarkStatus(city != null);
        }
      },
      child: BlocBuilder<BookmarkIconCubit, BookmarkIconState>(
        builder: (context, state) {
          // کنترل انیمیشن بر اساس وضعیت
          if (state.isBookmarked) {
            _controller.forward();
          } else {
            _controller.reverse();
          }

          return IconButton(
            onPressed: () {
              // تغییر وضعیت بوکمارک
              context.read<BookmarkIconCubit>().toggleBookmark();
              final newStatus = !state.isBookmarked;
              if (newStatus) {
                context.read<BookmarkBloc>().add(SaveCwEvent(widget.name));
              } else {
                context.read<BookmarkBloc>().add(DeleteCityEvent(widget.name));
              }
            },
            icon: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(_scaleAnimation.value) // مقیاس با افکت فنری
                    ..rotateZ(_rotationAnimation.value * 2 * 3.14159), // چرخش 360 درجه
                  child: Icon(
                    state.isBookmarked ? Icons.star : Icons.star_border,
                    color: _colorAnimation.value, // تغییر رنگ
                    size: 30,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}