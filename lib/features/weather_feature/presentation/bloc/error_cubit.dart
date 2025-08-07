import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorCubit extends Cubit<ErrorState> {
  ErrorCubit() : super(ErrorInitial());

  void showError(String message) {
    emit(ErrorDisplaying(message));
    // بعد از 2 ثانیه، پیام رو پاک کن
    Future.delayed(const Duration(seconds: 2), () {
      emit(ErrorInitial());
    });
  }
}

abstract class ErrorState {}

class ErrorInitial extends ErrorState {}

class ErrorDisplaying extends ErrorState {
  final String message;

  ErrorDisplaying(this.message);
}