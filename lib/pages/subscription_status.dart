import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionStatus extends ValueNotifier<bool> {
  static final SubscriptionStatus _instance = SubscriptionStatus._();

  SubscriptionStatus._() : super(false) {
    _load();
  }

  static SubscriptionStatus get instance => _instance;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool('is_subscribed') ?? false;
  }

  Future<void> subscribe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_subscribed', true);
    value = true;
  }

  Future<void> unsubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_subscribed', false);
    value = false;
  }

  Future<void> restore() async {
    await _load();
  }
}
