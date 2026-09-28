import 'dart:io';
import 'version_model.dart';

void expect(bool value, String message) {
  if (!value) throw StateError(message);
}

void main() {
  final v = GuayanVersion.parsePubspec('name: x\nversion: 2.0.6+47\n');
  expect(v.source == '2.0.6+47', 'source parse');
  expect(v.visible == '2.0.6.47', 'visible mapping');
  expect(v.next.source == '2.0.6+48', 'counter increment');
  expect(v.next.visible == '2.0.6.48', 'visible increment');
  var blocked = false;
  try {
    GuayanVersion.parsePubspec('version: 2.0.6.47');
  } on FormatException {
    blocked = true;
  }
  expect(blocked, 'invalid source format must block');
  expect(
    countedEventTypes.containsAll({'FEATURE', 'FIX', 'PERF'}),
    'event types',
  );
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  expect(
    gradle.contains(
      r'versionName = "${flutter.versionName}.${flutter.versionCode}"',
    ),
    'Android visible mapping',
  );
  print('GUAYAN VERSION SELFTEST PASS');
}
