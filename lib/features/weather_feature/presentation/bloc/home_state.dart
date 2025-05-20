part of 'home_bloc.dart';

class HomeState extends Equatable {
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;
  final bool isLocationLoading;
  final bool isCityLoading;
  final String? errorMessage;

  const HomeState({
    required this.cwStatus,
    required this.fwStatus,
    required this.aqStatus,
    required this.isLocationLoading,
    required this.isCityLoading,
    this.errorMessage,
  });

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
    bool? isLocationLoading,
    bool? isCityLoading,
    String? errorMessage,
  }) {
    return HomeState(
      cwStatus: newCwStatus ?? cwStatus,
      fwStatus: newFwStatus ?? fwStatus,
      aqStatus: newAirQualityStatus ?? aqStatus,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isCityLoading: isCityLoading ?? this.isCityLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [cwStatus, fwStatus, aqStatus, isLocationLoading, isCityLoading, errorMessage];
}