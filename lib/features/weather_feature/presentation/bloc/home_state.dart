part of 'home_bloc.dart';

class HomeState extends Equatable {
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;
  final bool isLocationLoading;
  final bool isCityLoading; // New field for city loading state

  HomeState({
    required this.cwStatus,
    required this.fwStatus,
    required this.aqStatus,
    required this.isLocationLoading,
    required this.isCityLoading,
  });

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
    bool? isLocationLoading,
    bool? isCityLoading,
  }) {
    return HomeState(
      cwStatus: newCwStatus ?? this.cwStatus,
      fwStatus: newFwStatus ?? this.fwStatus,
      aqStatus: newAirQualityStatus ?? this.aqStatus,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isCityLoading: isCityLoading ?? this.isCityLoading,
    );
  }

  @override
  List<Object?> get props => [cwStatus, fwStatus, aqStatus, isLocationLoading, isCityLoading];
}