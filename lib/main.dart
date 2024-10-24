import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'features/announcements/presentation/bloc/announcements_bloc.dart';
import 'features/onesignal/presentation/bloc/onesignal_health_bloc.dart';
import 'features/onesignal/presentation/bloc/onesignal_privacy_bloc.dart';
import 'features/onesignal/presentation/bloc/onesignal_subscription_bloc.dart';
import 'features/settings/domain/usecases/settings.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'injection_container.dart' as di;
import 'tautulli_remote.dart';
import 'translations/codegen_loader.g.dart';

/// Create an [HttpOverride] for [createHttpClient] to check cert failures
/// against the saved cert hash list
class MyHttpOverrides extends HttpOverrides {
  final List<int> customCertHashList;

  MyHttpOverrides(this.customCertHashList);

  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        int certHashCode = cert.pem.hashCode;

        if (customCertHashList.contains(certHashCode)) {
          return true;
        }
        return false;
      };
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();

  // Override global HttpClient to check for trusted cert hashes on certificate failure.
  final List<int> customCertHashList =
      await di.sl<Settings>().getCustomCertHashList();
  HttpOverrides.global = MyHttpOverrides(customCertHashList);

  // Get version information to determine if we should show the changelog
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final runningVersion = packageInfo.version;
  final lastAppVersion = await di.sl<Settings>().getLastAppVersion();
  final wizardCompleteStatus =
      await di.sl<Settings>().getWizardCompleteStatus();
  final serverList = await di.sl<Settings>().getAllServers();

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [
        Locale('en'),
      ],
      fallbackLocale: const Locale('en'),
      assetLoader: const CodegenLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (context) => di.sl<SettingsBloc>(),
          ),
          BlocProvider<OneSignalHealthBloc>(
            create: (context) => di.sl<OneSignalHealthBloc>(),
          ),
          BlocProvider<OneSignalSubscriptionBloc>(
            create: (context) => di.sl<OneSignalSubscriptionBloc>()
              ..add(OneSignalSubscriptionCheck()),
          ),
          BlocProvider<OneSignalPrivacyBloc>(
            create: (context) => di.sl<OneSignalPrivacyBloc>()
              ..add(OneSignalPrivacyCheckConsent()),
          ),
          BlocProvider<AnnouncementsBloc>(
            create: (context) =>
                di.sl<AnnouncementsBloc>()..add(AnnouncementsFetch()),
          ),
        ],
        child: TautulliRemote(
          showWizard: (wizardCompleteStatus != null && !wizardCompleteStatus) ||
              (wizardCompleteStatus == null && serverList.isEmpty),
          showChangelog: runningVersion != lastAppVersion,
        ),
      ),
    ),
  );
}
