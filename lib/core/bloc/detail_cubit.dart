import 'package:flutter_bloc/flutter_bloc.dart';

class DetailCubit extends Cubit<bool> {
  DetailCubit() : super(false);

  void toggleDetail() {
    emit(!state);
  }
}