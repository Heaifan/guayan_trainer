import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// §14 离线门禁：静态证明 Calendar Domain 没有运行时网络能力，
/// 且保持 Pure Dart（零 Flutter 依赖）。
///
/// 这是一条**结构性**断言：不靠人工检查，靠测试卡住。
void main() {
  const root = 'lib/domain/calendar';

  /// 禁止出现的网络 / IO / Flutter 依赖。
  const forbiddenImports = <String>[
    "dart:io",
    "dart:html",
    "dart:js",
    "package:http/",
    "package:dio/",
    "package:flutter/",
    "package:webview",
    "package:connectivity",
  ];

  /// 禁止出现的运行时不确定性调用。
  const forbiddenCalls = <String>[
    'DateTime.now(',
    'HttpClient(',
    'Socket.connect',
    'Uri.http(',
    'Uri.https(',
  ];

  /// 去掉注释行后再扫描 —— 门禁检查的是**代码**，不是散文。
  /// （文档注释里出现「禁止读取 DateTime.now()」这类字面量属于正常表述。）
  String stripComments(String src) => src
      .split('\n')
      .where((l) {
        final t = l.trimLeft();
        return !t.startsWith('//') && !t.startsWith('*') && !t.startsWith('/*');
      })
      .join('\n');

  late final List<File> dartFiles;

  setUpAll(() {
    final dir = Directory(root);
    expect(dir.existsSync(), isTrue, reason: '$root 不存在');
    dartFiles =
        dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
  });

  test('calendar domain 至少包含预期文件（防止扫空目录导致假绿）', () {
    expect(dartFiles.length, greaterThanOrEqualTo(10));
    expect(
      dartFiles.any((f) => f.path.endsWith('calendar_engine.dart')),
      isTrue,
    );
  });

  test('无网络 / Flutter 依赖', () {
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      for (final bad in forbiddenImports) {
        final hit = src
            .split('\n')
            .where((l) => l.trimLeft().startsWith('import ') && l.contains(bad))
            .toList();
        expect(hit, isEmpty, reason: '${f.path} 出现禁止依赖 $bad：$hit');
      }
    }
  });

  test('无 DateTime.now / 网络调用（核心层不读系统时间）', () {
    for (final f in dartFiles) {
      final code = stripComments(f.readAsStringSync());
      for (final bad in forbiddenCalls) {
        expect(code.contains(bad), isFalse, reason: '${f.path} 代码中出现禁止调用 $bad');
      }
    }
  });

  test('门禁自身有效：能识别出注入的网络调用', () {
    const injected =
        "import 'package:http/http.dart' as http;\n"
        'final t = DateTime.now();';
    expect(stripComments(injected).contains('DateTime.now('), isTrue);
    expect(
      injected
          .split('\n')
          .where((l) => l.trimLeft().startsWith('import '))
          .any((l) => l.contains('package:http/')),
      isTrue,
    );
  });
}
