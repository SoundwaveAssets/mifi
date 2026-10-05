import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mifi/core/data/in_memory_app_data_store.dart';
import 'package:mifi/core/models/status_models.dart';
import 'package:mifi/core/monitoring/monitoring_service.dart';
import 'package:mifi/core/monitoring/notification_service.dart';
import 'package:mifi/core/native/native_bridge.dart';
import 'package:mifi/core/settings/app_settings.dart';
import 'package:mifi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/notifications');
  final shown = <String>[];
  late InMemoryAppDataStore store;
  late MonitoringService monitoring;
  late DateTime now;

  AllStatus status({required bool internet}) => AllStatus({
        'simCardState': 'ready',
        'internetState': internet ? 'connected' : 'disconnected',
        'signalStrength': -85,
      });

  setUp(() async {
    shown.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'showNotification') shown.add('${(call.arguments as Map)['title']}');
      return null;
    });
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettings.load();
    final notifications = NotificationService(
      bridge: NativeBridge(channel: channel),
      settings: settings,
      localizations: () => lookupAppLocalizations(const Locale('fr')),
    );
    store = InMemoryAppDataStore();
    now = DateTime(2026, 10, 5, 12);
    monitoring = MonitoringService(store: store, notifications: notifications, settings: settings, clock: () => now);
  });

  Future<void> observe({required bool internet, Duration after = const Duration(seconds: 2)}) async {
    now = now.add(after);
    await monitoring.process(status: status(internet: internet));
  }

  test('test raté isolé : ni coupure ni alerte', () async {
    await observe(internet: true);
    await observe(internet: false);
    await observe(internet: true);
    expect(shown, isEmpty);
    expect(await store.recentOutages(), isEmpty);
  });

  test('coupure confirmée après 5 s : une seule alerte, datée du premier relevé sans internet', () async {
    await observe(internet: true);
    await observe(internet: false);
    final firstDown = now;
    await observe(internet: false);
    expect(shown, isEmpty);
    await observe(internet: false, after: const Duration(seconds: 4));
    expect(shown, hasLength(1));
    final outage = await store.ongoingOutage();
    expect(outage?.start, firstDown);
    await observe(internet: false);
    expect(shown, hasLength(1));

    // Retour d'internet : coupure close et seconde notification.
    await observe(internet: true);
    expect(await store.ongoingOutage(), isNull);
    expect(shown, hasLength(2));
  });

  test('historique du signal : un point toutes les 30 s au plus', () async {
    for (var i = 0; i < 30; i++) {
      await observe(internet: true);
    }
    final samples = await store.signalSamplesSince(DateTime(2026, 10, 5));
    expect(samples.length, 2);
  });
}
