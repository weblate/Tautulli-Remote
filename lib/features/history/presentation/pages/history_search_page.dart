import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:quiver/strings.dart';

import '../../../../core/pages/status_page.dart';
import '../../../../core/types/bloc_status.dart';
import '../../../../core/widgets/bottom_loader.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../dependency_injection.dart' as di;
import '../../../../translations/locale_keys.g.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../users/presentation/bloc/users_bloc.dart';
import '../bloc/search_history_bloc.dart';
import '../widgets/history_card.dart';

class HistorySearchPage extends StatelessWidget {
  const HistorySearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SearchHistoryBloc>(),
      child: const HistorySearchView(),
    );
  }
}

class HistorySearchView extends StatefulWidget {
  const HistorySearchView({
    super.key,
  });

  @override
  State<HistorySearchView> createState() => _HistorySearchViewState();
}

class _HistorySearchViewState extends State<HistorySearchView> {
  final TextEditingController _controller = TextEditingController();
  bool hasContent = false;

  final _scrollController = ScrollController();
  late SearchHistoryBloc _searchHistoryBloc;
  late SettingsBloc _settingsBloc;
  late String _tautulliId;
  int? _userId;
  String _mediaType = 'all';
  String _transcodeDecision = 'all';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _searchHistoryBloc = context.read<SearchHistoryBloc>();
    _settingsBloc = context.read<SettingsBloc>();
    final settingsState = _settingsBloc.state as SettingsSuccess;

    _tautulliId = settingsState.appSettings.activeServer.tautulliId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            settingsState as SettingsSuccess;

            return TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: Theme.of(context).colorScheme.tertiary,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).textTheme.subtitle2!.color!,
                    width: 2,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).textTheme.subtitle2!.color!,
                    width: 2,
                  ),
                ),
                hintText: LocaleKeys.search_history_title.tr(),
                suffixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.solidCircleXmark,
                      color: isNotEmpty(_controller.text)
                          ? Theme.of(context).textTheme.subtitle2!.color!
                          : Colors.transparent,
                      size: 20,
                    ),
                    onPressed: isNotEmpty(_controller.text)
                        ? () {
                            setState(() {
                              _controller.text = '';
                              hasContent = false;
                            });
                          }
                        : null,
                  ),
                ),
              ),
              onChanged: (value) {
                if (!hasContent) {
                  setState(() {
                    hasContent = true;
                  });
                }

                if (hasContent && value == '') {
                  setState(() {
                    hasContent = false;
                  });
                }
              },
              onSubmitted: (value) {
                if (isNotBlank(value)) {
                  context.read<SearchHistoryBloc>().add(
                        SearchHistoryFetched(
                          tautulliId:
                              settingsState.appSettings.activeServer.tautulliId,
                          search: value,
                          freshFetch: true,
                          settingsBloc: context.read<SettingsBloc>(),
                        ),
                      );
                }
              },
            );
          },
        ),
        actions: _appBarActions(),
      ),
      body: BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
        builder: (context, searchState) {
          return PageBody(
            loading: searchState.status == BlocStatus.inProgress,
            child: Builder(
              builder: (context) {
                if (searchState.history.isEmpty) {
                  if (searchState.status == BlocStatus.failure) {
                    return StatusPage(
                      scrollable: true,
                      message: searchState.message ?? '',
                      suggestion: searchState.suggestion ?? '',
                    );
                  }
                  if (searchState.status == BlocStatus.success) {
                    return StatusPage(
                      scrollable: true,
                      message: LocaleKeys.history_empty_message.tr(),
                    );
                  }
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: searchState.hasReachedMax ||
                          searchState.status == BlocStatus.initial ||
                          searchState.status == BlocStatus.inProgress
                      ? searchState.history.length
                      : searchState.history.length + 1,
                  separatorBuilder: (context, index) => const Gap(8),
                  itemBuilder: (context, index) {
                    if (index >= searchState.history.length) {
                      return BottomLoader(
                        status: searchState.status,
                        failure: searchState.failure,
                        message: searchState.message,
                        suggestion: searchState.suggestion,
                        onTap: () {
                          _searchHistoryBloc.add(
                            SearchHistoryFetched(
                              tautulliId: _tautulliId,
                              userId: _userId,
                              mediaType: _mediaType,
                              transcodeDecision: _transcodeDecision,
                              settingsBloc: _settingsBloc,
                            ),
                          );
                        },
                      );
                    }

                    final history = searchState.history[index];

                    return HistoryCard(history: history);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _searchHistoryBloc.add(
        SearchHistoryFetched(
          tautulliId: _tautulliId,
          userId: _userId,
          mediaType: _mediaType,
          transcodeDecision: _transcodeDecision,
          settingsBloc: _settingsBloc,
        ),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  List<Widget> _appBarActions() {
    return [
      BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          return Stack(
            children: [
              Center(
                child: PopupMenuButton(
                  enabled: state.status == BlocStatus.success,
                  icon: FaIcon(
                    state.status == BlocStatus.failure
                        ? FontAwesomeIcons.userSlash
                        : FontAwesomeIcons.solidUser,
                    color: (_userId != -1 && _userId != null)
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                    size: 20,
                  ),
                  tooltip: LocaleKeys.select_user_title.tr(),
                  onSelected: (value) {
                    setState(() {
                      _userId = value as int;
                    });

                    _searchHistoryBloc.add(
                      SearchHistoryFetched(
                        tautulliId: _tautulliId,
                        userId: _userId,
                        mediaType: _mediaType,
                        transcodeDecision: _transcodeDecision,
                        freshFetch: true,
                        settingsBloc: _settingsBloc,
                      ),
                    );
                  },
                  itemBuilder: (context) {
                    return state.users
                        .map(
                          (user) => PopupMenuItem(
                            value: user.userId,
                            child: BlocBuilder<SettingsBloc, SettingsState>(
                              builder: (context, state) {
                                state as SettingsSuccess;

                                return Text(
                                  state.appSettings.maskSensitiveInfo
                                      ? LocaleKeys.hidden_message.tr()
                                      : user.friendlyName ?? '',
                                  style: TextStyle(
                                    color: _userId == user.userId!
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList();
                  },
                ),
              ),
              if (state.status == BlocStatus.initial)
                const Positioned(
                  bottom: 12,
                  right: 10,
                  child: SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );
        },
      ),
      BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          return Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: DividerThemeData(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            child: PopupMenuButton(
              icon: FaIcon(
                FontAwesomeIcons.filter,
                color: _mediaType != 'all' || _transcodeDecision != 'all'
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                size: 20,
              ),
              tooltip: LocaleKeys.filter_history_title.tr(),
              itemBuilder: (context) {
                ValueNotifier<String> selectedMediaType = ValueNotifier(
                  _mediaType,
                );
                ValueNotifier<String> selectedTranscodeType =
                    ValueNotifier(_transcodeDecision);

                List mediaTypes = [
                  'all',
                  'movie',
                  'episode',
                  'track',
                  'live',
                ];
                List transcodeTypes = [
                  'all',
                  'direct play',
                  'copy',
                  'transcode',
                ];

                return List.generate(
                  10,
                  (index) {
                    if (index == 5) {
                      return const PopupMenuDivider();
                    } else if (index < 5) {
                      return PopupMenuItem(
                        padding: const EdgeInsets.all(0),
                        child: AnimatedBuilder(
                          animation: selectedMediaType,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              _mediaTypeToTitle(mediaTypes[index]),
                            ),
                          ),
                          builder: (context, child) {
                            return RadioListTile<String>(
                              value: mediaTypes[index],
                              groupValue: selectedMediaType.value,
                              onChanged: (value) {
                                if (value != null && _mediaType != value) {
                                  selectedMediaType.value = value;
                                  setState(() {
                                    _mediaType = value;
                                  });
                                  _searchHistoryBloc.add(
                                    SearchHistoryFetched(
                                      tautulliId: _tautulliId,
                                      userId: _userId,
                                      mediaType: _mediaType,
                                      transcodeDecision: _transcodeDecision,
                                      freshFetch: true,
                                      settingsBloc: _settingsBloc,
                                    ),
                                  );
                                }
                              },
                              title: child,
                            );
                          },
                        ),
                      );
                    } else {
                      return PopupMenuItem(
                        padding: const EdgeInsets.all(0),
                        child: AnimatedBuilder(
                          animation: selectedTranscodeType,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              _transcodeDecisionToTitle(
                                transcodeTypes[index - 6],
                              ),
                            ),
                          ),
                          builder: (context, child) {
                            return RadioListTile<String>(
                              value: transcodeTypes[index - 6],
                              groupValue: selectedTranscodeType.value,
                              onChanged: (value) {
                                if (value != null &&
                                    _transcodeDecision != value) {
                                  selectedTranscodeType.value = value;
                                  setState(() {
                                    _transcodeDecision = value;
                                  });
                                  _searchHistoryBloc.add(
                                    SearchHistoryFetched(
                                      tautulliId: _tautulliId,
                                      userId: _userId,
                                      mediaType: _mediaType,
                                      transcodeDecision: _transcodeDecision,
                                      freshFetch: true,
                                      settingsBloc: _settingsBloc,
                                    ),
                                  );
                                }
                              },
                              title: child,
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    ];
  }
}

String _mediaTypeToTitle(String mediaType) {
  switch (mediaType) {
    case ('all'):
      return LocaleKeys.all_title.tr();
    case ('movie'):
      return LocaleKeys.movies_title.tr();
    case ('episode'):
      return LocaleKeys.tv_shows_title.tr();
    case ('track'):
      return LocaleKeys.music_title.tr();
    case ('other_video'):
      return LocaleKeys.videos_title.tr();
    case ('live'):
      return LocaleKeys.live_tv_title.tr();
    default:
      return '';
  }
}

String _transcodeDecisionToTitle(String decision) {
  switch (decision) {
    case ('all'):
      return LocaleKeys.all_title.tr();
    case ('direct play'):
      return LocaleKeys.direct_play_title.tr();
    case ('copy'):
      return LocaleKeys.direct_stream_title.tr();
    case ('transcode'):
      return LocaleKeys.transcode_title.tr();
    default:
      return '';
  }
}