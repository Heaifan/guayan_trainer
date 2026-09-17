import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guayan_trainer/presentation/rules/rule_package_page.dart';
import 'package:guayan_trainer/services/rules/rule_package_file_adapter.dart';

void main() {
  testWidgets('imports a package through preview and shows installed state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fixture = File('test/fixtures/external_test_pack.json').readAsStringSync();
    await tester.pumpWidget(MaterialApp(
      home: RulePackagePage(
        fileAdapter: RulePackageFileAdapter(pickJsonOverride: () async => fixture),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('用户规则包'), findsOneWidget);
    expect(find.byKey(const Key('import_rule_package')), findsOneWidget);
    await tester.tap(find.byKey(const Key('import_rule_package_fab')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('名称：外部规则包 Golden'), findsOneWidget);
    expect(find.textContaining('导入后全局启用'), findsOneWidget);
    await tester.tap(find.text('导入').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('外部规则包 Golden'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
