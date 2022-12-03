import 'package:dartz/dartz.dart';

import '../../../../core/api/tautulli/tautulli_api.dart';
import '../models/activity_model.dart';

abstract class ActivityDataSource {
  Future<Tuple2<List<ActivityModel>, bool>> getActivity({
    required String tautulliId,
    int? sessionKey,
    String? sessionId,
  });
}

class ActivityDataSourceImpl implements ActivityDataSource {
  final GetActivity getActivityApi;

  ActivityDataSourceImpl({
    required this.getActivityApi,
  });

  @override
  Future<Tuple2<List<ActivityModel>, bool>> getActivity({
    required String tautulliId,
    int? sessionKey,
    String? sessionId,
  }) async {
    final result = await getActivityApi(
      tautulliId: tautulliId,
      sessionKey: sessionKey,
      sessionId: sessionId,
    );

    final List<ActivityModel> activityList = result.value1['response']['data']['sessions']
        .map<ActivityModel>((activityItem) => ActivityModel.fromJson(activityItem))
        .toList();

    return Tuple2(activityList, result.value2);
  }
}
