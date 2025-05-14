import 'package:flutter_bloc/flutter_bloc.dart';

class DetailCubit extends Cubit<bool> {
  DetailCubit() : super(false); // مقدار پیش‌فرض false (بسته)

  void toggleDetail() {
    emit(!state); // تغییر وضعیت بین true و false
  }
}