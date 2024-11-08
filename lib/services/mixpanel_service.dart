import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/foundation.dart'; // Pour accéder à kReleaseMode

class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  late Mixpanel _mixpanel;
  bool _isInitialized = false;

  factory AnalyticsManager() {
    return _instance;
  }

  AnalyticsManager._internal();

  Future<void> init(String token) async {
    try {
      _mixpanel = await Mixpanel.init(token,
          optOutTrackingDefault: false, trackAutomaticEvents: false);
      _isInitialized = true;
    } catch (e) {
      print("Erreur lors de l'initialisation de Mixpanel: $e");
    }
  }

  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    if (!_isInitialized) {
      print("Mixpanel n'est pas initialisé, impossible de suivre l'événement.");
      return;
    }

    if (kReleaseMode) {
      try {
        _mixpanel.track(eventName, properties: properties);
      } catch (e) {
        print('Erreur lors du tracking de l\'événement "$eventName": $e');
      }
    } else {
      print('Event "$eventName" not tracked in debug mode');
    }
  }

  void setUserProperties(Map<String, dynamic> properties) {
    if (!_isInitialized) {
      print(
          "Mixpanel n'est pas initialisé, impossible de définir les propriétés utilisateur.");
      return;
    }

    properties.forEach((key, value) {
      try {
        _mixpanel.getPeople().set(key, value);
      } catch (e) {
        print(
            'Erreur lors de la définition de la propriété utilisateur "$key": $e');
      }
    });
  }

  void identifyUser(String userId) {
    if (!_isInitialized) {
      print(
          "Mixpanel n'est pas initialisé, impossible d'identifier l'utilisateur.");
      return;
    }

    try {
      _mixpanel.identify(userId);
      _mixpanel.getPeople().set('user_id', userId);
    } catch (e) {
      print('Erreur lors de l\'identification de l\'utilisateur: $e');
    }
  }

  void aliasUser(String alias) async {
    if (!_isInitialized) {
      print(
          "Mixpanel n'est pas initialisé, impossible de créer un alias pour l'utilisateur.");
      return;
    }

    try {
      String distinctId = await _mixpanel.getDistinctId();
      _mixpanel.alias(alias, distinctId);
    } catch (e) {
      print('Erreur lors de la création de l\'alias pour l\'utilisateur: $e');
    }
  }

  void flush() {
    if (!_isInitialized) {
      print("Mixpanel n'est pas initialisé, impossible de flush.");
      return;
    }

    try {
      _mixpanel.flush();
    } catch (e) {
      print('Erreur lors du flush: $e');
    }
  }
}
