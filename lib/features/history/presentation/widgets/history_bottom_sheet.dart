import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/helpers/color_palette_helper.dart';
import '../../../../core/widgets/gesture_pill.dart';
import '../../../../core/widgets/poster.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../settings/data/models/custom_header_model.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../users/data/models/user_model.dart';
import '../../../users/presentation/pages/user_details_page.dart';
import '../../data/models/history_model.dart';
import 'history_bottom_sheet_details.dart';
import 'history_bottom_sheet_info.dart';

class HistoryBottomSheet extends StatelessWidget {
  final HistoryModel history;
  final bool viewUserEnabled;

  const HistoryBottomSheet({
    super.key,
    required this.history,
    this.viewUserEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Column(
          children: [
            // Add spacing above bottom sheet to account for status bar height.
            // Allows for that area to be tapped to dismiss the modal bottom
            // sheet but not be dragged down. Must be a container with
            // transparent color for this to work.
            GestureDetector(
              onTap: () => Navigator.pop(context),
              onVerticalDragDown: (_) {},
              child: Container(
                height: MediaQueryData.fromWindow(window).padding.top,
                color: Colors.transparent,
              ),
            ),
            Stack(
              children: [
                Column(
                  children: [
                    // Creates a transparent area for the poster to hover over.
                    // Allows for that area to be tapped to dismiss the modal bottom
                    // sheet but not be dragged down. Must be a container with
                    // transparent color for this to work.
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      onVerticalDragDown: (_) {},
                      child: Container(
                        height: 28,
                        color: Colors.transparent,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: SizedBox(
                        height: 110,
                        child: Stack(
                          children: [
                            //* Background
                            Positioned.fill(
                              child: BlocBuilder<SettingsBloc, SettingsState>(
                                builder: (context, state) {
                                  state as SettingsSuccess;

                                  return DecoratedBox(
                                    position: DecorationPosition.foreground,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: history.posterUri!.toString(),
                                      httpHeaders: {
                                        for (CustomHeaderModel headerModel
                                            in state.appSettings.activeServer
                                                .customHeaders)
                                          headerModel.key: headerModel.value,
                                      },
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/poster_fallback.png',
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/poster_fallback.png',
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  );
                                },
                              ),
                            ),
                            //* Info Section
                            Positioned.fill(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 25,
                                        sigmaY: 25,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              top: 4,
                                              bottom: 2,
                                            ),
                                            child: Center(
                                              child: GesturePill(),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Gap(100),
                                                Expanded(
                                                  child: HistoryBottomSheetInfo(
                                                    history: history,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //* Poster
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: SizedBox(
                    height: 130,
                    child: Poster(
                      mediaType: history.mediaType,
                      uri: history.posterUri,
                    ),
                  ),
                ),
              ],
            ),
            //* Details
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: HistoryBottomSheetDetails(history: history),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: viewUserEnabled
                                ? () {
                                    final user = UserModel(
                                      friendlyName: history.friendlyName,
                                      userId: history.userId,
                                    );

                                    Navigator.of(context).pop();

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => UserDetailsPage(
                                          user: user,
                                          fetchUser: true,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: const Text(LocaleKeys.view_user_title).tr(),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: PlexColorPalette.curiousBlue,
                            ),
                            onPressed: null,
                            child: const Text(LocaleKeys.view_media_title).tr(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}