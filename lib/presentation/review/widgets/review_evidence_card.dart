import 'package:flutter/material.dart';

import '../../../domain/rules/evidence/derived_evidence.dart';
import '../../../domain/rules/editor/rule_tag_catalog.dart';
import '../review_page_state.dart';

class ReviewEvidenceCard extends StatelessWidget {
  const ReviewEvidenceCard({super.key, required this.state, this.onOpen});

  final ReviewPageState state;
  final ValueChanged<DerivedEvidence>? onOpen;

  @override
  Widget build(BuildContext context) {
    final unique = <String, DerivedEvidence>{};
    for (final evidence in state.derivedEvidence) {
      final target = evidence.targetRefs.map((ref) => '${ref.kind}/${ref.key}').join('|');
      unique['${evidence.targetKind.name}:$target:${evidence.value}'] = evidence;
    }
    return Card(
      key: const Key('review_evidence_card'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('取象', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            if (unique.isEmpty)
              const Text('暂无规则取象', style: TextStyle(color: Colors.grey))
            else
              for (final evidence in unique.values)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(RuleTagCatalog.display(evidence.value)),
                  subtitle: Text(
                    '${evidence.targetKind.name == 'relation' ? '关系' : '对象'} · '
                    '${evidence.targetRefs.map((ref) => '${ref.kind}/${ref.key}').join(' → ')} · '
                    '${_supportCount(evidence)} 条依据',
                  ),
                  onTap: onOpen == null ? null : () => onOpen!(evidence),
                ),
          ],
        ),
      ),
    );
  }

  int _supportCount(DerivedEvidence evidence) => evidence.supports.length;
}
