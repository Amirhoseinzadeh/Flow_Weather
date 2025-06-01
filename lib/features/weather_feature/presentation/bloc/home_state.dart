part of 'home_bloc.dart';

class HomeState extends Equatable {
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;
  final bool isLocationLoading;
  final bool isCityLoading;
  final String? errorMessage;
  final bool isDetailsExpanded;
  final String? searchCityName;


  const HomeState({
    required this.cwStatus,
    required this.fwStatus,
    required this.aqStatus,
    required this.isLocationLoading,
    required this.isCityLoading,
    this.errorMessage,
    this.isDetailsExpanded = false,
    this.searchCityName,
  });

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
    bool? isLocationLoading,
    bool? isCityLoading,
    String? errorMessage,
    bool? isDetailsExpanded,
    String? searchCityName,
  }) {
    return HomeState(
      cwStatus: newCwStatus ?? cwStatus,
      fwStatus: newFwStatus ?? fwStatus,
      aqStatus: newAirQualityStatus ?? aqStatus,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isCityLoading: isCityLoading ?? this.isCityLoading,
      errorMessage: errorMessage,
      isDetailsExpanded: isDetailsExpanded ?? this.isDetailsExpanded,
      searchCityName: searchCityName ?? this.searchCityName,
    );
  }

  @override
  List<Object?> get props => [cwStatus, fwStatus, aqStatus, isLocationLoading, isCityLoading, errorMessage, errorMessage, isDetailsExpanded,searchCityName];
}