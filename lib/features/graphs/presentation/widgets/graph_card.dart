import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tautulli_remote/translations/locale_keys.g.dart';

import '../../../../core/types/bloc_status.dart';
import '../../../../core/types/graph_chart_type.dart';
import '../../../../core/types/graph_type.dart';
import '../../../../core/types/tautulli_types.dart';
import '../../data/models/graph_model.dart';
import '../../data/models/graph_series_data_model.dart';
import 'bar_chart_graph.dart';
import 'graph_card_legend.dart';
import 'line_chart_graph.dart';

class GraphCard extends StatelessWidget {
  final GraphChartType graphChartType;
  final GraphYAxis yAxis;
  final GraphType graphType;
  final GraphModel graph;
  final bool? isVertical;

  const GraphCard({
    super.key,
    required this.graphChartType,
    required this.yAxis,
    required this.graphType,
    required this.graph,
    this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    // Make sure the seriesDataModel contains data > 0 so the graphs can display.
    bool containsData = false;
    if (graph.graphDataModel != null) {
      for (GraphSeriesDataModel seriesDataModel
          in graph.graphDataModel!.seriesDataList) {
        if (seriesDataModel.seriesData.isNotEmpty &&
            seriesDataModel.seriesData.cast<int>().reduce(max) > 0) {
          containsData = true;
          break;
        }
      }
    }

    return Card(
      child: SizedBox(
        height: 275,
        child: Builder(builder: (context) {
          if (graph.status == BlocStatus.failure) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (graph.failureMessage != null)
                    Text(
                      graph.failureMessage!,
                      textAlign: TextAlign.center,
                    ),
                  if (graph.failureSuggestion != null)
                    Text(
                      graph.failureSuggestion!,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          }

          if (graph.graphDataModel == null &&
              graph.status != BlocStatus.initial) {
            return const Center(
              child: Text('No graph data provided'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  child: Builder(
                    builder: (context) {
                      if (graph.graphDataModel != null) {
                        if (containsData == true) {
                          switch (graphChartType) {
                            case (GraphChartType.line):
                              return LineChartGraph(
                                yAxis: yAxis,
                                graphData: graph.graphDataModel!,
                              );
                            case (GraphChartType.bar):
                              return BarChartGraph(
                                yAxis: yAxis,
                                graphType: graphType,
                                graphData: graph.graphDataModel!,
                                isVertical: isVertical,
                              );
                          }
                        }
                      }

                      return Center(
                        child: const Text(LocaleKeys.no_data).tr(),
                      );
                    },
                  ),
                ),
              ),
              if (graph.graphDataModel != null && containsData)
                GraphCardLegend(
                  graphData: graph.graphDataModel!,
                ),
              graph.status == BlocStatus.initial
                  ? LinearProgressIndicator(
                      backgroundColor: Theme.of(context).cardColor,
                    )
                  : const SizedBox(height: 4),
            ],
          );
        }),
      ),
    );
  }
}
