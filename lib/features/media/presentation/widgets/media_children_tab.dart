import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

import '../../../../core/pages/status_page.dart';
import '../../../../core/types/bloc_status.dart';
import '../../../../core/types/media_type.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../data/models/media_model.dart';
import '../bloc/children_metadata_bloc.dart';
import '../pages/media_page.dart';
import 'media_list_poster.dart';

class MediaChildrenTab extends StatefulWidget {
  final int ratingKey;
  final MediaType mediaType;

  const MediaChildrenTab({
    super.key,
    required this.ratingKey,
    required this.mediaType,
  });

  @override
  State<MediaChildrenTab> createState() => _MediaChildrenTabState();
}

class _MediaChildrenTabState extends State<MediaChildrenTab> {
  late ChildrenMetadataBloc _childrenMetadataBloc;
  late SettingsBloc _settingsBloc;
  late String _tautulliId;

  @override
  void initState() {
    super.initState();

    _childrenMetadataBloc = context.read<ChildrenMetadataBloc>();
    _settingsBloc = context.read<SettingsBloc>();
    final settingsState = _settingsBloc.state as SettingsSuccess;

    _tautulliId = settingsState.appSettings.activeServer.tautulliId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenMetadataBloc, ChildrenMetadataState>(
      builder: (context, state) {
        return ThemedRefreshIndicator(
          onRefresh: () {
            _childrenMetadataBloc.add(
              ChildrenMetadataFetched(
                tautulliId: _tautulliId,
                ratingKey: widget.ratingKey,
                freshFetch: true,
                settingsBloc: _settingsBloc,
              ),
            );

            return Future.value();
          },
          child: PageBody(
            loading: state.status == BlocStatus.initial,
            child: Builder(
              builder: (context) {
                if (state.status == BlocStatus.failure) {
                  return StatusPage(
                    scrollable: true,
                    message: state.message ?? 'Unknown failure.',
                    suggestion: state.suggestion,
                  );
                }

                return VsScrollbar(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: [
                        MediaType.album,
                        MediaType.artist,
                        MediaType.photo,
                        MediaType.photoAlbum,
                        MediaType.track,
                      ].contains(widget.mediaType)
                          ? 1
                          : 2 / 3,
                      children: state.children != null
                          ? state.children!
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: MediaListPoster(
                                    mediaType: item.mediaType,
                                    title: item.title,
                                    year: item.year,
                                    ratingKey: item.ratingKey,
                                    posterUri: item.imageUri,
                                    squarePosterFitCover:
                                        [MediaType.photo, MediaType.photoAlbum].contains(item.mediaType),
                                    onTap: () async {
                                      if (item.mediaType == MediaType.photoAlbum) {
                                      } else {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MediaPage(
                                              mediaType: item.mediaType ?? MediaType.unknown,
                                              posterUri: item.imageUri,
                                              title: _buildTitle(item),
                                              subtitle: _buildSubtitle(item),
                                              itemDetail: _buildItemDetail(item),
                                              ratingKey: item.ratingKey!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              )
                              .toList()
                          : [],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String? _buildTitle(MediaModel model) {
    if (model.mediaType == MediaType.season) return model.parentTitle;

    return model.title;
  }

  Text? _buildSubtitle(MediaModel model) {
    if (model.mediaType == MediaType.season) return Text(model.title ?? '');

    if (model.mediaType == MediaType.album) return Text(model.parentTitle ?? '');

    if ([
      MediaType.movie,
      MediaType.show,
    ].contains(model.mediaType)) {
      return Text(model.year.toString());
    }

    return null;
  }

  Text? _buildItemDetail(MediaModel model) {
    if (model.mediaType == MediaType.album) return Text(model.year.toString());

    return null;
  }
}