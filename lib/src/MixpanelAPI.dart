import 'dart:async';
import 'package:flutter/services.dart';

import 'MixpanelMockedAPI.dart';

///
/// Core class for interacting with Mixpanel Analytics.
///
/// See native [MixpanelAPI](https://mixpanel.github.io/mixpanel-android/com/mixpanel/android/mpmetrics/MixpanelAPI.html)
/// for more information.
class MixpanelAPI {
  static const String _pluginName = 'flutuate.io/plugins/mixpanel';

  static const MethodChannel _channel = const MethodChannel(_pluginName);

  ///
  /// Get the instance of native MixpanelAPI associated with your Mixpanel project
  /// [token].
  ///
  /// Use [getInstance] to get a reference to a shared instance of MixpanelAPI
  /// you can use to send events to Mixpanel.
  ///
  /// The [optOutTrackingDefault] parameters, determines whether or not Mixpanel
  /// can start tracking by default. See [optOutTracking].
  ///
  /// If you need test your application, set [mocked] as ```true```. See [MixpanelMockedAPI].
  static Future<MixpanelAPI> getInstance(String token,
      {bool optOutTrackingDefault, mocked = false}) async {
    if (mocked) {
      return new MixpanelMockedAPI();
    }

    Map<String, dynamic> properties = <String, dynamic>{'token': token};

    if (optOutTrackingDefault != null)
      properties['optOutTrackingDefault'] = optOutTrackingDefault;

    await _channel.invokeMethod<int>('getInstance', properties);

    return new MixpanelAPI();
  }

  ///
  /// Push all queued Mixpanel events to Mixpanel servers.
  ///
  /// Events are pushed gradually throughout the lifetime of your application.
  /// This means that to ensure that all messages are sent to Mixpanel when
  /// your application is shut down, you will need to call [flush] to let the
  /// Mixpanel library know it should send all remaining messages to the server.
  /// We strongly recommend placing a call to [flush] when your state class finalizes.
  void flush() {
    _channel.invokeMethod<void>('flush');
  }

  ///
  /// Track an event.
  ///
  /// Every call to [track] eventually results in a data point sent to Mixpanel.
  /// These data points are what are measured, counted, and broken down to create
  /// your Mixpanel reports. Events have a string name ([eventName]), and an
  /// optional set of name/value pairs that describe the [properties] of that event.
  void track(String eventName, [Map<String, dynamic> properties]) {
    _channel.invokeMethod<void>('track',
        <String, dynamic>{'eventName': eventName, 'properties': properties});
  }

  ///
  /// Returns an unmodifiable map that contains the device description properties
  /// that will be sent to Mixpanel. These are not all of the default properties,
  /// but are a subset that are dependant on the user's device or installed
  /// version of the host application, and are guaranteed not to change while
  /// the app is running.
  Future<Map<String, String>> getDeviceInfo() async {
    Map result = await _channel.invokeMethod<Map>('getDeviceInfo');
    Map<String, String> devInfo = {};
    for (dynamic key in result.keys) {
      devInfo[key as String] = result[key] as String;
    }
    return devInfo;
  }

  ///
  /// Returns the string id currently being used to uniquely identify the user
  /// associated with events sent using [track]. Before any calls to [identify],
  /// this will be an id automatically generated by the library.
  Future<String> getDistinctId() async {
    return await _channel.invokeMethod<String>('getDistinctId');
  }

  ///
  /// Associate all future calls to [track] with the user identified by the
  /// given distinct id.
  ///
  /// This call does not identify the user for People Analytics; to do that,
  /// see [MixpanelAPI.People.identify] (**not implemented**). Mixpanel recommends
  /// using the same distinct_id for both calls, and using a distinct_id
  /// that is easy to associate with the given user, for example, a server-side
  /// account identifier.
  ///
  /// Calls to [track] made before corresponding calls to identify will use an
  /// internally generated distinct id, which means it is best to call identify
  /// early to ensure that your Mixpanel funnels and retention analytics can
  /// continue to track the user throughout their lifetime.
  /// We recommend calling [identify] as early as you can.
  ///
  /// Once [identify] is called, the given distinct id persists across restarts
  /// of your application.
  void identify(String distinctId) {
    _channel.invokeMethod<void>('identify');
  }

  ///
  /// Use this method to opt-in an already opted-out user from tracking.
  /// People updates and track calls will be sent to Mixpanel after using this
  /// method. This method will internally track an opt-in event to your project.
  /// If you want to identify the opt-in event and/or pass properties to the event,
  /// see all [optInTracking] variants methods.
  /// See also [optOutTracking].
  void optInTracking() {
    _channel.invokeMethod<void>('optInTracking');
  }

  ///
  /// Use this method to opt-out a user from tracking. Events and people updates
  /// that haven't been flushed yet will be deleted. Use [flush] before calling
  /// this method if you want to send all the queues to Mixpanel before.
  /// This method will also remove any user-related information from the device.
  void optOutTracking() {
    _channel.invokeMethod<void>('optOutTracking');
  }

  ///
  /// Clears tweaks and all distinct_ids, superProperties, and push registrations
  /// from persistent storage. Will not clear referrer information.
  void reset() {
    _channel.invokeMethod<void>('reset');
  }
}
