import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class RulePackageFileAdapter {
  const RulePackageFileAdapter({this.pickJsonOverride, this.saveJsonOverride});

  final Future<String?> Function()? pickJsonOverride;
  final Future<bool> Function(String text, String fileName)? saveJsonOverride;

  Future<String?> pickJson() async {
    if (pickJsonOverride != null) return pickJsonOverride!();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    return bytes == null ? null : String.fromCharCodes(bytes);
  }

  Future<bool> saveJson(String text, {String fileName = 'guayan_rulepack.json'}) async {
    if (saveJsonOverride != null) return saveJsonOverride!(text, fileName);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: '导出规则包',
      fileName: fileName,
      bytes: Uint8List.fromList(text.codeUnits),
    );
    return path != null;
  }
}
