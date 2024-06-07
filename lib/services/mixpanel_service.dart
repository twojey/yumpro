import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  late Mixpanel _mixpanel;

  factory AnalyticsManager() {
    return _instance;
  }

  AnalyticsManager._internal();

  Future<void> init(String token) async {
    _mixpanel = await Mixpanel.init(token,
        optOutTrackingDefault: false, trackAutomaticEvents: false);
  }

  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    _mixpanel.track(eventName, properties: properties);
  }

  void setUserProperties(Map<String, dynamic> properties) {
    properties.forEach((key, value) {
      _mixpanel.getPeople().set(key, value);
    });
  }

  void identifyUser(String userId) {
    _mixpanel.identify(userId);
    _mixpanel
        .getPeople()
        .set('user_id', userId); // Utilisez set au lieu de identify
  }

  void aliasUser(String alias) async {
    String distinctId = await _mixpanel.getDistinctId();
    _mixpanel.alias(alias, distinctId);
  }

  void flush() {
    _mixpanel.flush();
  }
}
