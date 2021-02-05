import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/helpers/failure_mapper_helper.dart';
import '../../../image_url/domain/usecases/get_image_url.dart';
import '../../../media/domain/usecases/get_metadata.dart';
import '../../domain/entities/synced_item.dart';
import '../../domain/usecases/get_synced_items.dart';

part 'synced_items_event.dart';
part 'synced_items_state.dart';

List<SyncedItem> _syncedItemsListCache;
String _tautulliIdCache;

class SyncedItemsBloc extends Bloc<SyncedItemsEvent, SyncedItemsState> {
  final GetSyncedItems getSyncedItems;
  final GetMetadata getMetadata;
  final GetImageUrl getImageUrl;

  SyncedItemsBloc({
    @required this.getSyncedItems,
    @required this.getMetadata,
    @required this.getImageUrl,
  }) : super(SyncedItemsInitial());

  @override
  Stream<SyncedItemsState> mapEventToState(
    SyncedItemsEvent event,
  ) async* {
    if (event is SyncedItemsFetch) {
      yield* _fetchSyncedItems(
        tautulliId: event.tautulliId,
        useCachedList: true,
      );

      _tautulliIdCache = event.tautulliId;
    }
    if (event is SyncedItemsFilter) {
      yield SyncedItemsInitial();
      yield* _fetchSyncedItems(
        tautulliId: event.tautulliId,
      );

      _tautulliIdCache = event.tautulliId;
    }
  }

  Stream<SyncedItemsState> _fetchSyncedItems({
    @required String tautulliId,
    bool useCachedList = false,
  }) async* {
    if (useCachedList &&
        _syncedItemsListCache != null &&
        _tautulliIdCache == tautulliId) {
      yield SyncedItemsSuccess(
        list: _syncedItemsListCache,
      );
    } else {
      final syncedItemsListOrFailure = await getSyncedItems(
        tautulliId: tautulliId,
      );

      yield* syncedItemsListOrFailure.fold(
        (failure) async* {
          yield SyncedItemsFailure(
            failure: failure,
            message: FailureMapperHelper.mapFailureToMessage(failure),
            suggestion: FailureMapperHelper.mapFailureToSuggestion(failure),
          );
        },
        (list) async* {
          await _getImages(list: list, tautulliId: tautulliId);

          _syncedItemsListCache = list;

          yield SyncedItemsSuccess(
            list: list,
          );
        },
      );
    }
  }

  Future<void> _getImages({
    @required List<SyncedItem> list,
    @required String tautulliId,
  }) async {
    for (SyncedItem syncedItem in list) {
      int grandparentRatingKey;
      String grandparentThumb;
      int parentRatingKey;
      String parentThumb;
      int ratingKey = syncedItem.ratingKey;
      String thumb;

      // If item uses parent or grandparent info for poster then use GetMetadata to fetch correct thumb/rating key
      if (['episode', 'track'].contains(syncedItem.mediaType)) {
        final metadataOrFailure = await getMetadata(
          tautulliId: tautulliId,
          syncId: syncedItem.syncId,
        );

        metadataOrFailure.fold(
          (failure) {
            //TODO: Log failure
          },
          (item) {
            grandparentRatingKey = item.grandparentRatingKey;
            grandparentThumb = item.grandparentThumb;
            parentRatingKey = item.parentRatingKey;
            parentThumb = item.parentThumb;
            ratingKey = item.ratingKey;
            thumb = item.thumb;
          },
        );
      }

      //* Fetch and assign image URLs
      String posterImg;
      int posterRatingKey;
      String posterFallback;

      // Assign values for poster URL
      switch (syncedItem.mediaType) {
        case ('movie'):
          posterImg = thumb;
          posterRatingKey = ratingKey;
          posterFallback = 'poster';
          break;
        case ('episode'):
          posterImg = grandparentThumb;
          posterRatingKey = grandparentRatingKey;
          posterFallback = 'poster';
          break;
        case ('season'):
          posterImg = parentThumb;
          posterRatingKey = ratingKey;
          posterFallback = 'poster';
          break;
        case ('track'):
          posterImg = thumb;
          posterRatingKey = parentRatingKey;
          posterFallback = 'cover';
          break;
      }

      // Attempt to get poster URL
      final failureOrPosterUrl = await getImageUrl(
        tautulliId: tautulliId,
        img: posterImg,
        ratingKey: posterRatingKey ?? ratingKey,
        fallback: posterFallback,
      );
      failureOrPosterUrl.fold(
        (failure) {
          //TODO: log failure
          // logging.warning(
          //     'SyncedItem: Failed to load poster for rating key: ${syncedItem.ratingKey}');
        },
        (url) {
          syncedItem.posterUrl = url;
        },
      );
    }
  }
}

void clearCache() {
  _syncedItemsListCache = null;
  _tautulliIdCache = null;
}