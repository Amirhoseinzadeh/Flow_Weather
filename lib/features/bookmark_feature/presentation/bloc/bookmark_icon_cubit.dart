import 'package:bloc/bloc.dart';

class BookmarkIconState {
  final bool isBookmarked;
  final double animationValue;

  BookmarkIconState({required this.isBookmarked, required this.animationValue});
}

class BookmarkIconCubit extends Cubit<BookmarkIconState> {
  BookmarkIconCubit()
      : super(BookmarkIconState(isBookmarked: false, animationValue: 0.0));

  void updateBookmarkStatus(bool isBookmarked) {
    emit(BookmarkIconState(
      isBookmarked: isBookmarked,
      animationValue: isBookmarked ? 1.0 : 0.0,
    ));
  }

  void toggleBookmark() {
    final newStatus = !state.isBookmarked;
    emit(BookmarkIconState(
      isBookmarked: newStatus,
      animationValue: newStatus ? 1.0 : 0.0,
    ));
  }
}