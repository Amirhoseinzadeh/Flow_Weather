part of 'home_bloc.dart';

class HomeState extends Equatable {
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;
  final bool isLocationLoading;

  HomeState({
    required this.cwStatus,
    required this.fwStatus,
    required this.aqStatus,
    required this.isLocationLoading,
  });

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
    bool? isLocationLoading,
  }) {
    return HomeState(
      cwStatus: newCwStatus ?? this.cwStatus,
      fwStatus: newFwStatus ?? this.fwStatus,
      aqStatus: newAirQualityStatus ?? this.aqStatus,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
    );
  }

  @override
  List<Object?> get props => [cwStatus, fwStatus, aqStatus, isLocationLoading];
}