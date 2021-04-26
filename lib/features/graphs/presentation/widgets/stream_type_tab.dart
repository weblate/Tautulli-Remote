import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/color_palette_helper.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/graph_state.dart';
import '../bloc/stream_info_graphs_bloc.dart';
import 'bar_chart_graph.dart';
import 'graph_error_message.dart';
import 'graph_heading.dart';
import 'line_chart_graph.dart';

class StreamTypeTab extends StatefulWidget {
  final String tautulliId;
  final int timeRange;
  final String yAxis;

  StreamTypeTab({
    Key key,
    @required this.tautulliId,
    @required this.timeRange,
    @required this.yAxis,
  }) : super(key: key);

  @override
  _StreamTypeTabState createState() => _StreamTypeTabState();
}

class _StreamTypeTabState extends State<StreamTypeTab> {
  Completer<void> _refreshCompleter;
  SettingsBloc _settingsBloc;
  StreamInfoGraphsBloc _streamInfoGraphsBloc;
  bool _maskSensitiveInfo;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _settingsBloc = context.read<SettingsBloc>();
    _streamInfoGraphsBloc = context.read<StreamInfoGraphsBloc>();

    final settingsState = _settingsBloc.state;

    if (settingsState is SettingsLoadSuccess) {
      _maskSensitiveInfo = settingsState.maskSensitiveInfo;

      _streamInfoGraphsBloc.add(
        StreamInfoGraphsFetch(
          tautulliId: widget.tautulliId,
          timeRange: widget.timeRange,
          yAxis: widget.yAxis,
          settingsBloc: _settingsBloc,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StreamInfoGraphsBloc, StreamInfoGraphsState>(
      listener: (context, state) {
        if (state is StreamInfoGraphsLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () {
            _streamInfoGraphsBloc.add(
              StreamInfoGraphsFetch(
                tautulliId: widget.tautulliId,
                timeRange: widget.timeRange,
                yAxis: widget.yAxis,
                settingsBloc: _settingsBloc,
              ),
            );
            return _refreshCompleter.future;
          },
          child: Scrollbar(
            child: ListView(
              children: [
                GraphHeading(
                  graphHeading:
                      'Daily Play ${widget.yAxis == 'plays' ? 'Count' : 'Duration'} by Stream Type',
                ),
                (state is StreamInfoGraphsLoaded &&
                        state.playsByStreamType.graphCurrentState !=
                            GraphCurrentState.failure &&
                        state.playsByStreamType.graphData != null &&
                        widget.yAxis == state.playsByStreamType.yAxis)
                    ? LineChartGraph(
                        graphState: state.playsByStreamType,
                        dataIsMediaType: false,
                      )
                    : _GraphLoadingOrFailed(
                        child: state is StreamInfoGraphsLoaded &&
                                state.playsByStreamType.graphCurrentState ==
                                    GraphCurrentState.failure
                            ? GraphErrorMessage(
                                message: state.playsByStreamType.failureMessage,
                                suggestion:
                                    state.playsByStreamType.failureSuggestion,
                              )
                            : const CircularProgressIndicator(),
                      ),
                const SizedBox(height: 8),
                GraphHeading(
                  graphHeading:
                      'Play ${widget.yAxis == 'plays' ? 'Count' : 'Duration'} by Source Resolution',
                ),
                (state is StreamInfoGraphsLoaded &&
                        state.playsBySourceResolution.graphCurrentState !=
                            GraphCurrentState.failure &&
                        state.playsBySourceResolution.graphData != null &&
                        widget.yAxis == state.playsBySourceResolution.yAxis)
                    ? BarChartGraph(
                        graphState: state.playsBySourceResolution,
                        dataIsMediaType: false,
                      )
                    : _GraphLoadingOrFailed(
                        child: state is StreamInfoGraphsLoaded &&
                                state.playsBySourceResolution
                                        .graphCurrentState ==
                                    GraphCurrentState.failure
                            ? GraphErrorMessage(
                                message: state
                                    .playsBySourceResolution.failureMessage,
                                suggestion: state
                                    .playsBySourceResolution.failureSuggestion,
                              )
                            : const CircularProgressIndicator(),
                      ),
                const SizedBox(height: 8),
                GraphHeading(
                  graphHeading:
                      'Play ${widget.yAxis == 'plays' ? 'Count' : 'Duration'} by Stream Resolution',
                ),
                (state is StreamInfoGraphsLoaded &&
                        state.playsByStreamResolution.graphCurrentState !=
                            GraphCurrentState.failure &&
                        state.playsByStreamResolution.graphData != null &&
                        widget.yAxis == state.playsByStreamResolution.yAxis)
                    ? BarChartGraph(
                        graphState: state.playsByStreamResolution,
                        dataIsMediaType: false,
                      )
                    : _GraphLoadingOrFailed(
                        child: state is StreamInfoGraphsLoaded &&
                                state.playsByStreamResolution
                                        .graphCurrentState ==
                                    GraphCurrentState.failure
                            ? GraphErrorMessage(
                                message: state
                                    .playsByStreamResolution.failureMessage,
                                suggestion: state
                                    .playsByStreamResolution.failureSuggestion,
                              )
                            : const CircularProgressIndicator(),
                      ),
                const SizedBox(height: 8),
                GraphHeading(
                  graphHeading:
                      'Play ${widget.yAxis == 'plays' ? 'Count' : 'Duration'} by Platform and Stream Type',
                ),
                (state is StreamInfoGraphsLoaded &&
                        state.streamTypeByTop10Platforms.graphCurrentState !=
                            GraphCurrentState.failure &&
                        state.streamTypeByTop10Platforms.graphData != null &&
                        widget.yAxis == state.streamTypeByTop10Platforms.yAxis)
                    ? BarChartGraph(
                        graphState: state.streamTypeByTop10Platforms,
                        dataIsMediaType: false,
                        bottomTitlesRotateAngle: 320,
                        bottomTitlesMargin: 8,
                      )
                    : _GraphLoadingOrFailed(
                        child: state is StreamInfoGraphsLoaded &&
                                state.streamTypeByTop10Platforms
                                        .graphCurrentState ==
                                    GraphCurrentState.failure
                            ? GraphErrorMessage(
                                message: state
                                    .streamTypeByTop10Platforms.failureMessage,
                                suggestion: state.streamTypeByTop10Platforms
                                    .failureSuggestion,
                              )
                            : const CircularProgressIndicator(),
                      ),
                const SizedBox(height: 8),
                GraphHeading(
                  graphHeading:
                      'Play ${widget.yAxis == 'plays' ? 'Count' : 'Duration'} by User and Stream Type',
                ),
                (state is StreamInfoGraphsLoaded &&
                        state.streamTypeByTop10Users.graphCurrentState !=
                            GraphCurrentState.failure &&
                        state.streamTypeByTop10Users.graphData != null &&
                        widget.yAxis == state.streamTypeByTop10Users.yAxis)
                    ? BarChartGraph(
                        graphState: state.streamTypeByTop10Users,
                        dataIsMediaType: false,
                        bottomTitlesRotateAngle: 320,
                        bottomTitlesMargin: 8,
                        maskSensitiveInfo: _maskSensitiveInfo,
                      )
                    : _GraphLoadingOrFailed(
                        child: state is StreamInfoGraphsLoaded &&
                                state.streamTypeByTop10Users
                                        .graphCurrentState ==
                                    GraphCurrentState.failure
                            ? GraphErrorMessage(
                                message:
                                    state.streamTypeByTop10Users.failureMessage,
                                suggestion: state
                                    .streamTypeByTop10Users.failureSuggestion,
                              )
                            : const CircularProgressIndicator(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GraphLoadingOrFailed extends StatelessWidget {
  final Widget child;

  const _GraphLoadingOrFailed({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 8,
        right: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 275,
          color: TautulliColorPalette.gunmetal,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
