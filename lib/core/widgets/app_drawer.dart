import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/recent/presentation/pages/recently_added_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../helpers/color_palette_helper.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: PlexColorPalette.shark),
        child: ListView(
          children: <Widget>[
            Container(
              height: 100,
              decoration: BoxDecoration(color: TautulliColorPalette.midnight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 70,
                          padding: const EdgeInsets.only(right: 3),
                          child:
                              Image.asset('assets/logo/logo_transparent.png'),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tautulli',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Remote',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.tv,
                color: TautulliColorPalette.not_white,
              ),
              title: Text('Activity'),
              onTap: () {
                if (route.settings.name != ActivityPage.routeName) {
                  Navigator.of(context)
                      .pushReplacementNamed(ActivityPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
              onLongPress: () {
                Navigator.of(context)
                    .pushReplacementNamed(ActivityPage.routeName);
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.history,
                color: TautulliColorPalette.not_white,
              ),
              title: Text('History'),
              onTap: () {
                if (route.settings.name != HistoryPage.routeName) {
                  Navigator.of(context)
                      .pushReplacementNamed(HistoryPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
              onLongPress: () {
                Navigator.of(context)
                    .pushReplacementNamed(HistoryPage.routeName);
              },
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.clock,
                color: TautulliColorPalette.not_white,
              ),
              title: Text('Recently Added'),
              onTap: () {
                if (route.settings.name != RecentlyAddedPage.routeName) {
                  Navigator.of(context)
                      .pushReplacementNamed(RecentlyAddedPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
              onLongPress: () {
                Navigator.of(context)
                    .pushReplacementNamed(RecentlyAddedPage.routeName);
              },
            ),
            // ListTile(
            //   leading: FaIcon(
            //     FontAwesomeIcons.photoVideo,
            //     color: TautulliColorPalette.not_white,
            //   ),
            //   title: Text('Libraries'),
            //   onTap: () {},
            // ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.users,
                color: TautulliColorPalette.not_white,
              ),
              title: Text('Users'),
              onTap: () {
                if (route.settings.name != UsersPage.routeName) {
                  Navigator.of(context)
                      .pushReplacementNamed(UsersPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
              onLongPress: () {
                Navigator.of(context).pushReplacementNamed(UsersPage.routeName);
              },
            ),
            // ListTile(
            //   leading: FaIcon(
            //     FontAwesomeIcons.chartArea,
            //     color: TautulliColorPalette.not_white,
            //   ),
            //   title: Text('Statistics'),
            //   onTap: () {},
            // ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.cogs,
                color: TautulliColorPalette.not_white,
              ),
              title: Text('Settings'),
              onTap: () {
                if (route.settings.name != SettingsPage.routeName) {
                  Navigator.of(context)
                      .pushReplacementNamed(SettingsPage.routeName);
                } else {
                  Navigator.pop(context);
                }
              },
              onLongPress: () {
                Navigator.of(context)
                    .pushReplacementNamed(SettingsPage.routeName);
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25),
            //   child: Divider(
            //     color: PlexColorPalette.raven,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
