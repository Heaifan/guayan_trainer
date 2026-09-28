import 'dart:io';

const countedEventTypes = {'FEATURE', 'FIX', 'PERF'};

class GuayanVersion {
  const GuayanVersion(this.major, this.minor, this.patch, this.counter);

  final int major;
  final int minor;
  final int patch;
  final int counter;

  static GuayanVersion parsePubspec(String text) {
    final match = RegExp(
      r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(text);
    if (match == null) throw FormatException('Invalid GUAYAN version');
    return GuayanVersion(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
      int.parse(match[4]!),
    );
  }

  static GuayanVersion read() =>
      parsePubspec(File('pubspec.yaml').readAsStringSync());

  String get source => '$major.$minor.$patch+$counter';
  String get visible => '$major.$minor.$patch.$counter';
  GuayanVersion get next => GuayanVersion(major, minor, patch, counter + 1);
}
