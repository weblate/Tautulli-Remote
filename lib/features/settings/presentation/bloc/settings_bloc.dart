import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quiver/strings.dart';

import '../../../../core/api/tautulli/models/plex_info_model.dart';
import '../../../../core/api/tautulli/models/tautulli_general_settings_model.dart';
import '../../../../core/database/data/models/server_model.dart';
import '../../../../core/manage_cache/manage_cache.dart';
import '../../../../core/types/protocol.dart';
import '../../../logging/domain/usecases/logging.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/connection_address_model.dart';
import '../../data/models/custom_header_model.dart';
import '../../domain/usecases/settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Logging logging;
  final ManageCache manageCache;
  final Settings settings;

  SettingsBloc({
    required this.logging,
    required this.manageCache,
    required this.settings,
  }) : super(SettingsInitial()) {
    on<SettingsAddServer>((event, emit) => _onSettingsAddServer(event, emit));
    on<SettingsClearCache>((event, emit) => _onSettingsClearCache(event, emit));
    on<SettingsDeleteCustomHeader>(
      (event, emit) => _onSettingsDeleteCustomHeader(event, emit),
    );
    on<SettingsDeleteServer>(
      (event, emit) => _onSettingsDeleteServer(event, emit),
    );
    on<SettingsLoad>((event, emit) => _onSettingsLoad(event, emit));
    on<SettingsUpdateConnectionInfo>(
      (event, emit) => _onSettingsUpdateConnectionInfo(event, emit),
    );
    on<SettingsUpdateCustomHeaders>(
      (event, emit) => _onSettingsUpdateCustomHeaders(event, emit),
    );
    on<SettingsUpdateDoubleTapToExit>(
      (event, emit) => _onSettingsUpdateDoubleTapToExit(event, emit),
    );
    on<SettingsUpdateMaskSensitiveInfo>(
      (event, emit) => _onSettingsUpdateMaskSensitiveInfo(event, emit),
    );
    on<SettingsUpdateOneSignalBannerDismiss>(
      (event, emit) => _onSettingsUpdateOneSignalBannerDismiss(event, emit),
    );
    on<SettingsUpdatePrimaryActive>(
      (event, emit) => _onSettingsUpdatePrimaryActive(event, emit),
    );
    on<SettingsUpdateRefreshRate>(
      (event, emit) => _onSettingsUpdateRefreshRate(event, emit),
    );
    on<SettingsUpdateServer>(
      (event, emit) => _onSettingsUpdateServer(event, emit),
    );
    on<SettingsUpdateServerPlexAndTautulliInfo>(
      (event, emit) => _onSettingsUpdateServerPlexAndTautulliInfo(event, emit),
    );
    on<SettingsUpdateServerSort>(
      (event, emit) => _onSettingsUpdateServerSort(event, emit),
    );
    on<SettingsUpdateServerTimeout>(
      (event, emit) => _onSettingsUpdateServerTimeout(event, emit),
    );
  }

  void _onSettingsAddServer(
    SettingsAddServer event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    final ConnectionAddressModel primaryConnectionAddress =
        ConnectionAddressModel.fromConnectionAddress(
      primary: true,
      connectionAddress: event.primaryConnectionAddress,
    );

    ConnectionAddressModel secondaryConnectionAddress =
        const ConnectionAddressModel(primary: false);
    if (isNotBlank(event.secondaryConnectionAddress)) {
      secondaryConnectionAddress = ConnectionAddressModel.fromConnectionAddress(
        primary: false,
        connectionAddress: event.secondaryConnectionAddress!,
      );
    }

    ServerModel server = ServerModel(
      sortIndex: currentState.serverList.length,
      plexName: event.plexName,
      plexIdentifier: event.plexIdentifier,
      tautulliId: event.tautulliId,
      primaryConnectionAddress: primaryConnectionAddress.address!,
      primaryConnectionProtocol:
          primaryConnectionAddress.protocol?.toShortString() ?? 'http',
      primaryConnectionDomain: primaryConnectionAddress.domain!,
      primaryConnectionPath: primaryConnectionAddress.path,
      secondaryConnectionAddress: secondaryConnectionAddress.address,
      secondaryConnectionProtocol:
          secondaryConnectionAddress.protocol?.toShortString(),
      secondaryConnectionDomain: secondaryConnectionAddress.domain,
      secondaryConnectionPath: secondaryConnectionAddress.path,
      deviceToken: event.deviceToken,
      primaryActive: true,
      oneSignalRegistered: event.oneSignalRegistered,
      plexPass: event.plexPass,
      customHeaders: event.customHeaders ?? [],
    );

    final serverId = await settings.addServer(server);

    logging.info(
      "Settings :: Added server '${event.plexName}'",
    );

    server = server.copyWith(id: serverId);

    List<ServerModel> updatedList = [...currentState.serverList];

    updatedList.add(server);

    if (updatedList.length > 1) {
      updatedList.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    }

    emit(
      currentState.copyWith(serverList: updatedList),
    );

    _updateServerInfo(server: server);
  }

  void _onSettingsClearCache(
    SettingsClearCache event,
    Emitter<SettingsState> emit,
  ) async {
    manageCache.clearCache();
    logging.info(
      'Settings :: Image cache cleared',
    );
  }

  void _onSettingsDeleteCustomHeader(
    SettingsDeleteCustomHeader event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    final int index = currentState.serverList.indexWhere(
      (server) => server.tautulliId == event.tautulliId,
    );

    List<ServerModel> updatedList = [...currentState.serverList];

    List<CustomHeaderModel> customHeaders = [
      ...updatedList[index].customHeaders
    ];

    customHeaders.removeWhere((header) => header.key == event.title);

    await settings.updateCustomHeaders(
      tautulliId: event.tautulliId,
      headers: customHeaders,
    );

    logging.info("Settings :: Removed '${event.title}' header");

    updatedList[index] = currentState.serverList[index].copyWith(
      customHeaders: customHeaders,
    );
    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsDeleteServer(
    SettingsDeleteServer event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    List<ServerModel> updatedList = [...currentState.serverList];

    final int index = updatedList.indexWhere(
      (server) => server.id == event.id,
    );
    updatedList.removeAt(index);

    await settings.deleteServer(event.id);

    logging.info("Settings :: Deleted server '${event.plexName}'");

    // Delay item removal to avoid user noticing server page trying to display
    // after server is removed from the list
    //TODO: There has to be a better solution to this problem
    await Future.delayed(const Duration(milliseconds: 180));

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsLoad(
    SettingsLoad event,
    Emitter<SettingsState> emit,
  ) async {
    emit(
      SettingsInProgress(),
    );

    try {
      // Fetch settings
      final List<ServerModel> serverList = await settings.getAllServers();
      final AppSettingsModel appSettings = AppSettingsModel(
        doubleTapToExit: await settings.getDoubleTapToExit(),
        maskSensitiveInfo: await settings.getMaskSensitiveInfo(),
        oneSignalBannerDismissed: await settings.getOneSignalBannerDismissed(),
        oneSignalConsented: await settings.getOneSignalConsented(),
        serverTimeout: await settings.getServerTimeout(),
        refreshRate: await settings.getRefreshRate(),
      );

      emit(
        SettingsSuccess(
          serverList: serverList,
          appSettings: appSettings,
        ),
      );

      if (event.updateServerInfo) {
        for (ServerModel server in serverList) {
          _updateServerInfo(server: server);
        }
      }
    } catch (e) {
      logging.info(
        'Settings :: Failed to load settings [$e]',
      );

      emit(
        SettingsFailure(),
      );
    }
  }

  void _onSettingsUpdateConnectionInfo(
    SettingsUpdateConnectionInfo event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    final ConnectionAddressModel connectionAddress =
        ConnectionAddressModel.fromConnectionAddress(
      primary: event.primary,
      connectionAddress: event.connectionAddress,
    );

    await settings.updateConnectionInfo(
      id: event.server.id!,
      connectionAddress: connectionAddress,
    );

    final int index = currentState.serverList.indexWhere(
      (oldServer) => oldServer.id == event.server.id,
    );

    List<ServerModel> updatedList = [...currentState.serverList];

    if (event.primary) {
      updatedList[index] = currentState.serverList[index].copyWith(
        primaryConnectionAddress: connectionAddress.address,
        primaryConnectionProtocol: connectionAddress.protocol?.toShortString(),
        primaryConnectionDomain: connectionAddress.domain,
        primaryConnectionPath: connectionAddress.path,
      );
    } else {
      updatedList[index] = currentState.serverList[index].copyWith(
        secondaryConnectionAddress: connectionAddress.address,
        secondaryConnectionProtocol:
            connectionAddress.protocol?.toShortString(),
        secondaryConnectionDomain: connectionAddress.domain,
        secondaryConnectionPath: connectionAddress.path,
      );
    }

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsUpdateCustomHeaders(
    SettingsUpdateCustomHeaders event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;
    String loggingMessage = 'Settings :: Header changed but logging missed it';

    final int index = currentState.serverList.indexWhere(
      (server) => server.tautulliId == event.tautulliId,
    );

    List<ServerModel> updatedList = [...currentState.serverList];

    List<CustomHeaderModel> customHeaders = [
      ...updatedList[index].customHeaders
    ];

    if (event.basicAuth) {
      final currentIndex = customHeaders.indexWhere(
        (header) => header.key == 'Authorization',
      );

      final String base64Value = base64Encode(
        utf8.encode('${event.title}:${event.subtitle}'),
      );

      if (currentIndex == -1) {
        customHeaders.add(
          CustomHeaderModel(
            key: 'Authorization',
            value: 'Basic $base64Value',
          ),
        );

        loggingMessage = "Settings :: Added 'Authorization' header";
      } else {
        customHeaders[currentIndex] = CustomHeaderModel(
          key: 'Authorization',
          value: 'Basic $base64Value',
        );

        loggingMessage = "Settings :: Updated 'Authorization' header";
      }
    } else {
      if (event.previousTitle != null) {
        final oldIndex = customHeaders.indexWhere(
          (header) => header.key == event.previousTitle,
        );

        customHeaders[oldIndex] = CustomHeaderModel(
          key: event.title,
          value: event.subtitle,
        );

        if (event.previousTitle != event.title) {
          loggingMessage =
              "Settings :: Replaced '${event.previousTitle}' header with '${event.title}'";
        } else {
          loggingMessage = "Settings :: Updated '${event.title}' header'";
        }
      } else {
        // No previous title means a new header is being added. We need to
        // check and make sure we don't end up with headers that have duplicate
        // keys/titles
        final currentIndex = customHeaders.indexWhere(
          (header) => header.key == event.title,
        );

        if (currentIndex == -1) {
          customHeaders.add(
            CustomHeaderModel(
              key: event.title,
              value: event.subtitle,
            ),
          );

          loggingMessage = "Settings :: Added '${event.title}' header";
        } else {
          customHeaders[currentIndex] = CustomHeaderModel(
            key: event.title,
            value: event.subtitle,
          );

          loggingMessage = "Settings :: Updated '${event.title}' header";
        }
      }
    }

    await settings.updateCustomHeaders(
      tautulliId: event.tautulliId,
      headers: customHeaders,
    );

    logging.info(loggingMessage);

    updatedList[index] = currentState.serverList[index].copyWith(
      customHeaders: customHeaders,
    );

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsUpdateDoubleTapToExit(
    SettingsUpdateDoubleTapToExit event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.setDoubleTapToExit(event.doubleTapToExit);
    logging.info(
      'Settings :: Double Tap To Exit set to ${event.doubleTapToExit}',
    );

    emit(
      currentState.copyWith(
        appSettings: currentState.appSettings
            .copyWith(doubleTapToExit: event.doubleTapToExit),
      ),
    );
  }

  void _onSettingsUpdateMaskSensitiveInfo(
    SettingsUpdateMaskSensitiveInfo event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.setMaskSensitiveInfo(event.maskSensitiveInfo);
    logging.info(
      'Settings :: Mask Sensitive Info set to ${event.maskSensitiveInfo}',
    );

    emit(
      currentState.copyWith(
        appSettings: currentState.appSettings
            .copyWith(maskSensitiveInfo: event.maskSensitiveInfo),
      ),
    );
  }

  void _onSettingsUpdateOneSignalBannerDismiss(
    SettingsUpdateOneSignalBannerDismiss event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.setOneSignalBannerDismissed(event.dismiss);
    if (event.dismiss) {
      logging.info(
        'Settings :: OneSignal Banner Dismissed',
      );
    }

    emit(
      currentState.copyWith(
        appSettings: currentState.appSettings
            .copyWith(oneSignalBannerDismissed: event.dismiss),
      ),
    );
  }

  void _onSettingsUpdatePrimaryActive(
    SettingsUpdatePrimaryActive event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.updatePrimaryActive(
      tautulliId: event.tautulliId,
      primaryActive: event.primaryActive,
    );

    final int index = currentState.serverList.indexWhere(
      (oldServer) => oldServer.tautulliId == event.tautulliId,
    );

    List<ServerModel> updatedList = [...currentState.serverList];

    updatedList[index] = currentState.serverList[index].copyWith(
      primaryActive: event.primaryActive,
    );

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsUpdateRefreshRate(
    SettingsUpdateRefreshRate event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.setRefreshRate(event.refreshRate);
    logging.info(
      'Settings :: Activity Refresh Rate set to ${event.refreshRate}',
    );

    emit(
      currentState.copyWith(
        appSettings: currentState.appSettings.copyWith(
          refreshRate: event.refreshRate,
        ),
      ),
    );
  }

  void _onSettingsUpdateServer(
    SettingsUpdateServer event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    logging.info(
      'Settings :: Updating server details for ${event.plexName}',
    );

    final ConnectionAddressModel primaryConnectionAddress =
        ConnectionAddressModel.fromConnectionAddress(
      primary: true,
      connectionAddress: event.primaryConnectionAddress,
    );

    final ConnectionAddressModel secondaryConnectionAddress =
        ConnectionAddressModel.fromConnectionAddress(
      primary: true,
      connectionAddress: event.secondaryConnectionAddress,
    );

    List<ServerModel> updatedList = [...currentState.serverList];

    final int index = currentState.serverList.indexWhere(
      (server) => server.id == event.id,
    );

    updatedList[index] = currentState.serverList[index].copyWith(
      id: event.id,
      sortIndex: event.sortIndex,
      primaryConnectionAddress: primaryConnectionAddress.address,
      primaryConnectionProtocol:
          primaryConnectionAddress.protocol?.toShortString(),
      primaryConnectionDomain: primaryConnectionAddress.domain,
      primaryConnectionPath: primaryConnectionAddress.path,
      secondaryConnectionAddress: secondaryConnectionAddress.address,
      secondaryConnectionProtocol:
          secondaryConnectionAddress.protocol?.toShortString(),
      secondaryConnectionDomain: secondaryConnectionAddress.domain,
      secondaryConnectionPath: secondaryConnectionAddress.path,
      deviceToken: event.deviceToken,
      tautulliId: event.tautulliId,
      plexName: event.plexName,
      plexIdentifier: event.plexIdentifier,
      primaryActive: true,
      oneSignalRegistered: event.oneSignalRegistered,
      plexPass: event.plexPass,
      dateFormat: event.dateFormat,
      timeFormat: event.timeFormat,
      customHeaders: event.customHeaders,
    );

    await settings.updateServer(updatedList[index]);

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsUpdateServerPlexAndTautulliInfo(
    SettingsUpdateServerPlexAndTautulliInfo event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    List<ServerModel> updatedList = [...currentState.serverList];

    final int index = currentState.serverList.indexWhere(
      (server) => server.id == event.serverModel.id,
    );

    updatedList[index] = event.serverModel;

    await settings.updateServer(event.serverModel);

    emit(
      currentState.copyWith(serverList: updatedList),
    );
  }

  void _onSettingsUpdateServerSort(
    SettingsUpdateServerSort event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    List<ServerModel> updatedServerList = [...currentState.serverList];
    ServerModel movedServer = updatedServerList.removeAt(event.oldIndex);
    updatedServerList.insert(event.newIndex, movedServer);

    emit(
      currentState.copyWith(serverList: updatedServerList),
    );

    await settings.updateServerSort(
      serverId: event.serverId,
      oldIndex: event.oldIndex,
      newIndex: event.newIndex,
    );

    // Get Servers with updated sorts to keep state accurate
    updatedServerList = await settings.getAllServers();
    emit(
      currentState.copyWith(serverList: updatedServerList),
    );

    logging.info('Settings :: Updated server sort');
  }

  void _onSettingsUpdateServerTimeout(
    SettingsUpdateServerTimeout event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state as SettingsSuccess;

    await settings.setServerTimeout(event.timeout);
    logging.info(
      'Settings :: Server Timeout set to ${event.timeout}',
    );

    emit(
      currentState.copyWith(
        appSettings: currentState.appSettings.copyWith(
          serverTimeout: event.timeout,
        ),
      ),
    );
  }

  void _updateServerInfo({
    required ServerModel server,
  }) async {
    String? plexName;
    String? plexIdentifier;
    bool? plexPass;
    String? dateFormat;
    String? timeFormat;

    final failureOrPlexInfo = await settings.getPlexInfo(server.tautulliId);
    final failureOrTautulliSettings = await settings.getTautulliSettings(
      server.tautulliId,
    );

    failureOrPlexInfo.fold(
      (failure) {
        logging.error(
          'Settings: Failed to fetch updated Plex info for ${server.plexName}',
        );
      },
      (response) {
        add(
          SettingsUpdatePrimaryActive(
            tautulliId: server.tautulliId,
            primaryActive: response.value2,
          ),
        );

        final PlexInfoModel results = response.value1;

        plexName = results.pmsName;
        plexIdentifier = results.pmsIdentifier;
        plexPass = results.pmsPlexpass;
      },
    );

    failureOrTautulliSettings.fold(
      (failure) {
        logging.error(
          'Settings: Failed to fetch updated Tautulli Settings for ${server.plexName}',
        );
      },
      (response) {
        add(
          SettingsUpdatePrimaryActive(
            tautulliId: server.tautulliId,
            primaryActive: response.value2,
          ),
        );

        final TautulliGeneralSettingsModel results = response.value1;

        dateFormat = results.dateFormat;
        timeFormat = results.timeFormat;
      },
    );

    ServerModel updatedServer = server.copyWith(
      plexName: plexName,
      plexIdentifier: plexIdentifier,
      plexPass: plexPass,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
    );

    if (server != updatedServer) {
      logging.info(
        'Settings :: Updating Plex and Tautulli details for ${updatedServer.plexName}',
      );
      add(
        SettingsUpdateServerPlexAndTautulliInfo(serverModel: updatedServer),
      );
    }
  }
}
