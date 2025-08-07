import 'package:flow_weather/features/weather_feature/presentation/bloc/error_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CustomErrorDialog {
  static void show(BuildContext context, String message) {
    final errorCubit = context.read<ErrorCubit>();
    errorCubit.showError(message);
  }
}

class ErrorDialogWidget extends StatelessWidget {
  const ErrorDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ErrorCubit, ErrorState>(
      builder: (context, state) {
        if (state is ErrorDisplaying) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            onEnd: () {
              // انیمیشن محو شدن به‌صورت خودکار با تغییر حالت به ErrorInitial اعمال می‌شه
            },
            child: Center(
              child: Material(
                color: Colors.grey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'nazanin'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}