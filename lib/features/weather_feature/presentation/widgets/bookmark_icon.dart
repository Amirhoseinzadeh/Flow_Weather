import 'package:flow_weather/features/bookmark_feature/domain/entities/city_model.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/bookmark_bloc.dart';
import 'package:flow_weather/features/bookmark_feature/presentation/bloc/get_city_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookMarkIcon extends StatefulWidget {
  final String name;

  const BookMarkIcon({Key? key, required this.name}) : super(key: key);

  @override
  _BookMarkIconState createState() => _BookMarkIconState();
}

class _BookMarkIconState extends State<BookMarkIcon> {
  bool isBookmarked = false; // وضعیت محلی بوکمارک

  @override
  void initState() {
    super.initState();
    // دریافت اولیه وضعیت بوکمارک
    context.read<BookmarkBloc>().add(GetCityByNameEvent(widget.name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookmarkBloc, BookmarkState>(
      listenWhen: (previous, current) =>
      previous.getCityStatus != current.getCityStatus,
      listener: (context, state) {
        if (state.getCityStatus is GetCityCompleted) {
          final getCityCompleted = state.getCityStatus as GetCityCompleted;
          final City? city = getCityCompleted.city;
          setState(() {
            isBookmarked = city != null;
          });
        }
      },
      child: IconButton(
        onPressed: () {
          // تغییر وضعیت محلی بلافاصله
          final newStatus = !isBookmarked;
          setState(() {
            isBookmarked = newStatus;
          });
          // حالا رویداد مناسب رو ارسال کن
          if (newStatus) {
            // اگر می‌خوای شهر رو ذخیره کنی
            context.read<BookmarkBloc>().add(SaveCwEvent(widget.name));
          } else {
            // اگر می‌خوای شهر رو حذف کنی
            context.read<BookmarkBloc>().add(DeleteCityEvent(widget.name));
          }
        },
        icon: Icon(
          isBookmarked ? Icons.star : Icons.star_border,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
