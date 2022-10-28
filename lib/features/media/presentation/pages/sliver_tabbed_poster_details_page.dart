import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/poster.dart';
import '../../../../translations/locale_keys.g.dart';

const double _expandedHeight = 266;

class SliverTabbedPosterDetailsPage extends StatefulWidget {
  final bool sensitive;
  final Widget? background;
  final List<Widget>? appBarActions;
  final Poster? poster;
  final String? title;
  final Widget? subtitle;
  final Widget? itemDetail;
  final List<Widget> tabs;
  final List<Widget> tabChildren;

  const SliverTabbedPosterDetailsPage({
    super.key,
    this.sensitive = false,
    this.background,
    this.appBarActions,
    this.poster,
    required this.title,
    this.subtitle,
    this.itemDetail,
    required this.tabs,
    required this.tabChildren,
  });

  @override
  State<SliverTabbedPosterDetailsPage> createState() => _MediaSliverTabbedDetailsStatePage();
}

class _MediaSliverTabbedDetailsStatePage extends State<SliverTabbedPosterDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  double titleOpacity = 0;
  double radius = 16;
  double detailsOpacity = 1;
  double backgroundCoverOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs.length,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  title: Opacity(
                    opacity: titleOpacity,
                    child: Text(
                      widget.sensitive ? LocaleKeys.hidden_message.tr() : widget.title ?? '',
                    ),
                  ),
                  actions: widget.appBarActions,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  position: DecorationPosition.foreground,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  child: widget.background,
                                ),
                              ),
                              Positioned.fill(
                                child: Opacity(
                                  opacity: backgroundCoverOpacity,
                                  child: DecoratedBox(
                                    position: DecorationPosition.foreground,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(radius),
                                    topRight: Radius.circular(radius),
                                  ),
                                  child: Container(
                                    height: 100,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 10,
                                child: Opacity(
                                  opacity: detailsOpacity,
                                  child: SizedBox(
                                    height: 150,
                                    child: widget.poster,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: _expandedHeight - 118,
                                left: 116,
                                child: Opacity(
                                  opacity: detailsOpacity,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.sensitive ? LocaleKeys.hidden_message.tr() : widget.title ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (widget.subtitle != null) widget.subtitle!,
                                      if (widget.itemDetail != null) widget.itemDetail!,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 46,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ],
                    ),
                  ),
                  bottom: TabBar(
                    tabs: widget.tabs,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: widget.tabChildren.map(
              (tabSliver) {
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Builder(
                    key: PageStorageKey(ObjectKey(tabSliver)),
                    builder: (context) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: NestedScrollView.sliverOverlapAbsorberHandleFor(
                              context,
                            ).layoutExtent!,
                          ),
                          child: tabSliver,
                        ),
                      );
                    },
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    double progress = (_scrollController.offset) / (_expandedHeight - 46 - kToolbarHeight);
    double progressDelayed = (_scrollController.offset - 50) / (_expandedHeight - 50 - kToolbarHeight - 50);

    // Using modified easeOutCubic calculation from https://easings.net/#easeOutCubic
    if (progress <= 1) {
      setState(() {
        radius = pow(1 - progress, 3).toDouble() * 16;
      });
    }

    // Using modified easeOutCubic calculation from https://easings.net/#easeOutCubic
    if (progress <= 0 && detailsOpacity != 1) {
      setState(() {
        detailsOpacity = 1;
      });
    } else if (progress > 0 && progress <= 1) {
      setState(() {
        detailsOpacity = pow(1 - progress, 3).toDouble();
      });
    } else if (progress > 1 && detailsOpacity != 0) {
      setState(() {
        detailsOpacity = 0;
      });
    }

    // Using easeOutSine calculation from https://easings.net/#easeOutSine
    if (progress <= 0 && backgroundCoverOpacity != 0) {
      setState(() {
        backgroundCoverOpacity = 0;
      });
    } else if (progress > 0 && progress <= 1) {
      setState(() {
        backgroundCoverOpacity = sin((progress * pi) / 2);
      });
    } else if (progress > 1 && backgroundCoverOpacity != 0) {
      setState(() {
        backgroundCoverOpacity = 1;
      });
    }

    // Using easeInQuad calculation from https://easings.net/#easeInQuad
    if (progressDelayed <= 0 && titleOpacity != 0) {
      setState(() {
        titleOpacity = 0;
      });
    } else if (progressDelayed > 0 && progressDelayed <= 1) {
      setState(() {
        titleOpacity = progressDelayed * progressDelayed;
      });
    } else if (progressDelayed > 1 && titleOpacity != 1) {
      setState(() {
        titleOpacity = 1;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
