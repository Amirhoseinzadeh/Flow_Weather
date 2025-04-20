part of 'home_bloc.dart';

class HomeState extends Equatable{
  final CwStatus cwStatus;
  final FwStatus fwStatus;
  final AirQualityStatus aqStatus;

  HomeState({required this.cwStatus,required this.fwStatus,required this.aqStatus});

  HomeState copyWith({
    CwStatus? newCwStatus,
    FwStatus? newFwStatus,
    AirQualityStatus? newAirQualityStatus,
  }){
    return HomeState(
        cwStatus: newCwStatus ?? this.cwStatus,
        fwStatus: newFwStatus ?? this.fwStatus,
        aqStatus: newAirQualityStatus ?? this.aqStatus,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    cwStatus,
    fwStatus,
    aqStatus
  ];
}
