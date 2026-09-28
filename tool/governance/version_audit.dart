import 'dart:io';
import 'version_model.dart';

String git(List<String> args) {
  final result = Process.runSync('git', args);
  if (result.exitCode != 0) return 'UNAVAILABLE';
  return result.stdout.toString().trim();
}

void main() {
  final version = GuayanVersion.read();
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  const mapping = r'versionName = "${flutter.versionName}.${flutter.versionCode}"';
  final branch = git(['branch', '--show-current']);
  final head = git(['rev-parse', 'HEAD']);
  final short = git(['rev-parse', '--short=8', 'HEAD']);
  final dirty = git(['status', '--porcelain']).isNotEmpty;
  final mappingPass = gradle.contains(mapping);
  print('GUAYAN VERSION AUDIT');
  print('Source: ${version.source}');
  print('Visible: ${version.visible}');
  print('Branch: $branch');
  print('HEAD: $head');
  print('Identity: ${version.visible}@$short');
  print('Dirty: ${dirty ? 'YES' : 'NO'}');
  print('Android mapping: ${mappingPass ? 'PASS' : 'FAIL'}');
  if (!mappingPass || head == 'UNAVAILABLE') exitCode = 1;
}
