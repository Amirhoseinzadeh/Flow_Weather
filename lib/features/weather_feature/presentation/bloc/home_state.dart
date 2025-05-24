part of 'home_bloc.dart';

class HomeState extends Equatable {
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;
  final bool isLocationLoading;
  final bool isCityLoading;
  final String? errorMessage;
  final bool isDetailsExpanded;

  const HomeState({
    required this.cwStatus,
    required this.fwStatus,
    required this.aqStatus,
    required this.isLocationLoading,
    required this.isCityLoading,
    this.errorMessage,
    this.isDetailsExpanded = false,
  });

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
    bool? isLocationLoading,
    bool? isCityLoading,
    String? errorMessage,
    bool? isDetailsExpanded,
  }) {
    return HomeState(
      cwStatus: newCwStatus ?? cwStatus,
      fwStatus: newFwStatus ?? fwStatus,
      aqStatus: newAirQualityStatus ?? aqStatus,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isCityLoading: isCityLoading ?? this.isCityLoading,
      errorMessage: errorMessage,
      isDetailsExpanded: isDetailsExpanded ?? this.isDetailsExpanded,
    );
  }

  @override
  List<Object?> get props => [cwStatus, fwStatus, aqStatus, isLocationLoading, isCityLoading, errorMessage, errorMessage, isDetailsExpanded];
}