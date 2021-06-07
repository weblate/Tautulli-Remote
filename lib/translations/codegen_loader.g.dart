// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
  "activity_empty": "Nothing is currently being played",
  "activity_page_title": "Activity",
  "history_page_title": "History",
  "recently_added_page_title": "Recently Added",
  "libraries_page_title": "Libraries",
  "users_page_title": "Users",
  "statistics_page_title": "Statistics",
  "graphs_page_title": "Graphs",
  "synced_items_page_title": "Synced Items",
  "announcements_page_title": "Announcements",
  "donate_page_title": "Donate",
  "settings_page_title": "Settings",
  "media_details_audio": "AUDIO",
  "media_details_transcode": "Transcode",
  "media_details_direct_stream": "Direct Stream",
  "media_details_direct_play": "Direct Play",
  "media_details_unknown": "Unknown",
  "media_details_bandwidth": "BANDWIDTH",
  "media_details_container": "CONTAINER",
  "media_details_converting": "Converting",
  "media_details_na": "N/A",
  "masked_info_ip_address": "Hidden IP Address",
  "media_details_location": "LOCATION",
  "media_details_relay_message": "This stream is using Plex Relay",
  "masked_info_location": "Hidden Location",
  "media_details_optimized": "OPTIMIZED",
  "media_details_player": "PLAYER",
  "media_details_product": "PRODUCT",
  "media_details_quality": "QUALITY",
  "media_details_throttled": "Throttled",
  "media_details_speed": "Speed",
  "media_details_stream": "STREAM",
  "media_details_subtitle": "SUBTITLE",
  "media_details_burn": "Burn",
  "media_details_none": "None",
  "media_details_synced": "SYNCED",
  "media_details_video": "VIDEO",
  "button_view_user": "View User",
  "button_view_media": "View Media",
  "button_terminate_stream": "Terminate Stream",
  "button_learn_more": "LEARN MORE",
  "masked_info_user": "Hidden User",
  "termination_request_sent_alert": "Termination request sent to Plex",
  "termination_default_message": "The server owner has ended the stream",
  "termination_photo_alert": "Photo streams cannot be terminated",
  "termination_synced_alert": "Synced content cannot be terminated",
  "termination_dialog_title": "Are you sure you want to terminate this stream",
  "termination_terminate_message_label": "Terminate Message",
  "button_cancel": "CANCEL",
  "button_terminate": "TERMINATE",
  "button_go_to_settings": "Go to settings",
  "button_retry": "Retry",
  "media_details_location_error": "ERROR: IP Address not in GeoIP map",
  "media_details_location_loading": "Loading location data",
  "activity_time_left": "left",
  "settings_not_loaded_error": "ERROR: Settings not loaded",
  "general_unknown_error": "Unknown Error",
  "donate_thank_you_alert": "Thank you for your donation",
  "donate_error_alert": "Something went wrong.",
  "donate_message_title": "Tautulli Remote is free and open source.",
  "donate_message_body": "However, any contributions you can make towards the app are appreciated!",
  "donate_one_time_heading": "One-Time Donations",
  "donate_cone": "Buy Me A Cone",
  "donate_slice": "Buy Me A Slice",
  "donate_burger": "Buy Me A Burger",
  "donate_meal": "Buy Me A Meal",
  "donate_recurring_heading": "Recurring Donations",
  "donate_tip_jar": "Tip Jar",
  "donate_big_tip": "Big Tip",
  "donate_supporter": "Supporter",
  "donate_patron": "Patron",
  "donate_load_failed": "Failed to load donation items.",
  "donate_month": "month"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en};
}
