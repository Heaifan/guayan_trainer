import 'dart:io';
import 'version_model.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/governance/version_next.dart TYPE');
    exitCode = 2;
    return;
  }
  final type = args.first.toUpperCase();
  final current = GuayanVersion.read();
  if (type == 'GOVERNANCE' || type == 'DOCS') {
    print('VERSION EVENT\nType: $type\nCounter: NONE');
    print('Current: ${current.source}\nVisible: ${current.visible}');
    return;
  }
  if (!countedEventTypes.contains(type)) {
    stderr.writeln('BLOCKED: unknown event type $type');
    exitCode = 2;
    return;
  }
  final next = current.next;
  print('VERSION EVENT');
  print('Type: $type');
  print('Previous: ${current.source} (${current.visible})');
  print('Next: ${next.source} (${next.visible})');
}
