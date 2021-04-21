part of 'play_graphs_bloc.dart';

abstract class PlayGraphsState extends Equatable {
  const PlayGraphsState();
}

class PlayGraphsInitial extends PlayGraphsState {
  final int timeRange;

  PlayGraphsInitial({this.timeRange});

  @override
  List<Object> get props => [timeRange];
}

class PlayGraphsLoaded extends PlayGraphsState {
  final GraphState playsByDate;
  final GraphState playsByDayOfWeek;
  final GraphState playsByHourOfDay;
  final GraphState playsByTop10Platforms;

  PlayGraphsLoaded({
    @required this.playsByDate,
    @required this.playsByDayOfWeek,
    @required this.playsByHourOfDay,
    @required this.playsByTop10Platforms,
  });

  PlayGraphsLoaded copyWith({
    GraphState playsByDate,
    GraphState playsByDayOfWeek,
    GraphState playsByHourOfDay,
    GraphState playsByTop10Platforms,
  }) {
    return PlayGraphsLoaded(
      playsByDate: playsByDate ?? this.playsByDate,
      playsByDayOfWeek: playsByDayOfWeek ?? this.playsByDayOfWeek,
      playsByHourOfDay: playsByHourOfDay ?? this.playsByHourOfDay,
      playsByTop10Platforms:
          playsByTop10Platforms ?? this.playsByTop10Platforms,
    );
  }

  @override
  List<Object> get props => [
        playsByDate,
        playsByDayOfWeek,
        playsByHourOfDay,
        playsByTop10Platforms,
      ];
}
